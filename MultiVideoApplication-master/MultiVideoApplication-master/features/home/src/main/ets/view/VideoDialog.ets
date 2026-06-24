/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { resourceManager } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointConstants, CommonConstants } from 'base';
import { BreakpointType, Logger } from 'base';
import { HomeConstants } from '../constants/HomeConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
function MenuItemFunction(img: Resource, text: ResourceStr) {
  Row() {
    Image(img)
      .width($r('app.float.dialog_icon_size'))
      .height($r('app.float.dialog_icon_size'))
      .margin({ right: $r('app.float.dialog_icon_margin') })
    Text(text)
      .layoutWeight(1)
      .fontSize($r('app.float.dialog_text_font'))
      .fontWeight(FontWeight.Normal)
  }
  .height($r('app.float.dialog_menu_row_height'))
}

@Builder
export function RightClickMenu(currentWidthBreakpoint: string) {
  Column() {
    MenuItemFunction($r('app.media.ic_public_view_list'), HomeConstants.VIDEO_DIALOG_OPTIONS[0])
    MenuItemFunction($r('app.media.ic_public_highlights'), HomeConstants.VIDEO_DIALOG_OPTIONS[1])
    MenuItemFunction($r('app.media.ic_public_favor'), HomeConstants.VIDEO_DIALOG_OPTIONS[2])
  }
  .borderRadius($r('app.float.dialog_text_radius'))
  .backgroundColor(Color.White)
  .width(currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.dialog_text_col_width_lg') :
    $r('app.float.dialog_text_col_width'))
  .padding({
    left: $r('app.float.dialog_text_col_padding'),
    right: $r('app.float.dialog_text_col_padding')
  })
}

@CustomDialog
export struct VideoDialog {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  private xComponentController: XComponentController = new XComponentController();
  private surfaceId: string = '';
  private avPlayer?: media.AVPlayer;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private url?: resourceManager.RawFileDescriptor;
  private playState: boolean = true;
  private controller?: CustomDialogController;
  private onError: (err: BusinessError) => void = (err: BusinessError) => {
    Logger.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
    this.avPlayer!.reset().catch((error: BusinessError) => {
      hilog.error(0x00, 'VideoDialog', `reset failed, code = ${error.code}, message = ${error.message}`);
    });
  }
  private onStateChange: (state: media.AVPlayerState) => void = async (state: media.AVPlayerState) => {
    if (this.avPlayer === undefined) {
      Logger.error(`AvPlayer is undefined`);
      return;
    }
    switch (state) {
      case CommonConstants.AV_PLAYER_IDLE_STATE:
        try {
          this.url = await this.context.resourceManager.getRawFd(CommonConstants.PRODUCT_VIDEO_NAME);
          this.avPlayer.fdSrc = this.url;
          Logger.info('AVPlayer state idle called.');
        } catch (error) {
          let err = error as BusinessError;
          hilog.error(0x00, 'VideoDialog', `getRawFd failed, code = ${err.code}, message = ${err.message}`);
        }

        break;
      case CommonConstants.AV_PLAYER_INITIALIZED_STATE:
        // This status is reported after the AVPlayer sets the playback source.
        Logger.info('AVPlayer initialized called.');
        this.avPlayer.surfaceId = this.surfaceId;
        this.avPlayer.prepare().catch((error: BusinessError) => {
          hilog.error(0x00, 'VideoDialog', `prepare failed, code = ${error.code}, message = ${error.message}`);
        }).then(() => {
          Logger.info('AVPlayer prepare succeeded.');
        }, (err: BusinessError) => {
          Logger.error(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          this.avPlayer!.reset().catch((error: BusinessError) => {
            hilog.error(0x00, 'VideoDialog', `reset failed, code = ${error.code}, message = ${error.message}`);
          });
        });
        break;
      case CommonConstants.AV_PLAYER_PREPARED_STATE:
        // Report the state machine after the prepare interface is successfully invoked.
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
        Logger.info('AVPlayer state prepared called.');
        this.avPlayer.play().catch((error: BusinessError) => {
          hilog.error(0x00, 'VideoDialog', `play failed, code = ${error.code}, message = ${error.message}`);
        });
        break;
      case CommonConstants.AV_PLAYER_PLAYING_STATE:
        // Trigger the state machine to report after the play interface is successfully invoked.
        Logger.info('AVPlayer state playing called.');
        this.playState = true;
        break;
      case CommonConstants.AV_PLAYER_PAUSED_STATE:
        // Trigger the state machine to report after the pause function is successfully invoked.
        Logger.info('AVPlayer state paused called.');
        this.playState = false;
        break;
      case CommonConstants.AV_PLAYER_COMPLETED_STATE:
        // Trigger the state machine to report after the playback ends.
        Logger.info('AVPlayer state completed called.');
        this.avPlayer.stop().catch((error: BusinessError) => {
          hilog.error(0x00, 'VideoDialog', `stop failed, code = ${error.code}, message = ${error.message}`);
        });
        break;
      case CommonConstants.AV_PLAYER_STOPPED_STATE:
        // Trigger the state machine to report after the stop interface is successfully invoked.
        Logger.info('AVPlayer state stopped called.');
        break;
      case CommonConstants.AV_PLAYER_RELEASE_STATE:
        Logger.info('AVPlayer state released called.');
        break;
      case CommonConstants.AV_PLAYER_ERROR_STATE:
        Logger.error('AVPlayer state error called.');
        break;
      default:
        Logger.info('AVPlayer state unknown called.');
        break;
    }
  }

  aboutToAppear() {
    this.createAvPlayer();
  }

  aboutToDisappear() {
    try {
      this.avPlayer!.off('error');
      this.avPlayer!.off('stateChange');
    } catch (exception) {
      Logger.error('Failed to unregister callback. Code: ' + JSON.stringify(exception));
    }
    this.avPlayer!.release().catch((error: BusinessError) => {
      hilog.error(0x00, 'VideoDialog', `release failed, code = ${error.code}, message = ${error.message}`);
    });
  }

  build() {
    Column() {
      Column() {
        XComponent({
          type: XComponentType.SURFACE,
          controller: this.xComponentController
        })
          .borderRadius($r('app.float.x_component_radius'))
          .onLoad(() => {
            this.surfaceId = this.xComponentController.getXComponentSurfaceId();
          })
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
      }
      .margin({ bottom: $r('app.float.dialog_col_margin') })
      .height(new BreakpointType($r('app.float.dialog_col_height_sm'), $r('app.float.dialog_col_height_md'),
        $r('app.float.dialog_col_height_lg')).getValue(this.currentWidthBreakpoint))
      .width(new BreakpointType($r('app.float.dialog_col_width_sm'), $r('app.float.dialog_col_width_md'),
        $r('app.float.dialog_col_width_lg')).getValue(this.currentWidthBreakpoint))
      .aspectRatio(HomeConstants.VIDEO_DIALOG_ASPECT_RATIO)
      .onClick(() => {
        if (this.avPlayer!.state === CommonConstants.AV_PLAYER_STOPPED_STATE) {
          this.avPlayer!.prepare().catch((error: BusinessError) => {
            hilog.error(0x00, 'VideoDialog', `prepare failed, code = ${error.code}, message = ${error.message}`);
          });
          return;
        }
        if (!this.playState) {
          this.avPlayer!.play().catch((error: BusinessError) => {
            hilog.error(0x00, 'VideoDialog', `play failed, code = ${error.code}, message = ${error.message}`);
          });
        } else {
          this.avPlayer!.pause().catch((error: BusinessError) => {
            hilog.error(0x00, 'VideoDialog', `pause failed, code = ${error.code}, message = ${error.message}`);
          });
        }
      })

      RightClickMenu(this.currentWidthBreakpoint)
    }
    .alignItems(HorizontalAlign.Start)
  }

  async createAvPlayer(): Promise<void> {
    try {
      this.avPlayer = await media.createAVPlayer();
      // Entering the idle state.
      this.url = await this.context.resourceManager.getRawFd(CommonConstants.PRODUCT_VIDEO_NAME);
      this.avPlayer.fdSrc = this.url;
      this.setAVPlayerCallback();
      // Initialize the playback status.
      this.playState = false;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x00, 'VideoDialog', `createAVPlayer failed, code = ${err.code}, message = ${err.message}`);
    }

  }

  // Registering the avplayer callback function.
  setAVPlayerCallback(): void {
    this.avPlayer!.on('error', this.onError);
    // Callback function for state machine changes.
    this.avPlayer!.on('stateChange', this.onStateChange);
  }
}
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

import { display } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AvPlayerUtil, BreakpointConstants, CommonConstants, VideoNavPathStack, WindowUtil } from 'base';
import { DetailConstants } from '../constants/DetailConstants';
import { CastButton } from './CastButton';

@Component
export struct VideoPlayer {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'lg';
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: string = 'lg';
  @StorageLink('currentTime') currentTime: string = CommonConstants.INITIAL_TIME;
  @StorageLink('totalTime') totalTime: string = CommonConstants.INITIAL_TIME;
  @StorageLink('isHalfFolded') isHalfFolded: boolean = false;
  @StorageLink('creaseRegion') creaseRegion: number[] = [];
  @StorageLink('progress') progress: number = 0;
  @StorageLink('avplayerState') avplayerState: string = '';
  @StorageLink('isFullScreen') isFullScreen: boolean = false;
  @Link videoHeight: number;
  @Link isShowingSideBar: boolean;
  @Link foldStatus: display.FoldStatus;
  @Consume('pageInfo') pageInfo: VideoNavPathStack;
  private windowUtil?: WindowUtil = WindowUtil.getInstance();
  private avPlayerUtil?: AvPlayerUtil;
  private xComponentController: XComponentController = new XComponentController();
  private onFoldStatusChange: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    this.foldStatus = data;
    if (canIUse('SystemCapability.Window.SessionManager')) {
      if (data === display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
        let orientation: display.Orientation = display.getDefaultDisplaySync().orientation;
        if (orientation === display.Orientation.LANDSCAPE || orientation === display.Orientation.LANDSCAPE_INVERTED) {
          this.isHalfFolded = true;
          // Full-screen playback.
          if (!this.isFullScreen) {
            this.isFullScreen = true;
          }
        }
      } else {
        this.isHalfFolded = false;
      }
    }
  };

  aboutToAppear(): void {
    this.avPlayerUtil = AvPlayerUtil.getInstance(this.getUIContext());
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        display.on('foldStatusChange', this.onFoldStatusChange);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x00, 'VideoPlayer', `onFoldStatusChange failed, code = ${err.code}, message = ${err.message}`);
      }
    }
  }

  aboutToDisappear(): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        display.off('foldStatusChange');
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x00, 'VideoPlayer', `onFoldStatusChange failed, code = ${err.code}, message = ${err.message}`);
      }
    }
  }

  build() {
    // [Start stack_aligncontent]
    // [Start stack_isfullscreen]
    Stack({ alignContent: this.isFullScreen ? Alignment.Center : Alignment.Bottom }) {
      // [Start click_interaction]
      Flex({
        // [StartExclude stack_isfullscreen]
        // [StartExclude stack_aligncontent]
        // [StartExclude click_interaction]
        direction: FlexDirection.Column,
        justifyContent: this.isHalfFolded ? FlexAlign.Start : FlexAlign.Center,
        alignItems: ItemAlign.Start
        // [EndExclude stack_isfullscreen]
        // [EndExclude stack_aligncontent]
        // [EndExclude click_interaction]
      }) {
        Column() {
          // [StartExclude stack_isfullscreen]
          // [StartExclude stack_aligncontent]
          // [StartExclude click_interaction]
          XComponent({
            id: 'home',
            type: XComponentType.SURFACE,
            controller: this.xComponentController
          })
            .onLoad(() => {
              this.avPlayerUtil?.createAvPlayer(this.xComponentController.getXComponentSurfaceId());
              AppStorage.setOrCreate('detailSurfaceId', this.xComponentController.getXComponentSurfaceId());
            })
            .width(this.isFullScreen ? '100%' : this.videoHeight + '%')
            .aspectRatio(1.78)
          // [EndExclude stack_aligncontent]
          // [EndExclude stack_isfullscreen]
        }
        .justifyContent(FlexAlign.Center)
        .height(this.isHalfFolded ? (this.creaseRegion.length > 0 ? this.creaseRegion[0] : 'auto') : (this.isFullScreen ? '100%' : 'auto'))
        .width('100%')

        // [StartExclude stack_isfullscreen]
        // [EndExclude click_interaction]
      }
      .width('100%')
      .onClick(() => {
        // [StartExclude click_interaction]
        if (this.isShowingSideBar) {
          this.isShowingSideBar = false;
        } else {
          this.avPlayerUtil?.playerStateControl();
        }
        // [EndExclude click_interaction]
      })
      // [End click_interaction]
      .priorityGesture(
        TapGesture({ count: 2 })
          .onAction((event: GestureEvent) => {
            if (event && deviceInfo.deviceType === '2in1') {
              this.isFullScreen = true;
              this.windowUtil!.maximize();
            }
          })
      )

      // [EndExclude stack_isfullscreen]
      if (this.isFullScreen && !this.isShowingSideBar) {
        Column() {
          // [StartExclude stack_isfullscreen]
          // [StartExclude stack_aligncontent]
          Row() {
            TimeText({ time: this.currentTime })
              .margin({
                left: '36vp',
                right: '2vp'
              })

            Slider({
              min: 0,
              max: 100,
              step: 1,
              value: this.progress
            })
              .onChange((value: number, mode: SliderChangeMode) => {
                this.avPlayerUtil?.sliderChange(value, mode);
              })
              .layoutWeight(1)
              .selectedColor('#ED6F21')

            TimeText({ time: this.totalTime })
              .margin({
                left: '2vp',
                right: '36vp'
              })
          }
          .width('100%')
          .height('40vp')
          .alignItems(VerticalAlign.Center)

          Row() {
            Row() {
              Image(this.avplayerState === 'playing' ? $r('app.media.ic_public_pause') : $r('app.media.ic_public_play'))
                .height('24vp')
                .width('24vp')
                .margin({ left: '24vp' })
                .onClick(() => {
                  this.avPlayerUtil?.playerStateControl();
                })
              this.ImgIcon($r('app.media.ic_public_play_next'))
              this.ImgIcon($r('app.media.ic_public_view_list_white'))
            }
            .margin({
              top: this.currentWidthBreakpoint === 'sm' ? '0' : '14vp',
              bottom: this.currentWidthBreakpoint === 'sm' ? '15vp' : '24vp'
            })

            Blank()

            Row() {
              this.TextButton('选集', ()=>{
                this.isShowingSideBar = !this.isShowingSideBar;
              })
              this.TextButton('超清')
              this.TextButton('倍速')
              CastButton()
                .margin({ left: '8vp' })
            }
            .margin({
              top: this.currentWidthBreakpoint === 'sm' ? '4vp' : '16vp',
              bottom: this.currentWidthBreakpoint === 'sm' ? '19vp' : '28vp',
              right: '16vp'
            })
          }
          .height('60vp')
          .width('100%')

          // [EndExclude stack_aligncontent]
          // [EndExclude stack_isfullscreen]
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.End)
        .priorityGesture(
          TapGesture({ count: 2 })
            .onAction((event: GestureEvent) => {
              if (event && deviceInfo.deviceType === '2in1') {
                this.windowUtil!.maximize();
                this.windowUtil!.recover();
              }
            })
        )
      }

      // [StartExclude stack_isfullscreen]
      // [StartExclude stack_aligncontent]
      // CastButton for fullscreen mode with sidebar open
      if (this.isFullScreen && this.isShowingSideBar) {
        Row() {
          Blank()
          CastButton()
        }
        .width('100%')
        .margin({
          top: this.isHalfFolded && this.creaseRegion.length > 0 ?
            this.creaseRegion[0] + 8 : 56
        })
        .zIndex(10)
      }
      if (!this.isFullScreen) {
        Row() {
          TimeText({ time: this.currentTime })
            .margin({
              left: '24vp',
              right: '2vp'
            })

          Slider({
            min: 0,
            max: 100,
            step: 1,
            value: this.progress
          })
            .onChange((value: number, mode: SliderChangeMode) => {
              this.avPlayerUtil?.sliderChange(value, mode);
            })
            .layoutWeight(1)
            .selectedColor('#ED6F21')

          TimeText({ time: this.totalTime })
            .margin({
              left: '2vp',
              right: '8vp'
            })

          CastButton()
            .margin({ right: '8vp' })

          Image($r('app.media.ic_public_enlarge'))
            .height('24vp')
            .width('24vp')
            .margin({ right: '24vp' })
            .fillColor(Color.White)
            .onClick(() => {
              this.isFullScreen = true;
            })

          Image($r('app.media.ic_public_fullscreen'))
            .height('24vp')
            .width('24vp')
            .margin({ right: '24vp' })
            .fillColor(Color.White)
            .visibility(deviceInfo.deviceType === '2in1' ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              this.isFullScreen = true;
              this.windowUtil!.maximize();
            })
        }
        .width('100%')
        .height('40vp')
        .alignItems(VerticalAlign.Center)
      }

      // [EndExclude stack_aligncontent]
      // [EndExclude stack_isfullscreen]
      Image($r('app.media.ic_public_back'))
        .height('24vp')
        .width('24vp')
        .position({
          x: this.currentWidthBreakpoint === 'lg' ? '24vp' : '32vp',
          y: $r('app.float.back_position_y')
        })
        .fillColor(Color.White)
        .onClick(() => {
          if (this.isHalfFolded) {
            this.isHalfFolded = false;
          }
          if (this.isFullScreen) {
            this.isFullScreen = false;
          } else {
            this.pageInfo.setPageName('home');
            this.pageInfo.pop();
          }
        })
    }
    .height('auto')
    .layoutWeight(this.isFullScreen ? 1 : 0)
    .width('100%')
    .backgroundColor(Color.Black)
    .focusable(false)

    // [End stack_isfullscreen]
    // [End stack_aligncontent]
  }

  @Builder
  TextButton(content: ResourceStr = '', callback?: Function) {
    Text(content)
      .fontSize($r('app.float.button_text_font'))
      .fontWeight(FontWeight.Normal)
      .fontColor(Color.White)
      .margin({ right: $r('app.float.button_text_margin') })
      .onClick(() => {
        callback && callback()
      })
  }

  @Builder
  ImgIcon(img: ResourceStr = '') {
    Image(img)
      .height($r('app.float.icon_size'))
      .width($r('app.float.icon_size'))
      .margin({ left: $r('app.float.icon_margin') })
  }
}


@Component
struct TimeText {
  @Link time: string;

  build() {
    Text(this.time)
      .fontSize($r('app.float.time_font'))
      .fontColor(Color.White)
      .lineHeight($r('app.float.time_text_line'))
      .width($r('app.float.time_text_width'))
  }
}

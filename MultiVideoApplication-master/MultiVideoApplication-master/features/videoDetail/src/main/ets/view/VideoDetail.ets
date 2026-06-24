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

/*
* 最佳实践: 一多交互事件开发实践，一多断点开发实践
*/

import { KeyCode } from '@kit.InputKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { display, window } from '@kit.ArkUI';
import {
  AvPlayerUtil,
  DeviceScreen,
  Logger,
  WindowUtil,
  BreakpointConstants,
  CommonConstants,
  DisplayUtil,
  VideoNavPathStack
} from 'base';
import { SelfComment } from './SelfComment';
import { AllComments } from './AllComments';
import { VideoDetailView } from './VideoDetailView';
import { DetailConstants } from '../constants/DetailConstants';

@Component
export struct VideoDetail {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'lg';
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: string = 'lg';
  @StorageLink('windowWidth') windowWidth: number = 0;
  @StorageLink('isHalfFolded') @Watch('onHalfFoldedChange') isHalfFolded: boolean = false;
  @StorageLink('avplayerState') avplayerState: string = '';
  @StorageLink('isFullScreen') @Watch('onFullScreenChange') isFullScreen: boolean = false;
  @Consume('pageInfo') pageInfo: VideoNavPathStack;
  @State commentImgHeight: string = DetailConstants.INITIAL_COMMENT_IMAGE_HEIGHT;
  @State commentImgWidth: string = DetailConstants.INITIAL_COMMENT_IMAGE_WIDTH;
  @State relatedVideoHeight: number = DetailConstants.INITIAL_RELATED_VIDEO_HEIGHT;
  @State videoHeight: number = DetailConstants.INITIAL_VIDEO_HEIGHT;
  private avPlayerUtil?: AvPlayerUtil = AvPlayerUtil.getInstance(this.getUIContext());
  public screenHeight: number = 0;
  public isFoldable: boolean = display.isFoldable();
  private windowUtil?: WindowUtil = WindowUtil.getInstance();
  private mainWindow?: window.Window;
  // [Start on_window_size_change]
  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    // [StartExclude on_window_size_change]
    if (this.pageInfo.getPageName() !== 'videoDetail') {
      return;
    }
    // [EndExclude on_window_size_change]
    if (((this.currentWidthBreakpoint === 'md' && this.currentHeightBreakpoint !== 'sm') ||
      this.currentWidthBreakpoint === 'lg') && !this.isHalfFolded) {
      this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    }
    // [StartExclude on_window_size_change]
    else if (this.currentWidthBreakpoint === 'md' && this.currentHeightBreakpoint === 'sm') {
      if (this.isFullScreen) {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
      } else {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.PORTRAIT);
      }
    } else if (this.currentWidthBreakpoint === 'sm' && this.currentHeightBreakpoint === 'lg') {
      if (this.isFullScreen) {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
      } else {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.PORTRAIT);
      }
    }
    // [EndExclude on_window_size_change]
  };

  private onHalfFoldedChange(): void {
    if (this.isHalfFolded) {
      this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
    } else {
      if (this.currentWidthBreakpoint === 'md' && this.currentHeightBreakpoint === 'md') {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
      }
    }
  }

  // [Start on_full_screen_change]
  private onFullScreenChange(): void {
    // Large folding screen (X series) in unfolded state and tablet state, supporting rotation && large folding screen (X series) in hover state requires landscape display and does not support rotation.
    if (((this.currentWidthBreakpoint === 'md' && this.currentHeightBreakpoint !== 'sm') ||
      this.currentWidthBreakpoint === 'lg') && !this.isHalfFolded) {
      this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    }
    // Phone and large folding screen (X series) in portrait mode.
    else if (this.currentWidthBreakpoint === 'sm' && this.currentHeightBreakpoint === 'lg') {
      // In full-screen mode, the layout is displayed in landscape mode. Otherwise, the layout is displayed in portrait mode.
      if (this.isFullScreen) {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
      } else {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.PORTRAIT);
      }
    }
    // When the mobile phone and large folding screen (X series) are folded in landscape mode and the playback is not in full screen mode, the vertical display layout is displayed.
    else if (this.currentWidthBreakpoint === 'md' && this.currentHeightBreakpoint === 'sm' && !this.isFullScreen) {
      this.windowUtil?.setMainWindowOrientation(window.Orientation.PORTRAIT);
    }
    // The navigation bar is not hidden on a 2in1 device.
    if (deviceInfo.deviceType !== '2in1') {
      // The navigation bar is hidden in full-screen playback. Otherwise, the navigation bar is displayed.
      if (this.isFullScreen) {
        this.windowUtil!.disableWindowSystemBar();
      } else {
        this.windowUtil!.enableWindowSystemBar();
      }
    }
  }
  // [End on_full_screen_change]

  aboutToAppear() {
    // [StartExclude on_window_size_change]
    DisplayUtil.getFoldCreaseRegion(this.getUIContext());
    this.screenHeight = DeviceScreen.getDeviceHeight();
    // [EndExclude on_window_size_change]
    this.mainWindow = this.windowUtil!.getMainWindow();
    this.mainWindow?.on('windowSizeChange', this.onWindowSizeChange);
    if (this.currentWidthBreakpoint !== 'sm') {
      this.windowUtil!.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    }
  }
  // [End on_window_size_change]

  async aboutToDisappear() {
    this.isFullScreen = false;
    this.avPlayerUtil?.offTimeUpdate();
    this.avPlayerUtil?.release();

    if (this.currentWidthBreakpoint === 'lg') {
      this.windowUtil!.setMainWindowOrientation(window.Orientation.LANDSCAPE);
    } else {
      this.windowUtil!.setMainWindowOrientation(window.Orientation.PORTRAIT);
    }
  }

  build() {
    NavDestination() {
      GridRow({
        columns: {
          sm: BreakpointConstants.GRID_ROW_COLUMNS[2],
          md: BreakpointConstants.GRID_ROW_COLUMNS[0],
          lg: BreakpointConstants.GRID_ROW_COLUMNS[0]
        }
      }) {
        GridCol({
          span: {
            sm: BreakpointConstants.GRID_COLUMN_SPANS[5],
            md: BreakpointConstants.GRID_COLUMN_SPANS[0],
            lg: BreakpointConstants.GRID_COLUMN_SPANS[0]
          }
        }) {
          // [Start side_bar_container]
          SideBarContainer() {
            Column() {
              // Sidebar area.
              Scroll() {
                AllComments({ commentImgHeight: $commentImgHeight, commentImgWidth: $commentImgWidth })
                  .visibility(this.currentWidthBreakpoint === 'lg' ? Visibility.Visible : Visibility.None)
              }
              .align(Alignment.Top)
              .scrollBar(BarState.Off)
              .layoutWeight(1)
              .width('100%')
              .padding({ bottom: '12vp' })
              if(this.currentWidthBreakpoint === 'lg'){
                SelfComment()
              }
            }
            .justifyContent(FlexAlign.Start)
            .height('100%')
            .width('100%')
            .backgroundColor(Color.White)
            .onAreaChange((newValue: Area) => {
              if (newValue.width !== 0) {
                // Handling when the width of the sidebar changes.
                let height: number = 150 + (Number(newValue.width) - 320) /
                  (this.getUIContext().px2vp(this.windowWidth) * 0.4 - 320) * (182 - 150);
                let width: number = 219 + (Number(newValue.width) - 320) /
                  (this.getUIContext().px2vp(this.windowWidth) * 0.4 - 320) * (266 - 219);
                this.commentImgHeight = JSON.stringify(height);
                this.commentImgWidth = JSON.stringify(width);
              }
            })

            Column() {
              // Content area.
              VideoDetailView({
                screenHeight: this.screenHeight,
                relatedVideoHeight: this.relatedVideoHeight,
                videoHeight: this.videoHeight
              })
                .layoutWeight(1)
              if(!(this.currentWidthBreakpoint === 'lg' || this.isFullScreen)){
                SelfComment()
              }
            }
            .height('100%')
            .width('100%')
          }
          .showSideBar(this.currentWidthBreakpoint === 'lg' && !this.isFullScreen ? true : false)
          .showControlButton(false)
          .autoHide(false)
          .sideBarPosition(SideBarPosition.End)
          .sideBarWidth($r('app.float.side_bar_min_width'))
          .minSideBarWidth($r('app.float.side_bar_min_width'))
          .maxSideBarWidth(this.getUIContext().px2vp(this.windowWidth * 0.4))
          // [End side_bar_container]
        }
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .onBreakpointChange((breakPoints) => {
        if (breakPoints !== 'lg' &&
          this.videoHeight < DetailConstants.INITIAL_VIDEO_HEIGHT) {
          this.relatedVideoHeight = 0;
        } else if (breakPoints === 'lg') {
          this.relatedVideoHeight = DetailConstants.INITIAL_RELATED_VIDEO_HEIGHT;
        } else {
          Logger.info(`No specific function`);
        }
      })
    }
    .hideTitleBar(true)
    .onShown(() => {
      if (this.avplayerState !== CommonConstants.AV_PLAYER_PLAYING_STATE) {
        this.avPlayerUtil!.playerStateControl();
      }
      if (canIUse('SystemCapability.Window.SessionManager')) {
        if (this.currentWidthBreakpoint === 'md' && this.isFoldable) {
          this.isHalfFolded = false;
        }
      }
    })
    // [Start key_event_action]
    .onKeyEvent((event?: KeyEvent) => {
      //If the key type is pressed, the subsequent code will not be executed, and the specific key logic will be executed when released.
      if (!event || event.type !== KeyType.Down) {
        return;
      }
      // Space key controls pause/play.
      if (event.keyCode === KeyCode.KEYCODE_SPACE) {
        this.avPlayerUtil!.playerStateControl();
      }
      //press ESC to exit full screen.
      if (event.keyCode === KeyCode.KEYCODE_ESCAPE) {
        this.windowUtil!.recover();
      }
      //Right-click fast forward
      if (event.keyCode === KeyCode.KEYCODE_DPAD_RIGHT) {
        this.avPlayerUtil!.fastForward();
      }
      //Left click to go back quickly
      if (event.keyCode === KeyCode.KEYCODE_DPAD_LEFT) {
        this.avPlayerUtil!.rewind();
      }
    })
    // [End key_event_action]
  }
}
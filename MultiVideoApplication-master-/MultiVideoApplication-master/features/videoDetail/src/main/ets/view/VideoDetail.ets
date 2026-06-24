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
* 最佳实践 一多交互事件开发实践，一多断点开发实践*/

import { KeyCode } from '@kit.InputKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { display, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  AvPlayerUtil,
  DeviceScreen,
  Logger,
  WindowUtil,
  BreakpointConstants,
  CommonConstants,
  DisplayUtil,
  VideoNavPathStack,
  WatchHistoryUtil,
  WatchHistoryViewModel,
  CastConstants
} from 'base';
import { SelfComment } from './SelfComment';
import { AllComments } from './AllComments';
import { VideoDetailView } from './VideoDetailView';
import { DetailConstants } from '../constants/DetailConstants';

interface VideoDetailParams {
  currentTime: number;
  totalDuration: number;
  isPlaying: boolean;
  isFullScreen: boolean;
  videoSource: string;
}

@Component
export struct VideoDetail {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'lg';
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: string = 'lg';
  @StorageLink('windowWidth') windowWidth: number = 0;
  @StorageLink('isHalfFolded') @Watch('onHalfFoldedChange') isHalfFolded: boolean = false;
  @StorageLink('avplayerState') avplayerState: string = '';
  @StorageLink('isFullScreen') @Watch('onFullScreenChange') isFullScreen: boolean = false;
  @StorageLink('currentTime') currentTimeStr: string = CommonConstants.INITIAL_TIME;
  @StorageLink('totalTime') totalTimeStr: string = CommonConstants.INITIAL_TIME;
  @StorageLink('progress') progress: number = 0;
  @Consume('pageInfo') pageInfo: VideoNavPathStack;
  @State commentImgHeight: string = DetailConstants.INITIAL_COMMENT_IMAGE_HEIGHT;
  @State commentImgWidth: string = DetailConstants.INITIAL_COMMENT_IMAGE_WIDTH;
  @State relatedVideoHeight: number = DetailConstants.INITIAL_RELATED_VIDEO_HEIGHT;
  @State videoHeight: number = DetailConstants.INITIAL_VIDEO_HEIGHT;
  @State private seekToTime: number = 0; // Time to seek to when resuming playback
  @State private shouldAutoPlay: boolean = true; // Whether to auto play after seeking
  private avPlayerUtil?: AvPlayerUtil;
  public screenHeight: number = 0;
  public isFoldable: boolean = display.isFoldable();
  private windowUtil?: WindowUtil = WindowUtil.getInstance();
  private mainWindow?: window.Window;
  private watchHistoryUtil?: WatchHistoryUtil;
  private seekPollingCount: number = 0; // Polling counter for seek operation
  // [Start on_window_size_change]
  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    // [StartExclude on_window_size_change]
    if (this.pageInfo.getPageName() !== 'videoDetail') {
      return;
    }
    // [EndExclude on_window_size_change]
    if (((this.currentWidthBreakpoint === 'md' && this.currentHeightBreakpoint !== 'sm') ||
      this.currentWidthBreakpoint === 'lg') && !this.isHalfFolded) {
      if (this.isFullScreen) {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
      } else {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
      }
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
      if (this.isFullScreen) {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
      } else {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
      }
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
    // Initialize AvPlayerUtil in aboutToAppear to ensure UIContext is ready
    this.avPlayerUtil = AvPlayerUtil.getInstance(this.getUIContext());

    // [StartExclude on_window_size_change]
    DisplayUtil.getFoldCreaseRegion(this.getUIContext());
    this.screenHeight = DeviceScreen.getDeviceHeight();
    // [EndExclude on_window_size_change]
    this.mainWindow = this.windowUtil!.getMainWindow();
    this.mainWindow?.on('windowSizeChange', this.onWindowSizeChange);
    if (this.currentWidthBreakpoint !== 'sm') {
      this.windowUtil!.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    }
    // Initialize watch history util
    this.watchHistoryUtil = WatchHistoryUtil.getInstance(this.getUIContext().getHostContext() as common.UIAbilityContext);

    // Set current page name for migration
    AppStorage.setOrCreate('currentPageName', CastConstants.PAGE_NAME_VIDEO_DETAIL);
    Logger.info('VideoDetail page appeared, set currentPageName to videoDetail');

    // Check if there's watch history to resume
    this.checkResumePlayback();

    // Register fold status change listener for dynamic crease region update
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        display.on('foldStatusChange', (data: display.FoldStatus) => {
          Logger.info(`Fold status changed to: ${data}`);
          // Update crease region when fold status changes
          DisplayUtil.getFoldCreaseRegion(this.getUIContext());
          // Update breakpoints when fold status changes
          this.windowUtil?.updateWidthBp();
          this.windowUtil?.updateHeightBp();
        });
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(`Failed to register foldStatusChange listener: code = ${err.code}, message = ${err.message}`);
      }
    }
  }

  /**
   * Check if there's watch history to resume playback.
   */
  private async checkResumePlayback(): Promise<void> {
    // Get navigation params
    const navParams: Object | undefined = this.pageInfo.getParamByName(CommonConstants.PAGE_NAMES[1]);
    if (navParams !== undefined && navParams !== null) {
      // Check if it's a WatchHistoryViewModel or restore params
      const params = navParams as VideoDetailParams;
      
      // Check for currentTime (from watch history or migration)
      if (params.currentTime !== undefined && params.currentTime > 0) {
        this.seekToTime = params.currentTime;
        Logger.info(`Will resume playback at ${this.seekToTime}ms`);

        // Check if this is from migration (has totalDuration)
        if (params.totalDuration !== undefined) {
          this.shouldAutoPlay = params.isPlaying !== undefined ? params.isPlaying : true;
          Logger.info(`Migration restore - autoPlay: ${this.shouldAutoPlay}`);
          
          // Restore full screen state
          if (params.isFullScreen !== undefined) {
            AppStorage.setOrCreate('isFullScreen', params.isFullScreen);
          }
        }

        // Set up listener to seek when video is prepared
        this.setupSeekListener();
      }
    }
  }

  /**
   * Set up listener to seek to saved position when video is prepared.
   */
  private setupSeekListener(): void {
    this.seekPollingCount = 0;
    
    const checkAndSeek = () => {
      this.seekPollingCount++;
      
      if (this.seekPollingCount > CastConstants.SEEK_MAX_POLLING_COUNT) {
        Logger.warn('Seek polling timeout, giving up');
        this.seekToTime = 0;
        return;
      }

      const state = AppStorage.get<string>('avplayerState');
      const totalDuration = AppStorage.get<number>('totalDuration') || 0;

      if ((state === CommonConstants.AV_PLAYER_PLAYING_STATE || 
           state === CommonConstants.AV_PLAYER_PAUSED_STATE) && 
          this.seekToTime > 0 && totalDuration > 0) {
        
        Logger.info(`Video ready, seeking to ${this.seekToTime}ms (polling count: ${this.seekPollingCount})`);
        
        // Use AvPlayerUtil's seekToTime method for migration restore
        if (this.avPlayerUtil) {
          this.avPlayerUtil.seekToTime(this.seekToTime);
          
          // Update progress display
          const seekProgress = (this.seekToTime / totalDuration) * 100;
          AppStorage.setOrCreate<number>(CommonConstants.AV_PLAYER_PROGRESS, seekProgress);
          
          // Resume playback if needed
          if (this.shouldAutoPlay && state === CommonConstants.AV_PLAYER_PAUSED_STATE) {
            setTimeout(() => {
              this.avPlayerUtil?.play();
            }, 200);
          }
          
          Logger.info(`Seek completed to progress ${seekProgress}%`);
          this.seekToTime = 0; // Reset after seeking
        }
      } else {
        // Continue polling
        setTimeout(checkAndSeek, CastConstants.SEEK_POLLING_INTERVAL);
      }
    };

    // Start polling after a delay to ensure video is initializing
    setTimeout(checkAndSeek, CastConstants.SEEK_POLLING_INTERVAL);
  }
  // [End on_window_size_change]

  async aboutToDisappear() {
    // Clear current page name
    AppStorage.setOrCreate('currentPageName', '');
    Logger.info('VideoDetail page disappeared, cleared currentPageName');

    // Save watch history before leaving
    await this.saveWatchHistory();

    this.isFullScreen = false;
    this.avPlayerUtil?.offTimeUpdate();
    this.avPlayerUtil?.release();

    if (this.currentWidthBreakpoint === 'lg') {
      this.windowUtil!.setMainWindowOrientation(window.Orientation.LANDSCAPE);
    } else {
      this.windowUtil!.setMainWindowOrientation(window.Orientation.PORTRAIT);
    }
  }

  /**
   * Save watch history.
   */
  private async saveWatchHistory(): Promise<void> {
    if (!this.watchHistoryUtil) {
      Logger.error('Watch history util not initialized');
      return;
    }

    try {
      // Get current playback time and total duration from AppStorage
      const currentTime = AppStorage.get<number>(CommonConstants.AV_PLAYER_UPDATE_TIME) || 0;
      const totalTime = AppStorage.get<number>('totalDuration') || 0;

      if (totalTime <= 0) {
        Logger.info('Total time is 0, skip saving watch history');
        return;
      }

      // Calculate progress
      const progress = WatchHistoryViewModel.calculateProgress(currentTime, totalTime);

      // Create watch history record
      const history = new WatchHistoryViewModel(
        'product_video', // Video ID
        '产品视频', // Video title
        '', // Cover (will use default)
        currentTime,
        totalTime,
        progress,
        Date.now()
      );

      // Save to storage
      const success = await this.watchHistoryUtil.saveWatchHistory(history);
      if (success) {
        Logger.info(`Watch history saved: progress ${progress}%`);
      }
    } catch (error) {
      Logger.error(`Failed to save watch history: ${JSON.stringify(error)}`);
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

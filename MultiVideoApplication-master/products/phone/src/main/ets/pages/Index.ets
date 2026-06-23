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

import { common } from '@kit.AbilityKit';
import { Home, LastWatchDialog } from 'home';
import {
  CommonConstants,
  VideoNavPathStack,
  WindowUtil,
  WatchHistoryUtil,
  WatchHistoryViewModel,
  WatchHistoryConstants,
  CastConstants,
  Logger
} from 'base';
import { VideoDetail } from 'videoDetail/src/main/ets/view/VideoDetail';
import { SplashPage } from './SplashPage';

class RestoreParams {
  currentTime: number = 0;
  totalDuration: number = 0;
  progress: number = 0;
  title: string = '';
  videoSource: string = '';
}

@Entry
@Component
struct Index {
  @Provide('pageInfo') pageInfo: VideoNavPathStack = new VideoNavPathStack();
  @State private showSplash: boolean = true;
  @State private showDialog: boolean = false;
  @State private watchHistory: WatchHistoryViewModel | null = null;
  @StorageLink(CastConstants.RESTORE_PAGE_NAME_KEY) @Watch('onRestorePageNameChange') restorePageName: string = '';
  private watchHistoryUtil?: WatchHistoryUtil;

  aboutToAppear(): void {
    // Initialize watch history util
    this.watchHistoryUtil = WatchHistoryUtil.getInstance(getContext(this) as common.UIAbilityContext);
    this.watchHistoryUtil.initPreferences().then(() => {
      Logger.info('Watch history util initialized');
    }).catch((error: Error) => {
      Logger.error(`Failed to initialize watch history util: ${error.message}`);
    });

    // Check for migration restore data
    this.checkMigrationRestore();
  }

  /**
   * Watch for restore page name changes (triggered by onNewWant after migration).
   */
  private onRestorePageNameChange(): void {
    Logger.info(`Restore page name changed to: ${this.restorePageName}`);
    if (this.restorePageName) {
      // Trigger migration restore check when new restore data arrives
      this.checkMigrationRestore();
    }
  }

  aboutToDisappear(): void {
    let windowUtil: WindowUtil | undefined = WindowUtil.getInstance();
    windowUtil!.offWindowSizeChange();
  }

  /**
   * Check for migration restore data and navigate if present.
   */
  private checkMigrationRestore(): void {
    const restorePageName = AppStorage.get<string>(CastConstants.RESTORE_PAGE_NAME_KEY);
    const restoreUpdateTime = AppStorage.get<number>(CastConstants.RESTORE_UPDATE_TIME_KEY);

    Logger.info(`checkMigrationRestore - pageName: ${restorePageName}, updateTime: ${restoreUpdateTime}`);

    if (restorePageName && restoreUpdateTime !== undefined && restoreUpdateTime > 0) {
      Logger.info(`Migration restore detected - navigating to ${restorePageName}`);

      // Skip splash animation for migration restore
      this.showSplash = false;

      // Clear restore data to prevent repeated navigation
      AppStorage.setOrCreate(CastConstants.RESTORE_PAGE_NAME_KEY, '');
      AppStorage.setOrCreate(CastConstants.RESTORE_UPDATE_TIME_KEY, 0);

      // Delay navigation to ensure UI is ready
      setTimeout(() => {
        this.navigateToVideoDetail(restoreUpdateTime);
      }, CastConstants.NAVIGATION_DELAY);
    }
  }

  /**
   * Navigate to video detail page with restore data.
   */
  private navigateToVideoDetail(restoreUpdateTime: number): void {
    Logger.info(`Navigating to video detail with restore time: ${restoreUpdateTime}ms`);

    // Create restore params
    const restoreParams = new RestoreParams();
    restoreParams.currentTime = restoreUpdateTime;
    restoreParams.totalDuration = AppStorage.get<number>(CastConstants.RESTORE_TOTAL_DURATION_KEY) || 0;
    restoreParams.progress = 0;
    restoreParams.title = '视频播放';
    restoreParams.videoSource = CommonConstants.PRODUCT_VIDEO_NAME;

    // Calculate progress
    if (restoreParams.totalDuration > 0) {
      restoreParams.progress = (restoreUpdateTime / restoreParams.totalDuration) * 100;
    }

    // Navigate to video detail
    this.pageInfo.setPageName(CommonConstants.PAGE_NAMES[1]);
    this.pageInfo.pushPath({ 
      name: CommonConstants.PAGE_NAMES[1], 
      param: restoreParams 
    });

    Logger.info('Navigation to video detail completed');
  }

  /**
   * Check watch history and show dialog if exists.
   */
  private async checkWatchHistory(): Promise<void> {
    if (!this.watchHistoryUtil) {
      Logger.error('Watch history util not initialized');
      return;
    }

    try {
      const hasHistory = await this.watchHistoryUtil.hasValidWatchHistory();
      if (hasHistory) {
        const history = await this.watchHistoryUtil.getWatchHistory();
        if (history) {
          this.watchHistory = history;
          // Delay showing dialog
          setTimeout(() => {
            this.showDialog = true;
            Logger.info('Showing watch history dialog');
          }, WatchHistoryConstants.DIALOG_SHOW_DELAY);
        }
      }
    } catch (error) {
      Logger.error(`Failed to check watch history: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Handle continue watching.
   */
  private handleContinueWatching(): void {
    Logger.info('Continue watching clicked');
    // Navigate to video detail page
    this.pageInfo.setPageName(CommonConstants.PAGE_NAMES[1]);
    this.pageInfo.pushPath({ name: CommonConstants.PAGE_NAMES[1], param: this.watchHistory });
  }

  /**
   * Handle close dialog.
   */
  private handleCloseDialog(): void {
    Logger.info('Close dialog clicked');
    this.showDialog = false;
  }

  @Builder
  PageMap(name: string) {
    if (name === CommonConstants.PAGE_NAMES[1]) {
      VideoDetail()
    }
  }

  build() {
    Stack() {
      // Main navigation - always present but hidden during splash
      Navigation(this.pageInfo) {
        Home()
      }
      .mode(NavigationMode.Stack)
      .navDestination(this.PageMap)
      .hideToolBar(true)
      .hideTitleBar(true)
      .hideBackButton(true)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .visibility(this.showSplash ? Visibility.None : Visibility.Visible)

      // Splash screen - overlay on top
      if (this.showSplash) {
        SplashPage({
          onAnimationEnd: () => {
            console.info('Splash animation ended, switching to main page');
            this.showSplash = false;
            // Check watch history after splash ends
            this.checkWatchHistory();
          }
        })
        .width('100%')
        .height('100%')
      }

      // Watch history dialog
      LastWatchDialog({
        watchHistory: this.watchHistory,
        isVisible: $showDialog,
        onClose: () => {
          this.handleCloseDialog();
        },
        onContinueWatching: () => {
          this.handleContinueWatching();
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}

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
* 最佳实践 平板开发实践 一多断点开发实践*/

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { display, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowUtil, CastConstants, CommonConstants, Logger } from 'base';

// [Start multi_entryAbility]
export default class EntryAbility extends UIAbility {
  // [Start EntryAbility]
  private windowObj?: window.Window;
  private windowUtil?: WindowUtil = WindowUtil.getInstance();
  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    this.windowUtil!.updateHeightBp();
    this.windowUtil!.updateWidthBp();
    // [StartExclude EntryAbility]
    AppStorage.setOrCreate('windowWidth', windowSize.width);
    // [EndExclude EntryAbility]
  };

  // [StartExclude multi_entryAbility]
  // [StartExclude EntryAbility]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    // Handle migration restore when ability is created for the first time on target device
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      Logger.info('onCreate called for migration continuation');

      if (want.parameters) {
        // Safe type conversion for want.parameters
        const pageNameObj = want.parameters[CastConstants.PARAM_PAGE_NAME];
        const updateTimeObj = want.parameters[CastConstants.PARAM_UPDATE_TIME];
        const totalDurationObj = want.parameters[CastConstants.PARAM_TOTAL_DURATION];
        const isPlayingObj = want.parameters[CastConstants.PARAM_IS_PLAYING];
        const isFullScreenObj = want.parameters[CastConstants.PARAM_IS_FULL_SCREEN];
        const videoSourceObj = want.parameters[CastConstants.PARAM_VIDEO_SOURCE];

        const pageName = pageNameObj ? String(pageNameObj) : '';
        const updateTime = updateTimeObj !== undefined ? Number(updateTimeObj) : 0;
        const totalDuration = totalDurationObj !== undefined ? Number(totalDurationObj) : 0;
        const isPlaying = isPlayingObj !== undefined ? Boolean(isPlayingObj) : false;
        const isFullScreen = isFullScreenObj !== undefined ? Boolean(isFullScreenObj) : false;
        const videoSource = videoSourceObj ? String(videoSourceObj) : '';

        if (pageName && updateTime !== undefined) {
          Logger.info(`onCreate migration data - pageName: ${pageName}, updateTime: ${updateTime}, totalDuration: ${totalDuration}, isPlaying: ${isPlaying}, isFullScreen: ${isFullScreen}, videoSource: ${videoSource}`);

          // Store restore data in AppStorage for Index page to read
          AppStorage.setOrCreate(CastConstants.RESTORE_PAGE_NAME_KEY, pageName);
          AppStorage.setOrCreate(CastConstants.RESTORE_UPDATE_TIME_KEY, updateTime);
          AppStorage.setOrCreate(CastConstants.RESTORE_TOTAL_DURATION_KEY, totalDuration);
          AppStorage.setOrCreate(CastConstants.RESTORE_IS_PLAYING_KEY, isPlaying);
          AppStorage.setOrCreate(CastConstants.RESTORE_IS_FULL_SCREEN_KEY, isFullScreen);
          AppStorage.setOrCreate(CastConstants.RESTORE_VIDEO_SOURCE_KEY, videoSource);

          Logger.info('Migration restore data stored in AppStorage from onCreate');
        }
      }
    }
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  /**
   * Migration lifecycle callback - called when ability is about to migrate to another device.
   * Returns the data to be transferred to the target device.
   */
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    Logger.info('onContinue called for migration');

    // Get current playback state from AppStorage
    const updateTime = AppStorage.get<number>(CommonConstants.AV_PLAYER_UPDATE_TIME) || 0;
    const totalDuration = AppStorage.get<number>('totalDuration') || 0;
    const avplayerState = AppStorage.get<string>('avplayerState') || '';
    const isFullScreen = AppStorage.get<boolean>('isFullScreen') || false;
    const pageName = AppStorage.get<string>('currentPageName') || '';

    Logger.info(`onContinue data - updateTime: ${updateTime}, totalDuration: ${totalDuration}, isPlaying: ${avplayerState === 'playing'}, isFullScreen: ${isFullScreen}, pageName: ${pageName}`);

    // Write migration data to wantParam
    wantParam[CastConstants.PARAM_PAGE_NAME] = pageName;
    wantParam[CastConstants.PARAM_UPDATE_TIME] = updateTime;
    wantParam[CastConstants.PARAM_TOTAL_DURATION] = totalDuration;
    wantParam[CastConstants.PARAM_IS_PLAYING] = avplayerState === CommonConstants.AV_PLAYER_PLAYING_STATE;
    wantParam[CastConstants.PARAM_IS_FULL_SCREEN] = isFullScreen;
    wantParam[CastConstants.PARAM_VIDEO_SOURCE] = CommonConstants.PRODUCT_VIDEO_NAME;

    Logger.info('onContinue data written to wantParam');
    return AbilityConstant.OnContinueResult.AGREE;
  }

  /**
   * Called when ability receives a new Want, including after migration.
   */
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info('onNewWant called');

    // Check if this is a migration restore
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      Logger.info('onNewWant called for migration continuation');

      if (want.parameters) {
        // Safe type conversion for want.parameters
        const pageNameObj = want.parameters[CastConstants.PARAM_PAGE_NAME];
        const updateTimeObj = want.parameters[CastConstants.PARAM_UPDATE_TIME];
        const totalDurationObj = want.parameters[CastConstants.PARAM_TOTAL_DURATION];
        const isPlayingObj = want.parameters[CastConstants.PARAM_IS_PLAYING];
        const isFullScreenObj = want.parameters[CastConstants.PARAM_IS_FULL_SCREEN];
        const videoSourceObj = want.parameters[CastConstants.PARAM_VIDEO_SOURCE];

        const pageName = pageNameObj ? String(pageNameObj) : '';
        const updateTime = updateTimeObj !== undefined ? Number(updateTimeObj) : 0;
        const totalDuration = totalDurationObj !== undefined ? Number(totalDurationObj) : 0;
        const isPlaying = isPlayingObj !== undefined ? Boolean(isPlayingObj) : false;
        const isFullScreen = isFullScreenObj !== undefined ? Boolean(isFullScreenObj) : false;
        const videoSource = videoSourceObj ? String(videoSourceObj) : '';

        if (pageName && updateTime !== undefined) {
          Logger.info(`onNewWant migration data - pageName: ${pageName}, updateTime: ${updateTime}, totalDuration: ${totalDuration}, isPlaying: ${isPlaying}, isFullScreen: ${isFullScreen}, videoSource: ${videoSource}`);

          // Store restore data in AppStorage for Index page to read
          AppStorage.setOrCreate(CastConstants.RESTORE_PAGE_NAME_KEY, pageName);
          AppStorage.setOrCreate(CastConstants.RESTORE_UPDATE_TIME_KEY, updateTime);
          AppStorage.setOrCreate(CastConstants.RESTORE_TOTAL_DURATION_KEY, totalDuration);
          AppStorage.setOrCreate(CastConstants.RESTORE_IS_PLAYING_KEY, isPlaying);
          AppStorage.setOrCreate(CastConstants.RESTORE_IS_FULL_SCREEN_KEY, isFullScreen);
          AppStorage.setOrCreate(CastConstants.RESTORE_VIDEO_SOURCE_KEY, videoSource);

          Logger.info('Migration restore data stored in AppStorage');
        }
      }
    }
  }

  // [EndExclude multi_entryAbility]
  // [EndExclude EntryAbility]
  onWindowStageCreate(windowStage: window.WindowStage) {
    // [StartExclude EntryAbility]
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onWindowStageCreate');
    // [EndExclude EntryAbility]
    // [Start window_util_set]
    let windowUtil: WindowUtil | undefined = WindowUtil.getInstance();
    if (windowUtil !== undefined) {
      windowUtil.setWindowStage(windowStage);
      // Calculate breakpoints before loading content to ensure values are ready
      windowUtil.updateWidthBp();
      windowUtil.updateHeightBp();
      // windowUtil.setMainWindowPortrait();
    }
    // [End window_util_set]
    windowStage.getMainWindow().then((data: window.Window) => {
      this.windowObj = data;
      try {
        AppStorage.setOrCreate('windowWidth', data.getWindowProperties().windowRect.width);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x00, 'EntryAbility', `getWindowProperties failed, code = ${err.code}, message = ${err.message}`);
      }
      this.windowObj.on('windowSizeChange', this.onWindowSizeChange);
    }).catch((error: BusinessError) => {
      hilog.error(0x00, 'EntryAbility', `getWindowProperties failed, code = ${error.code}, message = ${error.message}`);
    })
    // [StartExclude EntryAbility]
    // [StartExclude multi_entryAbility]
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'EntryAbility', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'EntryAbility', 'Succeeded in loading the content. Data: %{public}s',
        JSON.stringify(data) ?? '');
    });
    // [EndExclude EntryAbility]
    // [EndExclude multi_entryAbility]
  }

  // [End EntryAbility]

  // [StartExclude multi_entryAbility]
  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onBackground');
  }

  // [EndExclude multi_entryAbility]
}

// [End multi_entryAbility]

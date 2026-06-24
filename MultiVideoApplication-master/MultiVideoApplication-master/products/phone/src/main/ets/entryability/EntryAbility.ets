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
* 最佳实践: 平板开发实践,一多断点开发实践
*/

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { display, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowUtil } from 'base';

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
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  // [EndExclude multi_entryAbility]
  // [EndExclude EntryAbility]
  onWindowStageCreate(windowStage: window.WindowStage) {
    // [StartExclude EntryAbility]
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onWindowStageCreate');
    // [EndExclude EntryAbility]
    this.windowUtil!.setWindowStage(windowStage);
    // [Start window_util_set]
    let windowUtil: WindowUtil | undefined = WindowUtil.getInstance();
    if (windowUtil !== undefined) {
      windowUtil.setWindowStage(windowStage);
      // windowUtil.setMainWindowPortrait();
    }
    // [End window_util_set]
    windowStage.getMainWindow().then((data: window.Window) => {
      this.windowObj = data;
      this.windowUtil!.updateWidthBp();
      this.windowUtil!.updateHeightBp();
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

  // [Start update_width_bp]
  // products/phone/src/main/ets/entryability/EntryAbility.ets
  private updateWidthBp(): void {
    if (this.windowObj === undefined) {
      return;
    }
    try {
      let mainWindow: window.WindowProperties = this.windowObj.getWindowProperties();
      let windowWidth: number = mainWindow.windowRect.width;
      let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
      let widthBp: string = '';
      let videoGridColumn: string = '1fr 1fr';
      if (windowWidthVp < 320) {
        widthBp = 'xs';
        videoGridColumn = '1fr 1fr';
      } else if (windowWidthVp >= 320 && windowWidthVp < 600) {
        widthBp = 'sm';
        videoGridColumn = '1fr 1fr';
      } else if (windowWidthVp >= 600 && windowWidthVp < 840) {
        widthBp = 'md';
        videoGridColumn = '1fr 1fr 1fr';
      } else if (windowWidthVp >= 840 && windowWidthVp < 1440) {
        widthBp = 'lg';
        videoGridColumn = '1fr 1fr 1fr 1fr';
      } else {
        widthBp = 'xl';
        videoGridColumn = '1fr 1fr 1fr 1fr';
      }
      AppStorage.setOrCreate('currentWidthBreakpoint', widthBp);
      AppStorage.setOrCreate('videoGridColumn', videoGridColumn);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x00, 'EntryAbility', `getDefaultDisplaySync failed, code = ${err.code}, message = ${err.message}`);
    }
  }

  // [End update_width_bp]
  // [EndExclude multi_entryAbility]
}

// [End multi_entryAbility]

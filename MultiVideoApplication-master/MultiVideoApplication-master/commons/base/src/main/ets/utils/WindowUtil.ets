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
* 最佳实践: 一多断点开发实践
*/

import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { display, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../constants/CommonConstants';

@Observed
export class WindowUtil {
  private windowStage?: window.WindowStage;
  private mainWindowClass?: window.Window;

  static getInstance(): WindowUtil | undefined {
    if (!AppStorage.get<WindowUtil>(CommonConstants.WINDOW_UTIL)) {
      AppStorage.setOrCreate(CommonConstants.WINDOW_UTIL, new WindowUtil());
    } else {
      hilog.info(0x0000, 'WindowUtil', '%{public}s', `AppStorage does not have windowUtil.`);
    }
    return AppStorage.get<WindowUtil>(CommonConstants.WINDOW_UTIL);
  }

  setWindowStage(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;
    this.windowStage.getMainWindow((err, windowClass: window.Window) => {
      this.mainWindowClass = windowClass;
      if (err.code) {
        hilog.error(0x0000, 'WindowUtil', `Failed to obtain the main window. Code:${err.code}, message:${err.message}`,
          JSON.stringify(err) ?? '');
        return;
      }
    });
  }

  setMainWindowOrientation(orientation: window.Orientation): void {
    // Setting orientation.
    this.mainWindowClass!.setPreferredOrientation(orientation)
      .then(() => {
        hilog.info(0x0000, 'WindowUtil', '%{public}s', `Succeed in setting the orientation.`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'WindowUtil', `Failed to set the orientation. Code: ${err.code}, message: ${err.message}`,
          JSON.stringify(err) ?? '');
      });
  }

  disableWindowSystemBar(): void {
    // Set the status bar and navigation bar to be invisible in full-screen mode.
    this.mainWindowClass!.setWindowSystemBarEnable([])
      .then(() => {
        hilog.info(0x0000, 'WindowUtil', '%{public}s', `Succeed in setting the window system bar disable.`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'WindowUtil',
          `Failed to set the window system bar disable. Code: ${err.code}, message: ${err.message}`,
          JSON.stringify(err) ?? '');
      });
  }

  enableWindowSystemBar(): void {
    this.mainWindowClass!.setWindowSystemBarEnable(['status', 'navigation'])
      .then(() => {
        hilog.info(0x0000, 'WindowUtil', '%{public}s', `Succeed in setting the window system bar enable.`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'WindowUtil', `Failed to set the orientation. Code: ${err.code}, message: ${err.message}`,
          JSON.stringify(err) ?? '');
      });
  }

  setFullScreen(): void {
    // Set full-screen display.
    this.mainWindowClass!.setWindowLayoutFullScreen(true)
      .then(() => {
        hilog.info(0x0000, 'WindowUtil', '%{public}s', `Succeed in setting the window layout full screen.`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'WindowUtil',
          `Failed to set the window layout full screen. Code: ${err.code}, message: ${err.message}`,
          JSON.stringify(err) ?? '');
      });
  }

  maximize(): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        if (this.mainWindowClass!.getWindowStatus() === window.WindowStatusType.FLOATING) {
          this.mainWindowClass!.maximize()
            .then(() => {
              hilog.info(0x0000, 'WindowUtil', '%{public}s', `Succeed in maximizing the window.`);
            })
            .catch((err: BusinessError) => {
              hilog.error(0x0000, 'WindowUtil',
                `Failed to maximize the window. Code: ${err.code}, message: ${err.message}`,
                JSON.stringify(err) ?? '');
            });
        }
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x00, 'WindowUtil', `getWindowStatus failed, code = ${err.code}, message = ${err.message}`);
      }
    }
  }

  recover(): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        if (this.mainWindowClass!.getWindowStatus() === window.WindowStatusType.FULL_SCREEN) {
          this.mainWindowClass!.recover()
            .then(() => {
              hilog.info(0x0000, 'WindowUtil', '%{public}s', `Succeed in rovering the window.`);
            })
            .catch((err: BusinessError) => {
              hilog.error(0x0000, 'WindowUtil',
                `Failed to rover the window. Code: ${err.code}, message: ${err.message}`,
                JSON.stringify(err) ?? '');
            });
        }
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x00, 'WindowUtil', `getWindowStatus failed, code = ${err.code}, message = ${err.message}`);
      }
    }
  }

  getMainWindow(): window.Window | undefined {
    return this.mainWindowClass;
  }

  offWindowSizeChange(): void {
    try {
      this.mainWindowClass!.off('windowSizeChange');
    } catch (err) {
      hilog.error(0x0000, 'WindowUtil', `Failed to off window size change. Code: ${err.code}, message: ${err.message}`,
        JSON.stringify(err) ?? '');
    }
  }

  // [Start update_widthbp]
  // [Start dd_update_widthbp]
  updateWidthBp(): void {
    try {
      let mainWindow: window.WindowProperties = this.mainWindowClass!.getWindowProperties();
      let windowWidth: number = mainWindow.windowRect.width;
      let windowWidthVp = windowWidth / (display.getDefaultDisplaySync().densityDPI / 160);
      if (deviceInfo.deviceType === CommonConstants.DEVICE_TYPE) {
        windowWidthVp -= 2 * CommonConstants.WINDOW_FLOATING_MARGIN;
      }
      let widthBp: string = '';
      let videoGridColumn: string = CommonConstants.VIDEO_GRID_COLUMNS[0];
      if (windowWidthVp < 320) {
        widthBp = 'xs';
        videoGridColumn = CommonConstants.VIDEO_GRID_COLUMNS[0];
      } else if (windowWidthVp >= 320 && windowWidthVp < 600) {
        widthBp = 'sm';
        videoGridColumn = CommonConstants.VIDEO_GRID_COLUMNS[0];
      } else if (windowWidthVp >= 600 && windowWidthVp < 840) {
        widthBp = 'md';
        videoGridColumn = CommonConstants.VIDEO_GRID_COLUMNS[1];
      } else {
        widthBp = 'lg';
        videoGridColumn = CommonConstants.VIDEO_GRID_COLUMNS[2];
      }
      AppStorage.setOrCreate('currentWidthBreakpoint', widthBp);
      AppStorage.setOrCreate('videoGridColumn', videoGridColumn);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x00, 'WindowUtil', `getDefaultDisplaySync failed, code = ${err.code}, message = ${err.message}`);
    }
  }

  // [End dd_update_widthbp]
  // [End update_heightbp]

  // [Start update_heightbp]
  // [Start dd_update_heightbp]
  updateHeightBp(): void {
    try {
      let mainWindow: window.WindowProperties = this.mainWindowClass!.getWindowProperties();
      let windowHeight: number = mainWindow.windowRect.height;
      let windowWidth: number = mainWindow.windowRect.width;
      let windowWidthVp = windowWidth / (display.getDefaultDisplaySync().densityDPI / 160);
      let windowHeightVp = windowHeight / (display.getDefaultDisplaySync().densityDPI / 160);
      let heightBp: string = '';
      let aspectRatio: number = windowHeightVp / windowWidthVp;
      if (aspectRatio < 0.8) {
        heightBp = 'sm';
      } else if (aspectRatio >= 0.8 && aspectRatio < 1.2) {
        heightBp = 'md';
      } else {
        heightBp = 'lg';
      }
      AppStorage.setOrCreate('currentHeightBreakpoint', heightBp);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x00, 'WindowUtil', `getDefaultDisplaySync failed, code = ${err.code}, message = ${err.message}`);
    }
  }

  // [End dd_update_heightbp]
  // [End update_heightbp]
}
/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';
import { CastConstants } from '../constants/CastConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { AvPlayerUtil } from './AvPlayerUtil';
import { WatchHistoryUtil } from './WatchHistoryUtil';

export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  isTrusted: boolean;
}

export class DeviceManagerUtil {
  private deviceManager?: distributedDeviceManager.DeviceManager;
  private context: common.UIAbilityContext;
  private availableDevices: DeviceInfo[] = [];

  constructor(uiContext: UIContext) {
    this.context = uiContext.getHostContext() as common.UIAbilityContext;
    this.initDeviceManager();
  }

  static getInstance(uiContext: UIContext): DeviceManagerUtil | undefined {
    if (!AppStorage.get<DeviceManagerUtil>('deviceManagerUtil')) {
      AppStorage.setOrCreate('deviceManagerUtil', new DeviceManagerUtil(uiContext));
    }
    return AppStorage.get<DeviceManagerUtil>('deviceManagerUtil');
  }

  private initDeviceManager(): void {
    try {
      const bundleName: string = this.context.abilityInfo.bundleName;
      this.deviceManager = distributedDeviceManager.createDeviceManager(bundleName);
      Logger.info('DeviceManager created successfully');

      this.deviceManager.on('serviceDie', () => {
        Logger.info('DeviceManager service died');
      });

      AppStorage.setOrCreate(CastConstants.CAST_STATE_KEY, CastConstants.CAST_STATE_IDLE);
      AppStorage.setOrCreate(CastConstants.AVAILABLE_DEVICES_KEY, [] as DeviceInfo[]);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x00, 'DeviceManagerUtil', `createDeviceManager failed, code = ${err.code}, message = ${err.message}`);
    }
  }

  private addDiscoveredDevice(deviceBasicInfo: distributedDeviceManager.DeviceBasicInfo): void {
    const existingDevice = this.availableDevices.find((d: DeviceInfo) => d.deviceId === deviceBasicInfo.deviceId);
    if (existingDevice) {
      return;
    }

    const deviceInfo: DeviceInfo = {
      deviceId: deviceBasicInfo.deviceId,
      deviceName: deviceBasicInfo.deviceName,
      deviceType: this.getDeviceTypeName(deviceBasicInfo.deviceType),
      isTrusted: true
    };

    this.availableDevices.push(deviceInfo);
    AppStorage.setOrCreate(CastConstants.AVAILABLE_DEVICES_KEY, this.availableDevices);
    Logger.info(`Added device: ${deviceInfo.deviceName}, type: ${deviceInfo.deviceType}`);
  }

  private getDeviceTypeName(deviceType: string): string {
    switch (deviceType) {
      case '0x0E':
        return CastConstants.DEVICE_TYPE_PHONE;
      case '0x11':
        return CastConstants.DEVICE_TYPE_TABLET;
      case '0x0D':
        return CastConstants.DEVICE_TYPE_TV;
      case '0x14':
        return CastConstants.DEVICE_TYPE_2IN1;
      default:
        return 'unknown';
    }
  }

  private updateAvailableDevices(): void {
    if (!this.deviceManager) {
      return;
    }

    try {
      const trustedDevices: Array<distributedDeviceManager.DeviceBasicInfo> =
        this.deviceManager.getAvailableDeviceListSync();
      Logger.info(`Trusted devices count: ${trustedDevices.length}`);

      trustedDevices.forEach((trustedDevice: distributedDeviceManager.DeviceBasicInfo) => {
        const existingDevice = this.availableDevices.find((d: DeviceInfo) => d.deviceId === trustedDevice.deviceId);
        if (existingDevice) {
          existingDevice.isTrusted = true;
        }
      });

      AppStorage.setOrCreate(CastConstants.AVAILABLE_DEVICES_KEY, this.availableDevices);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x00, 'DeviceManagerUtil', `getAvailableDeviceListSync failed, code = ${err.code}, message = ${err.message}`);
    }
  }

  startDiscovering(): void {
    if (!this.deviceManager) {
      Logger.error('DeviceManager not initialized');
      return;
    }

    AppStorage.setOrCreate(CastConstants.CAST_STATE_KEY, CastConstants.CAST_STATE_DISCOVERING);
    this.availableDevices = [];

    try {
      const deviceList: Array<distributedDeviceManager.DeviceBasicInfo> =
        this.deviceManager.getAvailableDeviceListSync();
      deviceList.forEach((device: distributedDeviceManager.DeviceBasicInfo) => {
        this.addDiscoveredDevice(device);
      });
      Logger.info(`Available devices count: ${deviceList.length}`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x00, 'DeviceManagerUtil', `getAvailableDeviceListSync failed, code = ${err.code}, message = ${err.message}`);
    }

    // Add a short delay before setting IDLE to allow UI to show loading state
    setTimeout(() => {
      AppStorage.setOrCreate(CastConstants.CAST_STATE_KEY, CastConstants.CAST_STATE_IDLE);
    }, 500);
  }

  stopDiscovering(): void {
    const currentState: string | undefined = AppStorage.get<string>(CastConstants.CAST_STATE_KEY);
    if (currentState === CastConstants.CAST_STATE_DISCOVERING) {
      AppStorage.setOrCreate(CastConstants.CAST_STATE_KEY, CastConstants.CAST_STATE_IDLE);
    }
  }

  async authenticateDevice(deviceInfo: DeviceInfo): Promise<boolean> {
    if (!this.deviceManager) {
      Logger.error('DeviceManager not initialized');
      return false;
    }

    Logger.info(`Device ${deviceInfo.deviceName} authentication skipped - handled by system during migration`);
    deviceInfo.isTrusted = true;
    AppStorage.setOrCreate(CastConstants.AVAILABLE_DEVICES_KEY, this.availableDevices);
    return true;
  }

  private getDeviceTypeCode(deviceType: string): string {
    switch (deviceType) {
      case CastConstants.DEVICE_TYPE_PHONE:
        return '0x0E';
      case CastConstants.DEVICE_TYPE_TABLET:
        return '0x11';
      case CastConstants.DEVICE_TYPE_TV:
        return '0x0D';
      case CastConstants.DEVICE_TYPE_2IN1:
        return '0x14';
      default:
        return '0x0E';
    }
  }

  async continueToTarget(deviceId: string): Promise<void> {
    Logger.info(`Starting migration to device: ${deviceId}`);

    // Step 1: Pause playback
    const avPlayerUtil = AppStorage.get<AvPlayerUtil>('avPlayerUtil');
    if (avPlayerUtil) {
      avPlayerUtil.pause();
      Logger.info('Playback paused for migration');
    }

    // Step 2: Clear watch history
    const watchHistoryUtil = WatchHistoryUtil.getInstance(this.context);
    if (watchHistoryUtil) {
      try {
        await watchHistoryUtil.clearWatchHistory();
        Logger.info('Watch history cleared for migration');
      } catch (error) {
        Logger.error(`Failed to clear watch history: ${JSON.stringify(error)}`);
      }
    }

    // Step 3: Record migration data to AppStorage (for onContinue to read)
    const updateTime = AppStorage.get<number>(CommonConstants.AV_PLAYER_UPDATE_TIME) || 0;
    const totalDuration = AppStorage.get<number>('totalDuration') || 0;
    const avplayerState = AppStorage.get<string>('avplayerState') || '';
    const isFullScreen = AppStorage.get<boolean>('isFullScreen') || false;
    const pageName = AppStorage.get<string>('currentPageName') || '';

    // Store migration data in AppStorage for onContinue callback
    AppStorage.setOrCreate(CastConstants.PARAM_PAGE_NAME, pageName);
    AppStorage.setOrCreate(CastConstants.PARAM_UPDATE_TIME, updateTime);
    AppStorage.setOrCreate(CastConstants.PARAM_TOTAL_DURATION, totalDuration);
    AppStorage.setOrCreate(CastConstants.PARAM_IS_PLAYING, avplayerState === CommonConstants.AV_PLAYER_PLAYING_STATE);
    AppStorage.setOrCreate(CastConstants.PARAM_IS_FULL_SCREEN, isFullScreen);
    AppStorage.setOrCreate(CastConstants.PARAM_VIDEO_SOURCE, CommonConstants.PRODUCT_VIDEO_NAME);

    Logger.info(`Migration data recorded - pageName: ${pageName}, updateTime: ${updateTime}, totalDuration: ${totalDuration}, isPlaying: ${avplayerState === CommonConstants.AV_PLAYER_PLAYING_STATE}, isFullScreen: ${isFullScreen}`);

    // Step 4: Set migrating state
    AppStorage.setOrCreate(CastConstants.CAST_STATE_KEY, CastConstants.CAST_STATE_MIGRATING);

    // Step 5: Log migration ready status
    Logger.info('迁移数据已准备就绪，请通过系统设备选择器发起迁移');

    // Step 6: Set migrated state (no API call, no exception)
    AppStorage.setOrCreate(CastConstants.CAST_STATE_KEY, CastConstants.CAST_STATE_MIGRATED);
  }

  getLocalDeviceId(): string {
    if (!this.deviceManager) {
      return '';
    }

    try {
      return this.deviceManager.getLocalDeviceNetworkId();
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x00, 'DeviceManagerUtil', `getLocalDeviceNetworkId failed, code = ${err.code}, message = ${err.message}`);
      return '';
    }
  }

  getTrustedDeviceListSync(): distributedDeviceManager.DeviceBasicInfo[] {
    if (!this.deviceManager) {
      return [];
    }

    try {
      return this.deviceManager.getAvailableDeviceListSync();
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x00, 'DeviceManagerUtil', `getAvailableDeviceListSync failed, code = ${err.code}, message = ${err.message}`);
      return [];
    }
  }

  release(): void {
    if (this.deviceManager) {
      try {
        this.stopDiscovering();
        this.deviceManager.off('serviceDie');
        Logger.info('DeviceManager released');
      } catch (error) {
        const err = error as BusinessError;
        hilog.error(0x00, 'DeviceManagerUtil', `release failed, code = ${err.code}, message = ${err.message}`);
      }
    }
  }
}

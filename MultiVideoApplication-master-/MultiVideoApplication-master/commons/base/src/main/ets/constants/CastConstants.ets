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

/**
 * Constants for cross-device migration (continuation) feature.
 */
export class CastConstants {
  // ==================== Cast States ====================
  /**
   * Idle state - no migration in progress.
   */
  static readonly CAST_STATE_IDLE: string = 'idle';

  /**
   * Discovering devices state.
   */
  static readonly CAST_STATE_DISCOVERING: string = 'discovering';

  /**
   * Connecting to device state.
   */
  static readonly CAST_STATE_CONNECTING: string = 'connecting';

  /**
   * Migration in progress state.
   */
  static readonly CAST_STATE_MIGRATING: string = 'migrating';

  /**
   * Migration completed state.
   */
  static readonly CAST_STATE_MIGRATED: string = 'migrated';

  // ==================== AppStorage Keys ====================
  /**
   * Key for cast state in AppStorage.
   */
  static readonly CAST_STATE_KEY: string = 'castState';

  /**
   * Key for available devices list in AppStorage.
   */
  static readonly AVAILABLE_DEVICES_KEY: string = 'availableDevices';

  /**
   * Key for restore page name in AppStorage.
   */
  static readonly RESTORE_PAGE_NAME_KEY: string = 'restorePageName';

  /**
   * Key for restore update time (playback progress in milliseconds) in AppStorage.
   */
  static readonly RESTORE_UPDATE_TIME_KEY: string = 'restoreUpdateTime';

  /**
   * Key for restore total duration in AppStorage.
   */
  static readonly RESTORE_TOTAL_DURATION_KEY: string = 'restoreTotalDuration';

  /**
   * Key for restore playing state in AppStorage.
   */
  static readonly RESTORE_IS_PLAYING_KEY: string = 'restoreIsPlaying';

  /**
   * Key for restore full screen state in AppStorage.
   */
  static readonly RESTORE_IS_FULL_SCREEN_KEY: string = 'restoreIsFullScreen';

  /**
   * Key for restore video source in AppStorage.
   */
  static readonly RESTORE_VIDEO_SOURCE_KEY: string = 'restoreVideoSource';

  // ==================== wantParam Data Keys ====================
  /**
   * Key for page name in wantParam.
   */
  static readonly PARAM_PAGE_NAME: string = 'pageName';

  /**
   * Key for update time in wantParam.
   */
  static readonly PARAM_UPDATE_TIME: string = 'updateTime';

  /**
   * Key for total duration in wantParam.
   */
  static readonly PARAM_TOTAL_DURATION: string = 'totalDuration';

  /**
   * Key for is playing in wantParam.
   */
  static readonly PARAM_IS_PLAYING: string = 'isPlaying';

  /**
   * Key for is full screen in wantParam.
   */
  static readonly PARAM_IS_FULL_SCREEN: string = 'isFullScreen';

  /**
   * Key for video source in wantParam.
   */
  static readonly PARAM_VIDEO_SOURCE: string = 'videoSource';

  // ==================== UI Parameters ====================
  /**
   * Dialog width for sm breakpoint (percentage).
   */
  static readonly DIALOG_WIDTH_SM: string = '80%';

  /**
   * Dialog width for md breakpoint (percentage).
   */
  static readonly DIALOG_WIDTH_MD: string = '60%';

  /**
   * Dialog width for lg breakpoint (percentage).
   */
  static readonly DIALOG_WIDTH_LG: string = '40%';

  /**
   * Cast button icon size (vp).
   */
  static readonly CAST_BUTTON_SIZE: number = 24;

  /**
   * Cast button icon size for sm breakpoint (vp).
   */
  static readonly CAST_BUTTON_SIZE_SM: number = 24;

  /**
   * Cast button icon size for md/lg breakpoint (vp).
   */
  static readonly CAST_BUTTON_SIZE_MD: number = 28;

  /**
   * Cast button container size for sm breakpoint (vp).
   */
  static readonly CAST_BUTTON_CONTAINER_SM: number = 40;

  /**
   * Cast button container size for md/lg breakpoint (vp).
   */
  static readonly CAST_BUTTON_CONTAINER_MD: number = 44;

  /**
   * Empty state tip text.
   */
  static readonly EMPTY_DEVICE_TIP: string = '未发现可用设备，请确保设备在同一网络';

  // ==================== Timeout and Retry ====================
  /**
   * Migration timeout in milliseconds.
   */
  static readonly MIGRATION_TIMEOUT: number = 10000;

  /**
   * Maximum retry count.
   */
  static readonly MAX_RETRY_COUNT: number = 2;

  /**
   * Seek polling interval in milliseconds.
   */
  static readonly SEEK_POLLING_INTERVAL: number = 500;

  /**
   * Maximum seek polling count (total 10 seconds).
   */
  static readonly SEEK_MAX_POLLING_COUNT: number = 20;

  // ==================== Device Discovery ====================
  /**
   * Device discovery timeout in milliseconds.
   */
  static readonly DISCOVERY_TIMEOUT: number = 30000;

  // ==================== Device Types ====================
  /**
   * Device type: phone.
   */
  static readonly DEVICE_TYPE_PHONE: string = 'phone';

  /**
   * Device type: tablet.
   */
  static readonly DEVICE_TYPE_TABLET: string = 'tablet';

  /**
   * Device type: TV (smart screen).
   */
  static readonly DEVICE_TYPE_TV: string = 'tv';

  /**
   * Device type: 2in1.
   */
  static readonly DEVICE_TYPE_2IN1: string = '2in1';

  // ==================== Page Names ====================
  /**
   * Page name for video detail.
   */
  static readonly PAGE_NAME_VIDEO_DETAIL: string = 'videoDetail';

  // ==================== Navigation Delay ====================
  /**
   * Delay before navigation after migration (milliseconds).
   */
  static readonly NAVIGATION_DELAY: number = 300;
}

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
 * Constants for like feature.
 */
export class LikeConstants {
  /**
   * Preferences storage name.
   */
  static readonly PREFERENCES_NAME: string = 'VideoLikeStorage';

  /**
   * Like status key prefix.
   */
  static readonly LIKE_STATUS_KEY_PREFIX: string = 'like_status_';

  /**
   * Like count key prefix.
   */
  static readonly LIKE_COUNT_KEY_PREFIX: string = 'like_count_';

  /**
   * All likes key.
   */
  static readonly ALL_LIKES_KEY: string = 'all_likes';

  /**
   * Liked icon color (red).
   */
  static readonly LIKED_COLOR: string = '#FF4757';

  /**
   * Unliked icon color (gray).
   */
  static readonly UNLIKED_COLOR: string = '#999999';

  /**
   * Icon size.
   */
  static readonly ICON_SIZE: number = 24;

  /**
   * Icon size for sm breakpoint.
   */
  static readonly ICON_SIZE_SM: number = 24;

  /**
   * Icon size for md/lg breakpoint.
   */
  static readonly ICON_SIZE_MD: number = 28;

  /**
   * Count font size.
   */
  static readonly COUNT_FONT_SIZE: number = 12;

  /**
   * Count font size for sm breakpoint.
   */
  static readonly COUNT_FONT_SIZE_SM: number = 12;

  /**
   * Count font size for md/lg breakpoint.
   */
  static readonly COUNT_FONT_SIZE_MD: number = 14;

  /**
   * Animation duration in milliseconds.
   */
  static readonly ANIMATION_DURATION: number = 300;

  /**
   * Scale animation peak value.
   */
  static readonly SCALE_PEAK: number = 1.3;

  /**
   * Default like count.
   */
  static readonly DEFAULT_LIKE_COUNT: number = 0;

  /**
   * Format threshold for 10,000.
   */
  static readonly FORMAT_THRESHOLD_WAN: number = 10000;

  /**
   * Format threshold for 100,000,000.
   */
  static readonly FORMAT_THRESHOLD_YI: number = 100000000;

  /**
   * Wan unit text.
   */
  static readonly UNIT_WAN: string = '万';

  /**
   * Yi unit text.
   */
  static readonly UNIT_YI: string = '亿';
}

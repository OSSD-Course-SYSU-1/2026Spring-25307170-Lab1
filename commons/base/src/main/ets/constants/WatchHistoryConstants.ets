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
 * Constants for watch history feature.
 */
export class WatchHistoryConstants {
  /**
   * Storage key for watch history.
   */
  static readonly WATCH_HISTORY_KEY: string = 'watchHistory';

  /**
   * Preferences store name.
   */
  static readonly PREFERENCES_NAME: string = 'watchHistoryStore';

  /**
   * Dialog width.
   */
  static readonly DIALOG_WIDTH: number = 320;

  /**
   * Dialog border radius.
   */
  static readonly DIALOG_BORDER_RADIUS: number = 16;

  /**
   * Dialog padding.
   */
  static readonly DIALOG_PADDING: number = 20;

  /**
   * Cover image width.
   */
  static readonly COVER_WIDTH: number = 120;

  /**
   * Cover image height.
   */
  static readonly COVER_HEIGHT: number = 68;

  /**
   * Cover border radius.
   */
  static readonly COVER_BORDER_RADIUS: number = 8;

  /**
   * Button height.
   */
  static readonly BUTTON_HEIGHT: number = 40;

  /**
   * Button border radius.
   */
  static readonly BUTTON_BORDER_RADIUS: number = 20;

  /**
   * Progress bar height.
   */
  static readonly PROGRESS_BAR_HEIGHT: number = 4;

  /**
   * Progress bar border radius.
   */
  static readonly PROGRESS_BAR_BORDER_RADIUS: number = 2;

  /**
   * Watch progress threshold (95%).
   * If progress >= this value, consider the video as completed.
   */
  static readonly WATCH_PROGRESS_THRESHOLD: number = 95;

  /**
   * Dialog show delay (1 second in milliseconds).
   */
  static readonly DIALOG_SHOW_DELAY: number = 1000;

  /**
   * Primary color (orange theme).
   */
  static readonly PRIMARY_COLOR: string = '#FF6B35';

  /**
   * Secondary color.
   */
  static readonly SECONDARY_COLOR: string = '#F5F5F5';

  /**
   * Text primary color.
   */
  static readonly TEXT_PRIMARY_COLOR: string = '#333333';

  /**
   * Text secondary color.
   */
  static readonly TEXT_SECONDARY_COLOR: string = '#999999';

  /**
   * Divider color.
   */
  static readonly DIVIDER_COLOR: string = '#E5E5E5';

  /**
   * Mask color.
   */
  static readonly MASK_COLOR: string = 'rgba(0, 0, 0, 0.5)';

  /**
   * Title font size.
   */
  static readonly TITLE_FONT_SIZE: number = 16;

  /**
   * Content font size.
   */
  static readonly CONTENT_FONT_SIZE: number = 14;

  /**
   * Small font size.
   */
  static readonly SMALL_FONT_SIZE: number = 12;

  /**
   * Button font size.
   */
  static readonly BUTTON_FONT_SIZE: number = 14;

  /**
   * Default video title.
   */
  static readonly DEFAULT_VIDEO_TITLE: string = '未知视频';

  /**
   * Default video cover.
   */
  static readonly DEFAULT_VIDEO_COVER: string = '';

  /**
   * Default progress.
   */
  static readonly DEFAULT_PROGRESS: number = 0;

  /**
   * Default current time.
   */
  static readonly DEFAULT_CURRENT_TIME: number = 0;

  /**
   * Default total time.
   */
  static readonly DEFAULT_TOTAL_TIME: number = 0;
}

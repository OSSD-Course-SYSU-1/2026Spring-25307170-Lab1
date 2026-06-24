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

import { WatchHistoryConstants } from 'base';
import { WatchHistoryViewModel } from 'base';

/**
 * Dialog component for showing last watch history.
 */
@Component
export struct LastWatchDialog {
  /**
   * Watch history data.
   */
  @Prop watchHistory: WatchHistoryViewModel | null = null;

  /**
   * Callback when close button is clicked.
   */
  onClose?: () => void;

  /**
   * Callback when continue watching button is clicked.
   */
  onContinueWatching?: () => void;

  /**
   * Dialog visibility.
   */
  @Link isVisible: boolean;

  build() {
    if (this.isVisible && this.watchHistory) {
      // Semi-transparent mask
      Column() {
        // Dialog container
        Column() {
          // Title area with close button
          this.TitleArea();

          // Video information area
          this.VideoInfoArea();

          // Button area
          this.ButtonArea();
        }
        .width(WatchHistoryConstants.DIALOG_WIDTH)
        .backgroundColor(Color.White)
        .borderRadius(WatchHistoryConstants.DIALOG_BORDER_RADIUS)
        .padding(WatchHistoryConstants.DIALOG_PADDING)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.15)',
          offsetX: 0,
          offsetY: 4
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WatchHistoryConstants.MASK_COLOR)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        // Close dialog when clicking mask
        this.handleClose();
      })
      .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
    }
  }

  /**
   * Title area with close button.
   */
  @Builder
  TitleArea() {
    Row() {
      Text('继续观看')
        .fontSize(WatchHistoryConstants.TITLE_FONT_SIZE)
        .fontWeight(FontWeight.Medium)
        .fontColor(WatchHistoryConstants.TEXT_PRIMARY_COLOR)

      Blank()

      Image($r('app.media.ic_public_back'))
        .width(20)
        .height(20)
        .fillColor(WatchHistoryConstants.TEXT_SECONDARY_COLOR)
        .onClick(() => {
          this.handleClose();
        })
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  /**
   * Video information area.
   */
  @Builder
  VideoInfoArea() {
    Row() {
      // Cover image
      Image(this.watchHistory?.cover || $r('app.media.ic_video_grid_1'))
        .width(WatchHistoryConstants.COVER_WIDTH)
        .height(WatchHistoryConstants.COVER_HEIGHT)
        .borderRadius(WatchHistoryConstants.COVER_BORDER_RADIUS)
        .objectFit(ImageFit.Cover)

      // Video info
      Column() {
        // Title
        Text(this.watchHistory?.title || WatchHistoryConstants.DEFAULT_VIDEO_TITLE)
          .fontSize(WatchHistoryConstants.CONTENT_FONT_SIZE)
          .fontColor(WatchHistoryConstants.TEXT_PRIMARY_COLOR)
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Blank()

        // Time info
        Text(`${this.watchHistory?.getFormattedCurrentTime()} / ${this.watchHistory?.getFormattedTotalTime()}`)
          .fontSize(WatchHistoryConstants.SMALL_FONT_SIZE)
          .fontColor(WatchHistoryConstants.TEXT_SECONDARY_COLOR)

        // Progress bar
        Stack() {
          // Background
          Row()
            .width('100%')
            .height(WatchHistoryConstants.PROGRESS_BAR_HEIGHT)
            .backgroundColor(WatchHistoryConstants.SECONDARY_COLOR)
            .borderRadius(WatchHistoryConstants.PROGRESS_BAR_BORDER_RADIUS)

          // Progress
          Row()
            .width(`${this.watchHistory?.progress || 0}%`)
            .height(WatchHistoryConstants.PROGRESS_BAR_HEIGHT)
            .backgroundColor(WatchHistoryConstants.PRIMARY_COLOR)
            .borderRadius(WatchHistoryConstants.PROGRESS_BAR_BORDER_RADIUS)
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .width('100%')
    .height(WatchHistoryConstants.COVER_HEIGHT)
    .margin({ bottom: 20 })
  }

  /**
   * Button area.
   */
  @Builder
  ButtonArea() {
    Row() {
      // Close button
      Button('关闭')
        .width('45%')
        .height(WatchHistoryConstants.BUTTON_HEIGHT)
        .fontSize(WatchHistoryConstants.BUTTON_FONT_SIZE)
        .fontColor(WatchHistoryConstants.TEXT_PRIMARY_COLOR)
        .backgroundColor(WatchHistoryConstants.SECONDARY_COLOR)
        .borderRadius(WatchHistoryConstants.BUTTON_BORDER_RADIUS)
        .onClick(() => {
          this.handleClose();
        })

      // Continue watching button
      Button('继续观看')
        .width('45%')
        .height(WatchHistoryConstants.BUTTON_HEIGHT)
        .fontSize(WatchHistoryConstants.BUTTON_FONT_SIZE)
        .fontColor(Color.White)
        .backgroundColor(WatchHistoryConstants.PRIMARY_COLOR)
        .borderRadius(WatchHistoryConstants.BUTTON_BORDER_RADIUS)
        .onClick(() => {
          this.handleContinueWatching();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  /**
   * Handle close button click.
   */
  private handleClose(): void {
    this.isVisible = false;
    if (this.onClose) {
      this.onClose();
    }
  }

  /**
   * Handle continue watching button click.
   */
  private handleContinueWatching(): void {
    this.isVisible = false;
    if (this.onContinueWatching) {
      this.onContinueWatching();
    }
  }
}

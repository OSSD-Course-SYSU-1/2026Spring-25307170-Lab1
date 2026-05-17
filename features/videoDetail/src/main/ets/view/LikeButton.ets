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

import { common } from '@kit.AbilityKit';
import { LikeConstants, LikeViewModel, LikeUtil, Logger } from 'base';

/**
 * Like button component with animation.
 */
@Component
export struct LikeButton {
  @Prop videoId: string = '';
  @Prop initialLikeCount: number = LikeConstants.DEFAULT_LIKE_COUNT;
  @State isLiked: boolean = false;
  @State likeCount: number = LikeConstants.DEFAULT_LIKE_COUNT;
  @State scaleValue: number = 1.0;
  @State isAnimating: boolean = false;
  @State isInitialized: boolean = false;
  private likeUtil: LikeUtil | null = null;

  /**
   * Initialize like state when component appears.
   */
  async aboutToAppear(): Promise<void> {
    // Initialize LikeUtil
    try {
      const context = getContext(this) as common.UIAbilityContext;
      this.likeUtil = LikeUtil.getInstance(context);
      await this.likeUtil.initPreferences();
      
      // Load like state
      if (this.videoId) {
        const viewModel = await this.likeUtil.getLikeViewModel(this.videoId, this.initialLikeCount);
        this.isLiked = viewModel.getIsLiked();
        this.likeCount = viewModel.getLikeCount();
        this.isInitialized = true;
        Logger.info(`LikeButton initialized: ${this.videoId}, isLiked: ${this.isLiked}, count: ${this.likeCount}`);
      } else {
        this.likeCount = this.initialLikeCount;
        this.isInitialized = true;
      }
    } catch (error) {
      Logger.error(`Failed to initialize LikeButton: ${JSON.stringify(error)}`);
      this.likeCount = this.initialLikeCount;
      this.isInitialized = true;
    }
  }

  /**
   * Handle like button click.
   */
  private async handleLikeClick(): Promise<void> {
    if (!this.videoId || !this.likeUtil) {
      Logger.error('VideoId or LikeUtil not set');
      return;
    }

    // Trigger animation
    this.triggerAnimation();

    // Toggle like status
    const newStatus = await this.likeUtil.toggleLike(this.videoId);
    this.isLiked = newStatus;

    // Update like count
    const newCount = await this.likeUtil.updateLikeCount(this.videoId, newStatus);
    this.likeCount = newCount;

    Logger.info(`Like toggled: ${this.videoId}, isLiked: ${newStatus}, count: ${newCount}`);
  }

  /**
   * Trigger scale animation.
   */
  private triggerAnimation(): void {
    if (this.isAnimating) {
      return;
    }
    this.isAnimating = true;
    // Scale up
    animateTo({
      duration: LikeConstants.ANIMATION_DURATION / 2,
      curve: Curve.EaseOut,
      onFinish: () => {
        // Scale down
        animateTo({
          duration: LikeConstants.ANIMATION_DURATION / 2,
          curve: Curve.EaseIn,
          onFinish: () => {
            this.scaleValue = 1.0;
            this.isAnimating = false;
          }
        }, () => {
          this.scaleValue = 1.0;
        });
      }
    }, () => {
      this.scaleValue = LikeConstants.SCALE_PEAK;
    });
  }

  /**
   * Get icon resource based on like status.
   */
  private getIconResource(): Resource {
    return this.isLiked ? $r('app.media.ic_public_favor_filled') : $r('app.media.ic_public_favor');
  }

  /**
   * Get icon color based on like status.
   */
  private getIconColor(): ResourceColor {
    return this.isLiked ? LikeConstants.LIKED_COLOR : LikeConstants.UNLIKED_COLOR;
  }

  /**
   * Get formatted like count.
   */
  private getFormattedCount(): string {
    return LikeViewModel.formatLikeCount(this.likeCount);
  }

  build() {
    Column() {
      Image(this.getIconResource())
        .width(LikeConstants.ICON_SIZE)
        .height(LikeConstants.ICON_SIZE)
        .fillColor(this.getIconColor())
        .scale({ x: this.scaleValue, y: this.scaleValue })
        .onClick(() => {
          this.handleLikeClick();
        })

      Text(this.getFormattedCount())
        .fontSize(LikeConstants.COUNT_FONT_SIZE)
        .fontColor(this.getIconColor())
        .margin({ top: 4 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

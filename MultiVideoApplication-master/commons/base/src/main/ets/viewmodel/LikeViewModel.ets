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

import { LikeConstants } from '../constants/LikeConstants';

/**
 * Like record interface.
 */
export interface LikeRecord {
  videoId: string;
  isLiked: boolean;
  likeTime: number;
}

/**
 * Like view model for managing like state.
 */
export class LikeViewModel {
  private videoId: string = '';
  private isLiked: boolean = false;
  private likeCount: number = LikeConstants.DEFAULT_LIKE_COUNT;
  private likeTime: number = 0;

  /**
   * Constructor.
   */
  constructor(videoId: string = '', isLiked: boolean = false, likeCount: number = LikeConstants.DEFAULT_LIKE_COUNT) {
    this.videoId = videoId;
    this.isLiked = isLiked;
    this.likeCount = likeCount;
    this.likeTime = isLiked ? Date.now() : 0;
  }

  /**
   * Get video ID.
   */
  getVideoId(): string {
    return this.videoId;
  }

  /**
   * Set video ID.
   */
  setVideoId(videoId: string): void {
    this.videoId = videoId;
  }

  /**
   * Get like status.
   */
  getIsLiked(): boolean {
    return this.isLiked;
  }

  /**
   * Set like status.
   */
  setIsLiked(isLiked: boolean): void {
    this.isLiked = isLiked;
    if (isLiked) {
      this.likeTime = Date.now();
    }
  }

  /**
   * Get like count.
   */
  getLikeCount(): number {
    return this.likeCount;
  }

  /**
   * Set like count.
   */
  setLikeCount(count: number): void {
    this.likeCount = count;
  }

  /**
   * Get like time.
   */
  getLikeTime(): number {
    return this.likeTime;
  }

  /**
   * Toggle like status.
   */
  toggleLike(): void {
    this.isLiked = !this.isLiked;
    if (this.isLiked) {
      this.likeTime = Date.now();
      this.likeCount++;
    } else {
      this.likeCount = Math.max(0, this.likeCount - 1);
    }
  }

  /**
   * Convert to like record.
   */
  toLikeRecord(): LikeRecord {
    return {
      videoId: this.videoId,
      isLiked: this.isLiked,
      likeTime: this.likeTime
    };
  }

  /**
   * Create from like record.
   */
  static fromLikeRecord(record: LikeRecord, likeCount: number = LikeConstants.DEFAULT_LIKE_COUNT): LikeViewModel {
    const viewModel = new LikeViewModel(record.videoId, record.isLiked, likeCount);
    viewModel.likeTime = record.likeTime;
    return viewModel;
  }

  /**
   * Convert to JSON string.
   */
  toJson(): string {
    const record: LikeRecord = this.toLikeRecord();
    return JSON.stringify(record);
  }

  /**
   * Create from JSON string.
   */
  static fromJson(jsonStr: string, likeCount: number = LikeConstants.DEFAULT_LIKE_COUNT): LikeViewModel | null {
    try {
      const record: LikeRecord = JSON.parse(jsonStr) as LikeRecord;
      return LikeViewModel.fromLikeRecord(record, likeCount);
    } catch (error) {
      return null;
    }
  }

  /**
   * Format like count for display.
   * Examples: 999 -> "999", 10000 -> "1万", 12345 -> "1.2万", 100000000 -> "1亿"
   */
  static formatLikeCount(count: number): string {
    if (count < LikeConstants.FORMAT_THRESHOLD_WAN) {
      return count.toString();
    } else if (count < LikeConstants.FORMAT_THRESHOLD_YI) {
      const wan = count / LikeConstants.FORMAT_THRESHOLD_WAN;
      const formatted = wan >= 10 ? Math.floor(wan).toString() : wan.toFixed(1);
      return `${formatted}${LikeConstants.UNIT_WAN}`;
    } else {
      const yi = count / LikeConstants.FORMAT_THRESHOLD_YI;
      const formatted = yi >= 10 ? Math.floor(yi).toString() : yi.toFixed(1);
      return `${formatted}${LikeConstants.UNIT_YI}`;
    }
  }
}

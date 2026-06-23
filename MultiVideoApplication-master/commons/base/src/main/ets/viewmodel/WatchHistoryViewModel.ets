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

import { WatchHistoryConstants } from '../constants/WatchHistoryConstants';

/**
 * Interface for watch history record.
 */
export interface IWatchHistory {
  /**
   * Video ID or identifier.
   */
  videoId: string;

  /**
   * Video title.
   */
  title: string;

  /**
   * Video cover image resource.
   */
  cover: string;

  /**
   * Current playback time in milliseconds.
   */
  currentTime: number;

  /**
   * Total video duration in milliseconds.
   */
  totalTime: number;

  /**
   * Watch progress percentage (0-100).
   */
  progress: number;

  /**
   * Timestamp when the video was last watched.
   */
  timestamp: number;
}

/**
 * Watch history data model.
 */
export class WatchHistoryViewModel {
  /**
   * Video ID or identifier.
   */
  videoId: string = '';

  /**
   * Video title.
   */
  title: string = WatchHistoryConstants.DEFAULT_VIDEO_TITLE;

  /**
   * Video cover image resource.
   */
  cover: string = WatchHistoryConstants.DEFAULT_VIDEO_COVER;

  /**
   * Current playback time in milliseconds.
   */
  currentTime: number = WatchHistoryConstants.DEFAULT_CURRENT_TIME;

  /**
   * Total video duration in milliseconds.
   */
  totalTime: number = WatchHistoryConstants.DEFAULT_TOTAL_TIME;

  /**
   * Watch progress percentage (0-100).
   */
  progress: number = WatchHistoryConstants.DEFAULT_PROGRESS;

  /**
   * Timestamp when the video was last watched.
   */
  timestamp: number = Date.now();

  /**
   * Constructor.
   */
  constructor(
    videoId?: string,
    title?: string,
    cover?: string,
    currentTime?: number,
    totalTime?: number,
    progress?: number,
    timestamp?: number
  ) {
    if (videoId !== undefined) this.videoId = videoId;
    if (title !== undefined) this.title = title;
    if (cover !== undefined) this.cover = cover;
    if (currentTime !== undefined) this.currentTime = currentTime;
    if (totalTime !== undefined) this.totalTime = totalTime;
    if (progress !== undefined) this.progress = progress;
    if (timestamp !== undefined) this.timestamp = timestamp;
  }

  /**
   * Convert to JSON string.
   */
  toJson(): string {
    return JSON.stringify({
      videoId: this.videoId,
      title: this.title,
      cover: this.cover,
      currentTime: this.currentTime,
      totalTime: this.totalTime,
      progress: this.progress,
      timestamp: this.timestamp
    });
  }

  /**
   * Create from JSON string.
   */
  static fromJson(jsonStr: string): WatchHistoryViewModel | null {
    try {
      const obj = JSON.parse(jsonStr) as IWatchHistory;
      return new WatchHistoryViewModel(
        obj.videoId,
        obj.title,
        obj.cover,
        obj.currentTime,
        obj.totalTime,
        obj.progress,
        obj.timestamp
      );
    } catch (error) {
      console.error('Failed to parse watch history from JSON:', error);
      return null;
    }
  }

  /**
   * Format time from milliseconds to HH:MM:SS or MM:SS.
   * @param milliseconds Time in milliseconds.
   * @returns Formatted time string.
   */
  static formatTime(milliseconds: number): string {
    if (milliseconds <= 0) {
      return '00:00';
    }

    const totalSeconds = Math.floor(milliseconds / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    if (hours > 0) {
      return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    } else {
      return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }
  }

  /**
   * Calculate progress percentage.
   * @param currentTime Current playback time in milliseconds.
   * @param totalTime Total video duration in milliseconds.
   * @returns Progress percentage (0-100).
   */
  static calculateProgress(currentTime: number, totalTime: number): number {
    if (totalTime <= 0) {
      return 0;
    }
    const progress = (currentTime / totalTime) * 100;
    return Math.min(Math.max(progress, 0), 100);
  }

  /**
   * Format timestamp to readable date string.
   * @param timestamp Timestamp in milliseconds.
   * @returns Formatted date string.
   */
  static formatTimestamp(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) {
      return '刚刚';
    } else if (diffMins < 60) {
      return `${diffMins}分钟前`;
    } else if (diffHours < 24) {
      return `${diffHours}小时前`;
    } else if (diffDays < 7) {
      return `${diffDays}天前`;
    } else {
      return `${date.getMonth() + 1}月${date.getDate()}日`;
    }
  }

  /**
   * Check if the video is considered as completed.
   * @returns True if progress >= threshold.
   */
  isCompleted(): boolean {
    return this.progress >= WatchHistoryConstants.WATCH_PROGRESS_THRESHOLD;
  }

  /**
   * Get formatted current time.
   */
  getFormattedCurrentTime(): string {
    return WatchHistoryViewModel.formatTime(this.currentTime);
  }

  /**
   * Get formatted total time.
   */
  getFormattedTotalTime(): string {
    return WatchHistoryViewModel.formatTime(this.totalTime);
  }

  /**
   * Get formatted timestamp.
   */
  getFormattedTimestamp(): string {
    return WatchHistoryViewModel.formatTimestamp(this.timestamp);
  }
}

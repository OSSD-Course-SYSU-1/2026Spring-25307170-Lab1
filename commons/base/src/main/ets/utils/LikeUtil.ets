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

import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { LikeConstants } from '../constants/LikeConstants';
import { LikeRecord, LikeViewModel } from '../viewmodel/LikeViewModel';
import Logger from './Logger';

/**
 * Utility class for managing like storage using Preferences.
 */
export class LikeUtil {
  private static instance: LikeUtil | null = null;
  private preferencesStore: preferences.Preferences | null = null;
  private context: common.UIAbilityContext;
  private likeStatusCache: Map<string, boolean> = new Map<string, boolean>(); // Memory cache for like status
  private likeCountCache: Map<string, number> = new Map<string, number>(); // Memory cache for like count
  private isInitialized: boolean = false;

  /**
   * Private constructor for singleton pattern.
   */
  private constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * Get singleton instance.
   */
  static getInstance(context: common.UIAbilityContext): LikeUtil {
    if (!LikeUtil.instance) {
      LikeUtil.instance = new LikeUtil(context);
    }
    return LikeUtil.instance;
  }

  /**
   * Initialize Preferences storage.
   */
  async initPreferences(): Promise<void> {
    if (this.isInitialized) {
      Logger.info('LikeUtil already initialized');
      return;
    }

    try {
      this.preferencesStore = await preferences.getPreferences(
        this.context,
        LikeConstants.PREFERENCES_NAME
      );
      this.isInitialized = true;
      Logger.info('LikeUtil initialized successfully');
    } catch (error) {
      Logger.error(`Failed to initialize LikeUtil: ${JSON.stringify(error)}`);
      this.isInitialized = false;
    }
  }

  /**
   * Get like status key for a video.
   */
  private getLikeStatusKey(videoId: string): string {
    return `${LikeConstants.LIKE_STATUS_KEY_PREFIX}${videoId}`;
  }

  /**
   * Get like count key for a video.
   */
  private getLikeCountKey(videoId: string): string {
    return `${LikeConstants.LIKE_COUNT_KEY_PREFIX}${videoId}`;
  }

  /**
   * Save like status for a video.
   * @param videoId Video ID.
   * @param isLiked Like status.
   */
  async saveLikeStatus(videoId: string, isLiked: boolean): Promise<boolean> {
    if (!this.preferencesStore || !this.isInitialized) {
      Logger.error('Preferences store not initialized');
      return false;
    }

    try {
      const key = this.getLikeStatusKey(videoId);
      const record: LikeRecord = {
        videoId: videoId,
        isLiked: isLiked,
        likeTime: isLiked ? Date.now() : 0
      };
      await this.preferencesStore.put(key, JSON.stringify(record));
      await this.preferencesStore.flush();
      // Update memory cache
      this.likeStatusCache.set(videoId, isLiked);
      Logger.info(`Like status saved: ${videoId} = ${isLiked}`);
      return true;
    } catch (error) {
      Logger.error(`Failed to save like status: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * Get like status for a video.
   * @param videoId Video ID.
   * @returns Like status (default false).
   */
  async getLikeStatus(videoId: string): Promise<boolean> {
    // Check memory cache first
    if (this.likeStatusCache.has(videoId)) {
      return this.likeStatusCache.get(videoId) as boolean;
    }

    if (!this.preferencesStore || !this.isInitialized) {
      Logger.error('Preferences store not initialized');
      return false;
    }

    try {
      const key = this.getLikeStatusKey(videoId);
      const jsonStr = await this.preferencesStore.get(key, '') as string;

      if (!jsonStr) {
        // Cache default value
        this.likeStatusCache.set(videoId, false);
        return false;
      }

      const record: LikeRecord = JSON.parse(jsonStr) as LikeRecord;
      // Update memory cache
      this.likeStatusCache.set(videoId, record.isLiked);
      return record.isLiked;
    } catch (error) {
      Logger.error(`Failed to get like status: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * Toggle like status for a video.
   * @param videoId Video ID.
   * @returns New like status.
   */
  async toggleLike(videoId: string): Promise<boolean> {
    const currentStatus = await this.getLikeStatus(videoId);
    const newStatus = !currentStatus;
    await this.saveLikeStatus(videoId, newStatus);
    return newStatus;
  }

  /**
   * Save like count for a video.
   * @param videoId Video ID.
   * @param count Like count.
   */
  async saveLikeCount(videoId: string, count: number): Promise<boolean> {
    if (!this.preferencesStore || !this.isInitialized) {
      Logger.error('Preferences store not initialized');
      return false;
    }

    try {
      const key = this.getLikeCountKey(videoId);
      await this.preferencesStore.put(key, count);
      await this.preferencesStore.flush();
      // Update memory cache
      this.likeCountCache.set(videoId, count);
      Logger.info(`Like count saved: ${videoId} = ${count}`);
      return true;
    } catch (error) {
      Logger.error(`Failed to save like count: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * Get like count for a video.
   * @param videoId Video ID.
   * @param defaultCount Default count if not found.
   * @returns Like count.
   */
  async getLikeCount(videoId: string, defaultCount: number = LikeConstants.DEFAULT_LIKE_COUNT): Promise<number> {
    // Check memory cache first
    if (this.likeCountCache.has(videoId)) {
      return this.likeCountCache.get(videoId) as number;
    }

    if (!this.preferencesStore || !this.isInitialized) {
      Logger.error('Preferences store not initialized');
      return defaultCount;
    }

    try {
      const key = this.getLikeCountKey(videoId);
      const count = await this.preferencesStore.get(key, defaultCount) as number;
      // Update memory cache
      this.likeCountCache.set(videoId, count);
      return count;
    } catch (error) {
      Logger.error(`Failed to get like count: ${JSON.stringify(error)}`);
      return defaultCount;
    }
  }

  /**
   * Update like count (increment or decrement).
   * @param videoId Video ID.
   * @param increment True to increment, false to decrement.
   */
  async updateLikeCount(videoId: string, increment: boolean): Promise<number> {
    const currentCount = await this.getLikeCount(videoId);
    const newCount = increment ? currentCount + 1 : Math.max(0, currentCount - 1);
    await this.saveLikeCount(videoId, newCount);
    return newCount;
  }

  /**
   * Get like view model for a video.
   * @param videoId Video ID.
   * @param defaultCount Default like count.
   */
  async getLikeViewModel(videoId: string, defaultCount: number = LikeConstants.DEFAULT_LIKE_COUNT): Promise<LikeViewModel> {
    const isLiked = await this.getLikeStatus(videoId);
    const likeCount = await this.getLikeCount(videoId, defaultCount);
    return new LikeViewModel(videoId, isLiked, likeCount);
  }

  /**
   * Batch get like status for multiple videos.
   * @param videoIds Array of video IDs.
   * @returns Map of video ID to like status.
   */
  async batchGetLikeStatus(videoIds: string[]): Promise<Map<string, boolean>> {
    const result: Map<string, boolean> = new Map<string, boolean>();
    for (const videoId of videoIds) {
      const isLiked = await this.getLikeStatus(videoId);
      result.set(videoId, isLiked);
    }
    return result;
  }

  /**
   * Clear all like data for a video.
   * @param videoId Video ID.
   */
  async clearLikeData(videoId: string): Promise<boolean> {
    if (!this.preferencesStore || !this.isInitialized) {
      Logger.error('Preferences store not initialized');
      return false;
    }

    try {
      const statusKey = this.getLikeStatusKey(videoId);
      const countKey = this.getLikeCountKey(videoId);
      await this.preferencesStore.delete(statusKey);
      await this.preferencesStore.delete(countKey);
      await this.preferencesStore.flush();
      // Clear memory cache
      this.likeStatusCache.delete(videoId);
      this.likeCountCache.delete(videoId);
      Logger.info(`Like data cleared for video: ${videoId}`);
      return true;
    } catch (error) {
      Logger.error(`Failed to clear like data: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * Clear all memory caches.
   */
  clearCache(): void {
    this.likeStatusCache.clear();
    this.likeCountCache.clear();
    Logger.info('Like memory caches cleared');
  }
}

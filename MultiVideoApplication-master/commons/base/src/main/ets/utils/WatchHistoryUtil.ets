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
import { WatchHistoryConstants } from '../constants/WatchHistoryConstants';
import { WatchHistoryViewModel } from '../viewmodel/WatchHistoryViewModel';
import Logger from './Logger';

/**
 * Utility class for managing watch history storage using Preferences.
 */
export class WatchHistoryUtil {
  private static instance: WatchHistoryUtil | null = null;
  private preferencesStore: preferences.Preferences | null = null;
  private context: common.UIAbilityContext;
  private memoryCache: WatchHistoryViewModel | null = null; // Memory cache for performance
  private isInitialized: boolean = false; // Flag to track initialization

  /**
   * Private constructor for singleton pattern.
   */
  private constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * Get singleton instance.
   */
  static getInstance(context: common.UIAbilityContext): WatchHistoryUtil {
    if (!WatchHistoryUtil.instance) {
      WatchHistoryUtil.instance = new WatchHistoryUtil(context);
    }
    return WatchHistoryUtil.instance;
  }

  /**
   * Initialize Preferences storage.
   */
  async initPreferences(): Promise<void> {
    if (this.isInitialized) {
      Logger.info('WatchHistoryUtil already initialized');
      return;
    }

    try {
      this.preferencesStore = await preferences.getPreferences(
        this.context,
        WatchHistoryConstants.PREFERENCES_NAME
      );
      this.isInitialized = true;
      Logger.info('WatchHistoryUtil initialized successfully');
    } catch (error) {
      Logger.error(`Failed to initialize WatchHistoryUtil: ${JSON.stringify(error)}`);
      this.isInitialized = false;
    }
  }

  /**
   * Save watch history record.
   * @param history Watch history record to save.
   */
  async saveWatchHistory(history: WatchHistoryViewModel): Promise<boolean> {
    if (!this.preferencesStore || !this.isInitialized) {
      Logger.error('Preferences store not initialized');
      return false;
    }

    try {
      const jsonStr = history.toJson();
      await this.preferencesStore.put(WatchHistoryConstants.WATCH_HISTORY_KEY, jsonStr);
      await this.preferencesStore.flush();
      // Update memory cache
      this.memoryCache = history;
      Logger.info(`Watch history saved: ${history.title}, progress: ${history.progress}%`);
      return true;
    } catch (error) {
      Logger.error(`Failed to save watch history: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * Get watch history record.
   * @returns Watch history record or null if not exists.
   */
  async getWatchHistory(): Promise<WatchHistoryViewModel | null> {
    // Return from memory cache if available
    if (this.memoryCache !== null) {
      Logger.info('Returning watch history from memory cache');
      return this.memoryCache;
    }

    if (!this.preferencesStore || !this.isInitialized) {
      Logger.error('Preferences store not initialized');
      return null;
    }

    try {
      const jsonStr = await this.preferencesStore.get(
        WatchHistoryConstants.WATCH_HISTORY_KEY,
        ''
      ) as string;

      if (!jsonStr) {
        Logger.info('No watch history found');
        return null;
      }

      const history = WatchHistoryViewModel.fromJson(jsonStr);
      if (history) {
        // Update memory cache
        this.memoryCache = history;
        Logger.info(`Watch history loaded: ${history.title}, progress: ${history.progress}%`);
      }
      return history;
    } catch (error) {
      Logger.error(`Failed to get watch history: ${JSON.stringify(error)}`);
      return null;
    }
  }

  /**
   * Clear watch history record.
   */
  async clearWatchHistory(): Promise<boolean> {
    if (!this.preferencesStore || !this.isInitialized) {
      Logger.error('Preferences store not initialized');
      return false;
    }

    try {
      await this.preferencesStore.delete(WatchHistoryConstants.WATCH_HISTORY_KEY);
      await this.preferencesStore.flush();
      // Clear memory cache
      this.memoryCache = null;
      Logger.info('Watch history cleared');
      return true;
    } catch (error) {
      Logger.error(`Failed to clear watch history: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * Clear memory cache.
   */
  clearCache(): void {
    this.memoryCache = null;
    Logger.info('Watch history memory cache cleared');
  }

  /**
   * Check if there is a watch history record.
   * @returns True if watch history exists.
   */
  async hasWatchHistory(): Promise<boolean> {
    const history = await this.getWatchHistory();
    return history !== null && !history.isCompleted();
  }

  /**
   * Check if there is a valid watch history (not completed).
   * @returns True if valid watch history exists.
   */
  async hasValidWatchHistory(): Promise<boolean> {
    const history = await this.getWatchHistory();
    if (!history) {
      return false;
    }
    // Don't show dialog if video is completed
    return !history.isCompleted();
  }
}

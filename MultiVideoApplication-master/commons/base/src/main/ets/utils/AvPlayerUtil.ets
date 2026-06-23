/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import Logger from './Logger';
import { CommonConstants } from '../constants/CommonConstants';

export class PlaybackSnapshot {
  videoSource: string = '';
  currentTime: number = 0;
  totalDuration: number = 0;
  isPlaying: boolean = false;
  state: string = '';
}

export class AvPlayerUtil {
  private avPlayer?: media.AVPlayer;
  private context: common.UIAbilityContext;
  private url: resourceManager.RawFileDescriptor | null = null;
  private surfaceId: string = '';
  private sliderBegin: number = 0;
  private isMoving: boolean = false;
  private videoSource: string = CommonConstants.PRODUCT_VIDEO_NAME;
  private onError: (err: BusinessError) => void = (err: BusinessError) => {
    Logger.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
    this.avPlayer?.reset().catch((error: BusinessError) => {
      hilog.error(0x00, 'AvPlayerUtil', `reset failed, code = ${error.code}, message = ${error.message}`);
    });
  };
  private onTimeUpdateFunction: (updateTime: number) => void = (updateTime: number) => {
    AppStorage.setOrCreate<string>(CommonConstants.AV_PLAYER_CURRENT_TIME, this.formatTime(updateTime));
    AppStorage.setOrCreate<number>(CommonConstants.AV_PLAYER_UPDATE_TIME, updateTime);
    AppStorage.setOrCreate<number>(CommonConstants.AV_PLAYER_PROGRESS, updateTime / this.avPlayer!.duration *
    CommonConstants.PROGRESS_HUNDRED);
  };
  private onStateChange: (state: media.AVPlayerState) => void = async (state: media.AVPlayerState) => {
    if (this.avPlayer === undefined) {
      Logger.error(`AvPlayer is undefined`);
      return;
    }
    switch (state) {
      case CommonConstants.AV_PLAYER_IDLE_STATE:
        try {
          this.url = await this.context.resourceManager.getRawFd(this.videoSource);
          this.avPlayer.fdSrc = this.url;
          Logger.info('AVPlayer state idle called.');
        } catch (error) {
          hilog.error(0x00, 'AvPlayerUtil', `getRawFd failed, code = ${error.code}, message = ${error.message}`);
        }
        break;
      case CommonConstants.AV_PLAYER_INITIALIZED_STATE:
        Logger.info('AVPlayer initialized called.');
        this.avPlayer.surfaceId = this.surfaceId;
        this.avPlayer.prepare().catch((error: BusinessError) => {
          hilog.error(0x00, 'AvPlayerUtil', `prepare failed, code = ${error.code}, message = ${error.message}`);
        }).then(() => {
          Logger.info('AVPlayer prepare succeeded.');
        }, (err: BusinessError) => {
          Logger.error(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          this.avPlayer!.reset().catch((error: BusinessError) => {
            hilog.error(0x00, 'AvPlayerUtil', `reset failed, code = ${error.code}, message = ${error.message}`);
          });
        });
        break;
      case CommonConstants.AV_PLAYER_PREPARED_STATE:
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
        Logger.info('AVPlayer state prepared called.');
        this.avPlayer.play().catch((error: BusinessError) => {
          hilog.error(0x00, 'AvPlayerUtil', `play failed, code = ${error.code}, message = ${error.message}`);
        });
        AppStorage.setOrCreate<string>(CommonConstants.AV_PLAYER_TOTAL_TIME, this.formatTime(this.avPlayer.duration));
        // Save total duration in milliseconds for watch history
        AppStorage.setOrCreate<number>('totalDuration', this.avPlayer.duration);
        break;
      case CommonConstants.AV_PLAYER_PLAYING_STATE:
        Logger.info('AVPlayer state playing called.');
        AppStorage.setOrCreate('avplayerState', this.avPlayer.state);
        break;
      case CommonConstants.AV_PLAYER_PAUSED_STATE:
        Logger.info('AVPlayer state paused called.');
        AppStorage.setOrCreate('avplayerState', this.avPlayer.state);
        break;
      case CommonConstants.AV_PLAYER_COMPLETED_STATE:
        Logger.info('AVPlayer state completed called.');
        AppStorage.setOrCreate('avplayerState', this.avPlayer.state);
        this.avPlayer.stop().catch((error: BusinessError) => {
          hilog.error(0x00, 'AvPlayerUtil', `stop failed, code = ${error.code}, message = ${error.message}`);
        });
        break;
      case CommonConstants.AV_PLAYER_STOPPED_STATE:
        Logger.info('AVPlayer state stopped called.');
        break;
      case CommonConstants.AV_PLAYER_RELEASE_STATE:
        Logger.info('AVPlayer state released called.');
        break;
      case CommonConstants.AV_PLAYER_ERROR_STATE:
        Logger.error('AVPlayer state error called.');
        break;
      default:
        Logger.info('AVPlayer state unknown called.');
        break;
    }
  };

  constructor(uiContext: UIContext) {
    this.context = uiContext.getHostContext() as common.UIAbilityContext;
  }

  static getInstance(uiContext: UIContext): AvPlayerUtil | undefined {
    if (!AppStorage.get<AvPlayerUtil>('avPlayerUtil')) {
      AppStorage.setOrCreate('avPlayerUtil', new AvPlayerUtil(uiContext));
    } else {
      Logger.info(`AppStorage does not have avPlayerUtil`);
    }
    return AppStorage.get<AvPlayerUtil>('avPlayerUtil');
  }

  async createAvPlayer(surfaceId: string): Promise<void> {
    if (!this.avPlayer || this.avPlayer.state === CommonConstants.AV_PLAYER_RELEASE_STATE) {
      try {
        this.avPlayer = await media.createAVPlayer();
        this.surfaceId = surfaceId;
        Logger.info('Created AvPlayer successfully.');
        // Entering idle state.
        this.url = await this.context.resourceManager.getRawFd(this.videoSource);
        this.avPlayer.fdSrc = this.url;
        this.setAVPlayerCallback();
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x00, 'testTag', `createAVPlayer failed, code = ${err.code}, message = ${err.message}`);
      }

    } else {
      Logger.info(`AvPlayer has been created`);
    }
  }

  setAVPlayerCallback(): void {
    this.avPlayer?.on('error', this.onError);
    this.onTimeUpdate();
    this.setStateChange();
  }

  /**
   * Set video source file name.
   * @param source Video file name in resources/rawfile directory.
   */
  setVideoSource(source: string): void {
    this.videoSource = source;
    Logger.info(`Video source set to: ${source}`);
  }

  /**
   * Get current playback snapshot for migration.
   * @returns Playback state snapshot.
   */
  getPlaybackSnapshot(): PlaybackSnapshot {
    let snapshot = new PlaybackSnapshot();
    snapshot.videoSource = this.videoSource;
    snapshot.currentTime = this.getCurrentTime();
    snapshot.totalDuration = this.getDuration();
    snapshot.isPlaying = this.avPlayer?.state === CommonConstants.AV_PLAYER_PLAYING_STATE;
    snapshot.state = this.getPlaybackState();
    return snapshot;
  }

  onTimeUpdate(): void {
    this.avPlayer?.on('timeUpdate', this.onTimeUpdateFunction);
  }

  offTimeUpdate(): void {
    try {
      this.avPlayer?.off('timeUpdate');
    } catch (exception) {
      Logger.error('Failed to unregister callback. Code: ' + JSON.stringify(exception));
    }
  }

  setStateChange(): void {
    this.avPlayer?.on('stateChange', this.onStateChange);
  }

  release(): void {
    if (this.avPlayer && this.avPlayer.state !== CommonConstants.AV_PLAYER_RELEASE_STATE) {
      try {
        this.avPlayer.off('error');
        this.avPlayer.off('stateChange');
      } catch (exception) {
        Logger.error('Failed to unregister callback. Code: ' + JSON.stringify(exception));
      }
      this.avPlayer.release().catch((error: BusinessError) => {
        hilog.error(0x00, 'AvPlayerUtil', `release failed, code = ${error.code}, message = ${error.message}`);
      });
    } else {
      Logger.info(`AvPlayer release failed`);
    }
  }

  sliderChange(value: number, mode: SliderChangeMode): void {
    let seekType: media.SeekMode = value > this.sliderBegin ? media.SeekMode.SEEK_PREV_SYNC :
      media.SeekMode.SEEK_NEXT_SYNC;
    switch (mode) {
      case SliderChangeMode.Begin:
        Logger.info(`AvPlayer SliderChangeMode Begin`);
        this.sliderBegin = value;
        this.avPlayer?.pause().catch((error: BusinessError) => {
          hilog.error(0x00, 'AvPlayerUtil', `pause failed, code = ${error.code}, message = ${error.message}`);
        });
        break;
      case SliderChangeMode.Moving:
        Logger.info(`AvPlayer SliderChangeMode Moving`);
        this.isMoving = true;
        break;
      case SliderChangeMode.End:
        Logger.info(`AvPlayer SliderChangeMode End`);
        this.avPlayer?.seek(value / CommonConstants.PROGRESS_HUNDRED * this.avPlayer.duration, seekType);
        this.isMoving = false;
        this.avPlayer?.play().catch((error: BusinessError) => {
          hilog.error(0x00, 'AvPlayerUtil', `play failed, code = ${error.code}, message = ${error.message}`);
        });
        break;
      case SliderChangeMode.Click:
        Logger.info(`AvPlayer SliderChangeMode Click`);
        this.avPlayer?.seek(this.sliderBegin / CommonConstants.PROGRESS_HUNDRED * this.avPlayer.duration, seekType);
        break;
      default:
        break;
    }
  }

  playerStateControl(): void {
    if (this.avPlayer?.state === CommonConstants.AV_PLAYER_STOPPED_STATE) {
      this.avPlayer.prepare().catch((error: BusinessError) => {
        hilog.error(0x00, 'AvPlayerUtil', `prepare failed, code = ${error.code}, message = ${error.message}`);
      });
    } else if (this.avPlayer?.state === CommonConstants.AV_PLAYER_PAUSED_STATE) {
      this.avPlayer.play().catch((error: BusinessError) => {
        hilog.error(0x00, 'AvPlayerUtil', `play failed, code = ${error.code}, message = ${error.message}`);
      });
    } else if (this.avPlayer?.state === CommonConstants.AV_PLAYER_PLAYING_STATE) {
      this.avPlayer.pause().catch((error: BusinessError) => {
        hilog.error(0x00, 'AvPlayerUtil', `pause failed, code = ${error.code}, message = ${error.message}`);
      });
    }
  }

  fastForward(): void {
    if (this.avPlayer?.state === CommonConstants.AV_PLAYER_PLAYING_STATE || this.avPlayer?.state ===
    CommonConstants.AV_PLAYER_PAUSED_STATE) {
      this.avPlayer.seek(this.avPlayer.currentTime + 5000);
    }
  }

  rewind(): void {
    if (this.avPlayer?.state === CommonConstants.AV_PLAYER_PLAYING_STATE || this.avPlayer?.state ===
    CommonConstants.AV_PLAYER_PAUSED_STATE) {
      this.avPlayer.seek(this.avPlayer.currentTime - 5000);
    }
  }

  formatTime(duration: number): string {
    let totalSecond: number = Math.round(duration / CommonConstants.PROGRESS_THOUSAND);
    let hourNum: number = Math.floor(totalSecond / CommonConstants.SECOND_IN_HOUR);
    let minNum: number = Math.floor((totalSecond % CommonConstants.SECOND_IN_HOUR) / CommonConstants.SECOND_IN_MINUTE);
    let secNum: number = (totalSecond % CommonConstants.SECOND_IN_HOUR) % CommonConstants.SECOND_IN_MINUTE;
    return this.formatUnitTime(hourNum) + CommonConstants.COLON + this.formatUnitTime(minNum) + CommonConstants.COLON +
    this.formatUnitTime(secNum);
  }

  formatUnitTime(time: number): string {
    if (time >= CommonConstants.ONE && time < CommonConstants.TEN) {
      let zero: string = CommonConstants.TIME_PREFIX;
      return zero.concat(time.toString());
    } else if (time >= CommonConstants.ZERO && time < CommonConstants.ONE) {
      return CommonConstants.EMPTY_TIME;
    }
    return time.toString();
  }

  // ==================== Migration Support Methods ====================

  /**
   * Pause playback (for migration).
   */
  pause(): void {
    if (this.avPlayer?.state === CommonConstants.AV_PLAYER_PLAYING_STATE) {
      this.avPlayer.pause().catch((error: BusinessError) => {
        hilog.error(0x00, 'AvPlayerUtil', `pause failed, code = ${error.code}, message = ${error.message}`);
      });
      Logger.info('AvPlayer paused for migration');
    }
  }

  /**
   * Resume playback (for migration restore).
   */
  play(): void {
    if (this.avPlayer?.state === CommonConstants.AV_PLAYER_PAUSED_STATE ||
        this.avPlayer?.state === CommonConstants.AV_PLAYER_PREPARED_STATE) {
      this.avPlayer.play().catch((error: BusinessError) => {
        hilog.error(0x00, 'AvPlayerUtil', `play failed, code = ${error.code}, message = ${error.message}`);
      });
      Logger.info('AvPlayer resumed after migration');
    }
  }

  /**
   * Seek to specified time in milliseconds (for migration restore).
   * @param timeMs Target time in milliseconds.
   */
  seekToTime(timeMs: number): void {
    if (this.avPlayer && 
        (this.avPlayer.state === CommonConstants.AV_PLAYER_PLAYING_STATE ||
         this.avPlayer.state === CommonConstants.AV_PLAYER_PAUSED_STATE ||
         this.avPlayer.state === CommonConstants.AV_PLAYER_PREPARED_STATE)) {
      this.avPlayer.seek(timeMs, media.SeekMode.SEEK_PREV_SYNC);
      Logger.info(`AvPlayer seek to ${timeMs}ms for migration restore`);
    }
  }

  /**
   * Get current playback state.
   * @returns Current AVPlayer state string.
   */
  getPlaybackState(): string {
    return this.avPlayer?.state || CommonConstants.AV_PLAYER_IDLE_STATE;
  }

  /**
   * Get current playback time in milliseconds.
   * @returns Current time in milliseconds.
   */
  getCurrentTime(): number {
    return this.avPlayer?.currentTime || 0;
  }

  /**
   * Get total duration in milliseconds.
   * @returns Total duration in milliseconds.
   */
  getDuration(): number {
    return this.avPlayer?.duration || 0;
  }

  /**
   * Check if player is in a valid state for migration.
   * @returns True if player can be migrated.
   */
  canMigrate(): boolean {
    const state = this.avPlayer?.state;
    return state === CommonConstants.AV_PLAYER_PLAYING_STATE ||
           state === CommonConstants.AV_PLAYER_PAUSED_STATE;
  }

  /**
   * Prepare player for migration - pause and return current state.
   * @returns Current playback time in milliseconds.
   */
  prepareForMigration(): number {
    const currentTime = this.getCurrentTime();
    this.pause();
    Logger.info(`Prepared for migration at ${currentTime}ms`);
    return currentTime;
  }

  /**
   * Restore playback after migration.
   * @param timeMs Time to seek to in milliseconds.
   * @param autoPlay Whether to auto play after seeking.
   */
  async restoreAfterMigration(timeMs: number, autoPlay: boolean = true): Promise<void> {
    Logger.info(`Restoring after migration at ${timeMs}ms, autoPlay: ${autoPlay}`);
    
    // Wait for player to be ready
    const maxWait = 5000; // 5 seconds max wait
    const interval = 100; // Check every 100ms
    let waited = 0;
    
    while (waited < maxWait) {
      const state = this.avPlayer?.state;
      if (state === CommonConstants.AV_PLAYER_PLAYING_STATE ||
          state === CommonConstants.AV_PLAYER_PAUSED_STATE ||
          state === CommonConstants.AV_PLAYER_PREPARED_STATE) {
        break;
      }
      await new Promise<void>(resolve => setTimeout(resolve, interval));
      waited += interval;
    }

    // Seek to saved position
    if (timeMs > 0) {
      this.seekToTime(timeMs);
    }

    // Auto play if requested
    if (autoPlay) {
      await new Promise<void>(resolve => setTimeout(resolve, 200)); // Small delay after seek
      this.play();
    }

    Logger.info('Migration restore completed');
  }
}

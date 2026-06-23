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

/**
 * Constants for splash animation.
 */
export class SplashConstants {
  /**
   * Splash text to display.
   */
  static readonly SPLASH_TEXT: string = 'MultiVideo';

  /**
   * Animation duration for each phase in milliseconds.
   */
  static readonly PHASE1_DURATION: number = 1500; // 粒子聚合阶段
  static readonly PHASE2_DURATION: number = 1000; // 文字保持阶段
  static readonly PHASE3_DURATION: number = 1500; // 粒子扩散阶段
  static readonly PHASE4_DURATION: number = 1000; // 淡出阶段

  /**
   * Total animation duration.
   */
  static readonly TOTAL_DURATION: number = 5000;

  /**
   * Particle count for different devices.
   */
  static readonly PARTICLE_COUNT_PHONE: number = 150;
  static readonly PARTICLE_COUNT_FOLDABLE: number = 200;
  static readonly PARTICLE_COUNT_TABLET: number = 250;

  /**
   * Pixel sampling step for text extraction.
   */
  static readonly PIXEL_SAMPLING_STEP: number = 3;

  /**
   * Animation frame rate.
   */
  static readonly ANIMATION_FRAME_RATE: number = 60;
  static readonly ANIMATION_INTERVAL: number = 1000 / 60; // ~16.67ms

  /**
   * Particle properties.
   */
  static readonly PARTICLE_MIN_SIZE: number = 2;
  static readonly PARTICLE_MAX_SIZE: number = 6;
  static readonly PARTICLE_MIN_OPACITY: number = 0.3;
  static readonly PARTICLE_MAX_OPACITY: number = 1.0;

  /**
   * Glow effect properties.
   */
  static readonly GLOW_RADIUS_MIN: number = 5;
  static readonly GLOW_RADIUS_MAX: number = 20;
  static readonly GLOW_COLOR: string = '#4A90E2';

  /**
   * Colors for particles.
   */
  static readonly PARTICLE_COLORS: string[] = [
    '#4A90E2', // 蓝色
    '#67B26F', // 绿色
    '#F2994A', // 橙色
    '#9B59B6', // 紫色
    '#E74C3C', // 红色
    '#F1C40F'  // 黄色
  ];

  /**
   * Canvas settings for text extraction.
   */
  static readonly CANVAS_FONT_SIZE: number = 120;
  static readonly CANVAS_FONT_FAMILY: string = 'sans-serif';
  static readonly CANVAS_WIDTH: number = 800;
  static readonly CANVAS_HEIGHT: number = 200;

  /**
   * Easing function parameters.
   */
  static readonly EASE_OUT_CUBIC: number = 3;
  static readonly EASE_IN_OUT_QUAD: number = 2;

  /**
   * Background gradient colors.
   */
  static readonly BG_COLOR_START: string = '#0F2027';
  static readonly BG_COLOR_MIDDLE: string = '#203A43';
  static readonly BG_COLOR_END: string = '#2C5364';

  /**
   * Text color for splash.
   */
  static readonly TEXT_COLOR: string = '#FFFFFF';

  /**
   * Delay before transitioning to main page.
   */
  static readonly TRANSITION_DELAY: number = 500;

  /**
   * Timeout for canvas initialization (5 seconds).
   * If canvas fails to initialize within this time, splash will end directly.
   */
  static readonly INIT_TIMEOUT: number = 5000;
}

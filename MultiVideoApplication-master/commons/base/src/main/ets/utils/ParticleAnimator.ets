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

import { SplashConstants } from '../constants/SplashConstants';

/**
 * Position interface for x,y coordinates.
 */
export interface Position {
  x: number;
  y: number;
}

/**
 * Animation phase info interface.
 */
export interface AnimationPhase {
  phase: number;
  progress: number;
}

/**
 * Particle animator utility class.
 */
export class ParticleAnimator {
  /**
   * Easing function: ease-out cubic.
   */
  static easeOutCubic(t: number): number {
    return 1 - Math.pow(1 - t, SplashConstants.EASE_OUT_CUBIC);
  }

  /**
   * Easing function: ease-in-out quadratic.
   */
  static easeInOutQuad(t: number): number {
    return t < 0.5 
      ? 2 * t * t 
      : 1 - Math.pow(-2 * t + 2, 2) / 2;
  }

  /**
   * Linear interpolation.
   */
  static lerp(start: number, end: number, t: number): number {
    return start + (end - start) * t;
  }

  /**
   * Calculate distance between two points.
   */
  static distance(x1: number, y1: number, x2: number, y2: number): number {
    return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
  }

  /**
   * Generate random number in range.
   */
  static randomInRange(min: number, max: number): number {
    return Math.random() * (max - min) + min;
  }

  /**
   * Generate random integer in range.
   */
  static randomIntInRange(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  /**
   * Get random color from palette.
   */
  static getRandomColor(): string {
    const index = ParticleAnimator.randomIntInRange(0, SplashConstants.PARTICLE_COLORS.length - 1);
    return SplashConstants.PARTICLE_COLORS[index];
  }

  /**
   * Calculate particle size based on distance to center.
   */
  static calculateParticleSize(distance: number, maxDistance: number): number {
    const normalizedDistance = distance / maxDistance;
    const size = ParticleAnimator.lerp(
      SplashConstants.PARTICLE_MAX_SIZE,
      SplashConstants.PARTICLE_MIN_SIZE,
      normalizedDistance
    );
    return size;
  }

  /**
   * Calculate glow radius based on animation progress.
   */
  static calculateGlowRadius(progress: number): number {
    // Glow intensity varies with animation phase
    const intensity = Math.sin(progress * Math.PI);
    return ParticleAnimator.lerp(
      SplashConstants.GLOW_RADIUS_MIN,
      SplashConstants.GLOW_RADIUS_MAX,
      intensity
    );
  }

  /**
   * Calculate opacity with fade effect.
   */
  static calculateOpacity(baseOpacity: number, fadeProgress: number): number {
    return baseOpacity * (1 - fadeProgress);
  }

  /**
   * Generate random position within bounds.
   */
  static randomPosition(width: number, height: number): Position {
    const pos: Position = {
      x: ParticleAnimator.randomInRange(0, width),
      y: ParticleAnimator.randomInRange(0, height)
    };
    return pos;
  }

  /**
   * Calculate spread position for dispersion phase.
   */
  static calculateSpreadPosition(
    centerX: number,
    centerY: number,
    angle: number,
    distance: number
  ): Position {
    const pos: Position = {
      x: centerX + Math.cos(angle) * distance,
      y: centerY + Math.sin(angle) * distance
    };
    return pos;
  }

  /**
   * Normalize value to 0-1 range.
   */
  static normalize(value: number, min: number, max: number): number {
    return (value - min) / (max - min);
  }

  /**
   * Clamp value within range.
   */
  static clamp(value: number, min: number, max: number): number {
    return Math.min(Math.max(value, min), max);
  }

  /**
   * Calculate animation phase based on elapsed time.
   * Returns phase number (1-4) and progress within that phase (0-1).
   */
  static calculateAnimationPhase(elapsedTime: number): AnimationPhase {
    const totalDuration = SplashConstants.TOTAL_DURATION;
    
    if (elapsedTime < SplashConstants.PHASE1_DURATION) {
      // Phase 1: Particle convergence
      const result: AnimationPhase = {
        phase: 1,
        progress: elapsedTime / SplashConstants.PHASE1_DURATION
      };
      return result;
    } else if (elapsedTime < SplashConstants.PHASE1_DURATION + SplashConstants.PHASE2_DURATION) {
      // Phase 2: Text hold
      const phaseTime = elapsedTime - SplashConstants.PHASE1_DURATION;
      const result: AnimationPhase = {
        phase: 2,
        progress: phaseTime / SplashConstants.PHASE2_DURATION
      };
      return result;
    } else if (elapsedTime < SplashConstants.PHASE1_DURATION + SplashConstants.PHASE2_DURATION + SplashConstants.PHASE3_DURATION) {
      // Phase 3: Particle dispersion
      const phaseTime = elapsedTime - SplashConstants.PHASE1_DURATION - SplashConstants.PHASE2_DURATION;
      const result: AnimationPhase = {
        phase: 3,
        progress: phaseTime / SplashConstants.PHASE3_DURATION
      };
      return result;
    } else {
      // Phase 4: Fade out
      const phaseTime = elapsedTime - SplashConstants.PHASE1_DURATION - SplashConstants.PHASE2_DURATION - SplashConstants.PHASE3_DURATION;
      const result: AnimationPhase = {
        phase: 4,
        progress: Math.min(phaseTime / SplashConstants.PHASE4_DURATION, 1.0)
      };
      return result;
    }
  }

  /**
   * Check if animation is complete.
   */
  static isAnimationComplete(elapsedTime: number): boolean {
    return elapsedTime >= SplashConstants.TOTAL_DURATION;
  }
}

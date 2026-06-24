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
import { ParticleAnimator } from '../utils/ParticleAnimator';

/**
 * Particle data model.
 */
export class Particle {
  id: number;
  x: number;
  y: number;
  targetX: number;
  targetY: number;
  startX: number;
  startY: number;
  size: number;
  color: string;
  opacity: number;
  angle: number;
  speed: number;
  glowRadius: number;

  constructor(id: number, x: number, y: number) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.targetX = x;
    this.targetY = y;
    this.startX = x;
    this.startY = y;
    this.size = ParticleAnimator.randomInRange(
      SplashConstants.PARTICLE_MIN_SIZE,
      SplashConstants.PARTICLE_MAX_SIZE
    );
    this.color = ParticleAnimator.getRandomColor();
    this.opacity = ParticleAnimator.randomInRange(
      SplashConstants.PARTICLE_MIN_OPACITY,
      SplashConstants.PARTICLE_MAX_OPACITY
    );
    this.angle = Math.random() * Math.PI * 2;
    this.speed = ParticleAnimator.randomInRange(50, 150);
    this.glowRadius = SplashConstants.GLOW_RADIUS_MIN;
  }
}

/**
 * Text pixel point data.
 */
export class TextPixelPoint {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

/**
 * Particle view model for managing particles and animation state.
 */
export class ParticleViewModel {
  private particles: Particle[] = [];
  private textPixelPoints: TextPixelPoint[] = [];
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;

  /**
   * Initialize particles based on device type.
   */
  initializeParticles(count: number, width: number, height: number): void {
    this.canvasWidth = width;
    this.canvasHeight = height;
    this.particles = [];

    for (let i = 0; i < count; i++) {
      const pos = ParticleAnimator.randomPosition(width, height);
      const particle = new Particle(i, pos.x, pos.y);
      this.particles.push(particle);
    }
  }

  /**
   * Extract text pixel points from canvas.
   * This method should be called after canvas renders the text.
   */
  extractTextPixels(imageData: ImageData, canvasWidth: number, canvasHeight: number): void {
    this.textPixelPoints = [];
    const step = SplashConstants.PIXEL_SAMPLING_STEP;
    const data = imageData.data;

    // Iterate through pixels with sampling step
    for (let y = 0; y < canvasHeight; y += step) {
      for (let x = 0; x < canvasWidth; x += step) {
        const index = (y * canvasWidth + x) * 4;
        const alpha = data[index + 3]; // Alpha channel

        // If pixel is part of text (alpha > 0)
        if (alpha > 128) {
          this.textPixelPoints.push(new TextPixelPoint(x, y));
        }
      }
    }
  }

  /**
   * Assign text pixel positions to particles as targets.
   */
  assignTextTargets(offsetX: number = 0, offsetY: number = 0): void {
    if (this.textPixelPoints.length === 0 || this.particles.length === 0) {
      return;
    }

    // Distribute particles across text pixels
    const pointsPerParticle = Math.ceil(this.textPixelPoints.length / this.particles.length);

    this.particles.forEach((particle, index) => {
      const pointIndex = Math.min(
        index * pointsPerParticle,
        this.textPixelPoints.length - 1
      );
      const targetPoint = this.textPixelPoints[pointIndex];
      
      // Apply offset for centering on screen
      particle.targetX = targetPoint.x + offsetX;
      particle.targetY = targetPoint.y + offsetY;
      
      // Also update start position to be relative to full canvas
      particle.startX = particle.x;
      particle.startY = particle.y;
    });
  }

  /**
   * Update particles for convergence phase (Phase 1).
   */
  updateConvergence(progress: number): void {
    const easedProgress = ParticleAnimator.easeOutCubic(progress);

    this.particles.forEach(particle => {
      particle.x = ParticleAnimator.lerp(
        particle.startX,
        particle.targetX,
        easedProgress
      );
      particle.y = ParticleAnimator.lerp(
        particle.startY,
        particle.targetY,
        easedProgress
      );
      
      // Update glow based on convergence
      particle.glowRadius = ParticleAnimator.calculateGlowRadius(progress);
    });
  }

  /**
   * Update particles for hold phase (Phase 2).
   */
  updateHold(progress: number): void {
    // Particles stay at target positions with subtle pulsing
    this.particles.forEach(particle => {
      const pulseFactor = 1 + Math.sin(progress * Math.PI * 2) * 0.05;
      particle.size = ParticleAnimator.clamp(
        particle.size * pulseFactor,
        SplashConstants.PARTICLE_MIN_SIZE,
        SplashConstants.PARTICLE_MAX_SIZE
      );
      
      // Pulsing glow effect
      particle.glowRadius = ParticleAnimator.calculateGlowRadius(progress);
    });
  }

  /**
   * Update particles for dispersion phase (Phase 3).
   */
  updateDispersion(progress: number, centerX: number, centerY: number): void {
    const easedProgress = ParticleAnimator.easeInOutQuad(progress);

    this.particles.forEach(particle => {
      // Calculate dispersion distance
      const maxDistance = Math.max(this.canvasWidth, this.canvasHeight) * 0.8;
      const distance = maxDistance * easedProgress;
      
      // Use particle's angle for dispersion direction
      const spreadPos = ParticleAnimator.calculateSpreadPosition(
        centerX,
        centerY,
        particle.angle,
        distance
      );

      // Interpolate from target to spread position
      particle.x = ParticleAnimator.lerp(
        particle.targetX,
        spreadPos.x,
        easedProgress
      );
      particle.y = ParticleAnimator.lerp(
        particle.targetY,
        spreadPos.y,
        easedProgress
      );

      // Fade out glow
      particle.glowRadius = ParticleAnimator.lerp(
        SplashConstants.GLOW_RADIUS_MAX,
        SplashConstants.GLOW_RADIUS_MIN,
        easedProgress
      );
    });
  }

  /**
   * Update particles for fade out phase (Phase 4).
   */
  updateFadeOut(progress: number): void {
    this.particles.forEach(particle => {
      particle.opacity = ParticleAnimator.calculateOpacity(
        SplashConstants.PARTICLE_MAX_OPACITY,
        progress
      );
      
      // Reduce glow
      particle.glowRadius = ParticleAnimator.lerp(
        SplashConstants.GLOW_RADIUS_MIN,
        0,
        progress
      );
    });
  }

  /**
   * Get all particles.
   */
  getParticles(): Particle[] {
    return this.particles;
  }

  /**
   * Set text pixel points (for testing).
   */
  setTextPixelPoints(points: TextPixelPoint[]): void {
    this.textPixelPoints = points;
  }

  /**
   * Get text pixel points count.
   */
  getTextPixelCount(): number {
    return this.textPixelPoints.length;
  }

  /**
   * Get particle count.
   */
  getParticleCount(): number {
    return this.particles.length;
  }

  /**
   * Clear all data.
   */
  clear(): void {
    this.particles = [];
    this.textPixelPoints = [];
  }
}

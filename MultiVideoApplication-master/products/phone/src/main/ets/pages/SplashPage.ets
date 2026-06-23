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

import { deviceInfo } from '@kit.BasicServicesKit';
import { Animator as animator, AnimatorOptions, AnimatorResult } from '@kit.ArkUI';
import { SplashConstants, ParticleAnimator, ParticleViewModel, Particle, TextPixelPoint } from 'base';

@Component
export struct SplashPage {
  // Callback for animation end - use regular property instead of @Prop for function type
  onAnimationEnd?: () => void;
  // Only keep @State for UI-affecting properties
  @State private backgroundOpacity: number = 1;
  
  // Remove @State from animation data - direct canvas rendering
  private particles: Particle[] = [];
  private animationPhase: number = 1;
  private phaseProgress: number = 0;
  private isAnimating: boolean = false;
  
  private particleViewModel: ParticleViewModel = new ParticleViewModel();
  // Animator for smooth frame-based animation
  private frameAnimator: AnimatorResult | null = null;
  private startTime: number = 0;
  // Timeout timer for canvas initialization failure
  private initTimeoutTimer: number = -1;
  // Flag to track if animation ended (either normally or via timeout)
  private hasAnimationEnded: boolean = false;
  // 文本提取用的 context (使用离屏Canvas)
  private textSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private textContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.textSettings);
  // 粒子渲染用的 context
  private particleSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private particleContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.particleSettings);
  // 粒子 Canvas 实际尺寸
  private particleCanvasWidth: number = 0;
  private particleCanvasHeight: number = 0;
  // 文本 Canvas 尺寸
  private textCanvasWidth: number = SplashConstants.CANVAS_WIDTH;
  private textCanvasHeight: number = SplashConstants.CANVAS_HEIGHT;
  // 粒子绘制偏移量（用于居中显示）
  private offsetX: number = 0;
  private offsetY: number = 0;
  // 状态标志
  private isTextCanvasReady: boolean = false;
  private isParticleCanvasReady: boolean = false;
  
  aboutToAppear(): void {
    // Determine particle count based on device type
    const particleCount = this.getParticleCount();
    
    // Initialize particles with default canvas size (will be updated when canvas is ready)
    this.particleViewModel.initializeParticles(
      particleCount,
      this.textCanvasWidth,
      this.textCanvasHeight
    );
    
    this.particles = this.particleViewModel.getParticles();
    
    // Start initialization timeout (5 seconds)
    this.startInitTimeout();
  }
  
  /**
   * Start initialization timeout to prevent app stuck if canvas fails to initialize.
   */
  private startInitTimeout(): void {
    this.initTimeoutTimer = setTimeout(() => {
      if (!this.hasAnimationEnded && !this.isAnimating) {
        console.warn('[SplashPage] Canvas initialization timeout, ending splash directly');
        this.hasAnimationEnded = true;
        this.notifyAnimationEnd();
      }
    }, SplashConstants.INIT_TIMEOUT);
  }
  
  /**
   * Clear initialization timeout.
   */
  private clearInitTimeout(): void {
    if (this.initTimeoutTimer !== -1) {
      clearTimeout(this.initTimeoutTimer);
      this.initTimeoutTimer = -1;
    }
  }
  
  aboutToDisappear(): void {
    this.stopAnimation();
    this.clearInitTimeout();
  }
  
  /**
   * Get particle count based on device type.
   */
  private getParticleCount(): number {
    const deviceType = deviceInfo.deviceType;
    
    if (deviceType === 'phone') {
      return SplashConstants.PARTICLE_COUNT_PHONE;
    } else if (deviceType === '2in1') {
      return SplashConstants.PARTICLE_COUNT_FOLDABLE;
    } else {
      return SplashConstants.PARTICLE_COUNT_TABLET;
    }
  }
  
  /**
   * Handle text canvas ready event.
   */
  private onTextCanvasReady(): void {
    console.info('[SplashPage] Text canvas ready');
    this.isTextCanvasReady = true;
    // Check if both canvases are ready
    this.tryStartAnimation();
  }
  
  /**
   * Handle particle canvas ready event.
   */
  private onParticleCanvasReady(): void {
    console.info('[SplashPage] onParticleCanvasReady called, dimensions: ' + 
      this.particleCanvasWidth + 'x' + this.particleCanvasHeight);
    this.isParticleCanvasReady = true;
    
    // If dimensions already available from onAreaChange, initialize now
    if (this.particleCanvasWidth > 0 && this.particleCanvasHeight > 0) {
      this.initializeParticleCanvas();
    }
    
    // Always try to start animation
    this.tryStartAnimation();
  }
  
  /**
   * Initialize particle canvas with proper dimensions.
   */
  private initializeParticleCanvas(): void {
    // Calculate offset to center the text area on screen
    this.offsetX = (this.particleCanvasWidth - this.textCanvasWidth) / 2;
    this.offsetY = (this.particleCanvasHeight - this.textCanvasHeight) / 2;
    
    console.info('[SplashPage] initializeParticleCanvas, offset: ' + 
      this.offsetX + ',' + this.offsetY);
    
    // Reinitialize particles with proper positions
    const particleCount = this.getParticleCount();
    this.particleViewModel.initializeParticles(
      particleCount,
      this.particleCanvasWidth,
      this.particleCanvasHeight
    );
    this.particles = this.particleViewModel.getParticles();
    
    console.info('[SplashPage] particles initialized: ' + this.particles.length);
  }
  
  /**
   * Try to start animation when both canvases are ready.
   */
  private tryStartAnimation(): void {
    console.info('[SplashPage] tryStartAnimation: textReady=' + this.isTextCanvasReady + 
      ', particleReady=' + this.isParticleCanvasReady + 
      ', animating=' + this.isAnimating +
      ', dimensions=' + this.particleCanvasWidth + 'x' + this.particleCanvasHeight);
    
    // Check if we can start animation
    if (this.isTextCanvasReady && this.isParticleCanvasReady && !this.isAnimating) {
      // Check dimensions
      if (this.particleCanvasWidth <= 0 || this.particleCanvasHeight <= 0) {
        console.warn('[SplashPage] Dimensions not ready, waiting...');
        // Try again after a short delay
        setTimeout(() => {
          this.tryStartAnimation();
        }, 100);
        return;
      }
      
      // Ensure particles are initialized
      if (this.particles.length === 0) {
        console.warn('[SplashPage] Particles not initialized, initializing now...');
        const particleCount = this.getParticleCount();
        this.particleViewModel.initializeParticles(
          particleCount,
          this.particleCanvasWidth,
          this.particleCanvasHeight
        );
        this.particles = this.particleViewModel.getParticles();
      }
      
      // Extract text pixels and assign targets (must be done after both canvases are ready)
      this.drawTextAndExtractPixels();
      
      console.info('[SplashPage] Starting animation with ' + this.particles.length + ' particles');
      
      // Initial draw
      this.drawParticles();
      
      // Start animation after a short delay
      setTimeout(() => {
        this.startAnimation();
      }, 100);
    } else {
      console.info('[SplashPage] Cannot start animation yet: textReady=' + this.isTextCanvasReady + 
        ', particleReady=' + this.isParticleCanvasReady + 
        ', animating=' + this.isAnimating);
    }
  }
  
  /**
   * Draw text on canvas and extract pixel points.
   */
  private drawTextAndExtractPixels(): void {
    console.info('[SplashPage] drawTextAndExtractPixels called, canvas size: ' + 
      this.textCanvasWidth + 'x' + this.textCanvasHeight);
    
    // Check if canvas context is valid
    if (!this.textContext) {
      console.error('[SplashPage] Text context is not available');
      this.createDummyTextPixels();
      return;
    }
    
    // First, try to create a simple test to verify canvas is working
    try {
      // Clear canvas with a background color to test
      this.textContext.fillStyle = '#000000';
      this.textContext.fillRect(0, 0, this.textCanvasWidth, this.textCanvasHeight);
      
      // Set text properties
      this.textContext.font = `bold ${SplashConstants.CANVAS_FONT_SIZE}px ${SplashConstants.CANVAS_FONT_FAMILY}`;
      this.textContext.fillStyle = SplashConstants.TEXT_COLOR;
      this.textContext.textAlign = 'center';
      this.textContext.textBaseline = 'middle';
      
      // Draw text at center
      const centerX = this.textCanvasWidth / 2;
      const centerY = this.textCanvasHeight / 2;
      console.info('[SplashPage] Drawing text "' + SplashConstants.SPLASH_TEXT + '" at: ' + centerX + ', ' + centerY);
      
      this.textContext.fillText(SplashConstants.SPLASH_TEXT, centerX, centerY);
      console.info('[SplashPage] Text drawn successfully');
      
      // Try to get a small area of ImageData first to test
      const testWidth = Math.min(10, this.textCanvasWidth);
      const testHeight = Math.min(10, this.textCanvasHeight);
      const testImageData = this.textContext.getImageData(centerX - 5, centerY - 5, testWidth, testHeight);
      
      if (testImageData && testImageData.data) {
        console.info('[SplashPage] Test ImageData obtained, length: ' + testImageData.data.length);
      } else {
        console.warn('[SplashPage] Test ImageData failed, using dummy pixels');
        this.createDummyTextPixels();
        return;
      }
      
      // Now get full ImageData
      const imageData = this.textContext.getImageData(
        0,
        0,
        this.textCanvasWidth,
        this.textCanvasHeight
      );
      
      if (!imageData || !imageData.data) {
        console.error('[SplashPage] Full ImageData is null or has no data');
        this.createDummyTextPixels();
        return;
      }
      
      console.info('[SplashPage] Full ImageData obtained, data length: ' + imageData.data.length + 
        ', width: ' + imageData.width + ', height: ' + imageData.height);
      
      // Check if we have any non-transparent pixels
      let hasPixels = false;
      for (let i = 3; i < Math.min(100, imageData.data.length); i += 4) {
        if (imageData.data[i] > 0) {
          hasPixels = true;
          break;
        }
      }
      
      if (!hasPixels) {
        console.warn('[SplashPage] No visible pixels found in ImageData');
        // Draw a test rectangle to verify canvas is working
        this.textContext.fillStyle = '#FF0000';
        this.textContext.fillRect(centerX - 50, centerY - 50, 100, 100);
        
        // Try again
        const testImageData2 = this.textContext.getImageData(centerX - 50, centerY - 50, 100, 100);
        if (testImageData2 && testImageData2.data && testImageData2.data[3] > 0) {
          console.info('[SplashPage] Test rectangle drawn successfully, using dummy pixels for text');
        }
        this.createDummyTextPixels();
        return;
      }
      
      // Extract text pixels
      this.particleViewModel.extractTextPixels(
        imageData,
        this.textCanvasWidth,
        this.textCanvasHeight
      );
      
      const pixelCount = this.particleViewModel.getTextPixelCount();
      console.info('[SplashPage] Extracted ' + pixelCount + ' text pixels');
      
      if (pixelCount === 0) {
        console.warn('[SplashPage] No text pixels found, using dummy pixels');
        this.createDummyTextPixels();
        return;
      }
      
      // Assign text targets to particles with offset for centering
      this.particleViewModel.assignTextTargets(this.offsetX, this.offsetY);
      
      // Update particles state
      this.particles = this.particleViewModel.getParticles();
      
      console.info('[SplashPage] Particles after assign: ' + this.particles.length);
    } catch (error) {
      console.error('[SplashPage] Error in drawTextAndExtractPixels: ' + error);
      // Fallback: create some dummy text pixels for testing
      this.createDummyTextPixels();
    }
  }
  
  /**
   * Create dummy text pixels for testing when getImageData fails.
   */
  private createDummyTextPixels(): void {
    console.info('[SplashPage] Creating dummy text pixels for testing');
    
    // Create some simple text pixel positions for testing
    const dummyPixels: TextPixelPoint[] = [];
    const centerX = this.textCanvasWidth / 2;
    const centerY = this.textCanvasHeight / 2;
    
    // Create a simple "M" shape for testing
    for (let i = 0; i < 20; i++) {
      const x = centerX - 50 + i * 5;
      const y = centerY - 20;
      dummyPixels.push(new TextPixelPoint(x, y));
    }
    
    for (let i = 0; i < 20; i++) {
      const x = centerX - 50 + i * 5;
      const y = centerY + 20;
      dummyPixels.push(new TextPixelPoint(x, y));
    }
    
    for (let i = 0; i < 10; i++) {
      const x = centerX - 50 + i * 10;
      const y = centerY - 20 + i * 4;
      dummyPixels.push(new TextPixelPoint(x, y));
    }
    
    for (let i = 0; i < 10; i++) {
      const x = centerX + 50 - i * 10;
      const y = centerY - 20 + i * 4;
      dummyPixels.push(new TextPixelPoint(x, y));
    }
    
    // Set dummy pixels in view model
    this.particleViewModel.setTextPixelPoints(dummyPixels);
    
    // Assign text targets to particles with offset for centering
    this.particleViewModel.assignTextTargets(this.offsetX, this.offsetY);
    
    // Update particles state
    this.particles = this.particleViewModel.getParticles();
    
    console.info('[SplashPage] Created ' + dummyPixels.length + ' dummy pixels');
  }
  
  /**
   * Start animation using Animator for smooth frame-based rendering.
   */
  private startAnimation(): void {
    console.info('[SplashPage] startAnimation called');
    this.isAnimating = true;
    this.startTime = Date.now();
    
    // Create animator with duration matching total animation time
    const animatorOptions: AnimatorOptions = {
      duration: SplashConstants.TOTAL_DURATION,
      easing: 'linear',
      delay: 0,
      fill: 'forwards',
      direction: 'normal',
      iterations: 1,
      begin: 0,
      end: 1
    };
    
    this.frameAnimator = this.getUIContext().createAnimator(animatorOptions);
    
    // Set frame callback for continuous updates
    this.frameAnimator.onFrame = () => {
      if (this.isAnimating) {
        this.updateAnimation();
      }
    };
    
    this.frameAnimator.play();
  }
  
  /**
   * Stop animation.
   */
  private stopAnimation(): void {
    if (this.frameAnimator) {
      this.frameAnimator.cancel();
      this.frameAnimator = null;
    }
    this.isAnimating = false;
  }
  
  /**
   * Update animation frame.
   * Directly updates particles and renders to canvas without @State updates.
   */
  private updateAnimation(): void {
    const elapsedTime = Date.now() - this.startTime;
    
    // Calculate current phase and progress
    const phaseInfo = ParticleAnimator.calculateAnimationPhase(elapsedTime);
    this.animationPhase = phaseInfo.phase;
    this.phaseProgress = phaseInfo.progress;
    
    // Update particles based on phase
    switch (phaseInfo.phase) {
      case 1:
        this.particleViewModel.updateConvergence(phaseInfo.progress);
        break;
      case 2:
        this.particleViewModel.updateHold(phaseInfo.progress);
        break;
      case 3:
        const centerX = this.particleCanvasWidth / 2;
        const centerY = this.particleCanvasHeight / 2;
        this.particleViewModel.updateDispersion(phaseInfo.progress, centerX, centerY);
        break;
      case 4:
        this.particleViewModel.updateFadeOut(phaseInfo.progress);
        // Only update @State for UI-affecting property
        const newOpacity = 1 - phaseInfo.progress;
        if (Math.abs(this.backgroundOpacity - newOpacity) > 0.01) {
          this.backgroundOpacity = newOpacity;
        }
        break;
    }
    
    // Get particles reference (no @State update)
    this.particles = this.particleViewModel.getParticles();
    
    // Directly render to canvas
    this.drawParticlesBatched();
    
    // Check if animation is complete
    if (ParticleAnimator.isAnimationComplete(elapsedTime)) {
      this.stopAnimation();
      this.notifyAnimationEnd();
    }
  }
  
  /**
   * Notify animation end.
   */
  private notifyAnimationEnd(): void {
    // Clear timeout timer if still active
    this.clearInitTimeout();
    
    // Prevent duplicate calls
    if (this.hasAnimationEnded) {
      console.info('[SplashPage] Animation already ended, skipping');
      return;
    }
    
    this.hasAnimationEnded = true;
    
    setTimeout(() => {
      if (this.onAnimationEnd) {
        this.onAnimationEnd();
      }
    }, SplashConstants.TRANSITION_DELAY);
  }
  
  build() {
    Stack() {
      // Background gradient
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [
            [SplashConstants.BG_COLOR_START, 0.0],
            [SplashConstants.BG_COLOR_MIDDLE, 0.5],
            [SplashConstants.BG_COLOR_END, 1.0]
          ]
        })
        .opacity(this.backgroundOpacity)
      
      // Hidden canvas for text pixel extraction (visible but fully transparent)
      Canvas(this.textContext)
        .width(this.textCanvasWidth)
        .height(this.textCanvasHeight)
        .opacity(0)
        .visibility(Visibility.Visible)
        .onReady(() => {
          console.info('[SplashPage] Text canvas onReady called');
          // Add a small delay to ensure canvas is fully initialized
          setTimeout(() => {
            this.onTextCanvasReady();
          }, 100);
        })
      
      // Particle display canvas
      Canvas(this.particleContext)
        .width('100%')
        .height('100%')
        .onAreaChange((oldValue: Area, newValue: Area) => {
          // Get actual canvas dimensions from area change event
          const newWidth = newValue.width as number;
          const newHeight = newValue.height as number;
          
          console.info('[SplashPage] onAreaChange: ' + newWidth + 'x' + newHeight);
          
          if (newWidth > 0 && newHeight > 0) {
            this.particleCanvasWidth = newWidth;
            this.particleCanvasHeight = newHeight;
            
            // Initialize particle canvas when dimensions are available
            if (this.isParticleCanvasReady) {
              this.initializeParticleCanvas();
              this.tryStartAnimation();
            }
          }
        })
        .onReady(() => {
          console.info('[SplashPage] Particle canvas onReady called');
          // Add a small delay to ensure canvas is fully initialized
          setTimeout(() => {
            this.onParticleCanvasReady();
          }, 100);
        })
    }
    .width('100%')
    .height('100%')
  }
  
  /**
   * Draw all particles on canvas with batched rendering by color.
   * Groups particles by color to minimize context state changes.
   */
  private drawParticlesBatched(): void {
    // Skip if canvas not ready
    if (this.particleCanvasWidth <= 0 || this.particleCanvasHeight <= 0) {
      return;
    }
    
    // Skip if no particles
    if (this.particles.length === 0) {
      return;
    }
    
    const ctx = this.particleContext;
    
    // Clear canvas before drawing
    ctx.clearRect(0, 0, this.particleCanvasWidth, this.particleCanvasHeight);
    
    // Group particles by color for batch rendering
    const colorGroups: Map<string, Particle[]> = new Map();
    
    for (const particle of this.particles) {
      const color = particle.color;
      if (!colorGroups.has(color)) {
        colorGroups.set(color, []);
      }
      colorGroups.get(color)!.push(particle);
    }
    
    // Render each color group
    colorGroups.forEach((particles: Particle[], color: string) => {
      // Set common properties for this color group
      ctx.fillStyle = color;
      ctx.shadowColor = color;
      
      for (const particle of particles) {
        // Set per-particle properties
        ctx.globalAlpha = particle.opacity;
        ctx.shadowBlur = particle.glowRadius;
        
        // Draw particle
        ctx.beginPath();
        ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
        ctx.fill();
        ctx.closePath();
      }
    });
    
    // Reset context state
    ctx.globalAlpha = 1.0;
    ctx.shadowBlur = 0;
    ctx.shadowColor = '';
  }
  
  /**
   * Draw all particles on canvas (legacy method, kept for compatibility).
   */
  private drawParticles(): void {
    this.drawParticlesBatched();
  }
}

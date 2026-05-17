# MultiVideo 功能描述文档

本文档详细描述了 MultiVideo 应用的核心功能实现，包括开场动画、历史播放视频弹窗和点赞功能。

---

## 目录

- [1. 开场动画功能](#1-开场动画功能)
- [2. 历史播放视频弹窗功能](#2-历史播放视频弹窗功能)
- [3. 点赞功能](#3-点赞功能)

---

## 1. 开场动画功能

### 功能概述

开场动画是应用启动时展示的视觉特效，通过粒子动画技术实现"MultiVideo"文字的动态呈现，为用户提供流畅、炫酷的启动体验。

### 核心特性

#### 1.1 四阶段动画流程

动画采用四阶段设计，总时长 **5秒**：

| 阶段 | 时长 | 描述 |
|------|------|------|
| **阶段一：粒子聚合** | 1.5秒 | 散布的粒子向目标位置移动，逐渐形成文字轮廓 |
| **阶段二：文字保持** | 1.0秒 | 粒子稳定显示，完整呈现"MultiVideo"文字 |
| **阶段三：粒子扩散** | 1.5秒 | 粒子从文字位置向外扩散，形成爆炸效果 |
| **阶段四：淡出消失** | 1.0秒 | 粒子和背景渐变淡出，过渡到主页面 |

#### 1.2 设备自适应

根据设备类型自动调整粒子数量，确保在不同屏幕尺寸下都有良好的视觉效果：

| 设备类型 | 粒子数量 |
|----------|----------|
| 手机 | 150个 |
| 折叠屏 | 200个 |
| 平板 | 250个 |

#### 1.3 粒子视觉特性

- **多彩粒子**：使用6种预设颜色（蓝、绿、橙、紫、红、黄）
- **动态大小**：粒子大小在2-6像素之间，根据距离中心的位置动态调整
- **发光效果**：粒子具有发光阴影效果，增强视觉冲击力
- **透明度变化**：粒子透明度在0.3-1.0之间变化

### 技术实现

#### 核心组件

- **SplashPage.ets**：开场动画页面组件
- **ParticleAnimator.ets**：粒子动画工具类，提供动画计算函数
- **ParticleViewModel.ets**：粒子视图模型，管理粒子状态
- **SplashConstants.ets**：动画常量配置

#### 关键技术点

1. **Canvas双缓冲渲染**
   - 使用离屏Canvas提取文字像素点
   - 使用主Canvas渲染粒子动画
   - 批量渲染优化，按颜色分组减少状态切换

2. **文字像素提取**
   ```typescript
   // 在Canvas上绘制文字
   context.fillText('MultiVideo', centerX, centerY)
   // 提取像素数据
   const imageData = context.getImageData(0, 0, width, height)
   // 分析像素点，生成粒子目标位置
   ```

3. **动画帧驱动**
   - 使用HarmonyOS Animator API实现60fps流畅动画
   - 采用缓动函数（EaseOutCubic、EaseInOutQuad）优化动画曲线

4. **性能优化**
   - 初始化超时保护（5秒），防止Canvas初始化失败导致卡顿
   - 直接Canvas渲染，避免频繁的@State更新
   - 粒子按颜色分组批量渲染

### 动画效果预览

```
[阶段一] 散布粒子 → 聚合成文字
   ●  ●    ●        ●●●●●●●●
  ●  ●  ●  ●   →   MultiVideo
   ●  ●    ●        ●●●●●●●●

[阶段二] 文字稳定显示
   MultiVideo (粒子稳定)

[阶段三] 文字爆炸扩散
   ●  ●    ●
  ●  ●  ●  ●   ←  MultiVideo
   ●  ●    ●

[阶段四] 淡出消失
   (透明度渐变至0)
```

---

## 2. 历史播放视频弹窗功能

### 功能概述

历史播放视频弹窗功能用于在用户打开应用时，提示上次未看完的视频，提供"继续观看"的便捷入口，提升用户体验和视频完播率。

### 核心特性

#### 2.1 弹窗内容

弹窗包含以下信息：

- **视频封面**：显示上次观看视频的缩略图
- **视频标题**：显示视频名称，最多显示2行
- **播放进度**：
  - 当前播放时间 / 总时长（格式：MM:SS / MM:SS）
  - 进度条可视化显示播放进度百分比
- **操作按钮**：
  - "关闭"按钮：关闭弹窗，进入首页
  - "继续观看"按钮：跳转到视频详情页，从上次位置继续播放

#### 2.2 显示时机

弹窗在以下情况下显示：

1. 用户打开应用进入首页时
2. 存在上次观看记录（Preferences中有数据）
3. 视频未播放完成（进度 < 95%）

#### 2.3 数据持久化

使用 HarmonyOS Preferences API 进行数据持久化存储：

- **存储位置**：应用私有数据目录
- **存储格式**：JSON字符串
- **存储内容**：
  ```json
  {
    "videoId": "视频ID",
    "title": "视频标题",
    "cover": "封面图片URL",
    "currentTime": 120,  // 当前播放时间（秒）
    "totalTime": 300,    // 总时长（秒）
    "progress": 40,      // 播放进度百分比
    "lastWatchTime": 1234567890  // 最后观看时间戳
  }
  ```

### 技术实现

#### 核心组件

- **LastWatchDialog.ets**：弹窗UI组件
- **WatchHistoryUtil.ets**：历史记录管理工具类（单例）
- **WatchHistoryViewModel.ets**：历史记录视图模型
- **WatchHistoryConstants.ets**：常量配置

#### 关键技术点

1. **单例模式**
   ```typescript
   static getInstance(context: UIAbilityContext): WatchHistoryUtil {
     if (!WatchHistoryUtil.instance) {
       WatchHistoryUtil.instance = new WatchHistoryUtil(context);
     }
     return WatchHistoryUtil.instance;
   }
   ```

2. **双缓存机制**
   - **内存缓存**：快速读取最近访问的数据
   - **持久化存储**：Preferences API存储到本地

3. **数据序列化**
   ```typescript
   // 保存时序列化为JSON
   toJson(): string {
     return JSON.stringify({
       videoId: this.videoId,
       title: this.title,
       // ...其他字段
     });
   }
   
   // 读取时反序列化
   static fromJson(jsonStr: string): WatchHistoryViewModel {
     const obj = JSON.parse(jsonStr);
     return new WatchHistoryViewModel(/* 参数 */);
   }
   ```

4. **UI交互设计**
   - 半透明遮罩层，点击可关闭弹窗
   - 平滑的淡入淡出动画（200ms）
   - 阴影效果增强层次感
   - 响应式布局适配不同屏幕尺寸

### 使用流程

```
用户打开应用
    ↓
检查是否有观看历史
    ↓
[有历史且未完成] → 显示弹窗
    ↓
用户选择操作：
  ├─ 点击"关闭" → 进入首页
  └─ 点击"继续观看" → 跳转到视频详情页，从上次位置播放
```

### 视觉设计

```
┌─────────────────────────────────┐
│  继续观看                    ✕  │
├─────────────────────────────────┤
│  ┌──────┐  视频标题            │
│  │      │  (最多两行显示)      │
│  │ 封面 │                      │
│  │ 图片 │  02:00 / 05:00       │
│  │      │  ████░░░░░░ 40%      │
│  └──────┘                      │
├─────────────────────────────────┤
│  [ 关闭 ]      [ 继续观看 ]    │
└─────────────────────────────────┘
```

---

## 3. 点赞功能

### 功能概述

点赞功能允许用户对喜欢的视频进行点赞操作，系统会记录点赞状态和点赞数量，并提供流畅的交互动画效果。

### 核心特性

#### 3.1 点赞状态管理

- **点赞状态**：记录每个视频是否被当前用户点赞
- **点赞数量**：记录每个视频的总点赞数
- **状态持久化**：使用Preferences API持久化存储
- **内存缓存**：提供快速读取的内存缓存机制

#### 3.2 交互动画

点赞时触发缩放动画效果：

```
正常大小 (1.0)
    ↓
放大 (1.3倍)
    ↓
恢复 (1.0)
```

动画参数：
- 总时长：300ms
- 分为两个阶段：
  - 放大阶段：150ms，EaseOut曲线
  - 缩小阶段：150ms，EaseIn曲线

#### 3.3 视觉反馈

- **未点赞状态**：
  - 图标：空心爱心
  - 颜色：灰色 (#999999)
  
- **已点赞状态**：
  - 图标：实心爱心
  - 颜色：红色 (#E74C3C)

- **数量显示**：
  - 格式化显示（如：1.2k, 15.3k）
  - 颜色跟随点赞状态变化

### 技术实现

#### 核心组件

- **LikeButton.ets**：点赞按钮UI组件
- **LikeUtil.ets**：点赞数据管理工具类（单例）
- **LikeViewModel.ets**：点赞视图模型
- **LikeConstants.ets**：常量配置

#### 关键技术点

1. **双缓存机制**
   ```typescript
   // 内存缓存
   private likeStatusCache: Map<string, boolean> = new Map();
   private likeCountCache: Map<string, number> = new Map();
   
   // 读取时优先从缓存获取
   async getLikeStatus(videoId: string): Promise<boolean> {
     if (this.likeStatusCache.has(videoId)) {
       return this.likeStatusCache.get(videoId);
     }
     // 从Preferences读取并更新缓存
   }
   ```

2. **点赞逻辑**
   ```typescript
   async toggleLike(videoId: string): Promise<boolean> {
     const currentStatus = await this.getLikeStatus(videoId);
     const newStatus = !currentStatus;
     await this.saveLikeStatus(videoId, newStatus);
     return newStatus;
   }
   
   async updateLikeCount(videoId: string, increment: boolean): Promise<number> {
     const currentCount = await this.getLikeCount(videoId);
     const newCount = increment ? currentCount + 1 : Math.max(0, currentCount - 1);
     await this.saveLikeCount(videoId, newCount);
     return newCount;
   }
   ```

3. **动画实现**
   ```typescript
   private triggerAnimation(): void {
     animateTo({
       duration: 150,
       curve: Curve.EaseOut,
       onFinish: () => {
         animateTo({
           duration: 150,
           curve: Curve.EaseIn,
           onFinish: () => {
             this.scaleValue = 1.0;
           }
         }, () => {
           this.scaleValue = 1.0;
         });
       }
     }, () => {
       this.scaleValue = 1.3;  // 放大到1.3倍
     });
   }
   ```

4. **数量格式化**
   ```typescript
   static formatLikeCount(count: number): string {
     if (count >= 10000) {
       return (count / 10000).toFixed(1) + 'w';
     } else if (count >= 1000) {
       return (count / 1000).toFixed(1) + 'k';
     } else {
       return count.toString();
     }
   }
   ```

### 数据存储结构

每个视频的点赞数据存储为两条记录：

1. **点赞状态记录**
   ```json
   {
     "videoId": "视频ID",
     "isLiked": true,
     "likeTime": 1234567890  // 点赞时间戳
   }
   ```

2. **点赞数量记录**
   ```
   Key: "like_count_视频ID"
   Value: 点赞数量（数字）
   ```

### 性能优化

1. **批量查询**
   ```typescript
   async batchGetLikeStatus(videoIds: string[]): Promise<Map<string, boolean>> {
     const result = new Map();
     for (const videoId of videoIds) {
       const isLiked = await this.getLikeStatus(videoId);
       result.set(videoId, isLiked);
     }
     return result;
   }
   ```

2. **缓存清理**
   - 提供缓存清理接口，在内存紧张时清理缓存
   - 数据仍从Preferences读取，不影响功能

### 使用示例

```typescript
// 在视频详情页使用
@Entry
@Component
struct VideoDetailPage {
  @State videoId: string = 'video_123';
  @State initialLikeCount: number = 1200;
  
  build() {
    Column() {
      // 视频播放器
      VideoPlayer({ videoId: this.videoId })
      
      // 点赞按钮
      LikeButton({
        videoId: this.videoId,
        initialLikeCount: this.initialLikeCount
      })
    }
  }
}
```

---

## 技术架构总结

### 共同设计模式

1. **单例模式**
   - WatchHistoryUtil：管理观看历史数据
   - LikeUtil：管理点赞数据
   - 确保全局唯一实例，避免重复初始化

2. **ViewModel模式**
   - WatchHistoryViewModel：封装观看历史数据
   - LikeViewModel：封装点赞数据
   - 提供数据转换和业务逻辑方法

3. **双缓存机制**
   - 内存缓存：快速读取，提升性能
   - 持久化存储：数据持久化，应用重启后数据不丢失

4. **常量管理**
   - SplashConstants：动画参数配置
   - WatchHistoryConstants：历史记录配置
   - LikeConstants：点赞功能配置
   - 集中管理常量，便于维护和调整

### 性能优化策略

1. **异步操作**：所有数据读写操作使用async/await，避免阻塞UI线程
2. **缓存优先**：优先从内存缓存读取，减少I/O操作
3. **批量处理**：提供批量查询接口，减少多次调用开销
4. **动画优化**：使用硬件加速的Canvas和Animator API

### 用户体验设计

1. **流畅动画**：所有交互都有平滑的动画过渡
2. **即时反馈**：用户操作立即得到视觉反馈
3. **数据持久**：用户数据自动保存，应用重启后恢复
4. **设备适配**：根据设备类型自动调整参数，确保最佳体验

---

## 文件结构

```
MultiVideoApplication/
├── commons/base/
│   └── src/main/ets/
│       ├── constants/
│       │   ├── SplashConstants.ets      # 开场动画常量
│       │   ├── WatchHistoryConstants.ets # 历史记录常量
│       │   └── LikeConstants.ets        # 点赞功能常量
│       ├── utils/
│       │   ├── ParticleAnimator.ets     # 粒子动画工具
│       │   ├── WatchHistoryUtil.ets     # 历史记录管理
│       │   └── LikeUtil.ets             # 点赞数据管理
│       └── viewmodel/
│           ├── ParticleViewModel.ets    # 粒子视图模型
│           ├── WatchHistoryViewModel.ets # 历史记录视图模型
│           └── LikeViewModel.ets        # 点赞视图模型
├── features/home/
│   └── src/main/ets/view/
│       └── LastWatchDialog.ets          # 历史播放弹窗
├── features/videoDetail/
│   └── src/main/ets/view/
│       └── LikeButton.ets               # 点赞按钮
└── products/phone/
    └── src/main/ets/pages/
        └── SplashPage.ets               # 开场动画页面
```

---

## 版本信息

- **文档版本**：v1.0
- **最后更新**：2026-05-17
- **适用版本**：MultiVideo Application v1.0

---

## 联系方式

如有问题或建议，请联系开发团队。

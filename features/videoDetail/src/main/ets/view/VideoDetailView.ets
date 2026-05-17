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

import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BreakpointConstants, CommonConstants } from 'base';
import { Logger } from 'base';
import { RelatedList } from './RelatedList';
import { CurrentOffsetUtil } from '../utils/CurrentOffsetUtil';
import { DetailConstants } from '../constants/DetailConstants';
import { VideoPlayer } from './VideoPlayer';
import { FooterEpisodes } from './FooterEpisodes';
import { SideEpisodes } from './SideEpisodes';
import { LikeButton } from './LikeButton';

@Component
export struct VideoDetailView {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('creaseRegion') creaseRegion: number[] = [];
  @StorageLink('isHalfFolded') isHalfFolded: boolean = false;
  @StorageLink('isFullScreen') isFullScreen: boolean = false;
  @Link relatedVideoHeight: number;
  @Link videoHeight: number;
  @State isShowingSideBar: boolean = false;
  @State foldStatus: display.FoldStatus | undefined = undefined;
  @State currentVideoId: string = 'video_1'; // Current video ID for like functionality
  public screenHeight: number = 0;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        this.foldStatus = display.getFoldStatus();
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x00, 'VideoDetailView', `getFoldStatus failed, code = ${err.code}, message = ${err.message}`);
      }
    }
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Row() {
          Column() {
            Stack({ alignContent: Alignment.BottomEnd }) {
              VideoPlayer({
                videoHeight: this.videoHeight,
                isShowingSideBar: this.isShowingSideBar,
                foldStatus: this.foldStatus
              })

              // Floating like button on video player
              if (!this.isFullScreen) {
                Column() {
                  LikeButton({
                    videoId: this.currentVideoId,
                    initialLikeCount: 1234
                  })
                }
                .margin({ right: 16, bottom: 16 })
              }
            }

            Blank()
              .height(this.creaseRegion[1])
              .width(CommonConstants.FULL_PERCENT)
              .visibility(this.isHalfFolded && this.isShowingSideBar && this.isFullScreen ? Visibility.Visible :
                Visibility.None)

            FooterEpisodes({
              isShowingSideBar: this.isShowingSideBar,
              foldStatus: this.foldStatus
            })
          }
          .layoutWeight(3)

          SideEpisodes({
            isShowingSideBar: this.isShowingSideBar,
            foldStatus: this.foldStatus
          })
        }
        .justifyContent(FlexAlign.Start)
        .backgroundColor(Color.Black)
        .height(this.isFullScreen ? CommonConstants.FULL_PERCENT : 'auto')
        .width(CommonConstants.FULL_PERCENT)

        RelatedList({
          relatedVideoHeight: this.relatedVideoHeight,
          videoHeight: this.videoHeight,
          screenHeight: this.screenHeight
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .height(CommonConstants.FULL_PERCENT)
    .onScrollFrameBegin((offset: number) => {
      if (this.isFullScreen) {
        return { offsetRemain: offset };
      }
      if (this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
        if ((offset > 0) && (this.videoHeight > DetailConstants.MIN_VIDEO_PERCENT)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT ? offsetPercent :
            this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT;
          this.videoHeight = this.videoHeight - heightOffset;
        } else if ((offset < 0) && (this.videoHeight < DetailConstants.MAX_VIDEO_PERCENT) &&
          (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset())))) {
          // Video magnification logic.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          let heightOffset = offsetPercent < DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight ? offsetPercent :
            DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight;
          this.videoHeight = this.videoHeight + heightOffset;
        } else {
          Logger.info(`No specific function`);
        }
      } else {
        if ((offset > 0) && (this.videoHeight === DetailConstants.MAX_VIDEO_PERCENT) && (this.relatedVideoHeight > 0)) {
          // Related list shrinking logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.TEN) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight - offsetPercent * DetailConstants.RELATED_LIST_HEIGHT) <
            0 ? 0 : (this.relatedVideoHeight - offsetPercent * DetailConstants.RELATED_LIST_HEIGHT);
        } else if ((offset > 0) && (this.videoHeight > DetailConstants.MIN_VIDEO_PERCENT) &&
          (this.relatedVideoHeight === 0)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT ? offsetPercent :
            this.videoHeight - DetailConstants.MIN_VIDEO_PERCENT;
          this.videoHeight = this.videoHeight - heightOffset;
        } else if ((this.videoHeight < DetailConstants.MAX_VIDEO_PERCENT) && (this.relatedVideoHeight === 0)
          && (offset < 0) && (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset())))) {
          // Video magnification logic.
          let offsetPercent = (Math.abs(offset) * DetailConstants.MAX_VIDEO_PERCENT) / this.screenHeight;
          let heightOffset = offsetPercent < DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight ? offsetPercent :
            DetailConstants.MAX_VIDEO_PERCENT - this.videoHeight;
          this.videoHeight = this.videoHeight + heightOffset;
        } else if ((offset < 0) && (this.videoHeight === DetailConstants.MAX_VIDEO_PERCENT) &&
          (this.relatedVideoHeight >= 0)) {
          // Related list enlargement logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.TEN) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight + offsetPercent * DetailConstants.RELATED_LIST_HEIGHT) >
          DetailConstants.RELATED_LIST_HEIGHT ? DetailConstants.RELATED_LIST_HEIGHT : (this.relatedVideoHeight +
            offsetPercent * DetailConstants.RELATED_LIST_HEIGHT);
        } else {
          Logger.info(`No specific function`);
        }
      }
      // Returns the actual offset 0.
      return { offsetRemain: 0 };
    })
  }
}
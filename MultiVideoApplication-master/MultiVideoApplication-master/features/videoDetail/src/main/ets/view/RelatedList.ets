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

import { BreakpointConstants, CommonConstants } from 'base';
import { DetailConstants } from '../constants/DetailConstants';
import { CurrentOffsetUtil } from '../utils/CurrentOffsetUtil';
import { RelatedVideo, RelatedVideoViewModel } from '../viewmodel/RelatedVideoViewModel';
import { AllComments } from './AllComments';

@Component
export struct RelatedList {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'lg';
  @StorageLink('isFullScreen') isFullScreen: boolean = false;
  @State commentImgHeight: string = DetailConstants.INITIAL_COMMENT_IMAGE_HEIGHT;
  @State commentImgWidth: string = DetailConstants.INITIAL_COMMENT_IMAGE_WIDTH;
  @Link relatedVideoHeight: number;
  @Link videoHeight: number;
  public screenHeight: number = 0;
  private relatedVideoList: RelatedVideo[] = new RelatedVideoViewModel().getRelatedVideoList();
  private peripheralVideoList: RelatedVideo[] = new RelatedVideoViewModel().getPeripheralVideoList();
  private episodes: string[] = DetailConstants.EPISODES_LIST;
  private currentIndex: number = 2;
  private iconList: Resource[] = DetailConstants.ICON_LIST;
  private scroller: Scroller = new Scroller();

  // [Start build_scroller]
  build() {
    Scroll(this.scroller) {
      Column() {
        this.RelatedVideoComponent()
        this.VideoIntroduction()
        AllComments({commentImgHeight: this.commentImgHeight, commentImgWidth: this.commentImgWidth})
          .visibility(this.currentWidthBreakpoint === 'lg' ? Visibility.None : Visibility.Visible)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ bottom: '10vp' })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .visibility(!this.isFullScreen ? Visibility.Visible : Visibility.None)
    .onScrollFrameBegin((offset: number) => {
      if (this.currentWidthBreakpoint === 'lg') {
        if ((offset > 0) && (this.videoHeight > 53)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * 100) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - 53 ? offsetPercent : this.videoHeight - 53;
          this.videoHeight = this.videoHeight - heightOffset;
          // Returns the actual offset 0.
          return { offsetRemain: 0 };
        } else if ((offset < 0) && (this.videoHeight < 100) &&
          (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset())))) {
          // Video magnification logic.
          let offsetPercent = (Math.abs(offset) * 100) / this.screenHeight;
          let heightOffset = offsetPercent < 100 - this.videoHeight ? offsetPercent : 100 - this.videoHeight;
          this.videoHeight = this.videoHeight + heightOffset;
          // Returns the actual offset 0.
          return { offsetRemain: 0 };
        }
        return { offsetRemain: offset };
      } else {
        if ((offset > 0) && (this.videoHeight === 100) && (this.relatedVideoHeight > 0)) {
          // Related list shrinking logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.TEN) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight - offsetPercent * 169) <
            0 ? 0 : (this.relatedVideoHeight - offsetPercent * 169);
          // Returns the actual offset 0.
          return { offsetRemain: 0 };
        } else if ((offset > 0) && (this.videoHeight > 53) &&
          (this.relatedVideoHeight === 0)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * 100) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - 53 ? offsetPercent : this.videoHeight - 53;
          this.videoHeight = this.videoHeight - heightOffset;
          // Returns the actual offset 0.
          return { offsetRemain: 0 };
        } else if ((offset > 0) && (this.videoHeight === 53) && (this.relatedVideoHeight === 0)) {
          return { offsetRemain: offset };
        } else if ((offset < 0) && (this.videoHeight < 100) && (this.relatedVideoHeight === 0)) {
          if (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset()))) {
            // Video magnification logic.
            let offsetPercent = (Math.abs(offset) * 100) / this.screenHeight;
            let heightOffset = offsetPercent < 100 - this.videoHeight ? offsetPercent : 100 - this.videoHeight;
            this.videoHeight = this.videoHeight + heightOffset;
            // Returns the actual offset 0.
            return { offsetRemain: 0 };
          }
          return { offsetRemain: offset };
        } else if ((offset < 0) && (this.videoHeight === 100) && (this.relatedVideoHeight >= 0)) {
          // Related list enlargement logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * DetailConstants.TEN) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight + offsetPercent * 169) > 169 ? 169 :
            (this.relatedVideoHeight + offsetPercent * 169);
          // Returns the actual offset 0.
          return { offsetRemain: 0 };
        }
        return { offsetRemain: 0 };
      }
    })
  }
  // [End build_scroller]

  @Builder
  RelatedVideoComponent() {
    Column() {
      this.SubTitleAndMore(DetailConstants.SUB_TITLES[1])

      Row() {
        List({ space: CommonConstants.LIST_SPACE }) {
          ForEach(this.relatedVideoList, (item: RelatedVideo, index: number) => {
            ListItem() {
              Column() {
                Image(item.getImageSrc())
                  .height($r('app.float.related_img_height'))
                  .width($r('app.float.related_img_width'))
                  .objectFit(ImageFit.Cover)
                  .borderRadius($r('app.float.related_img_radius'))
                  .margin({ bottom: $r('app.float.related_img_margin') })

                Text(item.getName())
                  .fontSize($r('app.float.related_name_font'))
                  .lineHeight($r('app.float.related_name_line'))
                  .fontWeight(500)
                  .opacity(CommonConstants.TEXT_OPACITY[2])
                  .fontColor(index === 0 ? $r('app.color.episodes_font') : Color.Black)
              }
            }
            .margin({
              top: $r('app.float.related_list_top'),
              bottom: $r('app.float.related_list_bottom')
            })
          }, (item: RelatedVideo, index: number) => index + JSON.stringify(item))
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
      }
      .padding({
        left: $r('app.float.related_row_left'),
        bottom: $r('app.float.related_row_bottom')
      })
      .height($r('app.float.related_row_height'))
      .width('100%')
    }
    .height(this.relatedVideoHeight + DetailConstants.LENGTH_UNIT)
  }

  // [Start video_introduction]
  @Builder
  VideoIntroduction() {
    Column() {
      // [StartExclude video_introduction]
      this.SubTitle($r('app.string.introduction'))

      Column() {
        this.IntroductionContent($r('app.string.product'))
        this.IntroductionContent($r('app.string.play'))
      }
      .padding({
        left: '24vp',
        right: '24vp'
      })
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // [EndExclude video_introduction]
      Row() {
        ForEach(this.iconList, (item: Resource, index: number) => {
          Image(item)
            .height('24vp')
            .width('24vp')
        }, (item: Resource, index: number) => index + JSON.stringify(item))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      // [StartExclude video_introduction]
      .padding({
        top: $r('app.float.introduction_row_padding'),
        bottom: $r('app.float.introduction_row_padding'),
        left: $r('app.float.sub_title_row_padding'),
        right: $r('app.float.sub_title_row_padding')
      })
      .height($r('app.float.sub_title_row_height_detail'))
      .width('100%')

      this.SubTitle($r('app.string.anthology'))
      // [EndExclude video_introduction]

      List({ space: '12vp' }) {
        ForEach(this.episodes, (item: string, index: number) => {
          ListItem() {
            // [StartExclude video_introduction]
            Row() {
              Image($r('app.media.video_playing'))
                .height($r('app.float.is_playing_icon_size'))
                .width($r('app.float.is_playing_icon_size'))
                .position({ x: $r('app.float.is_playing_icon_x'), y: $r('app.float.is_playing_icon_y') })
                .visibility((index + 1) === this.currentIndex ? Visibility.Visible : Visibility.None)

              Text(item)
                .fontSize($r('app.float.episodes_text_font'))
                .fontWeight(FontWeight.Normal)
                .height($r('app.float.episodes_text_height'))
                .fontColor((index + 1) === this.currentIndex ? $r('app.color.episodes_font') : Color.Black)
            }
            .justifyContent(FlexAlign.Center)
            .backgroundColor($r('app.color.episodes_background'))
            .height($r('app.float.episodes_list_height'))
            .width($r('app.float.episodes_list_width'))
            .borderRadius($r('app.float.episodes_list_radius'))
            // [EndExclude video_introduction]
          }
        }, (item: string, index: number) => index + JSON.stringify(item))
      }
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .padding({ left: $r('app.float.sub_title_row_padding') })
      .margin({ bottom: $r('app.float.episodes_list_margin') })
      .width('100%')

      this.SubTitleAndMore($r('app.string.Peripheral'))

      // [StartExclude video_introduction]
      List({ space: '12vp' }) {
        ForEach(this.peripheralVideoList, (item: RelatedVideo, index: number) => {
          ListItem() {
            Column() {
              Image(item.getImageSrc())
                .height($r('app.float.peripheral_img_height'))
                .width($r('app.float.peripheral_img_width'))
                .margin({ bottom: $r('app.float.peripheral_img_margin') })
                .borderRadius($r('app.float.peripheral_img_radius'))

              Text(item.getName())
                .lineHeight($r('app.float.peripheral_name_line'))
                .fontSize($r('app.float.peripheral_name_font'))
                .opacity(0.6)
                .fontWeight(500)
            }
          }
        }, (item: RelatedVideo, index: number) => index + JSON.stringify(item))
      }
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .margin({ top: $r('app.float.peripheral_list_margin') })
      .padding({
        left: $r('app.float.sub_title_row_padding'),
        right: $r('app.float.sub_title_row_padding')
      })
      .width('100%')
      // [EndExclude video_introduction]
    }
    .width('100%')
    .backgroundColor(Color.White)
    .visibility(this.currentWidthBreakpoint === 'lg' ? Visibility.Visible : Visibility.None)
  }

  // [StartExclude video_introduction]
  @Builder
  SubTitle(subtitle: ResourceStr) {
    Row() {
      Text(subtitle)
        .fontSize($r('app.float.detail_sub_title_font'))
        .lineHeight($r('app.float.sub_title_text_line'))
        .fontWeight(500)
    }
    .padding({
      left: $r('app.float.sub_title_row_padding'),
      right: $r('app.float.sub_title_row_padding')
    })
    .height($r('app.float.sub_title_row_height_detail'))
    .width('100%')
  }
  // [EndExclude video_introduction]

  @Builder
  SubTitleAndMore(subtitle: ResourceStr) {
    Row() {
      // [StartExclude video_introduction]
      Text(subtitle)
        .fontSize($r('app.float.detail_sub_title_font'))
        .lineHeight($r('app.float.sub_title_text_line'))
        .fontWeight(500)
      // [EndExclude video_introduction]
      Blank()
      // [StartExclude video_introduction]
      Text($r('app.string.more'))
        .fontSize($r('app.float.sub_title_font_more'))
        .lineHeight($r('app.float.sub_title_text_line_more'))
        .fontWeight(FontWeight.Normal)
        .opacity($r('app.string.more'))
      Image($r('app.media.ic_public_arrow_right'))
        .height($r('app.float.arrow_img_size'))
        .width($r('app.float.arrow_img_size'))
      // [EndExclude video_introduction]
    }
    .padding({
      left: $r('app.float.sub_title_row_padding'),
      right: $r('app.float.sub_title_row_padding')
    })
    .height($r('app.float.sub_title_row_height_detail'))
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
  // [End video_introduction]

  @Builder
  IntroductionContent(content: ResourceStr) {
    Text(content)
      .fontSize($r('app.float.introduction_content_font'))
      .lineHeight($r('app.float.introduction_content_line'))
      .fontWeight(500)
      .opacity(0.6)
  }
}
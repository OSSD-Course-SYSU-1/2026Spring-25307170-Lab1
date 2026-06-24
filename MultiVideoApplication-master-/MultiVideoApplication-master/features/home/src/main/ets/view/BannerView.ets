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

/*
* 最佳实践: 一多交互事件开发实践
*/

import { BreakpointConstants, CommonConstants } from 'base';
import { BreakpointType } from 'base';
import { HomeConstants } from '../constants/HomeConstants';
import { Banner, BannerViewModel } from '../viewmodel/BannerViewModel';
import { getTabIndex } from './CommonView';

class BannerDataSource implements IDataSource {
  private bannerImgList: Banner[] = [];

  constructor(bannerImgList: Banner[]) {
    this.bannerImgList = bannerImgList;
  }

  totalCount(): number {
    return this.bannerImgList.length;
  }

  getData(index: number): Banner {
    return this.bannerImgList[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener() {
  }
}

@Component
export struct BannerView {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowWidth') windowWidth: number = 0;
  @StorageLink('currentTopIndex') currentTopIndex: number = 0;
  private bannerImgList: Banner[] = new BannerViewModel().getBannerList();
  private bannerDataSource: BannerDataSource = new BannerDataSource([]);

  aboutToAppear(): void {
    this.bannerDataSource = new BannerDataSource(this.bannerImgList);
  }

  build() {
    Column() {
      // Banner layout.
      Row() {
        // [Start swiper1_lazyforeach]
        // [Start jh_lazy_for_each]
        Swiper() {
          LazyForEach(this.bannerDataSource, (item: Banner, index: number) => {
            // [StartExclude jh_lazy_for_each]
            this.BannerItem(item, index)
            // [EndExclude jh_lazy_for_each]
          }, (item: Banner, index: number) => `${index}_${item.getBannerImg().getImgSrcSm()}`)
        }
        // [StartExclude jh_lazy_for_each]
        .displayCount(this.currentWidthBreakpoint === 'sm' ? 1 : 2)
        // Interval between banner images
        .itemSpace('12vp')
        .cachedCount(3)
        .prevMargin(new BreakpointType("0vp",
          "12vp", "64vp")
          .getValue(this.currentWidthBreakpoint))
        .nextMargin(new BreakpointType("0vp",
          "12vp", "64vp")
          .getValue(this.currentWidthBreakpoint))
        // [End swiper1_lazyforeach]
        // Setting the navigation point Style of the swiper.
        .indicator(this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_SM ? Indicator.dot()
          .itemWidth($r('app.float.swiper_item_size'))
          .itemHeight($r('app.float.swiper_item_size'))
          .selectedItemWidth($r('app.float.swiper_selected_item_width'))
          .selectedItemHeight($r('app.float.swiper_item_size'))
          .color($r('app.color.swiper_indicator'))
          .bottom($r('app.float.indicator_bottom'))
          .selectedColor(Color.White) : false
        )
        .loop(true)
        .width('100%')
        .visibility((this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG) &&
          (this.currentTopIndex === 1) ? Visibility.None : Visibility.Visible)
        .effectMode(EdgeEffect.None)
        // The sizes of the front and rear banners on the MD and LG devices are different.
        .index(2)
        // [EndExclude jh_lazy_for_each]
        .tabIndex(getTabIndex('Banner'))
        .onAnimationStart((index: number, targetIndex: number) => {
        })
        // [End jh_lazy_for_each]
        // Switch the tab to switch the banner display effect.

        // [Start home_constants]
        Row({ space: '12vp' }) {
          this.BannerText(this.bannerImgList[2], 0, 4)
          this.BannerText(this.bannerImgList[1], 1, 4)

          Column({ space: '12vp' }) {
            this.BannerText(this.bannerImgList[0], 2)
            this.BannerText(this.bannerImgList[4], 3)
          }
          .layoutWeight(3)
        }
        .height(this.getBannerNewHeight(this.windowWidth))
        .width('100%')
        .visibility((this.currentWidthBreakpoint === 'lg') &&
          (this.currentTopIndex === 1) ? Visibility.Visible : Visibility.None)
        .padding({
          left: $r('app.float.banner_padding_sm'),
          right: $r('app.float.banner_padding_sm')
        })
        // [End home_constants]
      }
      .width('100%')
      .visibility(this.currentTopIndex === 2 ? Visibility.None : Visibility.Visible)

      Row() {
        // Immersive layout.
        Column() {
          Text(this.bannerImgList[2].getDescription().getIsLeftCenter().getValue(this.currentWidthBreakpoint) ?
            `${this.bannerImgList[2].getDescription().getDescription()[0]}${this.bannerImgList[2].getDescription()
              .getDescription()[1]}` : this.bannerImgList[2].getDescription().getDescription()[0])
            .fontSize(new BreakpointType($r('app.float.immersive_text_1_font_sm'), $r('app.float.immersive_text_1_font_md'), $r('app.float.immersive_text_1_font_lg')).getValue(this.currentWidthBreakpoint))
            .fontWeight(this.bannerImgList[2].getDescription().getFontWeight()[0])
            .lineHeight(new BreakpointType($r('app.float.immersive_text_1_line_sm'), $r('app.float.immersive_text_1_line_md'), $r('app.float.immersive_text_1_line_lg')).getValue(this.currentWidthBreakpoint))
            .fontColor(Color.White)
            .letterSpacing('1vp')
            .maxLines(1)

          Text(this.bannerImgList[2].getDescription().getDescription()[1])
            .fontSize(new BreakpointType($r('app.float.immersive_text_1_font_sm'), $r('app.float.immersive_text_1_font_md'), $r('app.float.immersive_text_1_font_lg')).getValue(this.currentWidthBreakpoint))
            .fontWeight(this.bannerImgList[2].getDescription().getFontWeight()[0])
            .lineHeight(new BreakpointType($r('app.float.immersive_text_1_line_sm'), $r('app.float.immersive_text_1_line_md'), $r('app.float.immersive_text_1_line_lg')).getValue(this.currentWidthBreakpoint))
            .fontColor(Color.White)
            .letterSpacing('1vp')
            .maxLines(1)
            .visibility(this.bannerImgList[2].getDescription().getIsLeftCenter().getValue(this.currentWidthBreakpoint) ?
            Visibility.None : Visibility.Visible)

          Text(this.bannerImgList[2].getDescription().getDescription()[2])
            .fontSize(new BreakpointType($r('app.float.immersive_text_2_font_sm'), $r('app.float.immersive_text_2_font_md'), $r('app.float.immersive_text_2_font_lg')).getValue(this.currentWidthBreakpoint))
            .fontWeight(this.bannerImgList[2].getDescription().getFontWeight()[1])
            .lineHeight(new BreakpointType($r('app.float.immersive_text_2_line_sm'), $r('app.float.immersive_text_2_line_md'), $r('app.float.immersive_text_2_line_lg')).getValue(this.currentWidthBreakpoint))
            .fontColor(Color.White)
            .margin({
              top: this.bannerImgList[2].getDescription().getTopPosition().getValue(this.currentWidthBreakpoint)[1]
            })
            .letterSpacing('3vp')
            .maxLines(1)
        }
        .padding({
          left: new BreakpointType($r('app.float.immersive_col_padding_left_sm'), $r('app.float.immersive_col_padding_left_md'), $r('app.float.immersive_col_padding_left_lg')).getValue(this.currentWidthBreakpoint),
          top: new BreakpointType($r('app.float.immersive_col_padding_top_sm'), $r('app.float.immersive_col_padding_top_md'), $r('app.float.immersive_col_padding_top_lg')).getValue(this.currentWidthBreakpoint)
        })
        .height('100%')
        .width('100%')
        .alignItems(new BreakpointType(true, false, false).getValue(this.currentWidthBreakpoint) ?
        HorizontalAlign.Center : HorizontalAlign.Start)
        .justifyContent(!this.bannerImgList[2].getDescription().getIsTopCenter().getValue(this.currentWidthBreakpoint) ?
        FlexAlign.Start : FlexAlign.Center)
      }
      .margin({
        top: $r('app.float.immersive_col_margin')
      })
      .padding({
        left: $r('app.float.home_content_padding'),
        right: $r('app.float.home_content_padding')
      })
      .height(new BreakpointType($r('app.float.immersive_banner_height_sm'), $r('app.float.immersive_banner_height_md'), $r('app.float.immersive_banner_height_lg')).getValue(this.currentWidthBreakpoint))
      .width('100%')
      .visibility(this.currentTopIndex === 2 ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .padding({
      left: this.currentWidthBreakpoint === 'sm' && this.currentTopIndex === 2 ? $r('app.float.side_bar_width') : 0
    })
  }

  getBannerNewHeight(windowWidth: number): string {
    // Obtain the window width and subtract the blank parts on both sides.
    let result: number = this.getUIContext().px2vp(windowWidth) - new BreakpointType(32, 48, 64).getValue(this.currentWidthBreakpoint) - 96;
    // Calculate the width of a single image based on the percent.
    result = (result - 12 * 2) * 4 / 11;
    // Calculate the total height of the grid layout.
    return result / 1.5 + 'vp';
  }
  @Builder
  BannerText(banner: Banner = new BannerViewModel().getBannerList()[0], index: number = 0, layoutWeight: number = 1){
    Stack() {
      Image(((index === 0) || (index === 1)) ? banner.getBannerImg().getImgSrcSm() :
        banner.getBannerImg().getImgSrc())
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
        .hoverEffect(HoverEffect.Scale)
        .borderRadius($r('app.float.banner_img_border_radius'))

      Column() {
        Text(banner.getDescription().getIsLeftCenter().getValue(this.currentWidthBreakpoint) ?
          `${banner.getDescription().getDescription()[0]}${banner.getDescription().getDescription()[1]}` :
          banner.getDescription().getDescription()[0])
          .fontSize(banner.getDescription().getFontSize().getValue(this.currentWidthBreakpoint)[0])
          .fontWeight(banner.getDescription().getFontWeight()[0])
          .lineHeight(banner.getDescription().getLineHeight().getValue(this.currentWidthBreakpoint)[0])
          .fontColor(Color.White)
          .letterSpacing('1vp')
          .maxLines(1)
        Text(banner.getDescription().getDescription()[1])
          .fontSize(banner.getDescription().getFontSize().getValue(this.currentWidthBreakpoint)[0])
          .fontWeight(banner.getDescription().getFontWeight()[0])
          .lineHeight(banner.getDescription().getLineHeight().getValue(this.currentWidthBreakpoint)[0])
          .fontColor(Color.White)
          .letterSpacing('1vp')
          .maxLines(1)
          .visibility(banner.getDescription().getIsLeftCenter().getValue(this.currentWidthBreakpoint) ?
            Visibility.None : Visibility.Visible)

        Text(banner.getDescription().getDescription()[2])
          .fontSize(banner.getDescription().getFontSize().getValue(this.currentWidthBreakpoint)[1])
          .fontWeight(banner.getDescription().getFontWeight()[1])
          .lineHeight(banner.getDescription().getLineHeight().getValue(this.currentWidthBreakpoint)[1])
          .fontColor(Color.White)
          .margin({ top: banner.getDescription().getTopPosition().getValue(this.currentWidthBreakpoint)[1] })
          .letterSpacing(HomeConstants.BANNER_TEXT_LETTER_SPACES[1])
          .maxLines(1)
      }
      .padding({
        left: !banner.getDescription().getIsLeftCenter().getValue(this.currentWidthBreakpoint) ?
          banner.getDescription().getLeftPosition().getValue(this.currentWidthBreakpoint)[0] : '0',
        top: !banner.getDescription().getIsTopCenter().getValue(this.currentWidthBreakpoint) ?
          banner.getDescription().getTopPosition().getValue(this.currentWidthBreakpoint)[0] : '0'
      })
      .alignItems(banner.getDescription().getIsLeftCenter().getValue(this.currentWidthBreakpoint) ?
        HorizontalAlign.Center : HorizontalAlign.Start)
      .justifyContent(!banner.getDescription().getIsTopCenter().getValue(this.currentWidthBreakpoint) ?
        FlexAlign.Start : FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
    .layoutWeight(layoutWeight)
  }

  @Builder
  BannerItem(item: Banner, index: number){
    Stack() {
      // [StartExclude swiper1_lazyforeach]
      // [EndExclude jh_lazy_for_each]
      Image(this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_SM ? item.getBannerImg().getImgSrcSm() :
        item.getBannerImg().getImgSrc())
        .objectFit(ImageFit.Fill)
        .borderRadius($r('app.float.banner_img_border_radius'))
        .height('100%')
        .width('100%')
        .focusable(true)
        .zIndex(1)
      // [StartExclude jh_lazy_for_each]
      Column() {
        Text(item.getDescription().getIsLeftCenter().getValue(this.currentWidthBreakpoint) ?
          `${item.getDescription().getDescription()[0]}${item.getDescription().getDescription()[1]}` :
          item.getDescription().getDescription()[0])
          .fontSize(item.getDescription().getFontSize().getValue(this.currentWidthBreakpoint)[0])
          .fontWeight(item.getDescription().getFontWeight()[0])
          .lineHeight(item.getDescription().getLineHeight().getValue(this.currentWidthBreakpoint)[0])
          .fontColor(Color.White)
          .letterSpacing('1vp')
          .maxLines(1)

        Text(item.getDescription().getDescription()[1])
          .fontSize(item.getDescription().getFontSize().getValue(this.currentWidthBreakpoint)[0])
          .fontWeight(item.getDescription().getFontWeight()[0])
          .lineHeight(item.getDescription().getLineHeight().getValue(this.currentWidthBreakpoint)[0])
          .fontColor(Color.White)
          .letterSpacing('1vp')
          .maxLines(1)
          .visibility(item.getDescription().getIsLeftCenter().getValue(this.currentWidthBreakpoint) ?
            Visibility.None : Visibility.Visible)

        Text(item.getDescription().getDescription()[2])
          .fontSize(item.getDescription().getFontSize().getValue(this.currentWidthBreakpoint)[1])
          .fontWeight(item.getDescription().getFontWeight()[1])
          .lineHeight(item.getDescription().getLineHeight().getValue(this.currentWidthBreakpoint)[1])
          .fontColor(Color.White)
          .margin({
            top: item.getDescription().getTopPosition().getValue(this.currentWidthBreakpoint)[1]
          })
          .letterSpacing(HomeConstants.BANNER_TEXT_LETTER_SPACES[1])
          .maxLines(1)
      }
      .padding({
        left: !item.getDescription().getIsLeftCenter().getValue(this.currentWidthBreakpoint) ?
          item.getDescription().getLeftPosition().getValue(this.currentWidthBreakpoint)[0] : '0',
        top: !item.getDescription().getIsTopCenter().getValue(this.currentWidthBreakpoint) ?
          item.getDescription().getTopPosition().getValue(this.currentWidthBreakpoint)[0] : '0'
      })
      .alignItems(item.getDescription().getIsLeftCenter().getValue(this.currentWidthBreakpoint) ?
        HorizontalAlign.Center : HorizontalAlign.Start)
      .justifyContent(!item.getDescription().getIsTopCenter().getValue(this.currentWidthBreakpoint) ?
        FlexAlign.Start : FlexAlign.Center)
      .height('100%')
      .width('100%')
      .zIndex(2)
      // [EndExclude swiper1_lazyforeach]
    }
    .height(item.getBannerImg().getHeight().getValue(this.currentWidthBreakpoint))
    .width('100%')
    // The width and height vary with the container assembly and the aspect ratio remains unchanged.
    .aspectRatio(new BreakpointType(1.49, 1.6,
      2.1).getValue(this.currentWidthBreakpoint))
    .groupDefaultFocus(index === 0 ? true : false)
    .focusable(true)
    .padding({
      top: $r('app.float.banner_margin'),
      bottom: $r('app.float.banner_margin'),
      left: this.currentWidthBreakpoint === 'sm' ? $r('app.float.banner_padding_sm') : 0,
      right: this.currentWidthBreakpoint === 'sm' ? $r('app.float.banner_padding_sm') : 0
    })

  }
}
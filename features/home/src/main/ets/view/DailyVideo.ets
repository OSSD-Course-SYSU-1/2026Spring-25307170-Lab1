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

import { BreakpointType } from 'base';
import { VideoImage, VideoImgViewModel } from '../viewmodel/VideoImgViewModel';
import { getTabIndex, SubtitleComponent, VideoImgComponent, VideoImgPlay, VideoImgRating } from './CommonView';

@Component
export struct DailyVideo {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'lg';
  @StorageLink('windowWidth') windowWidth: number = 0;
  @StorageLink('currentTopIndex') currentTopIndex: number = 0;
  @State isShowingMainBorder: boolean = false;
  private dailyVideoImgList: VideoImage[] = new VideoImgViewModel().getDailyVideoImgList();
  private mainDailyVideoImg: VideoImage = new VideoImgViewModel().getMainDailyVideoImg();

  build() {
    // [Start sub_title_component]
    Column() {
      SubtitleComponent({ title: '每日佳片' })

      GridRow({
        columns: { sm: 4, md: 12, lg: 12 },
        gutter: '12vp'
      }) {
        // Main video section.
        GridCol({ span: { sm: 4, md: 6, lg: 6 } }) {
          Column() {
            // [StartExclude sub_title_component]
            Stack({ alignContent: Alignment.Bottom }) {
              Image(this.mainDailyVideoImg.getImgSrc() ? this.mainDailyVideoImg.getImgSrc() : '')
                .focusable(true)
                .objectFit(ImageFit.Fill)
                .width('100%')
                .height('100%')
                .draggable(false)
                .borderRadius({
                  topLeft: '18vp',
                  topRight: '18vp'
                })
              VideoImgPlay()

              Row() {
                Text(this.mainDailyVideoImg.getTitle())
                  .fontSize(this.currentWidthBreakpoint === 'lg' ? '20fp' : '16fp')
                  .fontColor(Color.White)
                  .fontWeight(700)
                  .margin({ left: this.currentWidthBreakpoint === 'lg' ? '16vp' : '12vp' })
                  .layoutWeight(1)
                  .maxLines(1)

                Text(this.mainDailyVideoImg.getRating())
                  .fontSize(this.currentWidthBreakpoint === 'lg' ? '12fp' : '8fp')
                  .fontWeight(FontWeight.Normal)
                  .fontColor(Color.White)
                  .height(this.currentWidthBreakpoint === 'lg' ? '18vp' : '12vp')
                  .width(this.currentWidthBreakpoint === 'lg' ? '30vp' : '20vp')
                  .margin({
                    right: this.currentWidthBreakpoint === 'lg'? '16vp' : '12vp',
                    top: this.currentWidthBreakpoint === 'lg' ? '6vp' : '5vp'
                  })
                  .backgroundColor('#4D000000')
                  .borderRadius(this.currentWidthBreakpoint === 'lg' ? '3vp' : '2vp')
                  .textAlign(TextAlign.Center)
              }
              .alignItems(VerticalAlign.Top)
              .justifyContent(FlexAlign.Start)
              .width('100%')
              .height(this.currentWidthBreakpoint === 'lg' ? '46vp' : '33vp')
            }
            .width('100%')
            .layoutWeight(5)

            Row() {
              // [Start daily_small_video]
              Image($r('app.media.daily_small_video'))
                .height(new BreakpointType('40vp', '44vp', '68vp').getValue(this.currentWidthBreakpoint))
                .width(new BreakpointType('76vp', '84vp', '129vp').getValue(this.currentWidthBreakpoint))
                .borderRadius('8vp')
              // [End daily_small_video]

              Column() {
                // [Start dd_main_daily_video_img]
                Text(this.mainDailyVideoImg.getOtherInfo())
                  .fontSize(this.currentWidthBreakpoint === 'lg' ? '16vp' : '14vp')
                    // [End dd_main_daily_video_img]
                  .fontWeight(FontWeight.Normal)
                  .maxLines(1)
                Text(this.mainDailyVideoImg.getContent())
                  .opacity(0.4)
                  .fontSize(this.currentWidthBreakpoint === 'lg' ? '14vp' : '12vp')
                  .fontWeight(FontWeight.Normal)
                  .maxLines(1)
              }
              .margin({
                left: this.currentWidthBreakpoint === 'lg' ? '16vp': '12vp',
                right: this.currentWidthBreakpoint === 'lg' ? '16vp': '12vp'
              })
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Button('关注')
                .fontSize(this.currentWidthBreakpoint === 'lg' ? '14fp': '12fp')
                .fontColor('#ED6F21')
                .fontWeight(500)
                .height(this.currentWidthBreakpoint === 'lg' ? '34vp' : '34vp')
                .width(this.currentWidthBreakpoint === 'lg' ? '77vp' : '77vp')
                .borderRadius('16vp')
                .backgroundColor('#0D000000')
            }
            .alignItems(VerticalAlign.Center)
            .padding({
              left: this.currentWidthBreakpoint === 'lg' ? '16vp' : '12vp',
              right: this.currentWidthBreakpoint === 'lg' ? '16vp' : '12vp'
            })
            .layoutWeight(2)
            // [EndExclude sub_title_component]
          }
          .tabIndex(getTabIndex('DailyVideoOne'))
          .width('100%')
          // Dynamically setting the height at different breakpoints.
          .height(this.getDailyVideoHeight(this.currentWidthBreakpoint, this.windowWidth, true))
          .borderRadius('36vp')
          .backgroundColor('#F1F3F5')
        }
        .padding({
          top: '13vp',
          bottom: this.currentWidthBreakpoint !== 'sm' ? '13vp' : 0,
          left: new BreakpointType('16vp', '24vp', '36vp').getValue(this.currentWidthBreakpoint),
          right: this.currentWidthBreakpoint === 'sm' ? '16vp' : 0
        })

        // Sub video section.
        GridCol({ span: { sm: 4, md: 6, lg: 6 } }) {
          Grid() {
            ForEach(this.dailyVideoImgList, (item: VideoImage) => {
              GridItem() {
                Column() {
                  Stack({ alignContent: Alignment.Bottom }) {
                    VideoImgComponent(0, item.getImgSrc())
                    VideoImgPlay()
                    VideoImgRating(item.getRating())
                  }
                  .width('100%')
                  // The width and height vary with the container assembly and the aspect ratio remains unchanged.
                  .aspectRatio(1.74)
                  // [StartExclude sub_title_component]
                  Text(item.getTitle())
                    .fontSize(this.currentWidthBreakpoint === 'lg' ? '16fp' : '14fp')
                    .fontWeight(FontWeight.Normal)
                    .lineHeight(this.currentWidthBreakpoint === 'lg' ? '24vp' : '21vp')
                    .margin({ top: '4vp' })
                    .fontColor(this.currentTopIndex === 2 ? Color.White : '#182431')

                  Text(item.getContent())
                    .fontSize('12fp')
                    .fontWeight(FontWeight.Normal)
                    .lineHeight('18vp')
                    .margin({ top: '2vp' })
                    .opacity(0.4)
                    .fontColor(this.currentTopIndex === 2 ? Color.White : '#182431')
                    .visibility(this.currentWidthBreakpoint === 'sm' ? Visibility.Visible : Visibility.None)
                  // [EndExclude sub_title_component]
                }
                .alignItems(HorizontalAlign.Start)
              }
            }, (item: VideoImage, index: number) => index + JSON.stringify(item))
          }
          .tabIndex(getTabIndex('DailyVideoTwo'))
          // Dynamically setting the height at different breakpoints.
          .height(this.getDailyVideoHeight(this.currentWidthBreakpoint, this.windowWidth, false))
          .width('100%')
          // Sets the number of grid layout columns and evenly divides the height.
          .columnsTemplate('1fr 1fr')
          .rowsTemplate('1fr 1fr')
          .rowsGap('12vp')
          .columnsGap('12vp')
          .padding({
            top: this.currentWidthBreakpoint !== 'sm' ? '13vp' : '6vp',
            bottom: this.currentWidthBreakpoint !== 'sm' ? '13vp' : '6vp',
            left: this.currentWidthBreakpoint === 'sm' ? '16vp' : '6vp',
            right: new BreakpointType('16vp', '24vp', '36vp').getValue(this.currentWidthBreakpoint)
          })
        }
      }
    }
    .padding({ left: this.currentWidthBreakpoint === 'lg' && this.currentTopIndex === 2 ? '96vp' : 0 })
    .margin({ top: '12vp' })
    // [End sub_title_component]
  }

  getDailyVideoHeight(currentWidthBreakpoint: string, windowWidth: number, isMain: boolean): string {
    // Obtain the window width and subtract the blank parts on both sides.
    let result: number = this.getUIContext().px2vp(windowWidth) - new BreakpointType(32,
      48, 64).getValue(this.currentWidthBreakpoint) - 12;
    // Calculate the width of a single image based on the number of grid columns.
    if (currentWidthBreakpoint === 'lg') {
      result = (result - 96) / 2;
    } else if (currentWidthBreakpoint === 'md') {
      result /= 2;
    } else {
      result /= 1;
    }
    // Calculate the height of a single image and title, and calculate the total height of the grid layout.
    result = (result - 12) / 1.74;
    if (currentWidthBreakpoint === 'sm') {
      if (isMain) {
        return (result + 103 + 'vp');
      } else {
        return (result + 115 + 'vp');
      }
    } else {
      if (!isMain) {
        return (result + 88 + 'vp');
      } else {
        return (result + 62 + 'vp');
      }
    }
  }
}
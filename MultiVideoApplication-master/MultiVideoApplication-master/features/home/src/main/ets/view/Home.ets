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
* 最佳实践: 平板开发实践
*/

import { deviceInfo } from '@kit.BasicServicesKit';
import { SearchView } from 'search';
import { CommonConstants } from 'base';
import { FooterTab, FooterTabViewModel } from '../viewmodel/FooterTabViewModel';
import { HomeHeader } from './HomeHeader';
import { HomeContent } from './HomeContent';

@Component
export struct Home {
  @State currentBottomIndex: number = 0;
  @State isSearching: boolean = false;
  @StorageLink('scrollHeight') scrollHeight: number = 0;
  @StorageLink('currentTopIndex') currentTopIndex: number = 0;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'lg';
  private tabList: FooterTab[] = new FooterTabViewModel().getTabList();
  private scroller: Scroller = new Scroller();
  private sideScroller: Scroller = new Scroller();

  @Builder
  BottomTabBuilder(item: FooterTab, index: number) {
    Column() {
      Image(index !== this.currentBottomIndex ? (this.currentTopIndex === 2 && this.currentBottomIndex === 0 &&
        !this.isSearching ? item.getIconWhite() : item.getIcon()) : item.getIconSelected())
        .width('24vp')
        .height('24vp')
      Text(item.getName())
        .fontSize('10fp')
        .fontWeight(500)
        .fontColor(index === this.currentBottomIndex ? '#ED6F21' : (this.currentTopIndex === 2 &&
          this.currentBottomIndex === 0 && !this.isSearching ? Color.White : Color.Black))
        .margin({ top: '4vp' })
        .opacity(index === this.currentBottomIndex ? 1 : 0.4)
    }
    .padding({ bottom: this.currentWidthBreakpoint !== 'lg' && deviceInfo.deviceType !==
      '2in1' ? '24vp' : 0 })
    .height(this.currentWidthBreakpoint === 'lg' ? '100vp' :
      '100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    // [Start tabs_barposition]
    Tabs({
      barPosition: this.currentWidthBreakpoint === 'lg' ? BarPosition.Start : BarPosition.End
    }) {
      // [StartExclude tabs_barposition]
      // [Start tab_content]
      TabContent() {
        if (this.currentTopIndex === 2) {
          // The immersive design of the home page is displayed when the top tab is switched to 2.
          Stack() {
            Scroll(this.sideScroller) {
              Column() {
                HomeContent()
                  .visibility(!this.isSearching ? Visibility.Visible : Visibility.None)

                SearchView({ isSearching: $isSearching })
                  .visibility(!this.isSearching ? Visibility.None : Visibility.Visible)
              }
              .width('100%')
            }
            .scrollBar(BarState.Off)
            .height('100%')
            // Obtains the sliding offset on the y axis during sliding.
            .onScrollFrameBegin((offset: number) => {
              this.scrollHeight = this.sideScroller.currentOffset().yOffset;
              return { offsetRemain: offset }
            })

            HomeHeader({ isSearching: $isSearching })
              .visibility(!this.isSearching ? Visibility.Visible : Visibility.None)
              .padding({ left: this.currentWidthBreakpoint === 'lg' ? '96vp' : 0 })
          }
          .height('100%')
          .width('100%')
          .alignContent(Alignment.Top)
        } else {
          // Non-immersive design for the home page.
          Column() {
            HomeHeader({ isSearching: $isSearching })
              .visibility(!this.isSearching ? Visibility.Visible : Visibility.None)

            Scroll(this.scroller) {
              Column() {
                HomeContent()
                  .visibility(!this.isSearching ? Visibility.Visible : Visibility.None)

                SearchView({ isSearching: $isSearching })
                  .visibility(!this.isSearching ? Visibility.None : Visibility.Visible)
              }
              .width('100%')
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          }
          .height('100%')
          .width('100%')
        }
      }
      .tabBar(this.BottomTabBuilder(this.tabList[0], 0))
      // [End tab_content]

      TabContent() {
        Column()
      }
      .tabBar(this.BottomTabBuilder(this.tabList[1], 1))

      TabContent() {
        Column()
      }
      .tabBar(this.BottomTabBuilder(this.tabList[2], 2))

      TabContent() {
        Column()
      }
      .tabBar(this.BottomTabBuilder(this.tabList[3], 3))
      // [EndExclude tabs_barposition]
    }
    // Change the position and size of the tab at the bottom.
    .barWidth(this.currentWidthBreakpoint === 'lg' ? '96vp' : '100%')
    .barHeight(this.currentWidthBreakpoint === 'lg' ? '100%' : (deviceInfo.deviceType === '2in1' ? '56vp' : '76vp'))
    .barMode(this.currentWidthBreakpoint === 'lg' ? BarMode.Scrollable : BarMode.Fixed,
      { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
    .vertical(this.currentWidthBreakpoint === 'lg')
    // [End tabs_barposition]
    .barOverlap(this.currentWidthBreakpoint === 'lg' && this.currentTopIndex === 2 ? true : false)
    .barBackgroundBlurStyle(BlurStyle.NONE)
    .barBackgroundColor(this.currentTopIndex === 2 && this.currentBottomIndex === 0 ?
      (this.currentWidthBreakpoint === 'lg' ? '#0DFFFFFF' : '#222A3E') : '#F1F3F5')
    .onChange((index: number) => {
      this.currentBottomIndex = index;
    })
    .scrollable(false)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .height('100%')
    .width('100%')
  }
}
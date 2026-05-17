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
import { BreakpointConstants, CommonConstants } from 'base';
import { BreakpointType } from 'base';
import { HomeConstants } from '../constants/HomeConstants';
import { getTabIndex } from './CommonView';

@Component
export struct HomeHeader {
  @State isShowingBorder: boolean = false;
  @Link isSearching: boolean;
  @StorageLink('scrollHeight') scrollHeight: number = 0;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string =  'lg';
  @StorageLink('currentTopIndex') currentTopIndex: number = 0;

  // [Start Home_Header]
  // [Start build_column]
  build() {
    Column() {
      GridRow({ columns: { sm: 4, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 4, md: 7, lg: 7 } }) {
          this.TopTabBar()
        }
        .padding({ top: deviceInfo.deviceType === '2in1' ? 0 : $r('app.float.search_top_padding_top') })
        .height(deviceInfo.deviceType === '2in1' ? $r('app.float.search_top_height') : $r('app.float.search_top_height_more'))

        GridCol({ span: { sm: 4, md: 5, lg: 5 } }) {
          this.searchBar()
        }
        .padding({ top: this.currentWidthBreakpoint === 'sm' || deviceInfo.deviceType === '2in1' ? 0 : $r('app.float.search_top_padding_top') })
        .height(this.currentWidthBreakpoint === 'sm' || deviceInfo.deviceType === '2in1' ? $r('app.float.search_top_height') : $r('app.float.search_top_height_more'))
      }
      // The background color of the top tab bar is changed during the slide-down process.
      .backgroundColor(this.scrollHeight >= new BreakpointType(HomeConstants.BACKGROUND_CHANGE_HEIGHT[0],
        HomeConstants.BACKGROUND_CHANGE_HEIGHT[1], HomeConstants.BACKGROUND_CHANGE_HEIGHT[2])
        .getValue(this.currentWidthBreakpoint) && this.currentTopIndex === 2 ? $r('app.color.home_content_background') :
        Color.Transparent)
    }
    .width('100%')
  }
  // [End build_column]
  // [End Home_Header]

  // [Start top_tab_bar]
  @Builder
  TopTabBar() {
    Row() {
      Column() {
        List() {
          // [StartExclude top_tab_bar]
          ForEach(HomeConstants.TOP_TOPIC_LIST, (item: string, index: number) => {
            ListItem() {
              Text(item)
                .fontSize(this.currentTopIndex === index ? $r('app.float.search_tab_font_selected') : $r('app.float.search_tab_font'))
                .fontWeight(this.currentTopIndex === index ? 700 : 500)
                .width(this.currentTopIndex === index ? '70vp' : '66vp')
                .textAlign(TextAlign.Center)
                .fontColor(this.currentTopIndex === 2 ? Color.White : $r('app.color.normal_font_color'))
                .lineHeight(index === this.currentTopIndex ? $r('app.float.top_tab_list_height_selected') : $r('app.float.top_tab_list_height'))
                .focusable(true)
                .groupDefaultFocus(index === 0 ? true : false)
                .borderRadius($r('app.float.text_focus_radius'))
            }
            .align(Alignment.Center)
            .margin({
              top: this.currentTopIndex === index ? $r('app.float.top_tab_list_top_selected') : $r('app.float.top_tab_list_top'),
              bottom: this.currentTopIndex === index ? $r('app.float.top_tab_list_bottom_selected') : $r('app.float.top_tab_list_bottom')
            })
            .padding({
              left: new BreakpointType(8, 12, 18).getValue(this.currentWidthBreakpoint),
              right: new BreakpointType(8, 12, 18).getValue(this.currentWidthBreakpoint)
            })
            .onClick(() => {
              this.currentTopIndex = index;
              this.scrollHeight = 0;
            })
          }, (item: number, index: number) => index + JSON.stringify(item))
          // [EndExclude top_tab_bar]
        }
        .tabIndex(getTabIndex(HomeConstants.DIRECTION_LIST[1]))
        .scrollBar(BarState.Off)
        .listDirection(Axis.Horizontal)
        .padding({ left: $r('app.float.search_top_padding') })
      }
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)
      // [StartExclude top_tab_bar]
      Image($r('app.media.ic_public_more'))
        .width($r('app.float.top_tab_img_size'))
        .height($r('app.float.top_tab_img_size'))
        .margin({
          left: $r('app.float.top_tab_img_margin'),
          right: $r('app.float.top_tab_img_margin')
        })
        .fillColor(this.currentTopIndex === 2 ? Color.White : Color.Black)
        .visibility(this.currentWidthBreakpoint === 'sm' ? Visibility.Visible : Visibility.None)
      // [StartExclude top_tab_bar]
    }
    .height($r('app.float.top_bar_height'))
    .width('100%')
  }
  // [End top_tab_bar]

  // [Start search_bar]
  @Builder
  searchBar() {
    Row() {
      Stack({ alignContent: Alignment.Start }) {
        // [StartExclude search_bar]
        TextInput({ placeholder: HomeConstants.SEARCH_PLACEHOLDER })
          .placeholderFont({
            size: $r('app.float.search_input_font'),
            weight: FontWeight.Normal
          })
          .placeholderColor(this.currentTopIndex === 2 ? Color.White : $r('app.color.normal_font_color'))
          .height($r('app.float.search_input_height'))
          .fontSize($r('app.float.search_input_font'))
          .padding({
            left: $r('app.float.search_input_left'),
            right: $r('app.float.search_input_right')
          })
          .width('100%')
          .onClick(() => {
            this.isSearching = true;
          })
          .onSubmit((enterKey: EnterKeyType) => {
            if (enterKey === EnterKeyType.Go) {
              this.isSearching = true;
            }
          })
          .enterKeyType(EnterKeyType.Go)
          .enableKeyboardOnFocus(false)
          .backgroundColor(this.currentTopIndex === 2 ? $r('app.color.search_bar_background') : '')
          .tabIndex(getTabIndex(HomeConstants.DIRECTION_LIST[1]))
          .focusable(false)

        // Search image.
        Image(this.currentTopIndex === 2 ? $r("app.media.ic_public_search_white") :
          $r('app.media.ic_public_search'))
          .width($r('app.float.search_img_size'))
          .height($r('app.float.search_img_size'))
          .margin({ left: $r('app.float.search_img_left') })
        // [EndExclude search_bar]
      }
      .alignSelf(ItemAlign.Center)
      .layoutWeight(1)
      // [StartExclude search_bar]
      // History image.
      Image(this.currentTopIndex === 2 ? $r('app.media.ic_public_history_white') : $r('app.media.ic_public_history'))
        .width($r('app.float.history_img_size'))
        .height($r('app.float.history_img_size'))
        .margin({ left: $r('app.float.history_img_left') })

      Image(this.currentTopIndex === 2 ? $r('app.media.ic_public_more_white') : $r('app.media.ic_public_more'))
        .width($r('app.float.history_img_size'))
        .height($r('app.float.history_img_size'))
        .margin({ left: $r('app.float.history_img_left') })
        .visibility(this.currentWidthBreakpoint === 'sm' ? Visibility.None : Visibility.Visible)
      // [EndExclude search_bar]
    }
    .padding({
      left: $r('app.float.search_top_padding'),
      right: $r('app.float.search_top_padding')
    })
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
  // [End search_bar]
}
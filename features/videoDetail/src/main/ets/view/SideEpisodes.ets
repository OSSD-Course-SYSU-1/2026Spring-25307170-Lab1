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
import { BreakpointConstants, CommonConstants } from 'base';
import { DetailConstants } from '../constants/DetailConstants';

@Component
export struct SideEpisodes {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('isFullScreen') isFullScreen: boolean = false;
  @Link isShowingSideBar: boolean;
  @Link foldStatus: display.FoldStatus;

  build() {
    Column() {
      // Episodes sidebar.
      Row() {
        Blank()
        this.SideTitleText(DetailConstants.PLAYER_TEXT_LIST[0], $r('app.float.side_title_width_1'))
        this.SideTitleText(DetailConstants.PLAYER_TEXT_LIST[1], $r('app.float.side_title_width_2'), CommonConstants.TEXT_OPACITY[2])

        Blank()
      }
      .width(CommonConstants.FULL_PERCENT)
      .margin({ bottom: this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
        $r('app.float.side_row_margin_sm') : $r('app.float.side_row_margin') })

      List({ space: CommonConstants.LIST_SPACE }) {
        ForEach(DetailConstants.PLAYER_EPISODE, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize($r('app.float.title_font'))
                .fontColor(index === 1 ? $r('app.color.font_selected') : Color.White)
                .fontWeight(FontWeight.Normal)

              Image($r('app.media.video_playing'))
                .height($r('app.float.playing_size'))
                .width($r('app.float.playing_size'))
                .position({
                  x: this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
                    $r('app.float.playing_position_x_side_lg') : $r('app.float.playing_position_x_side'),
                  y: this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
                    $r('app.float.playing_position_y_side_lg') : $r('app.float.playing_position_y_side')
                })
                .visibility(index === 1 ? Visibility.Visible : Visibility.None)
            }
            .justifyContent(FlexAlign.Center)
            .borderRadius($r('app.float.episode_row_radius'))
            .backgroundColor($r('app.color.episode_row_background'))
            .width(this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
              $r('app.float.episode_row_width_lg') : $r('app.float.episode_row_width_other'))
            .height(this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
              $r('app.float.episode_row_height_lg')  : $r('app.float.episode_row_height_other'))
          }
        }, (item: string, index: number) => index + JSON.stringify(item))
      }
      .layoutWeight(1)
      .width(CommonConstants.FULL_PERCENT)
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .lanes(DetailConstants.EPISODE_LIST_LANES[1], $r('app.float.lanes_item_space'))
      .padding({
        left: $r('app.float.episodes_sidebar_padding_left_right'),
        right: $r('app.float.episodes_sidebar_padding_left_right'),
        bottom: $r('app.float.episodes_sidebar_padding_bottom')
      })
    }
    .justifyContent(FlexAlign.Start)
    .backgroundColor(Color.Black)
    .layoutWeight(this.currentWidthBreakpoint !== BreakpointConstants.BREAKPOINT_LG ? 2 : 0)
    .height(CommonConstants.FULL_PERCENT)
    .width(this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.side_col_width') : 0)
    .visibility((this.isShowingSideBar && this.isFullScreen && (this.currentWidthBreakpoint ===
      BreakpointConstants.BREAKPOINT_LG || (this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_MD &&
      this.currentHeightBreakpoint === BreakpointConstants.BREAKPOINT_SM))) ? Visibility.Visible : Visibility.None)
  }
  @Builder
  SideTitleText(content: ResourceStr, width: ResourceStr, opacity: number = 1){
    Text(content)
      .fontSize($r('app.float.side_text_font'))
      .fontColor(Color.White)
      .fontWeight(FontWeight.Normal)
      .lineHeight($r('app.float.side_text_line'))
      .width(width)
      .opacity(opacity)
  }
}
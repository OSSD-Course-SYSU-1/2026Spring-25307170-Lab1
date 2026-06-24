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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointConstants, CommonConstants } from 'base';
import { BreakpointType } from 'base';
import { HomeConstants } from '../constants/HomeConstants';
import { IconViewModel, VideoIcon } from '../viewmodel/IconViewModel';
import { getTabIndex } from './CommonView';

@Component
export struct IconView {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowWidth') windowWidth: number = 0;
  @StorageLink('currentTopIndex') currentTopIndex: number = 0;
  private iconList: VideoIcon[] = new IconViewModel().getIconList();

  build() {
    Column() {
      List({ space: this.getSpace(this.windowWidth, this.currentWidthBreakpoint) }) {
        ForEach(this.iconList, (item: VideoIcon, index: number) => {
          ListItem() {
            Column() {
              Image(item.getImage())
                .width($r('app.float.icon_img_size'))
                .height($r('app.float.icon_img_size'))
                .margin({ bottom: $r('app.float.icon_img_bottom_margin') })
                .focusable(true)
                .groupDefaultFocus(index === 0 ? true : false)
                .borderRadius($r('app.float.icon_img_radius'))

              Text(item.getName())
                .fontSize($r('app.float.icon_list_font_size'))
                .fontWeight(FontWeight.Normal)
                .lineHeight($r('app.float.icon_list_font_height'))
                .fontColor(this.currentTopIndex === 2 ? Color.White : Color.Black)
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .height($r('app.float.icon_list_height'))
          }
          .padding({
            right: index === this.iconList.length - 1 ?
              this.getSpace(this.windowWidth, this.currentWidthBreakpoint) / 2 : 0
          })
        }, (item: VideoIcon) => JSON.stringify(item))
      }
      .clip(false)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .scrollSnapAlign(ScrollSnapAlign.START)
      .edgeEffect(EdgeEffect.None)
      .chainAnimation(true)
      .tabIndex(getTabIndex(HomeConstants.DIRECTION_LIST[3]))
      .width(CommonConstants.FULL_PERCENT)
    }
    .padding({
      left: new BreakpointType($r('app.float.home_content_padding_sm'), $r('app.float.home_content_padding_md'),
        $r('app.float.home_content_padding_lg')).getValue(this.currentWidthBreakpoint)
    })
    .margin({
      top: this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
        $r('app.float.icon_list_column_margin_lg') : 0
    })
    .visibility(this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG && this.currentTopIndex === 2 ?
      Visibility.None : Visibility.Visible)
  }

  getSpace(windowWidth: number, currentWidthBreakpoint: string): number {
    // Obtain the window width and subtract the blank parts on both sides.
    try {
      let result: number =
        this.getUIContext().px2vp(windowWidth) - (new BreakpointType(HomeConstants.VIDEO_GRID_MARGIN[0],
          HomeConstants.VIDEO_GRID_MARGIN[1],
          HomeConstants.VIDEO_GRID_MARGIN[2]).getValue(this.currentWidthBreakpoint) /
        HomeConstants.TWO) -
          this.getUIContext().getHostContext()!.resourceManager.getNumber($r('app.float.icon_img_size').id) / 2;
      if (currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_SM) {
        result = (result - HomeConstants.ICONVIEW_ITEM_WIDTH[0] * CommonConstants.FOUR) / CommonConstants.FOUR;
      } else if (currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_MD) {
        result = (result - HomeConstants.ICONVIEW_ITEM_WIDTH[1] * HomeConstants.SIX) / HomeConstants.SIX;
      } else {
        result =
          (result - HomeConstants.LG_SIDEBAR_WIDTH - HomeConstants.ICONVIEW_ITEM_WIDTH[2] * HomeConstants.EIGHT) /
          HomeConstants.EIGHT;
      }
      return result;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x00, 'IconView', `getNumber failed, code = ${err.code}, message = ${err.message}`);
    }
    return 0;
  }
}
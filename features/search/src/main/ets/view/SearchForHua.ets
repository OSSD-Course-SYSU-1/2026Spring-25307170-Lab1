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

import { BreakpointConstants } from 'base';
import { Logger } from 'base';
import { SearchConstants } from '../constants/SearchConstants';

@Component
export struct SearchForHua {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Link searchInput: string;

  build() {
    Column() {
      // [Start searchForHua]
      List() {
        // [StartExclude searchForHua]
        ForEach(SearchConstants.HUA_LIST, (item: string, index: number) => {
          ListItem() {
            Column() {
              Text(item)
                .fontSize('16fp')
                .fontWeight(500)
                .height('47.5vp')

              Divider()
                .color(Color.Black)
                .height('1vp')
                .opacity(0.05)
                .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ right: this.currentWidthBreakpoint === 'lg' && index % 2 === 0 ? '12vp' : 0 })
            .height('48vp')
            .onClick(() => {
              if (index === 3) {
                this.searchInput = item;
              } else {
                Logger.info(`Please click on the third list item`);
              }
            })
          }
        }, (item: string, index: number) => `${index}_${item}`)
        // [EndExclude searchForHua]
      }
      .lanes(this.currentWidthBreakpoint === 'lg' ? 2 : 1)
      // [End searchForHua]
    }
    .layoutWeight(1)
    .padding({ top: $r('app.float.search_hua_list_padding') })
  }
}
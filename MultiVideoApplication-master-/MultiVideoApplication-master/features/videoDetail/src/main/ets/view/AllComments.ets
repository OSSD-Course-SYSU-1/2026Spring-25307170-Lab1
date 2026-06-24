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
import { BreakpointType } from 'base';
import { DetailConstants } from '../constants/DetailConstants';
import { UserInfo, UserViewModel } from '../viewmodel/UserViewModel';

@Component
export struct AllComments {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Link commentImgHeight: string;
  @Link commentImgWidth: string;
  private commentsList: UserInfo[] = new UserViewModel().getRelatedVideoList();

  build() {
    Column() {
      Row() {
        this.TitleText(DetailConstants.SUB_TITLES[0])
      }
      .padding({
        left: $r('app.float.all_comments_title_row_padding'),
        right: $r('app.float.all_comments_title_row_padding')
      })
      .height($r('app.float.all_comments_title_row_height'))
      .width(CommonConstants.FULL_PERCENT)

      Column() {
        ForEach(this.commentsList, (item: UserInfo, index: number) => {
          Row() {
            Image(item.getImageSrc())
              .height($r('app.float.all_comments_profile_size'))
              .width($r('app.float.all_comments_profile_size'))
              .margin({ right: $r('app.float.all_comments_profile_margin') })

            this.TitleText(item.getName())
          }
          .height($r('app.float.all_comments_title_row_height'))
          .width(CommonConstants.FULL_PERCENT)
          .margin({ top: $r('app.float.all_comments_title_margin') })
          .alignItems(VerticalAlign.Center)

          Row() {
            Text(item.getComment())
              .margin({ left: $r('app.float.all_comments_comment_left') })
              .opacity(CommonConstants.TEXT_OPACITY[2])
              .fontSize( $r('app.float.all_comments_comment_font'))
              .lineHeight( $r('app.float.all_comments_comment_text_line'))
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
          }
          .margin({ top:  $r('app.float.all_comments_comment_row_top') })
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)

          Row() {
            // [Start get_comment_image_src]
            Image(item.getCommentImageSrc())
              .width(new BreakpointType('227vp', '254vp', this.commentImgWidth).getValue(this.currentWidthBreakpoint))
              .height(new BreakpointType('227vp', '254vp', this.commentImgHeight).getValue(this.currentWidthBreakpoint))
              .borderRadius('8vp')
              .aspectRatio(1.46)
            // [End get_comment_image_src]
          }
          .padding({ left:  $r('app.float.all_comments_img_row_padding') })
          .margin({ top:  $r('app.float.all_comments_img_row_margin') })
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)
          .visibility(!item.getCommentImageSrc() ? Visibility.None : Visibility.Visible)

          Row() {
            Text(item.getTime())
              .opacity(CommonConstants.TEXT_OPACITY[2])
              .fontSize($r('app.float.all_comments_comment_time_font'))
              .lineHeight($r('app.float.all_comments_comment_time_line'))
              .fontWeight(FontWeight.Normal)
              .margin({ left: $r('app.float.all_comments_comment_time_margin') })

            Blank()
            Row({ space: $r('app.float.all_comments_icon_margin') }){
              this.IconImage($r('app.media.ic_public_comments'))
              this.IconImage($r('app.media.ic_public_thumb_sup'))
              this.IconImage($r('app.media.ic_public_share'))
            }
          }
          .margin({ top: $r('app.float.all_comments_icon_row_top') })
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)

          Divider()
            .color(Color.Black)
            .opacity(CommonConstants.DIVIDER_OPACITY)
            .margin({
              top: $r('app.float.all_comments_divider_margin')
            })
            .height($r('app.float.all_comments_divider_height'))
            .width(CommonConstants.FULL_PERCENT)
            .visibility(index === this.commentsList.length - 1 ? Visibility.None : Visibility.Visible)
        }, (item: UserInfo, index: number) => index + JSON.stringify(item))
      }
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: $r('app.float.all_comments_comment_col_padding'),
        right: $r('app.float.all_comments_comment_col_padding')
      })
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  TitleText(content: ResourceStr) {
    Text(content)
      .fontSize($r('app.float.all_comments_title_text_font'))
      .lineHeight($r('app.float.all_comments_title_text_line'))
      .fontWeight(CommonConstants.FONT_WEIGHT_500)
  }

  @Builder
  IconImage(image: Resource | null = null){
    Image(image)
      .height($r('app.float.all_comments_icon_size'))
      .width($r('app.float.all_comments_icon_size'))
  }
}
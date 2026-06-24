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

import { componentUtils } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { BreakpointType, Logger, WindowUtil } from 'base';
import { HomeConstants } from '../constants/HomeConstants';
import { VideoImage, VideoImgViewModel } from '../viewmodel/VideoImgViewModel';
import { getTabIndex, VideoContent, VideoImgRating, VideoTitle } from './CommonView';
import { RightClickMenu, VideoDialog } from './VideoDialog';

@Component
export struct RecommendedVideo {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'lg';
  @StorageLink('videoGridColumn') videoGridColumn: string = '1fr 1fr';
  @StorageLink('windowWidth') windowWidth: number = 0;
  @StorageLink('currentTopIndex') currentTopIndex: number = 0;
  @State isShowingRecommendBorder: boolean = false;
  @State currentRecommendFocusIndex: number = 0;
  @State videoImgList: VideoImage[] = new VideoImgViewModel().getVideoImgList();
  private videoDialogController?: CustomDialogController;
  private windowUtil?: WindowUtil;

  // [Start build_grid]
  build() {
    // Video grid layout.
    // [Start grid_foreach]
    // [Start jh_tabindex_gettabindex]
    Grid() {
      // [StartExclude jh_tabindex_gettabindex]
      ForEach(this.videoImgList, (item: VideoImage, index: number) => {
        GridItem() {
          Column() {
            // [Start aligncontent]
            Stack({ alignContent: Alignment.Center }) {
              // [StartExclude aligncontent]
              // [StartExclude build_grid]
              // [Start jh_get_img_src]
              Image(item.getImgSrc())
                .objectFit(ImageFit.Fill)
                .width('100%')
                .height('100%')
                .hoverEffect(HoverEffect.Scale)
                  // [End jh_get_img_src]
                .focusable(true)
                .groupDefaultFocus(index === 0 ? true : false)
                .draggable(false)
                .borderRadius('16vp')
                .id(JSON.stringify(item))
              Column() {
                VideoImgRating(item.getRating())
              }
              .width('100%')
              .height('100%')
              .alignItems(HorizontalAlign.End)
              .justifyContent(FlexAlign.End)
              // [EndExclude build_grid]
              // [EndExclude aligncontent]
            }
            .focusable(true)
            .width('100%')
            // The width and height vary with the container assembly and the aspect ratio remains unchanged.
            .aspectRatio(HomeConstants.VIDEO_DIALOG_ASPECT_RATIO)
            // [StartExclude aligncontent]
            // [StartExclude build_grid]
            .hoverEffect(HoverEffect.Scale)
            // [EndExclude build_grid]
            // [EndExclude aligncontent]
            .gesture(
              LongPressGesture({ repeat: false })
                .onAction(() => {
                  if (index !== 0) {
                    Logger.info(`Please long press the first image`);
                    return;
                  }
                  // Obtains all attributes of a component.
                  let modePosition: componentUtils.ComponentInfo =
                    this.getUIContext().getComponentUtils().getRectangleById(JSON.stringify(item));
                  let windowOffset = modePosition.windowOffset;
                  let size = modePosition.size;
                  // Obtains the height of the component from the top.
                  let rectTop: number = this.getUIContext().px2vp(windowOffset.y);
                  let rectTop2: number = this.getUIContext().px2vp(windowOffset.y + Math.floor(size.height));
                  // Obtains the width of the component from the left.
                  let rectLeft: number = this.getUIContext().px2vp(windowOffset.x);
                  let topHeightNeeded: number = new BreakpointType(HomeConstants.VIDEO_DIALOG_HEIGHTS[0],
                    HomeConstants.VIDEO_DIALOG_HEIGHTS[1], HomeConstants.VIDEO_DIALOG_HEIGHTS[2])
                    .getValue(this.currentWidthBreakpoint) + rectTop - rectTop2;
                  if (this.currentWidthBreakpoint === 'sm') {
                    topHeightNeeded += HomeConstants.HOME_HEADER_HEIGHT_SM;
                  }
                  let dialogYOffset: number;
                  // Adaptive pop-up window expansion direction.
                  if (topHeightNeeded < rectTop) {
                    dialogYOffset = rectTop2 - new BreakpointType(HomeConstants.VIDEO_DIALOG_HEIGHTS[0],
                      HomeConstants.VIDEO_DIALOG_HEIGHTS[1], HomeConstants.VIDEO_DIALOG_HEIGHTS[2])
                      .getValue(this.currentWidthBreakpoint);
                  } else {
                    dialogYOffset = rectTop;
                  }
                  this.windowUtil = WindowUtil.getInstance();
                  let isLayoutFullScreen: boolean = true;
                  let mainWindow = this.windowUtil!.getMainWindow();
                  isLayoutFullScreen = mainWindow!.getWindowProperties().isLayoutFullScreen;
                  // Subtract the width and height of the window in the PC/2in1 device.
                  if (deviceInfo.deviceType === '2in1' && !isLayoutFullScreen) {
                    dialogYOffset -= HomeConstants.WINDOW_UNDEFINED_TOP;
                    rectLeft -= HomeConstants.WINDOW_UNDEFINED_LEFT;
                  } else {
                    Logger.info(`No need to subtract extra height`);
                  }
                  this.videoDialogController = new CustomDialogController({
                    builder: VideoDialog(),
                    autoCancel: true,
                    customStyle: true,
                    alignment: DialogAlignment.TopStart,
                    offset: {
                      dx: rectLeft,
                      dy: dialogYOffset
                    }
                  });
                  // Display the customized pop-up window to play the video.
                  this.videoDialogController.open();
                }))
            .bindContextMenu(RightClickMenu(this.currentWidthBreakpoint), ResponseType.RightClick)
            // [End aligncontent]
            VideoTitle({ title: item.getTitle() })
            VideoContent({ content: item.getContent() })
          }
          .alignItems(HorizontalAlign.Start)
        }
      }, (item: VideoImage, index: number) => index + JSON.stringify(item))
      // [EndExclude jh_tabindex_gettabindex]
    }
    // [StartExclude build_grid]
    // [StartExclude grid_foreach]
    // [StartExclude jh_tabindex_gettabindex]
    .tabIndex(getTabIndex(HomeConstants.DIRECTION_LIST[4]))
    .editMode(false)
    // Sets the number of grid layout columns and evenly divides the width.
    .columnsTemplate(this.videoGridColumn)
    .rowsTemplate('1fr 1fr')
    .width('100%')
    .rowsGap('12vp')
    .columnsGap('12vp')
    // Dynamically calculates the total height based on the following numbers of breakpoints.
    .height(this.getGridHeight(this.videoGridColumn, this.currentWidthBreakpoint, this.windowWidth))
    .padding({
      left: this.currentWidthBreakpoint === 'lg' && this.currentTopIndex === 2 ?
        new BreakpointType('112vp', '120vp', '132vp').getValue(this.currentWidthBreakpoint) :
        new BreakpointType('16vp', '24vp', '36vp').getValue(this.currentWidthBreakpoint),
      right: new BreakpointType('16vp', '24vp', '36vp').getValue(this.currentWidthBreakpoint),
      top: '12vp',
      bottom: '6vp'
    })
    // [EndExclude grid_foreach]
    // [EndExclude build_grid]
    // Zooming and pinching functions of the grid.
    // [EndExclude jh_tabindex_gettabindex]
    .gesture(PinchGesture({ fingers: 2 }).onActionUpdate((event: GestureEvent) => {
      if (event.scale > 1 && this.currentWidthBreakpoint !== 'sm') {
        if (this.currentWidthBreakpoint === 'md') {
          this.getUIContext().animateTo({
            duration: 500
          }, () => {
            this.videoGridColumn = '1fr 1fr 1fr';
          })
        } else {
          this.getUIContext().animateTo({
            duration: 500
          }, () => {
            this.videoGridColumn = '1fr 1fr 1fr 1fr';
          })
        }
      } else if (event.scale < 1 && this.currentWidthBreakpoint !== 'sm') {
        if (this.currentWidthBreakpoint === 'md') {
          this.getUIContext().animateTo({
            duration: 500
          }, () => {
            this.videoGridColumn = '1fr 1fr 1fr 1fr';
          })
        } else {
          this.getUIContext().animateTo({
            duration: 500
          }, () => {
            this.videoGridColumn = '1fr 1fr 1fr 1fr 1fr';
          })
        }
      } else {
        Logger.info(`Two-finger operation is not supported`);
      }
    }))
    // [End jh_tabindex_gettabindex]
    // [End grid_foreach]
  }

  getGridHeight(videoGridColumn: string, currentWidthBreakpoint: string, windowWidth: number): string {
    // Obtain the window width and subtract the blank parts on both sides.
    let result: number = this.getUIContext().px2vp(windowWidth) - new BreakpointType(HomeConstants.VIDEO_GRID_MARGIN[0],
      HomeConstants.VIDEO_GRID_MARGIN[1], HomeConstants.VIDEO_GRID_MARGIN[2]).getValue(this.currentWidthBreakpoint);
    if (currentWidthBreakpoint === 'lg') {
      result = result - HomeConstants.LG_SIDEBAR_WIDTH;
    }
    // Calculate the width of a single image based on the number of grid columns.
    if (videoGridColumn === '1fr 1fr') {
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * 1) / HomeConstants.TWO;
    } else if (videoGridColumn === '1fr 1fr 1fr') {
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * 2) / 3;
    } else if (videoGridColumn === '1fr 1fr 1fr 1fr') {
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * 3) / 4;
    } else {
      result = (result - HomeConstants.VIDEO_GRID_ITEM_SPACE * 4) / HomeConstants.FIVE;
    }
    // Calculate the height of a single image, title, and content, and calculate the total height of the grid layout.
    return result / HomeConstants.VIDEO_DIALOG_ASPECT_RATIO * HomeConstants.TWO +
      HomeConstants.VIDEO_GRID_DESCRIPTION_HEIGHT + HomeConstants.HEIGHT_UNIT;
  }
  // [End build_grid]
}
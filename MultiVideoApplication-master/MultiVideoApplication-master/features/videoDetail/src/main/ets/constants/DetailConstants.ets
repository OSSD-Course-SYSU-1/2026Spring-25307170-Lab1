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

export class DetailConstants {
  /**
   * Initial comment image height.
   */
  static readonly INITIAL_COMMENT_IMAGE_HEIGHT: string = '150vp';
  /**
   * Initial comment image width.
   */
  static readonly INITIAL_COMMENT_IMAGE_WIDTH: string = '219vp';
  /**
   * Initial related video height.
   */
  static readonly INITIAL_RELATED_VIDEO_HEIGHT: number = 169;
  /**
   * Initial related video height.
   */
  static readonly INITIAL_VIDEO_HEIGHT: number = 100;
  /**
   * Comment image min height number.
   */
  static readonly COMMENT_IMAGE_MIN_HEIGHT_NUMBER: number = 150;
  /**
   * Comment image min width number.
   */
  static readonly COMMENT_IMAGE_MIN_WIDTH_NUMBER: number = 219;
  /**
   * Comment image max height number.
   */
  static readonly COMMENT_IMAGE_MAX_HEIGHT_NUMBER: number = 182;
  /**
   * Comment image max width number.
   */
  static readonly COMMENT_IMAGE_MAX_WIDTH_NUMBER: number = 266;
  /**
   * Side bar min width number.
   */
  static readonly SIDE_BAR_MIN_WIDTH_NUMBER: number = 320;
  /**
   * Offset for scrolling to top.
   */
  static readonly SCROLL_TO_TOP: string = '{"xOffset":0,"yOffset":0}';
  /**
   * Sub title list.
   */
  static readonly SUB_TITLES: ResourceStr[] =
    [$r('app.string.comments'), $r('app.string.related'), $r('app.string.more'), $r('app.string.introduction'),
      $r('app.string.anthology'), $r('app.string.Peripheral')];
  /**
   * Comment image aspect ratio.
   */
  static readonly COMMENT_IMAGE_ASPECT_RATIO: number = 1.46;
  /**
   * Comment image width list.
   */
  static readonly COMMENT_IMAGE_WIDTH: string[] = ['227vp', '371vp'];
  /**
   * Comment image height list.
   */
  static readonly COMMENT_IMAGE_HEIGHT: string[] = ['155vp', '254vp'];
  /**
   * Episodes list.
   */
  static readonly EPISODES_LIST: string[] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  /**
   * Length unit.
   */
  static readonly LENGTH_UNIT: string = 'vp';
  /**
   * Introduction content.
   */
  static readonly INTRODUCTION_CONTENT: ResourceStr[] = [$r('app.string.product'),
    $r('app.string.play')];
  /**
   * Icon list.
   */
  static readonly ICON_LIST: Resource[] = [$r('app.media.ic_public_favor'), $r('app.media.ic_public_comments'),
    $r('app.media.ic_public_thumb_sup'), $r('app.media.ic_public_download'), $r('app.media.ic_public_share')];
  /**
   * Shadow radius.
   */
  static readonly SHADOW_RADIUS: number = 50;
  /**
   * Shadow offset y.
   */
  static readonly SHADOW_OFFSET_Y: number = 10;
  /**
   * Percent sign.
   */
  static readonly PERCENT_SIGN: string = '%';
  /**
   * Related video title list.
   */
  static readonly RELATED_VIDEO_TITLES: ResourceStr[] =
    [$r('app.string.released'), $r('app.string.released'), $r('app.string.released'),
      $r('app.string.released'), $r('app.string.released'), $r('app.string.released'), $r('app.string.released')];
  /**
   * Peripheral video title list.
   */
  static readonly PERIPHERAL_VIDEO_TITLE: ResourceStr[] = [$r('app.string.series'), $r('app.string.series'),
    $r('app.string.series'), $r('app.string.series'), $r('app.string.series')];
  /**
   * User info name list.
   */
  static readonly USER_INFO_NAMES: string[] = ['m******', 'H******', 'BEI***'];
  /**
   * User info comment list.
   */
  static readonly USER_INFO_COMMENTS: ResourceStr[] = [
    $r('app.string.feel'),
    $r('app.string.love'),
    $r('app.string.design')
  ];
  /**
   * User info date.
   */
  static readonly USER_INFO_DATE: ResourceStr = $r('app.string.July');
  /**
   * Placeholder of comment text input.
   */
  static readonly COMMENT_PLACEHOLDER: ResourceStr = $r('app.string.comment');
  /**
   * Min video percent.
   */
  static readonly MIN_VIDEO_PERCENT: number = 53;
  /**
   * Max video percent.
   */
  static readonly MAX_VIDEO_PERCENT: number = 100;
  /**
   * Ten.
   */
  static readonly TEN: number = 10;
  /**
   * Related list height.
   */
  static readonly RELATED_LIST_HEIGHT: number = 169;
  /**
   * Full-screen page url.
   */
  static readonly FULL_SCREEN_URL: string = '@bundle:com.huawei.videoapplication/videoPlayer/ets/pages/Index';
  /**
   * Comments area percent.
   */
  static readonly COMMENTS_AREA_PERCENT: number = 0.4;
  /**
   * Player text list.
   */
  static readonly PLAYER_TEXT_LIST: ResourceStr[] = [$r('app.string.selections'), $r('app.string.just'),
    $r('app.string.super'), $r('app.string.speed')];
  /**
   * Episode list lanes list.
   */
  static readonly EPISODE_LIST_LANES: number[] = [8, 4];
  /**
   * Episodes.
   */
  static readonly PLAYER_EPISODE: string[] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14',
    '15', '16', '17', '18', '19', '20', '21', '22', '23', '24'];
}
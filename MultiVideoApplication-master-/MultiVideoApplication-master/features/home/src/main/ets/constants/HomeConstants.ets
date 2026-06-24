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

export class HomeConstants {
  /**
   * Top tab topics.
   */
  static readonly TOP_TOPIC_LIST: ResourceStr[] =
    [$r('app.string.sift'), $r('app.string.home_video'), $r('app.string.community'), $r('app.string.news'),
      $r('app.string.shop'), $r('app.string.science'), $r('app.string.finance'), $r('app.string.history'),
      $r('app.string.affairs')];
  /**
   * Icon list.
   */
  static readonly ICON_LIST: ResourceStr[] =
    [$r('app.string.home_all'), $r('app.string.heat_list'), $r('app.string.free'), $r('app.string.sutra'),
      $r('app.string.prefecture'), $r('app.string.kids_only'), $r('app.string.zone'), $r('app.string.Premium_products'),
      $r('app.string.Fitness')];
  /**
   * Banner text 1.
   */
  static readonly BANNER_TEXT_1: ResourceStr[] = ['HUAWEI ', 'Mate Book ', $r('app.string.new')];
  /**
   * Banner text 2.
   */
  static readonly BANNER_TEXT_2: ResourceStr[] = ['HUAWEI ', '', $r('app.string.new')];
  /**
   * Banner text 3.
   */
  static readonly BANNER_TEXT_3: ResourceStr[] = ['HUAWEI P60 ', '', $r('app.string.new')];
  /**
   * Banner text 4.
   */
  static readonly BANNER_TEXT_4: ResourceStr[] = ['HUAWEI P50', '', $r('app.string.new')];
  /**
   * Video grid rate list.
   */
  static readonly VIDEO_GRID_RATES: string[] = ['7.8', '8.0', '7.9', '8.4', '7.8', '8.0', '7.9', '8.4', '7.6', '8.0'];
  /**
   * Video grid name list.
   */
  static readonly VIDEO_GRID_NAMES: ResourceStr[] =
    [$r('app.string.home_cultural'), $r('app.string.home_cultural'), $r('app.string.home_cultural'), $r('app.string.home_cultural'),
      $r('app.string.home_cultural'),
      $r('app.string.home_cultural'), $r('app.string.home_cultural'), $r('app.string.home_cultural'), $r('app.string.home_cultural'),
      $r('app.string.home_cultural')];
  /**
   * Video grid content list.
   */
  static readonly VIDEO_GRID_CONTENTS: ResourceStr[] = [$r('app.string.home_europe'),
    $r('app.string.home_europe'), $r('app.string.home_europe'),
    $r('app.string.home_europe'), $r('app.string.home_europe'),
    $r('app.string.home_europe'), $r('app.string.home_europe'),
    $r('app.string.home_europe'), $r('app.string.home_europe'), $r('app.string.home_europe')];
  /**
   * New video grid rate list.
   */
  static readonly NEW_VIDEO_RATES: string[] = ['', '', '7.9', '7.9', '7.9', '7.9', '7.9'];
  /**
   * New video name list.
   */
  static readonly NEW_VIDEO_NAMES: ResourceStr[] =
    ['HUAWEI Mate30 ...', $r('app.string.life'), $r('app.string.life'), $r('app.string.life'),
      $r('app.string.life'), $r('app.string.life'), $r('app.string.life')];
  /**
   * New video content list.
   */
  static readonly NEW_VIDEO_CONTENTS: ResourceStr[] =
    [$r('app.string.landscape'), $r('app.string.landscape'), $r('app.string.landscape'),
      $r('app.string.landscape'), $r('app.string.landscape'), $r('app.string.landscape'), $r('app.string.landscape')];
  /**
   * Main daily video rate.
   */
  static readonly MAIN_DAILY_VIDEO_RATE: string = '8.4';
  /**
   * Main daily video name.
   */
  static readonly MAIN_DAILY_VIDEO_NAME: ResourceStr = $r('app.string.explore');
  /**
   * Main daily video content.
   */
  static readonly MAIN_DAILY_VIDEO_CONTENT: ResourceStr = $r('app.string.source');
  /**
   * Main daily video more info.
   */
  static readonly MAIN_DAILY_VIDEO_MORE: ResourceStr = $r('app.string.source');
  /**
   * Daily video rate list.
   */
  static readonly DAILY_VIDEO_RATES: string[] = ['8.4', '8.4', '8.4', '8.4'];
  /**
   * Daily video name list.
   */
  static readonly DAILY_VIDEO_NAMES: ResourceStr[] =
    [$r('app.string.lonely'), $r('app.string.lonely'), $r('app.string.lonely'), $r('app.string.lonely')];
  /**
   * Daily video name list.
   */
  static readonly DAILY_VIDEO_CONTENTS: ResourceStr[] = [$r('app.string.source'), $r('app.string.source'),
    $r('app.string.source'), $r('app.string.source')];
  /**
   * Previous video name list one.
   */
  static readonly PREVIOUS_VIDEO_NAMES_ONE: ResourceStr[] = [$r('app.string.life'), $r('app.string.life'),
    $r('app.string.life')];
  /**
   * Previous video content list one.
   */
  static readonly PREVIOUS_VIDEO_CONTENTS_ONE: ResourceStr[] = [$r('app.string.film'), $r('app.string.film'),
    $r('app.string.film')];
  /**
   * Previous video more info list one.
   */
  static readonly PREVIOUS_VIDEO_MORE_ONE: ResourceStr[] =
    [$r('app.string.home_plays'), $r('app.string.home_plays'), $r('app.string.home_plays')];
  /**
   * Previous video name list two.
   */
  static readonly PREVIOUS_VIDEO_NAMES_TWO: ResourceStr[] =
    [$r('app.string.life'), $r('app.string.life'), $r('app.string.life'),
      $r('app.string.life'), $r('app.string.life'), $r('app.string.life')];
  /**
   * Previous video content list two.
   */
  static readonly PREVIOUS_VIDEO_CONTENTS_TWO: ResourceStr[] = [$r('app.string.home_europe'), $r('app.string.home_europe'),
    $r('app.string.home_europe'), $r('app.string.home_europe'), $r('app.string.home_europe'), $r('app.string.home_europe')];
  /**
   * Banner text letter space list.
   */
  static readonly BANNER_TEXT_LETTER_SPACES: string[] = ['2vp', '3vp', '1vp'];
  /**
   * Swiper item space.
   */
  static readonly SWIPER_ITEM_SPACE: string = '12vp';
  /**
   * Banner row space.
   */
  static readonly BANNER_ROW_SPACE: string = '12vp';
  /**
   * Home sub title list.
   */
  static readonly HOME_SUB_TITLES: ResourceStr[] =
    [$r('app.string.release'), $r('app.string.tablet'), $r('app.string.back')];
  /**
   * New video rows template.
   */
  static readonly NEW_VIDEO_ROWS_TEMPLATE: string = '1fr';
  /**
   * Main daily video button text.
   */
  static readonly HOME_BUTTON_TEXT: ResourceStr[] =
    [$r('app.string.follow'), $r('app.string.play_on'), $r('app.string.home_player'), $r('app.string.search_cache')];
  /**
   * Previous two list translate position.
   */
  static readonly PREVIOUS_TWO_TRANSLATE_MD: string = '-42vp';
  /**
   * Search placeholder.
   */
  static readonly SEARCH_PLACEHOLDER: ResourceStr = $r('app.string.home_search');
  /**
   * Video dialog option list.
   */
  static readonly VIDEO_DIALOG_OPTIONS: ResourceStr[] = [$r('app.string.binge_watch'), $r('app.string.Collect'), $r('app.string.like')];
  /**
   * Side bar icon list height.
   */
  static readonly SIDE_ICON_LIST_HEIGHT: string = '25%';
  /**
   * Square brackets.
   */
  static readonly SQUARE_BRACKETS: string[] = ['[', ']'];
  /**
   * Height unit.
   */
  static readonly HEIGHT_UNIT: string = 'vp';
  /**
   * Two.
   */
  static readonly TWO: number = 2;
  /**
   * Five.
   */
  static readonly FIVE: number = 5;
  /**
   * Six.
   */
  static readonly SIX: number = 6;
  /**
   * Seven.
   */
  static readonly SEVEN: number = 7;
  /**
   * Eight.
   */
  static readonly EIGHT: number = 8;
  /**
   * Video dialog height list.
   */
  static readonly VIDEO_DIALOG_HEIGHTS: number[] = [161, 268, 347];
  /**
   * Video dialog aspect ratio.
   */
  static readonly VIDEO_DIALOG_ASPECT_RATIO: number = 1.74;
  /**
   * New banner aspect ratio.
   */
  static readonly NEW_BANNER_ASPECT_RATIO: number = 1.5;
  /**
   * Home header background change height.
   */
  static readonly BACKGROUND_CHANGE_HEIGHT: number[] = [27, 34, 56];
  /**
   * Video grid item space.
   */
  static readonly VIDEO_GRID_ITEM_SPACE: number = 12;
  /**
   * Video grid margin.
   */
  static readonly VIDEO_GRID_MARGIN: number[] = [32, 48, 64];
  /**
   * Number of displayed icons.
   */
  static readonly DISPLAYED_ICON_NUMBER: number[] = [9, 13, 17];
  /**
   * Lg sidebar width.
   */
  static readonly LG_SIDEBAR_WIDTH: number = 96;
  /**
   * Video grid description height.
   */
  static readonly VIDEO_GRID_DESCRIPTION_HEIGHT: number = 120;
  /**
   * New video aspect ratio.
   */
  static readonly NEW_VIDEO_ASPECT_RATIO: number = 0.72;
  /**
   * New video description height.
   */
  static readonly NEW_VIDEO_DESCRIPTION_HEIGHT: number = 71;
  /**
   * Daily video description height.
   */
  static readonly DAILY_VIDEO_DESCRIPTION_HEIGHT: number[] = [103, 88, 115, 62];
  /**
   * Previous two ratio list.
   */
  static readonly PREVIOUS_TWO_RATIOS: number[] = [0.76, 0.89, 0.86, 0.74, 0.8, 0.9, 0.83];
  /**
   * Banner aspect ratio list.
   */
  static readonly BANNER_RATIOS: number[] = [1.49, 1.6, 2.1];
  /**
   * Home header height for sm.
   */
  static readonly HOME_HEADER_HEIGHT_SM: number = 112;
  /**
   * Window undefined top.
   */
  static readonly WINDOW_UNDEFINED_TOP: number = 39;
  /**
   * Window undefined left.
   */
  static readonly WINDOW_UNDEFINED_LEFT: number = 5;
  /**
   * Eleven.
   */
  static readonly ELEVEN: number = 11;
  /**
   * Banner text 1 left position for md.
   */
  static readonly BANNER_TEXT_1_LEFT_MD: string = '8%';
  /**
   * Banner text 2 left position for md.
   */
  static readonly BANNER_TEXT_2_LEFT_MD: string = '8%';
  /**
   * Banner text 2 left position for lg.
   */
  static readonly BANNER_TEXT_2_LEFT_LG: string = '5%';
  /**
   * Banner text 1 top position for sm.
   */
  static readonly BANNER_TEXT_1_TOP_SM: string[] = ['15%', '2vp'];
  /**
   * Banner text 1 top position for md.
   */
  static readonly BANNER_TEXT_1_TOP_MD: string[] = ['8%', '4vp'];
  /**
   * Banner text 1 top position for lg.
   */
  static readonly BANNER_TEXT_1_TOP_LG: string[] = ['5%', '2vp'];
  /**
   * Banner text 2 top position for sm.
   */
  static readonly BANNER_TEXT_2_TOP_SM: string[] = ['15%', '2vp'];
  /**
   * Banner text 2 top position for md.
   */
  static readonly BANNER_TEXT_2_TOP_MD: string[] = ['10%', '4vp'];
  /**
   * Banner text 2 top position for lg.
   */
  static readonly BANNER_TEXT_2_TOP_LG: string[] = ['10%', '8vp'];
  /**
   * Video detail url.
   */
  static readonly VIDEO_DETAIL_URL: string = '@bundle:com.huawei.videoapplication/videoDetail/ets/pages/Index';
  /**
   * Direction list.
   */
  static readonly DIRECTION_LIST: string[] = ['BottomTabs', 'TopTabs', 'Banner', 'IconList', 'RecommendedVideo',
    'NewRelease', 'DailyVideoOne', 'DailyVideoTwo', 'PreviousVideo'];
  /**
   * Percent 105.
   */
  static readonly PERCENT_HUNDRED_AND_FIVE: string = '105%';
  /**
   * Animation duration.
   */
  static readonly ANIMATION_DURATION: number = 500;
  /**
   * Item width of IconView.
   */
  static readonly ICONVIEW_ITEM_WIDTH: number[] = [40, 43, 45];
}
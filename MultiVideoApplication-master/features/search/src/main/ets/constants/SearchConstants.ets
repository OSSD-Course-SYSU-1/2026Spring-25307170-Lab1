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

export class SearchConstants {
  /**
   * Searching for a recommendation list in large devices.
   */
  static readonly SEARCH_DISCOVERY_LARGE: ResourceStr[] =
    [$r('app.string.search'), $r('app.string.search'), $r('app.string.search'), $r('app.string.search'),
      $r('app.string.search'),
      $r('app.string.search'), $r('app.string.search'), $r('app.string.search'), $r('app.string.search')];
  /**
   * Tabs list.
   */
  static readonly SEARCH_TABS: ResourceStr[] =
    [$r('app.string.top'), $r('app.string.theater'), $r('app.string.movie'), $r('app.string.variety'),
      $r('app.string.anime'), $r('app.string.children'), $r('app.string.records')];
  /**
   * Search List for hua.
   */
  static readonly HUA_LIST: ResourceStr[] =
    [ $r('app.string.tv'), $r('app.string.tv'),  $r('app.string.tv'), $r('app.string.conference'),
      $r('app.string.tv'),  $r('app.string.tv')];
  /**
   * Search result tab List.
   */
  static readonly SEARCH_RESULT_TAB_LIST: ResourceStr[] = [$r('app.string.search_all'), $r('app.string.filmer'), $r('app.string.search_video'), $r('app.string.user')];
  /**
   * Search video img title list.
   */
  static readonly SEARCH_IMG_IMG_TITLES: ResourceStr[] =
    [$r('app.string.search_cultural'), $r('app.string.search_cultural'), $r('app.string.search_cultural'), $r('app.string.search_cultural'),
      $r('app.string.search_cultural'), $r('app.string.search_cultural'), $r('app.string.search_cultural'), $r('app.string.search_cultural'),
      $r('app.string.search_cultural'), $r('app.string.search_cultural'), $r('app.string.search_cultural'), $r('app.string.search_cultural')];
  /**
   * Search video img content list.
   */
  static readonly SEARCH_IMG_IMG_CONTENTS: ResourceStr[] =
    [$r('app.string.search_europe'), $r('app.string.search_europe'),
      $r('app.string.search_europe'), $r('app.string.search_europe'), $r('app.string.search_europe'),
      $r('app.string.search_europe'), $r('app.string.search_europe'),
      $r('app.string.search_europe'),
      $r('app.string.search_europe'), $r('app.string.search_europe'), $r('app.string.search_europe'),
      $r('app.string.search_europe')];
  /**
   * Search result title list.
   */
  static readonly SEARCH_RESULT_TITLES: ResourceStr[] = [$r('app.string.flagship'), $r('app.string.flagship'),
    $r('app.string.flagship')];
  /**
   * Search result content list.
   */
  static readonly SEARCH_RESULT_CONTENTS: ResourceStr[] = [$r('app.string.press'), $r('app.string.press'),
    $r('app.string.press')];
  /**
   * Search result more info list.
   */
  static readonly SEARCH_RESULT_MORE: ResourceStr[] = [$r('app.string.search_plays'), $r('app.string.search_plays'), $r('app.string.search_plays')];
  /**
   * Search sub title list.
   */
  static readonly SEARCH_SUB_TITLES: ResourceStr[] = [$r('app.string.history_search'), $r('app.string.content'), $r('app.string.find')];
  /**
   * Search recommend list lanes.
   */
  static readonly SEARCH_LIST_LANES: number[] = [3, 2, 1];
  /**
   * Hot trending list spaces.
   */
  static readonly HOT_TRENDING_LIST_SPACES: string[] = ['16vp', '24vp', '36vp'];
  /**
   * Search recommend divider padding.
   */
  static readonly SEARCH_RECOMMEND_DIVIDER_PADDING: string = '16vp';
  /**
   * Search index.
   */
  static readonly SEARCH_INDEX: number[] = [2, 3];
  /**
   * Search placeholder.
   */
  static readonly SEARCH_PLACEHOLDER: ResourceStr = $r('app.string.search1');
  /**
   * Type tabs divider stroke width.
   */
  static readonly TYPE_TABS_DIVIDER_STROKE_WIDTH: string = '2vp';
  /**
   * Search result title.
   */
  static readonly SEARCH_RESULT_TITLE: ResourceStr = $r('app.string.conference');
  /**
   * Search result button text list.
   */
  static readonly SEARCH_RESULT_BUTTON_TEXTS: ResourceStr[] = [$r('app.string.search_player'), $r('app.string.search_cache')];
  /**
   * Video detail url.
   */
  static readonly VIDEO_DETAIL_URL: string = '@bundle:com.huawei.videoapplication/videoDetail/ets/pages/Index';
  /**
   * Search input list.
   */
  static readonly SEARCH_INPUT_LIST: ResourceStr[] = ['华', '华为发布会'];
  /**
   * Hot video divider stroke width.
   */
  static readonly DIVIDER_STROKE_WIDTH: string = '0.5vp';
}
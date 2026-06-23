/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { promptAction } from '@kit.ArkUI';
import { CastConstants, DeviceManagerUtil, DeviceInfo, BreakpointType, Logger } from 'base';

@CustomDialog
export struct DeviceSelectDialog {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'lg';
  @StorageLink(CastConstants.CAST_STATE_KEY) castState: string = CastConstants.CAST_STATE_IDLE;
  @StorageLink(CastConstants.AVAILABLE_DEVICES_KEY) availableDevices: DeviceInfo[] = [];
  @Prop isVisible: boolean = false;
  controller: CustomDialogController;
  private deviceManagerUtil?: DeviceManagerUtil;
  private onDeviceSelected?: (deviceId: string) => void;

  aboutToAppear(): void {
    this.deviceManagerUtil = DeviceManagerUtil.getInstance(this.getUIContext());
    // Start discovering devices when dialog appears
    this.deviceManagerUtil?.startDiscovering();
  }

  aboutToDisappear(): void {
    // Stop discovering when dialog disappears
    this.deviceManagerUtil?.stopDiscovering();
  }

  /**
   * Get dialog width based on breakpoint.
   */
  private getDialogWidth(): string {
    const widthType = new BreakpointType<string>(
      CastConstants.DIALOG_WIDTH_SM,
      CastConstants.DIALOG_WIDTH_MD,
      CastConstants.DIALOG_WIDTH_LG
    );
    return widthType.getValue(this.currentWidthBreakpoint);
  }

  /**
   * Get device icon based on device type.
   */
  private getDeviceIcon(deviceType: string): Resource {
    switch (deviceType) {
      case CastConstants.DEVICE_TYPE_PHONE:
        return $r('app.media.device_phone');
      case CastConstants.DEVICE_TYPE_TABLET:
        return $r('app.media.device_tablet');
      case CastConstants.DEVICE_TYPE_TV:
        return $r('app.media.device_tv');
      default:
        return $r('app.media.device_phone');
    }
  }

  /**
   * Handle device item click.
   */
  private async handleDeviceClick(device: DeviceInfo): Promise<void> {
    Logger.info(`Device selected: ${device.deviceName}`);

    // Authenticate if not trusted
    if (!device.isTrusted) {
      const success = await this.deviceManagerUtil?.authenticateDevice(device);
      if (!success) {
        Logger.error(`Authentication failed for device: ${device.deviceName}`);
        return;
      }
    }

    // Close dialog
    this.controller.close();
    this.isVisible = false;

    // Notify parent
    if (this.onDeviceSelected) {
      this.onDeviceSelected(device.deviceId);
    }
    
    // 提示用户下一步操作
    promptAction.showToast({
      message: '已选中设备，请通过系统设备选择器完成迁移',
      duration: 2000
    });
  }

  /**
   * Handle cancel button click.
   */
  private handleCancel(): void {
    this.controller.close();
    this.isVisible = false;
  }

  build() {
    Column() {
      // Title
      Text($r('app.string.select_target_device'))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .margin({ top: 24, bottom: 16 })

      // Divider
      Divider()
        .width('100%')
        .color('#E5E5E5')

      // Content area
      if (this.castState === CastConstants.CAST_STATE_DISCOVERING && this.availableDevices.length === 0) {
        // Loading state
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#ED6F21')
            .margin({ bottom: 16 })

          Text($r('app.string.discovering_devices'))
            .fontSize(14)
            .fontColor('#99182431')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.availableDevices.length === 0) {
        // Empty state
        Column() {
          Image($r('app.media.ic_public_cast'))
            .width(64)
            .height(64)
            .fillColor('#99182431')
            .margin({ bottom: 16 })

          Text($r('app.string.no_device_found'))
            .fontSize(14)
            .fontColor('#99182431')
            .textAlign(TextAlign.Center)
            .padding({ left: 24, right: 24 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        // Device list
        List() {
          ForEach(this.availableDevices, (device: DeviceInfo) => {
            ListItem() {
              Row() {
                // Device icon
                Image(this.getDeviceIcon(device.deviceType))
                  .width(40)
                  .height(40)
                  .fillColor('#182431')
                  .margin({ right: 16 })

                // Device info
                Column() {
                  Text(device.deviceName)
                    .fontSize(16)
                    .fontColor('#182431')
                    .fontWeight(FontWeight.Medium)

                  Text(this.getDeviceTypeText(device.deviceType))
                    .fontSize(12)
                    .fontColor('#99182431')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                // Trust indicator
                if (device.isTrusted) {
                  Image($r('app.media.ic_public_ok'))
                    .width(20)
                    .height(20)
                    .fillColor('#4CAF50')
                }
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 16, bottom: 16 })
              .onClick(() => {
                this.handleDeviceClick(device);
              })
            }
          }, (device: DeviceInfo) => device.deviceId)
        }
        .width('100%')
        .height(this.currentWidthBreakpoint === 'sm' ? 200 : 280)
        .divider({
          strokeWidth: 1,
          color: '#E5E5E5',
          startMargin: 20,
          endMargin: 20
        })
      }

      // Divider
      Divider()
        .width('100%')
        .color('#E5E5E5')

      // Cancel button
      Button($r('app.string.cancel'))
        .width('100%')
        .height(this.currentWidthBreakpoint === 'sm' ? 40 : 48)
        .fontSize(this.currentWidthBreakpoint === 'sm' ? 14 : 16)
        .fontColor('#ED6F21')
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.handleCancel();
        })
    }
    .width(this.getDialogWidth())
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 20,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 4
    })
  }

  /**
   * Get device type display text.
   */
  private getDeviceTypeText(deviceType: string): string {
    switch (deviceType) {
      case CastConstants.DEVICE_TYPE_PHONE:
        return '手机';
      case CastConstants.DEVICE_TYPE_TABLET:
        return '平板';
      case CastConstants.DEVICE_TYPE_TV:
        return '智慧屏';
      case CastConstants.DEVICE_TYPE_2IN1:
        return '2合1设备';
      default:
        return '未知设备';
    }
  }
}

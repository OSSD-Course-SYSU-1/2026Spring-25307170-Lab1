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

import { abilityAccessCtrl, common, AbilityConstant } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { CastConstants, DeviceManagerUtil, DeviceInfo, Logger, BreakpointConstants } from 'base';
import { DeviceSelectDialog } from './DeviceSelectDialog';

/**
 * Cast button component for cross-device migration.
 */
@Component
export struct CastButton {
  @StorageLink(CastConstants.CAST_STATE_KEY) castState: string = CastConstants.CAST_STATE_IDLE;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'sm';
  @State private showDeviceDialog: boolean = false;
  @State private sourceDeviceId: string = '';
  private deviceManagerUtil?: DeviceManagerUtil;
  private dialogController?: CustomDialogController;

  aboutToAppear(): void {
    this.deviceManagerUtil = DeviceManagerUtil.getInstance(this.getUIContext());
    this.sourceDeviceId = this.deviceManagerUtil?.getLocalDeviceId() || '';
  }

  /**
   * Check and request distributed data sync permission.
   */
  private async checkAndRequestPermission(): Promise<boolean> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();

    try {
      // Check if permission is already granted
      const grantStatus = await atManager.checkAccessToken(
        context.applicationInfo.accessTokenId,
        'ohos.permission.DISTRIBUTED_DATASYNC'
      );

      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        Logger.info('DISTRIBUTED_DATASYNC permission already granted');
        return true;
      }

      // Request permission
      Logger.info('Requesting DISTRIBUTED_DATASYNC permission');
      const result = await atManager.requestPermissionsFromUser(context, ['ohos.permission.DISTRIBUTED_DATASYNC']);

      if (result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        Logger.info('DISTRIBUTED_DATASYNC permission granted');
        return true;
      } else {
        Logger.error('DISTRIBUTED_DATASYNC permission denied');
        promptAction.showToast({
          message: $r('app.string.need_distributed_permission'),
          duration: 2000
        });
        return false;
      }
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(`Permission check failed: ${err.message}`);
      return false;
    }
  }

  /**
   * Handle cast button click.
   */
  private async handleCastClick(): Promise<void> {
    Logger.info(`Cast button clicked, current state: ${this.castState}`);

    switch (this.castState) {
      case CastConstants.CAST_STATE_IDLE:
        // Check permission first
        const hasPermission = await this.checkAndRequestPermission();
        if (!hasPermission) {
          return;
        }
        // Open device select dialog
        this.openDeviceDialog();
        break;

      case CastConstants.CAST_STATE_MIGRATED:
        // Show confirm dialog for pulling back
        this.showPullBackConfirmDialog();
        break;

      case CastConstants.CAST_STATE_DISCOVERING:
      case CastConstants.CAST_STATE_CONNECTING:
      case CastConstants.CAST_STATE_MIGRATING:
        // Do nothing when in progress
        Logger.info(`Cast in progress, state: ${this.castState}`);
        break;
    }
  }

  /**
   * Open device select dialog.
   */
  private openDeviceDialog(): void {
    this.dialogController = new CustomDialogController({
      builder: DeviceSelectDialog({
        isVisible: this.showDeviceDialog,
        onDeviceSelected: (deviceId: string) => {
          this.handleDeviceSelected(deviceId);
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    });
    this.showDeviceDialog = true;
    this.dialogController.open();
  }

  /**
   * Handle device selected from dialog.
   */
  private async handleDeviceSelected(deviceId: string): Promise<void> {
    Logger.info(`Device selected for migration: ${deviceId}`);

    try {
      await this.deviceManagerUtil?.continueToTarget(deviceId);
      Logger.info('Migration started successfully');
      
      // 提示用户通过系统设备选择器发起迁移
      promptAction.showToast({
        message: '请通过系统设备选择器发起迁移',
        duration: 2000
      });
    } catch (error) {
      Logger.error('Migration error: ' + JSON.stringify(error));
    }
  }

  /**
   * Show pull back confirmation dialog.
   */
  private showPullBackConfirmDialog(): void {
    promptAction.showDialog({
      message: $r('app.string.pull_back_confirm'),
      buttons: [
        { text:$r('app.string.cancel'), color: '#666666' },
        { text: $r('app.string.confirm'), color: '#ED6F21' }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        this.handlePullBackConfirm();
      }
    });
  }

  /**
   * Handle pull back confirmation.
   */
  private async handlePullBackConfirm(): Promise<void> {
    Logger.info('Pull back confirmed');

    if (this.sourceDeviceId) {
      try {
        await this.deviceManagerUtil?.continueToTarget(this.sourceDeviceId);
        Logger.info('Pull back migration started');
      } catch (error) {
        const err = error as BusinessError;
        Logger.error(`Pull back migration failed: ${err.message}`);
        promptAction.showToast({
          message: $r('app.string.migration_failed'),
          duration: 2000
        });
      }
    } else {
      Logger.error('Source device ID not available');
      AppStorage.setOrCreate(CastConstants.CAST_STATE_KEY, CastConstants.CAST_STATE_IDLE);
    }
  }

  /**
   * Get button icon based on state.
   */
  private getButtonIcon(): Resource {
    if (this.castState === CastConstants.CAST_STATE_MIGRATED) {
      return $r('app.media.ic_public_cast_active');
    }
    return $r('app.media.ic_public_cast');
  }

  /**
   * Get button color based on state.
   */
  private getButtonColor(): string | Resource {
    if (this.castState === CastConstants.CAST_STATE_MIGRATED) {
      return '#ED6F21'; // Active color
    }
    return '#FFFFFF';
  }

  /**
   * Get button size based on breakpoint.
   */
  private getButtonSize(): number {
    if (this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_MD ||
        this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
      return CastConstants.CAST_BUTTON_SIZE_MD;
    }
    return CastConstants.CAST_BUTTON_SIZE_SM;
  }

  /**
   * Get container size based on breakpoint.
   */
  private getContainerSize(): number {
    if (this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_MD ||
        this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
      return CastConstants.CAST_BUTTON_CONTAINER_MD;
    }
    return CastConstants.CAST_BUTTON_CONTAINER_SM;
  }

  build() {
    Stack() {
      if (this.castState === CastConstants.CAST_STATE_MIGRATING ||
          this.castState === CastConstants.CAST_STATE_CONNECTING) {
        // Show loading indicator
        LoadingProgress()
          .width(this.getButtonSize())
          .height(this.getButtonSize())
          .color(Color.White)
      } else {
        // Show cast icon
        Image(this.getButtonIcon())
          .width(this.getButtonSize())
          .height(this.getButtonSize())
          .fillColor(this.getButtonColor())
          .onClick(() => {
            this.handleCastClick();
          })
      }
    }
    .width(this.getContainerSize())
    .height(this.getContainerSize())
    .alignContent(Alignment.Center)
  }

}

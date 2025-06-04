// src/notifications/notification.controller.ts
import {
  Controller,
  Get,
  Param,
  Patch,
  UseGuards,
  Query,Delete,Req
} from '@nestjs/common';
import { NotificationService } from './notification.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { RolesGuard } from 'src/auth/roles.guard';
import { Roles } from 'src/auth/roles.decorator';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Get('user')
  getUserNotifications(@Req() req: any) {
    const userId = req.user.id;
    return this.notificationService.getUserNotifications(userId);
  }

  @Get('admin')
  @UseGuards(RolesGuard)
  @Roles('admin')
  getAdminNotifications() {
    return this.notificationService.getAdminNotifications();
  }

  @Patch(':id/read')
  markAsRead(@Param('id') id: number, @Req() req: any) {
    return this.notificationService.markAsRead(id, req.user);
  }



  @Patch('mark-all-read')
  @UseGuards(RolesGuard)
  markAllAsRead(@Req() req: any) {
    const user = req.user;

    if (user.roles && user.roles.includes('admin')) {
      return this.notificationService.markAllAdminNotificationsAsRead();
    } else {
      return this.notificationService.markAllAsRead(user.id);
    }
  }

  @Delete(':id')
  deleteNotification(@Param('id') id: number, @Req() req: any) {
    return this.notificationService.deleteNotification(Number(id), req.user);
  }
}

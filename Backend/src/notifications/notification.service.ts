// src/notifications/notification.service.ts
import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from './notification.entity';
import { User } from 'src/users/user.entity';
import { CreateNotificationDto } from './create-notification.dto';

@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(Notification)
    private notificationRepo: Repository<Notification>,
  ) {}
  async createNotification(createNotificationDto: CreateNotificationDto) {
    // Use the correct structure for the `findOne` method
    const user = await this.notificationRepo.manager.findOne(User, {
      where: { id: createNotificationDto.userId }, // Use `where` to specify the condition
    });

    if (!user) throw new NotFoundException('User not found');

    const notification = this.notificationRepo.create({
      message: createNotificationDto.message,
      recipientType: 'user',
      user,
      type: createNotificationDto.type,
    });

    await this.notificationRepo.save(notification);
    return notification;
  }

  async notifyAdmin(message: string, type: string) {
    const notification = this.notificationRepo.create({
      message,
      recipientType: 'admin',
      type,
      isRead: true,
    });
    await this.notificationRepo.save(notification);
  }

  async notifyUser(user: User, message: string, type: string) {
    const notification = this.notificationRepo.create({
      message,
      recipientType: 'user',
      user,
      type,
    });
    await this.notificationRepo.save(notification);
  }

  async getUserNotifications(userId: number) {
    return this.notificationRepo.find({
      where: { recipientType: 'user', user: { id: userId } },
      order: { createdAt: 'DESC' },
    });
  }

  async getAdminNotifications() {
    return this.notificationRepo.find({
      where: { recipientType: 'admin' },
      order: { createdAt: 'DESC' },
    });
  }

  async markAsRead(id: number, user: any): Promise<any> {
    const notification = await this.notificationRepo.findOne({
      where: { id },
      relations: ['user'],
    });

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    // Check if the user is owner or admin
    if (
      (!notification.user || notification.user.id !== user.id) &&
      user.role !== 'admin'
    ) {
      throw new ForbiddenException(
        'You can only mark read your own notifications',
      );
    }
    
    
    await this.notificationRepo.update(id, { isRead: true });
  }
  async deleteNotification(id: number, user: any): Promise<any> {
    const notification = await this.notificationRepo.findOne({
      where: { id },
      relations: ['user'],
    });

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    // Check if the user is owner or admin
    if (
      (!notification.user || notification.user.id !== user.id) &&
      user.role !== 'admin'
    ) {
      throw new ForbiddenException(
        'You can only delete your own notifications',
      );
    }
    

    await this.notificationRepo.remove(notification);
    return { message: 'Notification deleted successfully' };
  }

  async markAllAsRead(userId: number): Promise<any> {
    // Marks all unread notifications for the user as read
    const result = await this.notificationRepo
      .createQueryBuilder()
      .update(Notification)
      .set({ isRead: true })
      .where('recipientType = :recipientType', { recipientType: 'user' })
      .andWhere('userId = :userId', { userId })
      .andWhere('isRead = false')
      .execute();

    return { affected: result.affected };
  }

  async markAllAdminNotificationsAsRead(): Promise<any> {
    // Log before finding
    console.log('Fetching unread admin notifications...');

    // Find unread admin notifications
    const unreadAdminNotifications = await this.notificationRepo.find({
      where: {
        recipientType: 'admin',
        isRead: false,
      },
    });

    console.log('Unread Admin Notifications:', unreadAdminNotifications.length);

    const ids = unreadAdminNotifications.map((n) => n.id);

    if (ids.length === 0) {
      console.log('No unread admin notifications found.');
      return { affected: 0 };
    }

    // Update using manual `where IN` to avoid issues with whereInIds
    const result = await this.notificationRepo
      .createQueryBuilder()
      .update(Notification)
      .set({ isRead: true })
      .where('id IN (:...ids)', { ids })
      .execute();

    console.log('Marked as read:', result.affected);
    return { affected: result.affected };
  }
}
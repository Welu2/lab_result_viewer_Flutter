// src/notifications/notification.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Notification } from './notification.entity';
import { NotificationService } from './notification.service';
import { NotificationController } from './notification.controller';
import { JwtModule } from '@nestjs/jwt';
import { UsersModule } from 'src/users/users.module';
import { AuthModule } from 'src/auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Notification]),
    JwtModule.register({}),
    UsersModule,
    AuthModule,
  ],
  providers: [NotificationService],
  controllers: [NotificationController],
  exports: [NotificationService, TypeOrmModule], // Make it usable in other modules like AppointmentService
})
export class NotificationModule {}

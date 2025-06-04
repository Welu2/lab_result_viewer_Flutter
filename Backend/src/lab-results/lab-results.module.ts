import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LabResult } from './entities/lab-result.entity';
import { LabResultsService } from './lab-results.service';
import { LabResultsController } from './lab-results.controller';
import { User } from 'src/users/user.entity';
import { NotificationModule } from '../notifications/notification.module';
import { UsersModule } from '../users/users.module';
import { AuthModule } from 'src/auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([LabResult, User]),
    NotificationModule,
    UsersModule,
    AuthModule,
  ],
  controllers: [LabResultsController],
  providers: [LabResultsService],
  exports: [LabResultsService],
})
export class LabResultsModule {}

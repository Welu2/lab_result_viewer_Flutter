import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { User } from './users/user.entity'; // Your User entity
import { ProfileModule } from './profile/profile.module';
import { Profile } from './profile/entities/profile.entity';
import { AppointmentModule } from './appointment/appointment.module';
import { Appointment } from './appointment/entities/appointment.entity';
import { Notification } from './notifications/notification.entity';
import { LabResultsModule } from './lab-results/lab-results.module';
import { LabResult } from './lab-results/entities/lab-result.entity';
import { DashboardModule } from './dashboard/dashboard.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'mysql', // Database type
      host: 'localhost', // MySQL host (localhost for local MySQL)
      port: 3306, // Default MySQL port
      username: 'root', // MySQL username (replace with your own)
      password: '', // MySQL password (replace with your own)
      database: 'my-nest-app', // Replace with your MySQL database name
      entities: [User,Profile,Appointment,Notification,LabResult], // List all entities you want to use
      synchronize: true, // Automatically sync database on app startup (only in dev, not recommended for production)
    }),
    TypeOrmModule.forFeature([User]),
    AuthModule,
    UsersModule,
    ProfileModule,
    AppointmentModule,
    LabResultsModule,
    DashboardModule,
  ],
})
export class AppModule {}

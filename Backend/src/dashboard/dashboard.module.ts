import { Module } from '@nestjs/common';
import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';
import { AppointmentModule } from '../appointment/appointment.module';
import { UsersModule } from '../users/users.module';
import { LabResultsModule } from '../lab-results/lab-results.module';

@Module({
  imports: [AppointmentModule, UsersModule, LabResultsModule],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {} 
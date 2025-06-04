import { Injectable } from '@nestjs/common';
import { AppointmentService } from '../appointment/appointment.service';
import { UsersService } from '../users/users.service';
import { LabResultsService } from '../lab-results/lab-results.service';
import { DashboardStatsDto } from './dashboard-stats.dto';

@Injectable()
export class DashboardService {
  constructor(
    private readonly appointmentService: AppointmentService,
    private readonly usersService: UsersService,
    private readonly labResultsService: LabResultsService,
  ) {}

  async getDashboardStats(): Promise<DashboardStatsDto> {
    // Get all appointments
    const allAppointments = await this.appointmentService.getAllAppointments();
    // Get all users
    const allUsers = await this.usersService.getAllUsers();
    // Get all lab results
    const allLabResults = await this.labResultsService.findAll();

    // Filter patients
    const patients = allUsers.filter(u => u.role === 'user');

    // Get today's date string (YYYY-MM-DD)
    const today = new Date().toISOString().slice(0, 10);
    const todaysAppointments = allAppointments.filter(appt =>
      appt.date && new Date(appt.date).toISOString().slice(0, 10) === today
    );

    // Get upcoming appointments (next 3, sorted by time)
    const upcomingAppointments = allAppointments
      .filter(appt => appt.date && new Date(appt.date) >= new Date())
      .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())
      .slice(0, 3)
      .map(appt => ({
        id: appt.id,
        time: appt.time?.slice(0, 5),
        patientName: appt.patient?.profile?.name || appt.patient?.email || 'Unknown',
        testType: appt.testType,
      }));

    return {
      totalAppointments: todaysAppointments.length,
      totalPatients: patients.length,
      totalLabResults: allLabResults.length,
      upcomingAppointments,
    };
  }
} 
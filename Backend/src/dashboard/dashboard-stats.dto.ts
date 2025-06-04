export class DashboardStatsDto {
  totalAppointments: number;
  totalPatients: number;
  totalLabResults: number;
  upcomingAppointments: Array<{
    id: number;
    time: string;
    patientName: string;
    testType: string;
  }>;
} 
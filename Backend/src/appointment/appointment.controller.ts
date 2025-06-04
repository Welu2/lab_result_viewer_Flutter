import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  ParseIntPipe,Request,
} from '@nestjs/common';
import { AppointmentService } from './appointment.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { RolesGuard } from 'src/auth/roles.guard';
import { Roles } from 'src/auth/roles.decorator';
import { Appointment } from './entities/appointment.entity';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';

@Controller('appointments')
export class AppointmentController {
  constructor(private readonly appointmentService: AppointmentService) {}

  // User: Create appointment
  @Post()
  @UseGuards(JwtAuthGuard)
  createAppointment(
    @Body() createAppointmentDto: CreateAppointmentDto,
    @Request() req,
  ): Promise<Appointment> {
    const { testType, date, time } = createAppointmentDto;

    // Automatically set the patientId of the logged-in user
    const patientId = req.user.id;
    return this.appointmentService.create(patientId, testType, date, time);
  }

  // User: Update appointment
  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  updateAppointment(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateAppointmentDto: UpdateAppointmentDto,
    @Request() req,
  ): Promise<Appointment> {
    const { testType, date, time } = updateAppointmentDto;
    const patientId = req.user.id;
    return this.appointmentService.update(id, patientId, testType, date, time);
  }

  // User: Delete appointment
  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  deleteAppointment(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { patientId: number },
    @Request() req,
  ): Promise<void> {
    const patientId = req.user.id;
    return this.appointmentService.delete(id, patientId);
  }

  // User: View all their appointments
  @Get('me')
  @UseGuards(JwtAuthGuard)
  getUserAppointments(
    @Request() req,
  ): Promise<Appointment[]> {
     const patientId = req.user.id;
    return this.appointmentService.getUserAppointments(patientId);
  }

  // Admin: View all appointments (optionally filter by status)
  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  getAllAppointments(@Query('status') status: string): Promise<Appointment[]> {
    return this.appointmentService.getAllAppointments(status);
  }

  // Admin: Confirm or disapprove appointment
  @Patch(':id/status')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  adminUpdateAppointmentStatus(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { status: 'confirmed' | 'disapproved' },
  ): Promise<Appointment | null> {
    return this.appointmentService.adminUpdateAppointmentStatus(
      id,
      body.status,
    );
  }
}

import { Injectable, NotFoundException ,  BadRequestException} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Appointment } from './entities/appointment.entity';
import { User } from 'src/users/user.entity';
import { NotificationService } from 'src/notifications/notification.service';

@Injectable()
export class AppointmentService {
  constructor(
    @InjectRepository(Appointment)
    private appointmentRepository: Repository<Appointment>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private notificationService: NotificationService,
  ) {}

  // Create Appointment
  async create(
    patientId: number,
    testType: string,
    date: string,
    time: string,
  ): Promise<Appointment> {
    const patient = await this.userRepository.findOne({
      where: { id: patientId },
    });
    if (!patient) {
      throw new NotFoundException('User not found');
    }

    const appointment = this.appointmentRepository.create({
      testType,
      date: new Date(date),
      time,
      patient,
      status: 'pending',
    });

    await this.appointmentRepository.save(appointment);

    await this.notificationService.notifyAdmin(
       `User ${patient.email} created a new appointment.`,
       'appointment_created',
     );
    return appointment;
  }

  // Update Appointment
  async update(
    id: number,
    patientId: number,
    testType: string,
    date: string | undefined,
    time: string,
  ): Promise<Appointment> {
    const appointment = await this.appointmentRepository.findOne({
      where: { id, patient: { id: patientId } },
      relations: ['patient'],
    });
    if (!appointment) {
      throw new NotFoundException('Appointment not found');
    }
    if (
      appointment.testType !== testType ||
      (appointment.date instanceof Date ? appointment.date.toISOString().slice(0, 10) : new Date(appointment.date).toISOString().slice(0, 10)) !== date ||
      appointment.time !== time
    ) {
      appointment.status = 'pending';
    }

    appointment.testType = testType;
    
    appointment.time = time;
     if (date) {
       const parsedDate = new Date(date);
       if (isNaN(parsedDate.getTime())) {
         throw new BadRequestException('Invalid date format');
       }
       appointment.date = parsedDate; // Only update if date is provided and valid
     }

    await this.appointmentRepository.save(appointment);

     await this.notificationService.notifyAdmin(
       `User ${appointment.patient.email} updated their appointment.`,
       'appointment_updated',
     );

    return appointment;
  }

  // Admin Confirm/Disapprove Appointment
  async adminUpdateAppointmentStatus(
    id: number,
    status: 'confirmed' | 'disapproved',
  ): Promise<Appointment | null> {
    const appointment = await this.appointmentRepository.findOne({
      where: { id },
      relations: ['patient'],
    });
    if (!appointment) {
      throw new NotFoundException('Appointment not found');
    }
  
    if (status === 'confirmed') {
      appointment.status = status;
      await this.appointmentRepository.save(appointment);
  
      await this.notificationService.notifyUser(
        appointment.patient,
        `Your appointment has been confirmed.`,
        'appointment_status_update',
      );
      return appointment;
    } else if (status === 'disapproved') {
      await this.notificationService.notifyUser(
        appointment.patient,
        `Your appointment has been disapproved.`,
        'appointment_status_update',
      );
      // Delete the appointment after notifying the user
      await this.appointmentRepository.remove(appointment);
      return null;
    }
    return null;
  }

  // Delete Appointment (User)
  async delete(id: number, patientId: number): Promise<void> {
    const appointment = await this.appointmentRepository.findOne({
      where: { id, patient: { id: patientId } },
      relations: ['patient'],
    });

    if (!appointment) {
      throw new NotFoundException('Appointment not found');
    }

    await this.appointmentRepository.remove(appointment);

     await this.notificationService.notifyAdmin(
       `User ${appointment.patient.email} deleted an appointment.`,
       'appointment_deleted',
     );
  }

  // Delete Appointment (Admin)
  async adminDeleteAppointment(id: number): Promise<void> {
    const appointment = await this.appointmentRepository.findOne({
      where: { id },
    });
    if (!appointment) {
      throw new NotFoundException('Appointment not found');
    }

    await this.appointmentRepository.remove(appointment);

     await this.notificationService.notifyAdmin(
       `Admin deleted appointment with ID ${id}.`,
       'admin_deleted',
     );
  }

  // Get User's Appointments
  async getUserAppointments(patientId: number): Promise<Appointment[]> {
    const patient = await this.userRepository.findOne({
      where: { id: patientId },
    });

    if (!patient) {
      throw new NotFoundException('User not found');
    }

    return await this.appointmentRepository.find({
      where: { patient: { id: patientId } },
      relations: ['patient'],
    });
  }

  // Get All Appointments (Admin)
  async getAllAppointments(status?: string): Promise<Appointment[]> {
    let query = this.appointmentRepository
      .createQueryBuilder('appointment')
      .leftJoinAndSelect('appointment.patient', 'patient');

    if (status) {
      query = query.where('appointment.status = :status', { status });
    }

    return await query.getMany();
  }

  // Notify Admin about user actions
  
}

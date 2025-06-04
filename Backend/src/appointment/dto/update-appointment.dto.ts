// update-appointment.dto.ts
import { IsString, IsNotEmpty, IsNumber } from 'class-validator';

export class UpdateAppointmentDto {
  @IsNumber()
  patientId: number;

  @IsString()
  @IsNotEmpty()
  testType: string;

  @IsString()
  @IsNotEmpty()
  date: string;

  @IsString()
  @IsNotEmpty()
  time: string;
}

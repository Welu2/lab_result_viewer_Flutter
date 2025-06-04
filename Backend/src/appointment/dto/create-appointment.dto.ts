import {
  IsInt,
  IsString,
  IsDateString,
  IsNotEmpty,
  IsOptional,
} from 'class-validator';

export class CreateAppointmentDto {
  @IsInt()
  @IsNotEmpty()
  patientId: Number; // The ID of the patient (User)

  @IsDateString() // Validates that the date is a valid ISO 8601 date string
  @IsNotEmpty()
  date: string;

  @IsString()
  @IsNotEmpty()
  time: string; // e.g., "10:00 AM"

  @IsString()
  @IsNotEmpty()
  testType: string; // e.g., "Blood Test"
}

import { IsString, IsNotEmpty, IsEnum, IsInt } from 'class-validator';
import { User } from 'src/users/user.entity';

export class CreateNotificationDto {
  @IsInt()
  @IsNotEmpty()
  userId: number; // The user to receive the notification

  @IsString()
  @IsNotEmpty()
  message: string; // The message content of the notification

  @IsEnum(['lab-result', 'appointment', 'system', 'other'])
  @IsNotEmpty()
  type: string; // Type of notification (e.g., lab result, appointment, etc.)
}

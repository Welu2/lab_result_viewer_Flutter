import {
  IsString,
  IsOptional,
  IsDateString,
  IsNumber,
  IsIn,
} from 'class-validator';

export class CreateProfileDto {
  @IsString()
  name: string;

  @IsDateString()
  dateOfBirth: string;

  @IsIn(['male', 'female', 'other'])
  gender: 'male' | 'female' | 'other';

  @IsOptional()
  @IsNumber()
  weight?: number;

  @IsOptional()
  @IsNumber()
  height?: number;

  @IsOptional()
  @IsString()
  bloodType?: string;

  
  @IsString()
  phoneNumber?: string;
}

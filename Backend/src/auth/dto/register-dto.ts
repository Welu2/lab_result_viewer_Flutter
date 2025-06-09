export class RegisterUserDto {
    email: string;
    password: string;
    name: string;
    dateOfBirth: string;
    gender: 'male' | 'female' | 'other';
    weight?: number;
    height?: number;
    relative?: string;
    bloodType?: string;
    phoneNumber?: string;
  }
  
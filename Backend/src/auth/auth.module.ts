import { forwardRef, Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { UsersModule } from '../users/users.module'; // Import UsersModule
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtAuthGuard } from './jwt-auth.guard';
import { ProfileModule } from 'src/profile/profile.module';

@Module({
  imports: [
    JwtModule.register({
      secret: 'your_secret_key', // Replace with a secure secret key
      signOptions: { expiresIn: '1h' }, // Token expiry (optional)
    }),
    UsersModule, // Import UsersModule to provide UsersService
    forwardRef(() => ProfileModule),
  ],
  providers: [AuthService, JwtAuthGuard], // Provide AuthService and JwtAuthGuard
  controllers: [AuthController],
  exports: [JwtModule, JwtAuthGuard, AuthService],
})
export class AuthModule {}

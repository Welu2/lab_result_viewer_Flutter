import {
  Controller,
  Post,
  Body,
  Delete,
  Param,
  Get,
  UseGuards,
} from '@nestjs/common';

import { AuthService } from './auth.service';

import { UsersService } from '../users/users.service';

import { JwtAuthGuard } from './jwt-auth.guard';

import { RolesGuard } from './roles.guard';

import { Roles } from './roles.decorator';

import { Role } from '../users/user.entity';

import { CurrentUser } from './current-user.decorator';

@Controller('auth')

export class AuthController {
  constructor(
    private authService: AuthService,
    private usersService: UsersService,
  ) {}

  // Signup Route

  @Post('signup')

  async signup(@Body() body: any) {
    if (
      !body ||
      typeof body !== 'object' ||
      !('email' in body) ||
      !('password' in body)
    ) {
      return { message: 'Email and password are required in the request body' };
    }

    const { email, password } = body;

    try {
      const { user, token } = await this.authService.signup(email, password); // Ensure token is returned
      return { user, token }; // Return user and token
    } catch (error) {
      return { message: 'Error during signup: ' + error.message };
    }
  }

  // Login Route

  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    const { email, password } = body;
    const user = await this.authService.validateUser(email, password);

    if (!user) {
      return { message: 'Invalid credentials' };
    }
    const token = await this.authService.login(user); // Return token after login
    return { message: 'Login successful', token };
  }

  // Get All Users - Only Admins

  @Get('users')

  @UseGuards(JwtAuthGuard, RolesGuard)

  @Roles(Role.ADMIN) // Only admins can access

  async getAllUsers(@CurrentUser() user: any) {

    return await this.usersService.findAll(user); // Pass currentUser here
  }

  // Get Own User Data - Any logged-in user

  @Get('user/:id')

  @UseGuards(JwtAuthGuard)

  async getUserData(@Param('id') patientId: string, @CurrentUser() user: any) {
    if (user.patientId !== patientId && user.role !== Role.ADMIN) {
      return {
        message: 'You can only view your own account, unless you are admin',
      };
    }
    return await this.usersService.findById(patientId);
  }

  // Delete Account - Only own account or Admin

  @Delete('delete/:id')

  @UseGuards(JwtAuthGuard)

  async deleteAccount(

    @Param('id') patientId: string,
    
    @CurrentUser() user: any,
  ) {
    if (user.patientId !== patientId && user.role !== Role.ADMIN) {
      return { message: 'You do not have permission to delete this account' };
    }
    try {
      await this.usersService.remove(patientId, user); // Pass currentUser here
      return { message: 'User account deleted successfully' };
    } catch (error) {
      return { message: 'Error deleting account: ' + error.message };
    }
  }
}

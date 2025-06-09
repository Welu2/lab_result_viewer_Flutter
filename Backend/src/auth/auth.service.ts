import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcryptjs';
import { Role } from '../users/user.entity';
import { ProfileService } from '../profile/profile.service';

import { RegisterUserDto } from './dto/register-dto';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private profileService: ProfileService,
  ) {}

  // Validate user credentials during login
  async validateUser(email: string, password: string) {
    const user = await this.usersService.findByEmail(email);

    if (!user) {
      return null; // User not found, return null
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (isPasswordValid) {
      // Return the user excluding password
      const userWithoutPassword = {
        id: user.id,
        email: user.email,
        role: user.role,
        patientId: user.patientId, // if exists
      };
      return userWithoutPassword;
    }

    return null;
  }

  // Invalid password
  async registerWithProfile(data: RegisterUserDto) {
    const { email, password, ...profileData } = data;

    // 1. Check for existing user
    const existingUser = await this.usersService.findByEmail(email);
    if (existingUser) {
      throw new HttpException('User already exists', HttpStatus.BAD_REQUEST);
    }

    // 2. Create user
    const newUser = await this.usersService.createUser(email, password);

    // 3. Assign patientId (if applicable)
    newUser.patientId = newUser.patientId;

    await this.usersService.save(newUser); // if UsersService has a save method

    // 4. Create profile for user
    const profile = await this.profileService.register(profileData, newUser);

    // 5. Generate token
    const payload = {
      email: newUser.email,
      sub: newUser.id,
      role: newUser.role,
    };

    const token = {
      access_token: this.jwtService.sign(payload),
    };

    return { user: newUser, profile, token };
  }

  // Login method to generate JWT token
  async login(user: any) {
    const payload = {
      email: user.email,
      sub: user.id,
      role: user.role,
    };
    return {
      access_token: this.jwtService.sign(payload), // Create JWT token
    };
  }

  // Signup method to register a new user
  async signup(email: string, password: string) {
    // Check if the email already exists
    const existingUser = await this.usersService.findByEmail(email);
    if (existingUser) {
      throw new HttpException(
        'User already exists with that email',
        HttpStatus.BAD_REQUEST, // Return a 400 error if the user already exists
      );
    }

    // Create the user with the provided email and hashed password
    const newUser = await this.usersService.createUser(email, password);

    // Generate JWT token for the newly created user
    const payload = {
      email: newUser.email,
      sub: newUser.id,
      role: newUser.role,
    };

    return {
      user: newUser,
      token: {
        access_token: this.jwtService.sign(payload),
      },
    };
  }

  // Delete user account by user ID
  async deleteAccount(patientId: string, currentUser: any) {
    const user = await this.usersService.findById(patientId);
    if (!user) {
      throw new HttpException('User not found', HttpStatus.NOT_FOUND); // Handle case where user is not found
    }

    // Only the user or an admin can delete the account
    if (currentUser.id !== patientId && currentUser.role !== Role.ADMIN) {
      throw new HttpException(
        'You do not have permission to delete this account',
        HttpStatus.FORBIDDEN, // Handle unauthorized access
      );
    }

    // Pass both userId and currentUser to the remove method
    await this.usersService.remove(patientId, currentUser);

    return { message: 'User account deleted successfully' }; // Return success message
  }
}

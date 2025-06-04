import {
  Injectable,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, Role } from './user.entity';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  // Find user by email
  async findByEmail(email: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { email } });
  }

  // Find user by ID
  async findById(patientId: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { patientId } });
  }

  // Generate a unique patient ID like "PAT-00001"
  async generatePatientId(): Promise<string> {
    const latestUser = await this.usersRepository
      .createQueryBuilder('user')
      .orderBy('user.patientId', 'DESC')
      .getOne();

    const latestId =
      latestUser && latestUser.patientId
        ? parseInt(latestUser.patientId.split('-')[1], 10)
        : 0;
    const newIdNumber = latestId + 1;

    return `PAT-${newIdNumber.toString().padStart(5, '0')}`;
  }

  // Create a new user with hashed password and generated patient ID
  async createUser(email: string, password: string): Promise<User> {
    const existingUser = await this.findByEmail(email);
    if (existingUser) {
      throw new ConflictException('Email already in use');
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const role: Role = email.endsWith('@pulse.org') ? Role.ADMIN : Role.USER;

    let patientId: string | null = null;
    if (role !== Role.ADMIN) {
      patientId = await this.generatePatientId(); // Generate patient ID only for regular users
    }

    // Create user with the hashed password, role, and patient ID
    const newUser = this.usersRepository.create({
      email,
      password: hashedPassword,
      role,
      patientId, // Save the generated patient ID (null for admin users)
    });

    return this.usersRepository.save(newUser);
  }

  // Remove user by ID - Only the user themselves or Admin
  async remove(patientId: string, currentUser: User): Promise<void> {
    if (
      currentUser.patientId !== patientId &&
      currentUser.role !== Role.ADMIN
    ) {
      throw new ForbiddenException(
        'You do not have permission to delete this user',
      );
    }
    await this.usersRepository.delete(patientId);
  }

  // Update user data - Only the user themselves or Admin
  async updateUser(
    patientId: string,
    currentUser: User,
    email?: string,
    password?: string,
  ): Promise<User | undefined> {
    if (
      currentUser.patientId !== patientId &&
      currentUser.role !== Role.ADMIN
    ) {
      throw new ForbiddenException(
        'You do not have permission to update this user',
      );
    }
    const user = await this.findById(patientId);
    if (user) {
      if (email) user.email = email;
      if (password) user.password = await bcrypt.hash(password, 10);
      return this.usersRepository.save(user);
    }
    return undefined;
  }

  // Find all users - Only Admins
  async findAll(currentUser: User): Promise<User[]> {
    if (currentUser.role !== Role.ADMIN) {
      throw new ForbiddenException('Only admins can view all users');
    }
    return this.usersRepository.find();
  }

  // Get all users (for internal use, e.g., dashboard aggregation)
  async getAllUsers(): Promise<User[]> {
    return this.usersRepository.find();
  }
}

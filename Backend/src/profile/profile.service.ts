import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateProfileDto } from './dto/create-profile.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UpdateEmailDto } from './dto/update-email.dto';
import { Profile } from './entities/profile.entity';
import { User } from 'src/users/user.entity';
import { UsersService } from 'src/users/users.service';

@Injectable()
export class ProfileService {
  constructor(
    @InjectRepository(Profile)
    private readonly profileRepository: Repository<Profile>,
    private readonly usersService: UsersService
  ) {}

  async create(data: CreateProfileDto & { user: User }) {
    const profile = this.profileRepository.create(data);
    return this.profileRepository.save(profile);
  }

  async findAll() {
    return this.profileRepository.find({ relations: ['user'] });
  }

  async findOne(id: number) {
    const profile = await this.profileRepository.findOne({
      where: { id },
      relations: ['user'],
    });

    if (!profile) {
      throw new NotFoundException(`Profile with id ${id} not found`);
    }

    return profile;
  }

  async findByUserId(userId: number) {
    const profile = await this.profileRepository.findOne({
      where: { user: { id: userId } },
      relations: ['user'],
    });

    if (!profile) {
      throw new NotFoundException(`Profile for user ${userId} not found`);
    }

    return profile;
  }

  async update(id: number, updateProfileDto: UpdateProfileDto) {
    const profile = await this.findOne(+id);
    const updated = this.profileRepository.merge(profile, updateProfileDto);
    return this.profileRepository.save(updated);
  }

  async remove(id: number) {
    const profile = await this.findOne(+id);
    const userId = profile.user.id;
    
    // First remove the profile
    await this.profileRepository.remove(profile);
    
    // Then remove the user
    await this.profileRepository.manager.getRepository(User).delete(userId);
    
    return { message: 'Profile and user deleted successfully' };
  }

  async findByPatientId(patientId: string) {
    const profile = await this.profileRepository.findOne({
      where: { patientId },
      relations: ['user'],
    });

    if (!profile) {
      throw new NotFoundException(
        `Profile with patientId ${patientId} not found`,
      );
    }

    return profile;
  }

  async updateEmail(userId: number, updateEmailDto: UpdateEmailDto) {
    const profile = await this.findByUserId(userId);
    if (!profile.user.patientId) {
      throw new NotFoundException('User patientId not found');
    }
    const updatedUser = await this.usersService.updateUser(
      profile.user.patientId,
      profile.user,
      updateEmailDto.email,
      updateEmailDto.password
    );
  
    if (!updatedUser) {
      throw new NotFoundException('Failed to update email');
    }
  
    return this.findByUserId(userId);
  }
}


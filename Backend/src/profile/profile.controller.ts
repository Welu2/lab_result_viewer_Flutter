import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
  ForbiddenException,
} from '@nestjs/common';
import { ProfileService } from './profile.service';
import { CreateProfileDto } from './dto/create-profile.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UpdateEmailDto } from './dto/update-email.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('profile')
export class ProfileController {
  constructor(private readonly profileService: ProfileService) {}

  @Post()
  async create(@Body() createProfileDto: CreateProfileDto, @Request() req) {
    return this.profileService.create({
      ...createProfileDto,
      user: req.user, // Attach the logged-in user to the profile
    });
  }

  @Get()
  async findAll(@Request() req) {
    if (req.user.role !== 'admin') {
      throw new ForbiddenException('Only admins can view all profiles');
    }
    return this.profileService.findAll();
  }

  @Get('me')
  async findMyProfile(@Request() req) {
    return this.profileService.findByUserId(req.user.id);
  }

  @Get(':id')
  async findOne(@Param('id') id: number, @Request() req) {
    const profile = await this.profileService.findOne(id);
    if (req.user.role !== 'admin' && req.user.id !== profile.user.id) {
      throw new ForbiddenException('Access denied');
    }
    return profile;
  }

  @Patch('update-email')
  async updateEmail(
    @Body() updateEmailDto: UpdateEmailDto,
    @Request() req,
  ) {
    return this.profileService.updateEmail(req.user.id, updateEmailDto);
  }

  @Patch(':id')
  async update(
    @Param('id') id: number,
    @Body() body: UpdateProfileDto,
    @Request() req,
  ) {
    const profile = await this.profileService.findOne(id);
    if (req.user.role !== 'admin' && req.user.id !== profile.user.id) {
      throw new ForbiddenException('Access denied');
    }
    return this.profileService.update(id, body);
  }

  @Delete(':id')
  async delete(@Param('id') id: number, @Request() req) {
    const profile = await this.profileService.findOne(id);
    if (req.user.role !== 'admin' && req.user.id !== profile.user.id) {
      throw new ForbiddenException('Access denied');
    }
    return this.profileService.remove(id);
  }
  @Get('by-patient/:patientId')
  async findByPatientId(@Param('patientId') patientId: string, @Request() req) {
    const profile = await this.profileService.findByPatientId(patientId);

    if (req.user.role !== 'admin' && req.user.id !== profile.user.id) {
      throw new ForbiddenException('Access denied');
    }

    return profile;
  }
}

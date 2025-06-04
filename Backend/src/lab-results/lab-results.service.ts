import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LabResult } from './entities/lab-result.entity';
import { Notification } from '../notifications/notification.entity';
import { User } from '../users/user.entity';
import { NotificationService } from '../notifications/notification.service';
import { CreateLabResultDto } from './dto/create-lab-result.dto';
import { UpdateLabResultDto } from './dto/update-lab-result.dto';

@Injectable()
export class LabResultsService {
  constructor(
    @InjectRepository(LabResult)
    private readonly labResultRepo: Repository<LabResult>,
    @InjectRepository(Notification)
    private readonly notificationRepo: Repository<Notification>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly notificationService: NotificationService, // Inject NotificationService
  ) {}

  // ADMIN: Create lab result
  async create(createLabResultDto: CreateLabResultDto): Promise<LabResult> {
    const user = await this.userRepo.findOne({
      where: { id: createLabResultDto.userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const labResult = this.labResultRepo.create({
      title: createLabResultDto.title,
      description: createLabResultDto.description,
      filePath: createLabResultDto.filePath,
      user: user,
      patientId: user.patientId, // set directly to avoid relying on @BeforeInsert
    });

    return this.labResultRepo.save(labResult);
  }

  // ADMIN: Send result to the user
  async sendToUser(id: number): Promise<LabResult> {
    const result = await this.labResultRepo.findOne({
      where: { id }, // Use `where` to filter by `id`
      relations: ['user'], // Include related `user` entity
    });

    if (!result) throw new NotFoundException('Lab result not found');

    // Mark the result as sent
    result.isSent = true;
    await this.labResultRepo.save(result);

    // Create a notification for the user using the NotificationService
    await this.notificationService.createNotification({
      userId: result.user.id, // User to receive the notification
      message: `Your lab result titled "${result.title}" is now available.`,
      type: 'lab-result', // Type of notification (e.g., lab-result)
    });

    return result;
  }
  // Send lab result to the user by patientId
  async sendToUserByPatientId(patientId: string): Promise<LabResult> {
    // Fetch lab result by patientId
    const result = await this.labResultRepo.findOne({
      where: { patientId },
      relations: ['user'], // Include the user relation to access the user data
    });

    if (!result) {
      throw new NotFoundException('Lab result not found for this patient ID');
    }

    if (!result.user) {
      throw new NotFoundException('User not found for this lab result');
    }

    // Get the userId from the fetched user
    const userId = result.user.id;

    // Mark the result as sent
    result.isSent = true;
    await this.labResultRepo.save(result);

    // Create and send the notification
    await this.notificationService.createNotification({
      userId, // User who will receive the notification
      message: `Your lab result titled "${result.title}" is now available.`,
      type: 'lab-result', // Type of notification
    });

    return result;
  }
  // Find all lab results for a user (USER only)
  async findAllByUser(userId: number): Promise<LabResult[]> {
    return this.labResultRepo.find({ where: { user: { id: userId } } });
  }

  // Find one lab result for a user (USER only)
  async findOneForUser(id: number, userId: number): Promise<LabResult> {
    const result = await this.labResultRepo.findOne({
      where: { id, user: { id: userId } },
    });
    if (!result) throw new NotFoundException('Lab result not found');
    return result;
  }

  // ADMIN: Get all lab results
  async findAll(): Promise<LabResult[]> {
    return this.labResultRepo.find({
      relations: ['user.profile'],
      order: { createdAt: 'DESC' },
    });
  }

  // Other CRUD operations (update, remove, etc.) remain as needed

  async update(
    id: number,
    updateLabResultDto: UpdateLabResultDto,
  ): Promise<LabResult> {
    // Correct usage of `findOne` with options
    const result = await this.labResultRepo.findOne({
      where: { id }, // Find the lab result by ID
    });

    if (!result) throw new NotFoundException('Lab result not found');

    // Update the result with new values
    Object.assign(result, updateLabResultDto);

    // Save the updated result
    return this.labResultRepo.save(result);
  }

  async remove(id: number): Promise<void> {
    // Correct usage of `findOne` with options
    const result = await this.labResultRepo.findOne({
      where: { id }, // Use `where` to specify the condition
    });

    if (!result) throw new NotFoundException('Lab result not found');

    // Remove the found lab result
    await this.labResultRepo.remove(result);
  }

  async getDownloadPath(labResultId: number, userId: number): Promise<string> {
    // Logic to retrieve the lab result based on labResultId and userId
    const result = await this.labResultRepo.findOne({
      where: { id: labResultId, user: { id: userId } },
      relations: ['user'],
    });

    if (!result) {
      throw new NotFoundException('Lab result not found');
    }

    // Assuming the file path is stored in the `filePath` column of the LabResult entity
    return result.filePath;
  }
  async createForUser(
    userId: number,
    dto: CreateLabResultDto,
  ): Promise<LabResult> {
    const user = await this.userRepo.findOne({
      where: { patientId: String(userId) },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const labResult = this.labResultRepo.create({
      ...dto,
      user,
    });

    return this.labResultRepo.save(labResult);
  }
  async createForPatient(
    patientId: string,
    data: Partial<CreateLabResultDto>,
  ): Promise<LabResult> {
    const user = await this.userRepo.findOne({ where: { patientId } });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const labResult = this.labResultRepo.create({
      ...data,
      user,
      patientId: user.patientId,
    });

    return this.labResultRepo.save(labResult);
  }
}

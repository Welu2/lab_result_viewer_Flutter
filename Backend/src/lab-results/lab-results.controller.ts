import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  UploadedFile,
  UseInterceptors,
  Req,
  Res,
} from '@nestjs/common';
import { NotFoundException,UnauthorizedException } from '@nestjs/common';

import { LabResultsService } from './lab-results.service';
import { CreateLabResultDto } from './dto/create-lab-result.dto';
import { UpdateLabResultDto } from './dto/update-lab-result.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { Response, Request } from 'express';
import * as path from 'path';
import { NotificationService } from '../notifications/notification.service'; // Import the NotificationService
import { User } from 'src/users/user.entity';

@Controller('lab-results')
@UseGuards(JwtAuthGuard, RolesGuard)
export class LabResultsController {
  constructor(
    private readonly labResultsService: LabResultsService,
    private readonly notificationService: NotificationService, // Inject the NotificationService
  ) {}

  // ADMIN: Create lab result manually
  @Post()
  @Roles('admin')
  create(@Body() createLabResultDto: CreateLabResultDto) {
    return this.labResultsService.create(createLabResultDto);
  }

  // ADMIN: Upload lab result file for a user
  @Post('upload/:patientId')
  @Roles('admin')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, cb) => {
          const unique = `${Date.now()}-${file.originalname}`;
          cb(null, unique);
        },
      }),
    }),
  )
  upload(
    @Param('patientId') patientId: string,
    @UploadedFile() file: Express.Multer.File,
    @Body() body: { testType: string },
  ) {
    return this.labResultsService.createForPatient(patientId, {
      title: body.testType || 'Lab Result', // Use testType from frontend, fallback to 'Lab Result'
      description: 'Uploaded lab result',
      filePath: file.path,
    });
  }

  // ADMIN: Send result to user (marks as sent + triggers notification)
  //@Patch(':id/send')
  @Post(':id/send')
  @Roles('admin')
  async sendResult(@Param('id') id: string) {
    const result = await this.labResultsService.sendToUser(+id); // Ensures `id` is a number

    if (!result) {
      throw new NotFoundException('Lab result not found');
    }

    // Assuming result has a `user` object or `userId` you can use
    const userId = result.user?.id;

    if (!userId) {
      throw new NotFoundException('User not found for this lab result');
    }

    // Create notification using NotificationService after result is sent
    const notification = await this.notificationService.createNotification({
      userId, // User who will receive the notification
      message: `Your lab result titled "${result.title}" is now available.`,
      type: 'lab-result', // You can use this type to categorize notifications
    });

    return {
      message: 'Result sent to user and notification triggered',
      result,
      notification,
    };
  }
  @Post('send/:patientId')
  @Roles('admin')
  async sendByPatientId(@Param('patientId') patientId: string) {
    const result =
      await this.labResultsService.sendToUserByPatientId(patientId);

    return {
      message: 'Result sent to user and notification triggered',
      result,
    };
  }

  // ADMIN ONLY: Update lab result
  @Patch(':id')
  @Roles('admin')
  update(
    @Param('id') id: string,
    @Body() updateLabResultDto: UpdateLabResultDto,
  ) {
    return this.labResultsService.update(+id, updateLabResultDto);
  }

  // ADMIN ONLY: Delete lab result
  @Delete(':id')
  @Roles('admin')
  remove(@Param('id') id: string) {
    return this.labResultsService.remove(+id);
  }

  // USER: Get all results (only their own)
  @Get()
  @Roles('user')
  findAll(@Req() req: Request) {
    if (!req.user) {
      throw new UnauthorizedException('User is not authenticated');
    }
    const userId = req.user['id'];
    return this.labResultsService.findAllByUser(userId);
  }

  @Get('admin')
  @Roles('admin')
  getAllForAdmin() {
    return this.labResultsService.findAll();
  }

  // USER: Get a specific result if it belongs to them
  @Get(':id')
  @Roles('user')
  findOne(@Param('id') id: string, @Req() req: Request) {
    if (!req.user) {
      throw new UnauthorizedException('User is not authenticated');
    }
    return this.labResultsService.findOneForUser(+id, req.user['id']);
  }

  // USER: Download file (if it's theirs)
  @Get('download/:id')
  @Roles('user') // Assuming you have a custom Roles decorator to check the user's role
  async download(
    @Param('id') id: string,
    @Req() req: Request,
    @Res() res: Response,
  ) {
    // Check if req.user exists
    if (!req.user) {
      throw new UnauthorizedException('User not authenticated');
    }

    // Ensure id is a number
    const labResultId = +id;

    // Ensure the userId exists from the request
    const userId = req.user['id'];

    if (!userId) {
      throw new UnauthorizedException('User ID not found');
    }

    // Fetch the file path for the download 
    const filePath = await this.labResultsService.getDownloadPath(
      labResultId,
      userId,
    );

    if (!filePath) {
      throw new NotFoundException('Lab result not found or file not available');
    }

    // Get the filename from the file path
    const filename = path.basename(filePath);

    // Send the file as a download
    return res.download(filePath, filename);
  }
}

import { PartialType } from '@nestjs/mapped-types';
import { CreateLabResultDto } from './create-lab-result.dto';

export class UpdateLabResultDto extends PartialType(CreateLabResultDto) {}

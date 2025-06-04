import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './user.entity';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';


@Module({
  imports: [TypeOrmModule.forFeature([User])], // Add the User entity to the TypeOrmModule
  providers: [UsersService], // Make sure UsersService is in the providers array
  exports: [UsersService], // Export UsersService to be used in other modules (e.g., AuthModule)
  controllers: [UsersController],
})
export class UsersModule {}

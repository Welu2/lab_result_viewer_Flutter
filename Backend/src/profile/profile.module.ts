// profile.module.ts
import { forwardRef, Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProfileService } from './profile.service';
import { ProfileController } from './profile.controller';
import { Profile } from './entities/profile.entity';
import { User } from 'src/users/user.entity';
import { AuthModule } from 'src/auth/auth.module'; // ✅ import your AuthModule
import { UsersModule } from 'src/users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Profile, User]),
    forwardRef(() => AuthModule),
    UsersModule,
  ],
  controllers: [ProfileController],
  providers: [ProfileService],
  exports: [ProfileService],
})
export class ProfileModule {}

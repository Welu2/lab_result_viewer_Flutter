import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  ForbiddenException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from './roles.decorator'; // adjust path

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private jwtService: JwtService,
    private userService: UsersService,
    private reflector: Reflector, // <- Add Reflector to read metadata
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = request.headers['authorization']?.split(' ')[1];

    if (!token) {
      throw new UnauthorizedException('Token missing');
    }

    try {
      const decodedToken = this.jwtService.verify(token, {
        secret: process.env.JWT_SECRET, // Add the secret used when signing the JWT
      });

      const user = await this.userService.findByEmail(decodedToken.email);

      if (!user) {
        throw new ForbiddenException('User not found');
      }
      request.user = { ...user, role: decodedToken.role };


      const requiredRoles = this.reflector.getAllAndOverride<string[]>(
        ROLES_KEY,
        [context.getHandler(), context.getClass()],
      );

      if (!requiredRoles || requiredRoles.length === 0) {
        return true;
      }
      const hasRole = requiredRoles.includes(request.user.role);

     
      if (!hasRole) {
        throw new ForbiddenException('Access denied: insufficient role');
      }

      return true;
    } catch (error) {
      console.log('JWT Error:', error.message);
      throw new UnauthorizedException('Invalid or expired token');
    }
  }
}

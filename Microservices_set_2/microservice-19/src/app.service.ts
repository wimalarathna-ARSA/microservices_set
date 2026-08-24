import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Hello from Microservice 19 (TypeScript NestJS)';
  }
}
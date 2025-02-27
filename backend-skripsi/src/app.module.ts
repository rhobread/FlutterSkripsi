import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UserModule } from './user/user.module';
import { DatabaseModule } from './database/database.module';
import { FileModule } from './file/file.module';
import { WorkoutModule } from './workout/workout.module';

@Module({
  imports: [UserModule, DatabaseModule, FileModule, WorkoutModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }

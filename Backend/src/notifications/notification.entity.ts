// src/notifications/entities/notification.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,JoinColumn,BeforeInsert,
} from 'typeorm';
import { User } from 'src/users/user.entity';

@Entity()
export class Notification {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  message: string;

  @Column({ default: false })
  isRead: boolean;

  @Column()
  type: string;

  @Column({ type: 'enum', enum: ['user', 'admin'] })
  recipientType: 'user' | 'admin';

  @ManyToOne(() => User, (user) => user.notifications, {
    nullable: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'userId' })
  user?: User;

  // @ManyToOne(() => User, (user) => user.appointments, { nullable: true }) // One user can have many appointments
  // @JoinColumn({ name: 'userId' })
  // user?: User;
  @Column({ type: 'varchar', length: 255, nullable: true })
  patientId: string | null; // Store the patientId from User

  // On insert, set the patientId to be the same as User's patientId
  @BeforeInsert()
  setPatientId() {
    if (this.recipientType === 'user' && this.user) {
      this.patientId = this.user.patientId;
    } else {
      this.patientId = null;
    }
  }

  @CreateDateColumn()
  createdAt: Date;
}

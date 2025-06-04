import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  OneToOne,
  JoinColumn,BeforeInsert,
} from 'typeorm';
import { User } from '../../users/user.entity';

@Entity()
export class Profile {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column()
  relative: string;

  @Column({ type: 'date' })
  dateOfBirth: Date;

  @Column()
  gender: 'male' | 'female' | 'other';

  @Column({ type: 'float', nullable: true })
  weight: number;

  @Column({ type: 'float', nullable: true })
  height: number;

  @Column({ nullable: true })
  bloodType: string;

  @Column({ nullable: true })
  phoneNumber: string;

  // Relationship to User
  @OneToOne(() => User, (user) => user.profile, { eager: true, cascade: true })
  @JoinColumn({ name: 'userId' }) // creates a foreign key column 'userId'
  user: User;

  @Column({ type: 'varchar', length: 255, nullable: true })
  patientId: string | null; // Store the patientId from User

  // On insert, set the patientId to be the same as User's patientId
  @BeforeInsert()
  setPatientId() {
    if (this.user) {
      this.patientId = this.user.patientId;
    }
  }
}


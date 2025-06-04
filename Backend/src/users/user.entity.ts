import { Entity, PrimaryGeneratedColumn, Column,OneToMany ,OneToOne} from 'typeorm';
import { Appointment } from '../appointment/entities/appointment.entity';
import { LabResult } from 'src/lab-results/entities/lab-result.entity';
import { Profile } from 'src/profile/entities/profile.entity';
export enum Role {
  USER = 'user',
  ADMIN = 'admin',
}

@Entity()
export class User {
  @PrimaryGeneratedColumn()
  id: number;
  @Column({ type: 'varchar', length: 255, nullable: true, unique: true })
  patientId: string | null; // e.g., "PAT-00001"

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @Column()
  role: Role;
  // One-to-many relationship with Appointment
  @OneToMany(() => Appointment, (appointment) => appointment.patient) // One user can have many appointments
  appointments: Appointment[];
  @OneToMany(() => LabResult, (result) => result.user)
  results: LabResult[];
  @OneToOne(() => Profile, (profile) => profile.user)
  profile: Profile;
}

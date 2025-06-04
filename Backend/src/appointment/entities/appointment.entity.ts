// appointment.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,BeforeInsert,
} from 'typeorm';
import { User } from 'src/users/user.entity'; // Import the User entity

@Entity()
export class Appointment {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'date' })
  date: Date; // The date of the appointment

  @Column({ type: 'time' })
  time: string; // The time of the appointment

  @Column()
  testType: string; // The type of test (e.g., blood test, X-ray)

  @Column({ default: 'pending' })
  status: 'pending' | 'confirmed' | 'disapproved'; // Status of the appointment

  // Foreign key references for both user id and patientId
  @ManyToOne(() => User, (user) => user.appointments) // One user can have many appointments
  @JoinColumn({ name: 'userId' }) // This will reference User's id column
  patient: User;

  @Column({ type: 'varchar', length: 255, nullable: true })
  patientId: string | null; // Store the patientId from User

  // On insert, set the patientId to be the same as User's patientId
  @BeforeInsert()
  setPatientId() {
    if (this.patient) {
      this.patientId = this.patient.patientId;
    }
  }
}

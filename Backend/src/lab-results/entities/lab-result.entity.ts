import { Entity, PrimaryGeneratedColumn, Column, ManyToOne,CreateDateColumn ,JoinColumn,BeforeInsert,} from 'typeorm';
import { User } from 'src/users/user.entity';
@Entity()
export class LabResult {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  title: string;

  @Column({ nullable: true })
  description: string;

  @Column()
  filePath: string; // Local path

  @Column({ default: false })
  isSent: boolean;

  @ManyToOne(() => User, (user) => user.appointments) // One user can have many appointments
  @JoinColumn({ name: 'UserId' }) // If you want the column to be specifically 'patientId'
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


  @CreateDateColumn()
  createdAt: Date;
}

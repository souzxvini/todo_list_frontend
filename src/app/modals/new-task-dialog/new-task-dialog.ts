import { ChangeDetectorRef, Component, inject } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSnackBar } from '@angular/material/snack-bar';
import { TasksService } from '../../services/tasks.service';
import { MatIconModule } from '@angular/material/icon';
import { finalize } from 'rxjs';

@Component({
  selector: 'app-new-task-dialog',
  imports: [
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatCheckboxModule,
    ReactiveFormsModule,
    MatIconModule
  ],
  templateUrl: './new-task-dialog.html',
  styleUrl: './new-task-dialog.scss',
})
export class NewTaskDialog {
  private readonly fb = inject(FormBuilder);
  private readonly tasksService = inject(TasksService);
  private readonly dialogRef = inject(MatDialogRef<NewTaskDialog>);
  private readonly cdr = inject(ChangeDetectorRef);
  private readonly snackBar = inject(MatSnackBar);

  taskForm: FormGroup = this.fb.group({
    titulo: ['', [Validators.required]],
    descricao: ['', [Validators.required]],
    manterModalAberta: [false]
  });

  isSubmitting = false;

  onSubmit(): void {
    if (this.taskForm.valid) {
      this.isSubmitting = true;
      const formValue = this.taskForm.value as { titulo: string; descricao: string; manterModalAberta: boolean };
      
      this.tasksService.createTask(formValue.titulo, formValue.descricao)
        .pipe(
          finalize(() => {
            this.isSubmitting = false;
            this.cdr.detectChanges();
          })
        ).subscribe({
          next: () => {
            this.snackBar.open('Tarefa criada com sucesso!', '', {
              duration: 3000,
              horizontalPosition: 'center',
              verticalPosition: 'bottom',
              panelClass: ['snackbar-success']
            });

            if (!formValue.manterModalAberta) {
              this.dialogRef.close();
            } else {
              this.taskForm.patchValue({
                titulo: '',
                descricao: '',
                manterModalAberta: true
              });
            }
          },
          error: (error: unknown) => {
            console.error('Erro ao criar tarefa:', error);
            this.snackBar.open('Erro ao criar tarefa. Tente novamente.', '', {
              duration: 225000,
              horizontalPosition: 'center',
              verticalPosition: 'bottom',
              panelClass: ['snackbar-error']
            });
          }
        });
    }
  }

  onCancel(): void {
    this.dialogRef.close();
  }
}


import { Injectable, inject, signal } from '@angular/core';
import { Observable, tap } from 'rxjs';
import { ApiIntegrationService } from './api-integration.service';
import { Task } from '../models';

@Injectable({
  providedIn: 'root'
})
export class TasksService {
  private readonly apiIntegration = inject(ApiIntegrationService);

  tasks = signal<Task[]>([]);

  fetchTasks(): void {
    this.apiIntegration.get<Task[]>('/tasks').subscribe({
      next: (tasks) => {
        this.tasks.set(tasks);
      },
      error: (error) => {
        console.error('Erro ao buscar tarefas:', error);
      }
    });
  }

  createTask(titulo: string, descricao: string): Observable<Task> {
    return this.apiIntegration.post<Task>('/tasks', { titulo, descricao }).pipe(
      tap(task => {
        this.addTask(task);
      })
    );
  }

  addTask(task: Task): void {
    this.tasks.update(currentTasks => [...currentTasks, task]);
  }

  removeTask(taskId: string): void {
    this.tasks.update(currentTasks => currentTasks.filter(task => task.id !== taskId));
  }

  updateTask(updatedTask: Task): void {
    this.tasks.update(currentTasks =>
      currentTasks.map(task => task.id === updatedTask.id ? updatedTask : task)
    );
  }
}


import { CdkDrag, CdkDragDrop, CdkDropList, moveItemInArray, transferArrayItem } from '@angular/cdk/drag-drop';
import { Component, inject } from '@angular/core';
import { MatButtonModule} from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDialog } from '@angular/material/dialog';
import { NewTaskDialog } from './new-task-dialog/new-task-dialog';
import { ConfirmLogoutDialog } from './confirm-logout-dialog/confirm-logout-dialog';

@Component({
  selector: 'app-home',
  imports: [CdkDropList, CdkDrag, MatButtonModule, MatIconModule],
  templateUrl: './home.html',
  styleUrl: './home.scss',
})
export class Home {
  private readonly dialog = inject(MatDialog);

  todo = ['Get to work', 'Pick up groceries', 'Go home'];
  inProgress = ['Review code', 'Write documentation'];
  done = ['Get up', 'Brush teeth', 'Take a shower'];

  drop(event: CdkDragDrop<string[]>) {
    if (event.previousContainer === event.container) {
      moveItemInArray(event.container.data, event.previousIndex, event.currentIndex);
    } else {
      transferArrayItem(
        event.previousContainer.data,
        event.container.data,
        event.previousIndex,
        event.currentIndex,
      );
    }
  }

  logout(): void {
    this.dialog.open(ConfirmLogoutDialog, {
      width: '400px',
    });
  }

  openNewTaskDialog(): void {
    this.dialog.open(NewTaskDialog, {
      width: '500px',
    });
  }
}

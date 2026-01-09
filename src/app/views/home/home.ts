import { CdkDrag, CdkDragDrop, CdkDropList, moveItemInArray, transferArrayItem } from '@angular/cdk/drag-drop';
import { Component } from '@angular/core';
import { MatButtonModule} from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-home',
  imports: [CdkDropList, CdkDrag, MatButtonModule, MatIconModule],
  templateUrl: './home.html',
  styleUrl: './home.scss',
})
export class Home {

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
    // Limpa tudo local do app (session + local)
    sessionStorage.clear();
    localStorage.clear();
  
    const logoutUri = encodeURIComponent(environment.appUrl);
    window.location.href =
      `${environment.cognitoLogoutUrl}` +
      `?client_id=7lt80c43cs8mplhdop9r3ao57n` +
      `&logout_uri=${logoutUri}`;
  }
}

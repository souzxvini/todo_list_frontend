import { Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-confirm-logout-dialog',
  imports: [
    MatDialogModule,
    MatButtonModule
  ],
  templateUrl: './confirm-logout-dialog.html',
  styleUrl: './confirm-logout-dialog.scss',
})
export class ConfirmLogoutDialog {
  private readonly dialogRef = inject(MatDialogRef<ConfirmLogoutDialog>);

  onConfirm(): void {
    // Limpa tudo local do app (session + local)
    sessionStorage.clear();
    localStorage.clear();
  
    const logoutUri = encodeURIComponent(environment.appUrl);
    window.location.href =
      `${environment.cognitoLogoutUrl}` +
      `?client_id=7lt80c43cs8mplhdop9r3ao57n` +
      `&logout_uri=${logoutUri}`;
    
    this.dialogRef.close();
  }

  onCancel(): void {
    this.dialogRef.close();
  }
}


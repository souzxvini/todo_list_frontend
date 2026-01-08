import { Component, inject, signal } from '@angular/core';
import { Router, RouterOutlet } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  protected readonly title = signal('todo_list_frontend');

  private readonly oidc = inject(OidcSecurityService);
  private readonly router = inject(Router);

  isAuthenticated$ = this.oidc.isAuthenticated$;
  userData$ = this.oidc.userData$;
  
  constructor() {
    console.log("entrou")
    this.oidc.checkAuth().subscribe({
      next: ({ isAuthenticated,  configId}) => {
        console.log("entrou no next")
        console.log("configId: ", configId);
        console.log("isAuthenticated: ", isAuthenticated);
        if(isAuthenticated) {
          this.router.navigateByUrl('/home');
        } else {
          this.oidc.authorize();
        }
      }
    });
  }
}

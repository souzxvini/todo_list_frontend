import { Routes } from '@angular/router';
import { App } from './app';
import { Home } from './views/home/home';
import { authGuard } from './auth/auth.guard';

export const routes: Routes = [
    { path: '', component: App },
    { path: 'home', component: Home, canActivate: [authGuard] },
  ];

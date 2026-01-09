import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { map, switchMap, take } from 'rxjs';

export const authGuard: CanActivateFn = (route, state) => {
  const oidcSecurityService = inject(OidcSecurityService);
  const router = inject(Router);
  
  // Verifica se a autenticação foi completada antes de validar
  return oidcSecurityService.checkAuth().pipe(
    take(1),
    map(({ isAuthenticated }) => {
      if (isAuthenticated) {
        return true;
      }
      
      // Se não estiver autenticado, redireciona para a página de login
      router.navigate(['/']);
      return false;
    })
  );
};


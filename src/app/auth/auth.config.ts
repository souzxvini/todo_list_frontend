import { PassedInitialConfig } from 'angular-auth-oidc-client';

export const authConfig: PassedInitialConfig = {
  config: {
              authority: 'https://cognito-idp.us-east-1.amazonaws.com/us-east-1_74RxY2But',
              redirectUrl: 'http://localhost:4200/home',
              postLogoutRedirectUri: 'http://localhost:4200',
              clientId: '7lt80c43cs8mplhdop9r3ao57n',
              scope: 'email openid',
              responseType: 'code',
              silentRenew: true,
              useRefreshToken: true,
              renewTimeBeforeTokenExpiresInSeconds: 30,
          }
}

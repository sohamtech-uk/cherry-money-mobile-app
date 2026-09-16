import { Component, OnInit } from '@angular/core';
import { DomSanitizer } from '@angular/platform-browser';
import { SignInWithApple } from '@capacitor-community/apple-sign-in';
import { MenuController } from '@ionic/angular';
import { OtherService } from '../service/other.service';
import { ServerService } from '../service/server.service';
import { SocialLogin } from '@capgo/capacitor-social-login';

@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss'],
})
export class LoginPage implements OnInit {
  hasClick: any = false;
  app_logo: any;
  email: any;
  password: any;
  googleRes:any;
  serverRes:any;

  constructor(
    private sanitizer: DomSanitizer,
    private menuCtrl: MenuController,
    public server: ServerService,
    public otherService: OtherService
  ) {
    this.otherService.statusBar('#ffffff', 1);

    this.app_logo = localStorage.getItem('app_logo');
  }

  ngOnInit() {
    this.menuCtrl.enable(false);
  }

  async login(data: any) {
    this.hasClick = true;

    this.server.login(data).subscribe((response: any) => {
      this.hasClick = false;

      if (response.msg != 'done') {
        this.otherService.toast(response.error);
      } else {
        this.otherService.toast('Login Successfully.');

        localStorage.setItem('show_sub', response.show_sub);

        localStorage.setItem('user_data', JSON.stringify(response.user));

        localStorage.setItem('_token', response.token);

        window.location.href = '/home';
      }
    });

    return;
  }

  async loginWithApple() {
    const user = await SignInWithApple.authorize({
      clientId: "",
      redirectURI: "",
      scopes: "email name"
    });
    console.log(user.response);
  }

  async loginWithGoogle() {
    const result = await SocialLogin.login({
      provider: 'google',
      options: {
        scopes: ['email', 'profile'],
      },
    });


    this.hasClick = true;


    this.server.loginGoogle(result).subscribe((response: any) => {

    this.hasClick = false;

    console.log(response);

    if (response.msg != 'done') {
      this.otherService.toast(response.error);
    } else {
      this.otherService.toast('Login Successfully.');

      localStorage.setItem('show_sub', response.show_sub);

      localStorage.setItem('user_data', JSON.stringify(response.user));

      localStorage.setItem('_token', response.token);

      window.location.href = '/home';
    }

    });

  }
}

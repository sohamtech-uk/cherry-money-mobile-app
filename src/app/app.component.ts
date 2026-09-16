import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { IonicModule,Platform,LoadingController,AlertController, isPlatform } from '@ionic/angular';
import { ServerService } from './service/server.service';
import { OtherService } from './service/other.service';
import { StatusBar, Style } from '@capacitor/status-bar';
import OneSignal from 'onesignal-cordova-plugin';
import { TranslateService } from '@ngx-translate/core';
import { SocialLogin } from '@capgo/capacitor-social-login';

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss'],
})
export class AppComponent {

user:any;
appPages:any = [];
url:any;
name:any;
email:any;
token:any;
perm:any;
push_id:any;
night:any = false;
dir:any = 'ltr';
show_sub:any = 2;

  constructor(private alertController: AlertController,private translate: TranslateService,public server : ServerService,public otherService : OtherService,private platform: Platform,public loadingController: LoadingController) {

    if(localStorage.getItem("_token") && localStorage.getItem("_token") != undefined)
    {
      this.otherService.redirect("home","root");
    }
    else
    {
      this.otherService.redirect("welcome","root");
    }

    this.show_sub = localStorage.getItem("show_sub");

   if(localStorage.getItem('app_lang') && localStorage.getItem('app_lang') != undefined)
   {
      var lng:any = localStorage.getItem('app_lang');

      this.translate.setDefaultLang(lng);

      if(lng === 'ar')
      {
        this.dir = 'rtl';
      }
      else
      {
        this.dir = 'ltr';
      }
   }
   else
   {
     this.translate.setDefaultLang('en');
   }


    if(localStorage.getItem('dark_mode') == '1')
    {
      document.body.classList.toggle('dark',true);
      this.night = true;
    }
    else
    {
      document.body.classList.toggle('dark',false);
      this.night = false;
    }

    this.appPages = [
      { title: this.translate.instant('Home'), url: '/home', icon: 'home' },
      { title: this.translate.instant('Account Setting'), url: '/setting', icon: 'settings' },
      { title: this.translate.instant('Manage Users'), url: '/user', icon: 'person-add' },
      { title: this.translate.instant('Manage Clients'), url: '/client', icon: 'people' },
      { title: this.translate.instant('Manage Products'), url: '/product', icon: 'grid' },
      { title: this.translate.instant('Manage Tax'), url: '/tax', icon: 'pricetags' },
      { title: this.translate.instant('Manage Quotes'), url: '/quote', icon: 'document-text' },
      { title: this.translate.instant('Manage Invoice'), url: '/invoice', icon: 'receipt' },
      { title: this.translate.instant('Recurring Invoice'), url: '/rec', icon: 'refresh' },
      { title: this.translate.instant('Manage Payments'), url: '/payment', icon: 'cash' },
      { title: this.translate.instant('Cherry Pay'), url: '/cherry-pay', icon: 'qr-code' },
      { title: this.translate.instant('Manage Expense'), url: '/expense', icon: 'wallet' },

    ];

    if(this.show_sub == "1")
    {
      this.appPages.push({ title: this.translate.instant('My Subscription'), url: '/sub', icon: 'checkbox' });
    }

    this.appPages.push({ title: this.translate.instant('Change Language'), url: '/language', icon: 'language' },{ title: this.translate.instant('Contact Us'), url: '/contact', icon: 'mail' });

    const user    = localStorage.getItem('user_data');
    this.push_id  = localStorage.getItem('push_id');

    if(user !== null)
    {
      this.user =  JSON.parse(user);
    }

    if(this.push_id)
    {
      this.OneSignalInit();
    }

    this.platform.ready().then(() => {
      StatusBar.setBackgroundColor({ color: '#AD1929' });
      StatusBar.setStyle({ style: Style.Light });
      if (isPlatform('android') || isPlatform('tablet')) {
        SocialLogin.initialize({
          google: {
            webClientId: '996173642915-8vj2jsbktcd02g7r6k1260lis5f747cg.apps.googleusercontent.com',
          },
        });
      }
    });
  }

  checkPerm(val:any)
  {
    val = val.replace(/\//g, '');

    if(val == 'rec')
    {
      val = 'invoice';
    }

    if(val == 'cherry-pay')
    {
      val = 'payment';
    }

    if(this.user.admin == true || val == 'home' || val == 'setting' || val == 'contact' || val == 'language')
    {
      return true;
    }
    else
    {
      const index = this.user.perm.indexOf(val);

      if (index === -1) {

      return false;

      } else {

        return true;
      }
    }
  }

  async logout() {
    const res = await this.otherService.confirm();

    if (res === 'ok') {
      const loading = await this.loadingController.create({
        spinner: 'dots',
        cssClass: 'loader-css-class'
      });

      await loading.present();

      this.server.logout().subscribe((response: any) => {
        loading.dismiss();
        localStorage.removeItem("user_data");
        localStorage.removeItem("_token");
        this.otherService.redirect("welcome", "root");
      });
    }
  }

  async deleteAccount()
  {
    const alert = await this.alertController.create({
      header: 'Are you sure?',
      message : 'Want to delete your account? All the data will be removed and you will not be able to undo.',
      mode : 'ios',
      inputs: [
        {
          name: 'password',
          type: 'password',
          placeholder: 'Enter your password',
        },
      ],
      buttons: [
        {
          text: 'Cancel',
          role: 'cancel',
          cssClass: 'secondary',
          handler: () => {
            console.log('Cancel clicked');
          },
        },
        {
          text: 'OK',
          handler: (data) => {

          if(data.password)
          {
            this.accountDelete(data.password);
          }
          else
          {
            this.otherService.toast("Please enter password for continue.");
          }

          },
        },
      ],
    });

    await alert.present();
  }

  async accountDelete(pass:any)
  {
    const loading = await this.loadingController.create({
      spinner: 'dots',
      cssClass: 'loader-css-class'
    });

    await loading.present();

    this.server.deleteAccount({password : pass}).subscribe((response: any) => {
      loading.dismiss();

      if(response.msg == "done")
      {
        this.otherService.toast("Your account is deleted successfully. We will wait untill you back soon.");
        localStorage.removeItem("user_data");
        localStorage.removeItem("_token");
        this.otherService.redirect("welcome", "root");
      }
      else
      {
        this.otherService.toast(response.error);
      }

    });
  }


  async OneSignalInit()
  {
    OneSignal.initialize(this.push_id);

    OneSignal.Notifications.addEventListener('click', async (e) => {
      let clickData = await e.notification;
      console.log("Notification Clicked : " + clickData);
    })

    OneSignal.Notifications.requestPermission(true).then((success: Boolean) => {
      console.log("Notification permission granted " + success);
    })

    if(this.user && this.user.company_id)
    {
      OneSignal.User.addTags({user_id : this.user.company_id});
    }
  }
}

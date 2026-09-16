import { Component, OnInit,CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,AlertController,Platform,MenuController,LoadingController} from '@ionic/angular';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { RouterLink } from '@angular/router';
import { App } from '@capacitor/app';

@Component({
  selector: 'app-welcome',
  templateUrl: './welcome.page.html',
  styleUrls: ['./welcome.page.scss'],
  
  
})
export class WelcomePage implements OnInit {

  data:any;
  welcomeTitle = 'Cherry Money';
  welcomeDescription = 'Invoices, expenses, VAT, payments and business finance in one place.';
  hasClick:any = false;
  subscription:any;

  constructor(public loadingController: LoadingController,private menuCtrl : MenuController,public server : ServerService,public otherService : OtherService,public alertController: AlertController,public platform : Platform) {

    this.otherService.statusBar("#ffffff",1);
  }

  ngOnInit()
  { 
    this.menuCtrl.enable(false);
  }

  ionViewDidEnter(){

    this.loadData();
   
    document.body.classList.toggle('dark',false);

    localStorage.setItem('dark_mode','0');

    this.subscription = this.platform.backButton.subscribe(()=>{
          
      this.presentAlertConfirm();

    });

  }

  ionViewWillLeave(){
      
    this.subscription.unsubscribe();
}

async presentAlertConfirm() {
  const alert = await this.alertController.create({
    header: "Exit App",
    message: "Are you sure? Want to exit.",
    buttons: [
      {
        text: "Cancel",
        role: 'cancel',
        cssClass: 'secondary',
        handler: (blah) => {
          console.log('Confirm Cancel: blah');
        }
      }, {
        text: "Yes Exit",
        handler: () => {
        
          App.exitApp();

        }
      }
    ]
  });

  await alert.present();
}

  async loadData()
  {
    const loading = await this.loadingController.create({
      spinner:'dots',
      cssClass:'loader-css-class'
    });

    loading.present();

      this.server.welcome().subscribe((response:any) => {

      loading.dismiss();
      
      this.data = response.data;
      this.welcomeTitle = this.brandWelcomeTitle(response.data?.admin?.welcome_title);
      this.welcomeDescription = this.brandWelcomeDescription(response.data?.admin?.welcome_desc);

      localStorage.setItem('app_logo',response.data.logo);
      localStorage.setItem('push_id',response.data.admin.push_app_id);
      localStorage.setItem('privacy_link',response.data.privacy_link);
      
      localStorage.setItem('demo_email',response.data.demo_email);
      localStorage.setItem('demo_password',response.data.demo_password);
      localStorage.setItem('demo',response.data.demo);

      });
  }

  private brandWelcomeTitle(title:any)
  {
    if(!title || title === 'Cherry Invoice' || title === 'CherryBank' || title === 'CherryBank Money')
    {
      return 'Cherry Money';
    }

    return title;
  }

  private brandWelcomeDescription(description:any)
  {
    if(!description || description === 'A complete solution for your accounting problem. Easy & Fast')
    {
      return 'Invoices, expenses, VAT, payments and business finance in one place.';
    }

    return description;
  }
}

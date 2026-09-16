import { Component, OnInit,CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,AlertController,Platform,MenuController,LoadingController,ModalController} from '@ionic/angular';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { RouterLink } from '@angular/router';
import { App } from '@capacitor/app';
import { QuoteviewPage } from '../quoteview/quoteview.page';
import { InvoiceviewPage } from '../invoiceview/invoiceview.page';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-home',
  templateUrl: './home.page.html',
  styleUrls: ['./home.page.scss'],
  
  
})
export class HomePage implements OnInit {

  data:any;
  hasClick:any = false;
  subscription:any;
  user:any;
  overview_type:any = 1;
  type:any = 1;
  perm:any;
  night:any = false;
  isNet:any = true;

  constructor(private translate: TranslateService,private modalCtrl: ModalController,public loadingController: LoadingController,private menuCtrl : MenuController,public server : ServerService,public otherService : OtherService,public alertController: AlertController,public platform : Platform) {

    this.otherService.statusBar("#AD1929",2);

    const user  = localStorage.getItem('user_data');
    
    if(user !== null) 
    {
      this.user =  JSON.parse(user);
    }
  }

  ngOnInit()
  { 
    this.loadData();
  }

  ionViewDidEnter(){
   
    if(localStorage.getItem('dark_mode') && localStorage.getItem('dark_mode') == '1')
    {
      this.night = true;
    }

    this.subscription = this.platform.backButton.subscribe(()=>{
          
      this.presentAlertConfirm();

    });

  }
  

  ionViewWillLeave(){
      
    this.subscription.unsubscribe();
}


async presentAlertConfirm() {
  this.translate.get(['Exit App', 'Are you sure? Want to exit.', 'Cancel', 'Yes Exit']).subscribe(async (translations) => {
    const alert = await this.alertController.create({
      header: translations['Exit App'],
      message: translations['Are you sure? Want to exit.'],
      buttons: [
        {
          text: translations['Cancel'],
          role: 'cancel',
          cssClass: 'secondary',
          handler: () => {
            console.log('Confirm Cancel');
          }
        }, 
        {
          text: translations['Yes Exit'],
          handler: () => {
            App.exitApp();
          }
        }
      ]
    });

    await alert.present();
  });
}

nightMode()
{
  this.night = !this.night;
  
  return this.setTheme();
}

setTheme()
{
  if(this.night)
  {
    document.body.classList.toggle('dark',true);
    
    localStorage.setItem('dark_mode','1');

    this.otherService.statusBar("#2f2f2f",2);
  }
  else
  {
    document.body.classList.toggle('dark',false);
    localStorage.setItem('dark_mode','0');
    this.otherService.statusBar("#AD1929",2);
  }
}

  async loadData()
  {
    const loading = await this.loadingController.create({
      spinner:'dots',
      cssClass:'loader-css-class'
    });

    loading.present();

    this.server.home().subscribe((response:any) => {

    loading.dismiss();

     if(response.fail && response.fail.status == 401)
     {
        this.otherService.toast(response.fail.error.message);

        localStorage.removeItem("user_data");
        localStorage.removeItem("_token");
        return this.otherService.redirect("welcome","root");
     }

     if(response.data.valid == false)
     {
        this.translate.get('Your subscription is expired. Please renew it to continue.').subscribe((translatedMessage: string) => {
          this.otherService.toast(translatedMessage);
        });

        if(response.data.user.admin == 1)
        {
          this.otherService.redirect("sub");
        }
        else
        {
          localStorage.removeItem("user_data");
          localStorage.removeItem("_token");
          this.otherService.redirect("welcome","root");
        }
     }
     else if(response.data.status == false)
     {
          this.translate.get('Your account is disabled. Please contact to admin.').subscribe((translatedMessage: string) => {
            this.otherService.toast(translatedMessage);
          });
          
          localStorage.removeItem("user_data");
          localStorage.removeItem("_token");
          this.otherService.redirect("welcome","root");
     }

     this.data = response.data;
     this.perm = this.data.user_data;

     localStorage.setItem('user_data',JSON.stringify(response.data.user_data));

     return;

      });

      
  }

  async quoteView(data:any = [],email:any = null)
  {
    const allData = {data : data,email : email}

    const modal = await this.modalCtrl.create({
      component: QuoteviewPage,
      animated:true,
      mode:'ios',
      componentProps: allData,

    });

   modal.onDidDismiss().then(data=>{
    
    

    })

    return await modal.present();
  }

  async invoiceView(data:any = [],email:any = null)
  {
    const allData = {data : data,email : email}

    const modal = await this.modalCtrl.create({
      component: InvoiceviewPage,
      animated:true,
      mode:'ios',
      componentProps: allData,

    });

   modal.onDidDismiss().then(data=>{
    
    

    })

    return await modal.present();
  }

  checkPerm(val:any)
  {
    if(this.perm.admin == true)
    {
      return true;
    }
    else
    {
      const index = this.perm.perm.indexOf(val);
  
      if (index === -1) {
        
      return false;

      } else {
        
        return true;
      }
    }
  }
}

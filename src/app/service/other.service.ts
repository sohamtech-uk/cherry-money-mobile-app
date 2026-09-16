import { Injectable } from '@angular/core';
import { IonicModule,NavController,LoadingController,ToastController,AlertController,ModalController } from '@ionic/angular';
import { StatusBar, Style } from '@capacitor/status-bar';

@Injectable({
  providedIn: 'root'
})
export class OtherService {

  constructor(private modalCtrl: ModalController,private alertController: AlertController,public loadingController: LoadingController,private nav: NavController,public toastController: ToastController) { }

  async showLoading()
  {
    const loading = await this.loadingController.create({
      spinner : 'crescent',
      cssClass:'loader-css-class',
      showBackdrop: false,

      });
      
      await loading.present();
  }

  async hideLoading()
  {
    return this.loadingController.dismiss();
  }

  async redirectWithDelay(url:any,time = 1000)
  {
    setTimeout(() => { 

      return this.nav.navigateForward('/'+url);

     }, time);
  }

  async redirect(url:any,type:any = false)
  {
    if(type)
    {
      return this.nav.navigateRoot('/'+url);
    }
    else
    {
      return this.nav.navigateForward('/'+url);
    }
  }

  async goBack()
  {
    this.nav.back();
  }

  async toast(txt:any) {
    
    const toast = await this.toastController.create({
      message: txt,
      duration: 2000,
      position : 'top',
      mode : 'ios',
      color : 'dark'
    });

    toast.present();
  }

  async confirm(): Promise<any> {
    return new Promise(async (resolve) => {
      const alert = await this.alertController.create({
        header: "Are you sure?",
        cssClass: 'alertClass',
        mode : 'ios',
        buttons: [
          {
            text: 'Cancel',
            role: 'cancel',
            cssClass: 'dark',
            handler: (cancel) => {
              resolve('cancel');
            }
          }, {
            text: 'Yes Sure',
            handler: (ok) => {
              resolve('ok');
            }
          }
        ]
      });
      alert.present();
    });
  }

  formValidation(data:any)
  {
    let email_error:any;
    let phone_error:any;
    let password_error:any;
    let name_error:any;

   if(data.name.length < 2 || data.phone.length > 20)
   {
     name_error = "Please enter valid name";
   }

   if(!this.validateEmail(data.email))
   {
     email_error = "Please enter valid email";
   }

   if(data.phone.length < 8 || data.phone.length > 10)
   {
     phone_error = "Please enter valid phone number";
   }

   if(data.password.length < 6)
   {
     password_error = "Password must be at least 6 characters";
   }

    return {
    
    email : email_error,
    phone : phone_error,
    password : password_error,
    name : name_error

    }   
  }

  validateEmail(email:any) 
  {
    const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return pattern.test(email);
  }

  async openModal(page:any,parm:any = {}) {
    const modal = await this.modalCtrl.create({
      component: page,
      componentProps: parm
    });
  
    await modal.present();
  
    const { data } = await modal.onDidDismiss();
  
    if (data) {
      return data;
    }
  }

  async closeModel(data:any)
  {
    await this.modalCtrl.dismiss(data);
  }

  async alert(txt:any) {
    const alert = await this.alertController.create({
      message: txt,
      buttons: ['OK'],
    });

    await alert.present();
  }

  async statusBar(color:any,style:any = 1)
  {
    StatusBar.setBackgroundColor({ color: color });
    
    if(style == 2)
    {
      StatusBar.setStyle({ style: Style.Dark });
    }
    else
    {
      StatusBar.setStyle({ style: Style.Light });
    }

  }

  async getLang()
  {
    const text = localStorage.getItem('app_lang');
    
    if(text !== null) 
    {
      return JSON.parse(text);
    }
  }

  async showAd()
  {
    
  }
}

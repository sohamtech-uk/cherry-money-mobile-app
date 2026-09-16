import { Component, OnInit,CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,AlertController,Platform,MenuController,LoadingController} from '@ionic/angular';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { RouterLink } from '@angular/router';
import { App } from '@capacitor/app';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-setting',
  templateUrl: './setting.page.html',
  styleUrls: ['./setting.page.scss'],
  
  
})
export class SettingPage implements OnInit {

  data:any;
  hasClick:any = false;
  subscription:any;
  type:any = 1;
  hasImg:any;
  d_charges_type:any = 1;
  user:any;
  night:any;

  constructor(private translate: TranslateService,public loadingController: LoadingController,private menuCtrl : MenuController,public server : ServerService,public otherService : OtherService,public alertController: AlertController,public platform : Platform) {

    this.otherService.statusBar("#296fda",2);

    const user  = localStorage.getItem('user_data');
    
    if(user !== null) 
    {
      this.user =  JSON.parse(user);
    }
  }

  ngOnInit()
  { 
    
  }

  ionViewDidEnter(){
   
    if(localStorage.getItem('dark_mode') && localStorage.getItem('dark_mode') == '1')
    {
      this.night = true;
    }

    this.loadData();
  }

  async loadData()
  {
    const loading = await this.loadingController.create({
      spinner:'dots',
      cssClass:'loader-css-class'
    });

    loading.present();

    this.server.setting().subscribe((response:any) => {

     this.data = response.data;

      loading.dismiss();

     return;

      });

      
  }

  async updateSetting(data:any)
  {
    if(data.new_pass && data.new_pass.length < 6)
    {
      this.translate.get('Password length should be atlest 6').subscribe((translatedMessage: string) => {
        return this.otherService.toast(translatedMessage);
      });
    }

    if(data.new_pass && data.new_pass != data.c_pass)
    {
      this.translate.get('Confirm Password not match.').subscribe((translatedMessage: string) => {
        return this.otherService.toast(translatedMessage);
      });
    }

    if(data.phone && data.phone.length < 6)
    {
      this.translate.get('Please enter valid phone number').subscribe((translatedMessage: string) => {
        return this.otherService.toast(translatedMessage);
      });
    }

    if(data.company_phone && data.company_phone.length < 6)
    {
      this.translate.get('Please enter valid phone number').subscribe((translatedMessage: string) => {
        return this.otherService.toast(translatedMessage);
      });
    }

    this.hasClick = true;

    const loading = await this.loadingController.create({
      spinner:'dots',
      cssClass:'loader-css-class'
    });

    loading.present();

    this.server.updateSetting(data).subscribe((response:any) => {

    this.hasClick = false;

     if(response.msg == "error")
     {
       this.otherService.toast(response.error);
     }
     else
     {

      this.translate.get('Setting updated successfully.').subscribe((translatedMessage: string) => {
        return this.otherService.toast(translatedMessage);
      });

      this.data = response.data; 

      if(this.type == 4)
      {
        this.type = 1;
      }
     }

      loading.dismiss();

      return;

      });

    
  }
}

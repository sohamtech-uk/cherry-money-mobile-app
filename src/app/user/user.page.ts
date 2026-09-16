import { Component, OnInit,CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,AlertController,Platform,ModalController,LoadingController,ActionSheetController} from '@ionic/angular';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { RouterLink } from '@angular/router';
import { App } from '@capacitor/app';
import { UseraddPage } from '../useradd/useradd.page';
import { PermPage } from '../perm/perm.page';
import { Ng2SearchPipe } from 'ng2-search-filter';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-user',
  templateUrl: './user.page.html',
  styleUrls: ['./user.page.scss'],
   
})
export class UserPage implements OnInit {

  data:any;
  hasClick:any = false;
  term:any;
  allData:any;
  currentPage = 1;
  currency:any;

  constructor(private translate: TranslateService,private actionSheetCtrl: ActionSheetController,private ng2SearchPipe: Ng2SearchPipe,public loadingController: LoadingController,private modalCtrl: ModalController,public server : ServerService,public otherService : OtherService) {

    this.otherService.statusBar("#AD1929",2);
  }

  ngOnInit()
  { 
    
  }

  ionViewDidEnter(){
   
    this.loadData();

  }

  onSearchChange(type:any) {
    
    this.data = this.ng2SearchPipe.transform(this.allData, this.term);
  }

  async loadData()
  {
    const loading = await this.loadingController.create({
      spinner:'dots',
      cssClass:'loader-css-class'
    });

    loading.present();

    this.server.user().subscribe((response:any) => {

      this.data     = response.data;
      this.allData  = response.data;

      loading.dismiss();

      });
  }

  async addNew(data:any = [])
  {
    const allData = {data : data}

    const modal = await this.modalCtrl.create({
      component: UseraddPage,
      animated:true,
      mode:'ios',
      componentProps: allData,

    });

   modal.onDidDismiss().then(data=>{
    
    if(data.data.data && data.data.data.length > 0)
    { 
      this.data = data.data.data;
    }

    })

    return await modal.present();
  }

  async perm(data:any = [])
  {
    const allData = {data : data}

    const modal = await this.modalCtrl.create({
      component: PermPage,
      animated:true,
      mode:'ios',
      componentProps: allData,

    });

   modal.onDidDismiss().then(data=>{
    
    if(data.data.data && data.data.data.length > 0)
    { 
      this.data = data.data.data;
    }

    })

    return await modal.present();
  }

  async remove(id:any)
  {
    this.otherService.confirm() .then(res => {
      if (res === 'ok') 
      {
        this.otherService.showLoading();

        this.server.removeUser(id).subscribe((response:any) => {

          this.otherService.hideLoading();

          console.log(response);

          if(response.msg != "error")
          {
            this.data  = response.data;

            this.translate.get('User Removed Successfully.').subscribe((translatedMessage: string) => {
              this.otherService.toast(translatedMessage);
            });
          }
          else
          {
            this.otherService.toast(response.error);
          }
          
          });       
      }
    });
  }

  async viewOption(data: any) {
    const buttons = [];
  
    // Always show Cancel button
    buttons.push({
      text: this.translate.instant('Cancel'),
      icon: 'close-outline',
      role: 'cancel',
      data: {
        action: 'cancel',
      },
    });
  
    buttons.push({
      text: this.translate.instant('Assign Permissions'),
      icon: 'checkbox-outline',
      role: 'destructive',
      handler: () => {
        
      this.perm(data);

      },
    });

    buttons.push({
      text: this.translate.instant('Edit'),
      icon: 'create-outline',
      role: 'destructive',
      handler: () => {
        
      this.addNew(data);

      },
    });

    buttons.push({
      text: this.translate.instant('Delete'),
      icon: 'trash-outline',
      role: 'destructive',
      handler: () => {
        
      this.remove(data.id);

      },
    });
  
    const actionSheet = await this.actionSheetCtrl.create({
      header: this.translate.instant('Options'),
      mode: 'md',
      buttons: buttons,
    });
  
    await actionSheet.present();
  }
}

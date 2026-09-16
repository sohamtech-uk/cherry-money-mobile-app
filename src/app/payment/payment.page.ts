import { Component, OnInit,CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,AlertController,Platform,ModalController,LoadingController,ActionSheetController} from '@ionic/angular';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { RouterLink } from '@angular/router';
import { App } from '@capacitor/app';
import { PaymentaddPage } from '../paymentadd/paymentadd.page';
import { Ng2SearchPipe } from 'ng2-search-filter';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-payment',
  templateUrl: './payment.page.html',
  styleUrls: ['./payment.page.scss'],
   
})
export class PaymentPage implements OnInit {

  data:any;
  hasClick:any = false;
  term:any;
  allData:any;
  currentPage = 1;
  currency:any;
  status_id:any = 'all';

  constructor(private actionSheetCtrl: ActionSheetController,private translate: TranslateService,private ng2SearchPipe: Ng2SearchPipe,public loadingController: LoadingController,private modalCtrl: ModalController,public server : ServerService,public otherService : OtherService) {

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

  setStatus()
  {
    this.loadData(this.status_id);
  }

  async loadData(status:any = 'all')
  {
    const loading = await this.loadingController.create({
      spinner:'dots',
      cssClass:'loader-css-class'
    });

    loading.present();

    this.server.payment(1,status).subscribe((response:any) => {

      this.data     = response.data;
      this.allData  = response.data;
      this.currency = response.currency;

      loading.dismiss();

      });
  }

  async addNew(data:any = [])
  {
    const allData = {data : data}

    const modal = await this.modalCtrl.create({
      component: PaymentaddPage,
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

        this.server.removePayment(id).subscribe((response:any) => {

          this.otherService.hideLoading();

          console.log(response);

          if(response.msg != "error")
          {
            this.data  = response.data;

            this.otherService.toast(this.translate.instant("Payment Removed Successfully."));
          }
          else
          {
            this.otherService.toast(response.error);
          }
          
          });       
      }
    });
  }

  async loadMoreData(event: any) {
    this.currentPage++; 
    this.server.payment(this.currentPage,this.status_id).subscribe((response: any) => {
      
      this.data     = [...this.data, ...response.data];
      this.allData  = this.data;
      event.target.complete();
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
        text: this.translate.instant('Delete'),
        icon: 'trash-outline',
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

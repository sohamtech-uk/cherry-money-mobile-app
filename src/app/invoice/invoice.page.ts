import { Component, OnInit,CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,AlertController,Platform,ModalController,LoadingController,ActionSheetController} from '@ionic/angular';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { RouterLink } from '@angular/router';
import { App } from '@capacitor/app';
import { InvoiceaddPage } from '../invoiceadd/invoiceadd.page';
import { RecaddPage } from '../recadd/recadd.page';
import { InvoiceviewPage } from '../invoiceview/invoiceview.page';
import { Ng2SearchPipe } from 'ng2-search-filter';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-invoice',
  templateUrl: './invoice.page.html',
  styleUrls: ['./invoice.page.scss'],
  
  
})
export class InvoicePage implements OnInit {

  data:any;
  hasClick:any = false;
  term:any;
  allData:any;
  currentPage = 1;
  currency:any;
  add:any;
  download:any;
  status_id:any = 'all';

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

    this.server.invoice(1,status).subscribe((response:any) => {

      this.data     = response.data;
      this.allData  = response.data;
      this.currency = response.add.currency;
      this.add      = response.add;
      this.download = response.add.download;

      loading.dismiss();

      });
  }

  async addNew(data:any = [])
  {
    const allData = {data : data,add : this.add}

    const modal = await this.modalCtrl.create({
      component: InvoiceaddPage,
      animated:true,
      mode:'ios',
      componentProps: allData,

    });

   modal.onDidDismiss().then(data=>{
    
    if(data.data.data && data.data.data.length > 0)
    { 
      this.data = data.data.data;
      this.add  = data.data.add;
    }

    })

    return await modal.present();
  }

  async addNewRec(data:any = [])
  {
    const allData = {data : data,add : this.add}

    const modal = await this.modalCtrl.create({
      component: RecaddPage,
      animated:true,
      mode:'ios',
      componentProps: allData,

    });

   modal.onDidDismiss().then(data=>{
    
    if(data.data.data && data.data.data.length > 0)
    { 
      this.data = data.data.data;
      this.add  = data.data.add;
    }

    })

    return await modal.present();
  }

  async view(data:any = [],email:any = null)
  {
    const allData = {data : data,email : email}

    const modal = await this.modalCtrl.create({
      component: InvoiceviewPage,
      animated:true,
      mode:'ios',
      componentProps: allData,

    });

   modal.onDidDismiss().then(data=>{
    
    if(data.data.data && data.data.data.length > 0)
    {
      this.data = data.data.data;
      this.add  = data.data.add;
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

        this.server.removeInvoice(id).subscribe((response:any) => {

          this.otherService.hideLoading();

          console.log(response);

          if(response.msg != "error")
          {
            this.data  = response.data;

            this.otherService.toast(this.translate.instant("Invoice Removed Successfully."));
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
    this.server.invoice(this.currentPage,this.status_id).subscribe((response: any) => {
      
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
  
    // Conditionally add "View Quote" button
    if (data.status === 2) {
      buttons.push({
        text: this.translate.instant('View Invoice'),
        icon: 'eye-outline',
        role: 'destructive',
        handler: () => {
          this.view(data);
        },
      });

      buttons.push({
        text: this.translate.instant('Download'),
        icon: 'download-outline',
        handler: () => {
          window.open(this.download + "?id=" + data.id + "&type=download", '_blank');
        },
      });
    }
  
    if(data.status != 2)
    {
      buttons.push({
        text: this.translate.instant('View Invoice'),
        icon: 'eye-outline',
        role: 'destructive',
        handler: () => {
          this.view(data);
        },
      });


      buttons.push({
        text: this.translate.instant('Edit Invoice'),
        icon: 'create-outline',
        handler: () => {
          this.addNew(data);
        },
      });

      buttons.push({
        text: this.translate.instant('Download'),
        icon: 'download-outline',
        handler: () => {
          window.open(this.download + "?id=" + data.id + "&type=download", '_blank');
        },
      });

      buttons.push({
        text: this.translate.instant('Send Email To Client'),
        icon: 'mail-outline',
        handler: () => {
          this.view(data, 'email');
        },
      });
      buttons.push({
        text: this.translate.instant('Delete'),
        icon: 'trash-outline',
        handler: () => {
          this.remove(data.id);
        },
      });
    }
  
    if(data.rec_start)
    {
      buttons.push({
        text: this.translate.instant('Stop Recurring'),
        icon: 'ban-outline',
        role: 'destructive',
        handler: () => {
          this.stopRec(data.id);
        },
      });
    }
    else
    {
      buttons.push({
        text: this.translate.instant('Start Recurring'),
        icon: 'refresh-outline',
        role: 'destructive',
        handler: () => {
          this.addNewRec(data);
        },
      });
    }

    const actionSheet = await this.actionSheetCtrl.create({
      header: this.translate.instant('Options'),
      mode: 'md',
      buttons: buttons,
    });
  
    await actionSheet.present();
  }

  async stopRec(id:any)
  {
    this.otherService.confirm() .then(res => {
      if (res === 'ok') 
      {
        this.otherService.showLoading();

        this.server.stopRec(id).subscribe((response:any) => {

          this.otherService.hideLoading();

          console.log(response);

          if(response.msg != "error")
          {
            this.data  = response.data;

            this.otherService.toast(this.translate.instant("Recurring Invoice Removed Successfully."));
          }
          else
          {
            this.otherService.toast(response.error);
          }
          
          });       
      }
    });
  }
}

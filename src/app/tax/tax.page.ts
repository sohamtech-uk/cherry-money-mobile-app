import { Component, OnInit,CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,AlertController,Platform,ModalController,LoadingController} from '@ionic/angular';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { RouterLink } from '@angular/router';
import { App } from '@capacitor/app';
import { TaxaddPage } from '../taxadd/taxadd.page';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-tax',
  templateUrl: './tax.page.html',
  styleUrls: ['./tax.page.scss'],
  
  
})
export class TaxPage implements OnInit {

  data:any;
  hasClick:any = false;
  term:any;
  allData:any;
  currentPage = 1;

  constructor(private translate: TranslateService,public loadingController: LoadingController,private modalCtrl: ModalController,public server : ServerService,public otherService : OtherService) {

    this.otherService.statusBar("#AD1929",2);
  }

  ngOnInit()
  { 
    
  }

  ionViewDidEnter(){
   
    this.loadData();

  }

  async loadData()
  {
    const loading = await this.loadingController.create({
      spinner:'dots',
      cssClass:'loader-css-class'
    });

    loading.present();

    this.server.tax().subscribe((response:any) => {

      this.data     = response.data;

      loading.dismiss();

      });
  }

  async addNew(data:any = [])
  {
    const allData = {data : data}

    const modal = await this.modalCtrl.create({
      component: TaxaddPage,
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

        this.server.removeTax(id).subscribe((response:any) => {

          this.otherService.hideLoading();

          console.log(response);

          if(response.msg != "error")
          {
            this.data  = response.data;

            this.otherService.toast(this.translate.instant("Tax Removed Successfully."));
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

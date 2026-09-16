import { Component, OnInit,CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,AlertController,Platform,ModalController,LoadingController} from '@ionic/angular';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { RouterLink } from '@angular/router';
import { App } from '@capacitor/app';
import { ClientaddPage } from '../clientadd/clientadd.page';
import { ClientviewPage } from '../clientview/clientview.page';
import { Ng2SearchPipe } from 'ng2-search-filter';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-client',
  templateUrl: './client.page.html',
  styleUrls: ['./client.page.scss'],
  
  
})
export class ClientPage implements OnInit {

  data:any;
  hasClick:any = false;
  term:any;
  allData:any;
  currentPage = 1;

  constructor(private translate: TranslateService,private ng2SearchPipe: Ng2SearchPipe,public loadingController: LoadingController,private modalCtrl: ModalController,public server : ServerService,public otherService : OtherService) {

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

    this.server.client().subscribe((response:any) => {

      this.data     = response.data;
      this.allData  = response.data;

      loading.dismiss();

      });
  }

  async addNew(data:any = [])
  {
    const allData = {data : data}

    const modal = await this.modalCtrl.create({
      component: ClientaddPage,
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

  async view(data:any = [])
  {
    const allData = {data : data}

    const modal = await this.modalCtrl.create({
      component: ClientviewPage,
      animated:true,
      mode:'ios',
      componentProps: allData,

    });

   modal.onDidDismiss().then(data=>{
    
   

    })

    return await modal.present();
  }

  async remove(id:any)
  {
    this.otherService.confirm() .then(res => {
      if (res === 'ok') 
      {
        this.otherService.showLoading();

        this.server.removeClient(id).subscribe((response:any) => {

          this.otherService.hideLoading();

          console.log(response);

          if(response.msg != "error")
          {
            this.data  = response.data;

            this.otherService.toast(this.translate.instant('Client Removed Successfully'));
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
    this.server.client(this.currentPage).subscribe((response: any) => {
      
      this.data     = [...this.data, ...response.data];
      this.allData  = this.data;
      event.target.complete();
    });

  }
}

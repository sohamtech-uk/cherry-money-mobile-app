import { Component, OnInit,CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,AlertController,Platform,ModalController,LoadingController} from '@ionic/angular';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { RouterLink } from '@angular/router';
import { App } from '@capacitor/app';
import { ExpenseviewPage } from '../expenseview/expenseview.page';
import { Ng2SearchPipe } from 'ng2-search-filter';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-rec',
  templateUrl: './rec.page.html',
  styleUrls: ['./rec.page.scss'],
   
})
export class RecPage implements OnInit {

  data:any;
  hasClick:any = false;
  term:any;
  allData:any;
  currentPage = 1;
  currency:any;

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

    this.server.rec().subscribe((response:any) => {

      this.data     = response.data;
      this.allData  = response.data;
      this.currency = response.currency;

      loading.dismiss();

      });
  }

  async remove(id:any)
  {
    this.otherService.confirm() .then(res => {
      if (res === 'ok') 
      {
        this.otherService.showLoading();

        this.server.stopRec(id,1).subscribe((response:any) => {

          this.otherService.hideLoading();

          if(response.msg != "error")
          {
            this.data     = response.data;
            this.allData  = response.data;

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

  async loadMoreData(event: any) {
    this.currentPage++; 
    this.server.rec(this.currentPage).subscribe((response: any) => {
      
      this.data     = [...this.data, ...response.data];
      this.allData  = this.data;
      event.target.complete();
    });

  }
}

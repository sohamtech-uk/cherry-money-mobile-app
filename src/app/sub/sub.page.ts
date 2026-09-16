import { Component, OnInit,CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,AlertController,Platform,ModalController,LoadingController} from '@ionic/angular';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { RouterLink } from '@angular/router';
import { App } from '@capacitor/app';
import { ExpenseaddPage } from '../expenseadd/expenseadd.page';
import { ExpenseviewPage } from '../expenseview/expenseview.page';
import { Ng2SearchPipe } from 'ng2-search-filter';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-sub',
  templateUrl: './sub.page.html',
  styleUrls: ['./sub.page.scss'],
   
})
export class SubPage implements OnInit {

  data:any;
  token:any;

  constructor(private translate: TranslateService,private ng2SearchPipe: Ng2SearchPipe,public loadingController: LoadingController,private modalCtrl: ModalController,public server : ServerService,public otherService : OtherService) {

    this.otherService.statusBar("#296fda",2);

    this.token = localStorage.getItem('_token');
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

    this.server.sub().subscribe((response:any) => {

      this.data     = response.data;

      loading.dismiss();

      });
  }

}

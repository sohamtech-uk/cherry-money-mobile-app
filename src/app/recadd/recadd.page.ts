import { Component, OnInit,ViewChild,ElementRef,NgZone } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,Platform,NavParams,LoadingController,IonContent } from '@ionic/angular';
import { OtherService } from '../service/other.service';
import { ServerService } from '../service/server.service';
import { TranslateService } from '@ngx-translate/core';


@Component({
  selector: 'app-recadd',
  templateUrl: './recadd.page.html',
  styleUrls: ['./recadd.page.scss'],
})
export class RecaddPage implements OnInit {

  data:any;
  start_date:any;
  days:any = 30;
  hasClick:any = false;


  constructor(private translate: TranslateService,public navParams: NavParams,public otherService : OtherService,public server : ServerService,public loadingController: LoadingController) { 
  
    this.data       = navParams.get('data');

    let currentDate = new Date();
    currentDate.setDate(currentDate.getDate() + 1);

    let year = currentDate.getFullYear();
    let month = String(currentDate.getMonth() + 1).padStart(2, '0');
    let day = String(currentDate.getDate()).padStart(2, '0');
    this.start_date = `${year}-${month}-${day}`;

    console.log(this.start_date);

  }

  ngOnInit()
  {
    
  } 

  async close(data:any = [])
  {
    this.otherService.closeModel(data);
  }

  async addNew(data:any,id = 0)
  {
    data.start_from = this.start_date;
    data.invoice_id = this.data.id;

    console.log(data);

    this.hasClick = true;
 
    this.server.recAdd(data).subscribe((response:any) => {

      this.hasClick = false;

      this.close(response);

      this.otherService.toast( this.translate.instant("Recurring invoice started successfully."));

    });

    return;
  }
}

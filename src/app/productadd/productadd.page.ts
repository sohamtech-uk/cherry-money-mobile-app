import { Component, OnInit,ViewChild,ElementRef,NgZone } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,Platform,NavParams } from '@ionic/angular';
import { OtherService } from '../service/other.service';
import { ServerService } from '../service/server.service';
import { TranslateService } from '@ngx-translate/core';


@Component({
  selector: 'app-productadd',
  templateUrl: './productadd.page.html',
  styleUrls: ['./productadd.page.scss'],
})
export class ProductaddPage implements OnInit {

  data:any;
  hasClick = false;
  text:any;

  constructor(private translate: TranslateService,public navParams: NavParams,public otherService : OtherService,public server : ServerService) { 
  
    this.data       = navParams.get('data');
  }

  ngOnInit() {
  } 


  async close(data:any = [])
  {
    this.otherService.closeModel(data);
  }

  async addNew(data:any,id = 0)
  {
    this.hasClick = true;
 
    this.server.productAdd(data,this.data.id ? this.data.id : id).subscribe((response:any) => {

      this.hasClick = false;

      this.close(response);

      this.otherService.toast(this.translate.instant("New Product Added Successfully."));

    });

    return;
  }
}

import { Component, OnInit,ViewChild,ElementRef,NgZone } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,Platform,NavParams } from '@ionic/angular';
import { OtherService } from '../service/other.service';
import { ServerService } from '../service/server.service';
import { TranslateService } from '@ngx-translate/core';


@Component({
  selector: 'app-useradd',
  templateUrl: './useradd.page.html',
  styleUrls: ['./useradd.page.scss'],
})
export class UseraddPage implements OnInit {

  data:any;
  hasClick = false;
  text:any;
  date_added:any = new Date();
  pass_text:any;

  constructor(private translate: TranslateService,public navParams: NavParams,public otherService : OtherService,public server : ServerService) { 
  
    this.data       = navParams.get('data');

    if(this.data.date_added)
    {
      this.date_added = this.data.date_added;
    }

    this.pass_text = this.data.id ? this.translate.instant('Change Password') : this.translate.instant('Choose Password *');
  }

  ngOnInit() {
  } 


  async close(data:any = [])
  {
    this.otherService.closeModel(data);
  }

  async addNew(data:any,id = 0)
  {
    data.date_added = this.date_added;

    this.hasClick = true;
 
    this.server.userAdd(data,this.data.id ? this.data.id : id).subscribe((response:any) => {

      this.hasClick = false;

      if(response.msg == "error")
      {
        this.otherService.toast(response.error);
      }
      else
      {
        this.close(response);

        this.otherService.toast(this.translate.instant('New User Added Successfully.'));
      }

    });

    return;
  }

  
}

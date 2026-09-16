import { Component, OnInit,ViewChild,ElementRef,NgZone } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,Platform,NavParams } from '@ionic/angular';
import { OtherService } from '../service/other.service';
import { ServerService } from '../service/server.service';
import { TranslateService } from '@ngx-translate/core';


@Component({
  selector: 'app-perm',
  templateUrl: './perm.page.html',
  styleUrls: ['./perm.page.scss'],
})
export class PermPage implements OnInit {

  data:any;
  hasClick = false;
  text:any;
  array:any = [];

  constructor(private translate: TranslateService,public navParams: NavParams,public otherService : OtherService,public server : ServerService) { 
  
    this.data       = navParams.get('data');

    if(this.data.perm)
    {
      this.array = this.data.perm.split(',');
    }
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
 
    this.server.assignPerm({perm : this.array,id : this.data.id}).subscribe((response:any) => {

      this.hasClick = false;

      if(response.msg == "error")
      {
        this.otherService.toast(response.error);
      }
      else
      {
        this.close(response);

        this.otherService.toast(this.translate.instant("Permission Assigned Successfully."));
      }

    });

    return;
  }

  setPerm(val:any)
  {
    const index = this.array.indexOf(val);
  
    if (index === -1) {
      
      this.array.push(val);
    } else {
      
      this.array.splice(index, 1);
    }

  }
  
  checkVal(val:any)
  {
    const index = this.array.indexOf(val);
  
    if (index === -1) {
      
    return false;

    } else {
      
      return true;
    }
  }

}

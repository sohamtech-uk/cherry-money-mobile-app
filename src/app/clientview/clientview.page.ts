import { Component, OnInit,ViewChild,ElementRef,NgZone } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,Platform,NavParams } from '@ionic/angular';
import { OtherService } from '../service/other.service';
import { ServerService } from '../service/server.service';


@Component({
  selector: 'app-clientview',
  templateUrl: './clientview.page.html',
  styleUrls: ['./clientview.page.scss'],
})
export class ClientviewPage implements OnInit {

  data:any;
  hasClick = false;
  text:any;
  user_data:any;

  constructor(public navParams: NavParams,public otherService : OtherService,public server : ServerService) { 
  
    this.data       = navParams.get('data');

    const user      = localStorage.getItem('user_data');
    
    if(user !== null) 
    {
      this.user_data =  JSON.parse(user);
    }
  }

  ngOnInit() {
  } 


  async close(data:any = [])
  {
    this.otherService.closeModel(data);
  }
}

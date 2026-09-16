import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,MenuController } from '@ionic/angular';
import { RouterLink } from '@angular/router';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { DomSanitizer, SafeUrl } from '@angular/platform-browser';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-contact',
  templateUrl: './contact.page.html',
  styleUrls: ['./contact.page.scss'],
})
export class ContactPage implements OnInit {

  hasClick:any = false;
  user:any;
  name:any;
  email:any;
  phone:any;

  constructor(private translate: TranslateService,private sanitizer: DomSanitizer,private menuCtrl : MenuController,public server : ServerService,public otherService : OtherService) {

    const user  = localStorage.getItem('user_data');
    
    if(user !== null) 
    {
      this.user =  JSON.parse(user);
      this.name = this.user.name;
      this.email = this.user.email;
      this.phone = this.user.phone;
    }

  }

  ngOnInit() {

    this.menuCtrl.enable(false);
  }


  async contact(data:any)
  {
    this.hasClick = true;

    this.server.contact(data).subscribe((response:any) => {

    this.hasClick = false;

    this.otherService.toast(this.translate.instant("Thank you, We have received your message, we will contact you soon." ));

    this.otherService.redirect('home');

    });

    return;
  }
}

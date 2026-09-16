import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,MenuController } from '@ionic/angular';
import { RouterLink } from '@angular/router';
import { ServerService } from '../service/server.service';
import { OtherService } from '../service/other.service';
import { DomSanitizer, SafeUrl } from '@angular/platform-browser';

@Component({
  selector: 'app-signup',
  templateUrl: './signup.page.html',
  styleUrls: ['./signup.page.scss'],
})
export class SignupPage implements OnInit {

  hasClick:any = false;
  term:any = false;
  privacy_link:any;
  country:any;
  app_logo:any;

  constructor(private sanitizer: DomSanitizer,private menuCtrl : MenuController,public server : ServerService,public otherService : OtherService) {

    const country = localStorage.getItem('country');
    
    if(country !== null) 
    {
      this.country =  JSON.parse(country);
    }

    this.privacy_link = localStorage.getItem('privacy_link');
    this.app_logo     = localStorage.getItem('app_logo');
  }

  ngOnInit() {

    this.menuCtrl.enable(false);
  }

  checkTerm()
  {
    this.term = !this.term;

    console.log(this.term);
  }

  async signup(data:any)
  {
    if(data.password.length < 6)
    {
      return this.otherService.toast("Password length should be atlest 6");
    }

    if(data.phone.length < 6)
    {
      return this.otherService.toast("Please enter valid phone number");
    }

    this.hasClick = true;

    this.server.signup(data).subscribe((response:any) => {

    this.hasClick = false;

    if(response.msg != "done")
    {
      this.otherService.toast(response.error);
    }
    else
    {
      this.otherService.redirect("otp/"+response.user.id+"/1");
    }

    });

    return;
  }
}

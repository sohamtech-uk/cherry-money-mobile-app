import { Component, OnInit,ViewChild,ElementRef,NgZone } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,Platform,NavParams,LoadingController,IonContent } from '@ionic/angular';
import { OtherService } from '../service/other.service';
import { ServerService } from '../service/server.service';
import { TranslateService } from '@ngx-translate/core';


@Component({
  selector: 'app-invoiceview',
  templateUrl: './invoiceview.page.html',
  styleUrls: ['./invoiceview.page.scss'],
})
export class InvoiceviewPage implements OnInit {

@ViewChild('content',{static : false}) private content: any;


  data:any;
  items:any;
  taxs:any;
  client:any;
  company:any;
  sub_total:any;
  hasClick:any = false;
  email:any;
  email_msg:any;
  logo:any;
  added:any;
  updated:any;


  constructor(private translate: TranslateService,public navParams: NavParams,public otherService : OtherService,public server : ServerService,public loadingController: LoadingController) { 
  
    this.data       = navParams.get('data');
    this.email      = navParams.get('email');
  }

  ngOnInit()
  {
    if(this.data.id)
    {
      this.loadData();
    }
  } 

  async close(data:any = [])
  {
    this.otherService.closeModel(data);
  }

  async loadData()
  {
    const loading = await this.loadingController.create({
      spinner:'dots',
      cssClass:'loader-css-class'
    });

    loading.present();

    this.server.editInvoice(this.data.id).subscribe((response:any) => {

      this.data     = response.data;
      this.items    = response.items;
      this.taxs     = response.taxs;
      this.client   = response.client;
      this.company  = response.company;
      this.logo     = response.logo;
      this.added    = response.added;
      this.updated  = response.updated;

      this.sub_total = this.items.reduce((sum: number, item: { price: number; qty: number; }) => {
        return sum + (item.price * item.qty);
      }, 0);

      this.email_msg = "Hi, "+this.client.first_name+" "+this.client.last_name+", Please check the attached invoice "+this.data.prefix+this.data.invo_no+" from "+this.company.company_name;
      
      setTimeout(() => {

        if(this.email)
        {
          const element = document.getElementById("email");
         
          if(element)
          {
            element.scrollIntoView({behavior: "smooth"});
          }
        }
    
      },100);

      loading.dismiss();

      });
  }

  async sendEmail()
  {
    this.hasClick = true;

    const data = {

      msg : this.email_msg,
      mobile : true
    }

    this.server.sendEmailInvoice(data,this.data.id).subscribe((response:any) => {

    this.hasClick = false;

    if(response.msg == "done")
    {
      this.otherService.toast( this.translate.instant("Email sent successfully."));

      this.close(response);
    }
    else
    {
      this.otherService.toast( this.translate.instant("Something went wrong, Please try again after some time."));
    }

    });
  }
}

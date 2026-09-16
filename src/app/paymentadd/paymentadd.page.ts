import { Component, OnInit,ViewChild,ElementRef,NgZone } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,Platform,NavParams,LoadingController } from '@ionic/angular';
import { OtherService } from '../service/other.service';
import { ServerService } from '../service/server.service';
import { TranslateService } from '@ngx-translate/core';


@Component({
  selector: 'app-paymentadd',
  templateUrl: './paymentadd.page.html',
  styleUrls: ['./paymentadd.page.scss'],
})
export class PaymentaddPage implements OnInit {

  data:any;
  hasClick = false;
  text:any;
  date_added:any;
  invoices:any;
  currency:any;
  select_invoice:any;
  invoice_id:any;
  amount:any;
  o_amount:any;

  constructor(private translate: TranslateService,public navParams: NavParams,public otherService : OtherService,public server : ServerService,public loadingController: LoadingController) { 
  
    this.data       = navParams.get('data');

    if(this.data.date_added)
    {
      this.date_added = this.data.date_added;
    }

    let currentDate = new Date();
    let year        = currentDate.getFullYear();
    let month       = String(currentDate.getMonth() + 1).padStart(2, '0');
    let day         = String(currentDate.getDate()).padStart(2, '0');
    this.date_added = `${year}-${month}-${day}`;
  }

  ngOnInit()
  {
    this.loadData();
  } 

  selectInvoice()
  {
    this.invoice_id = this.select_invoice.id;
    this.amount     = this.select_invoice.total_amount;
    this.o_amount   = this.select_invoice.total_amount;
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

    this.server.getUnpaid(this.data.id).subscribe((response:any) => {

    this.invoices = response.data;
    this.currency = response.currency;

    loading.dismiss();

    });

  }

  async addNew(data:any,id = 0)
  {
    if(this.amount > this.o_amount)
    {
      return this.otherService.toast("Amount cannot be greater than "+this.currency+this.o_amount);
    }

    data.date_added = this.date_added;
    data.invoice_id = this.invoice_id;

    this.hasClick = true;
 
    this.server.paymentAdd(data,this.data.id ? this.data.id : id).subscribe((response:any) => {

      this.hasClick = false;

      this.close(response);

      this.otherService.toast( this.translate.instant("New Payment Added Successfully."));

    });

    return;
  }
}

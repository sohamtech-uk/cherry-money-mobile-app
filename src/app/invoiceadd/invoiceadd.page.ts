import { Component, OnInit,ViewChild,ElementRef,NgZone } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,Platform,NavParams,LoadingController } from '@ionic/angular';
import { OtherService } from '../service/other.service';
import { ServerService } from '../service/server.service';
import { TranslateService } from '@ngx-translate/core';


@Component({
  selector: 'app-invoiceadd',
  templateUrl: './invoiceadd.page.html',
  styleUrls: ['./invoiceadd.page.scss'],
})
export class InvoiceaddPage implements OnInit {

  data:any;
  hasClick = false;
  text:any;
  add:any;
  date_added:any;
  due_date:any;
  array = [1];
  selectedProducts: any[] = [];
  qty: number[] = [];
  price: number[] = [];
  total: number[] = [];
  discount:any;
  added_items:any;
  added_taxs:any;
  qno:any;
  prefix:any;
  add_new_client:any = false;

  constructor(private translate: TranslateService,public navParams: NavParams,public otherService : OtherService,public server : ServerService,public loadingController: LoadingController) { 
  
    this.data       = navParams.get('data');
    this.add        = navParams.get('add');

    if(!this.data.temp_type)
    {
      this.data.temp_type     = "temp_1";
      this.data.invoice_note  = this.add.company.invoice_note;
      this.qno                = this.add.qno
      this.prefix             = this.add.company.prefix
    }

    let currentDate = new Date();
    let year        = currentDate.getFullYear();
    let month       = String(currentDate.getMonth() + 1).padStart(2, '0');
    let day         = String(currentDate.getDate()).padStart(2, '0');
    this.date_added = `${year}-${month}-${day}`;
  }

  ngOnInit()
  {
    if(this.data.id)
    {
      this.loadData();
    }
  } 

  addClient()
  {
    this.add_new_client = !this.add_new_client;
  }

  async loadData()
  {
    const loading = await this.loadingController.create({
      spinner:'dots',
      cssClass:'loader-css-class'
    });

    loading.present();

    this.server.editInvoice(this.data.id).subscribe((response:any) => {

      this.data         = response.data;
      this.qno          = this.data.invo_no;
      this.prefix       = this.data.prefix;
      this.added_items  = response.items;
      this.added_taxs   = response.taxs;
      this.array        = [];

      for(var i =0;i<this.added_items.length;i++)
      {
        this.selectedProducts.push(this.added_items[i].product_id);
        this.qty[i] = this.added_items[i].qty; 
        this.price[i] = this.added_items[i].price; 
        this.setTotal(i);

        this.array.push(i+1);

      }

      loading.dismiss();

      });
  }

  addMore()
  {
    this.array.push(this.array.length+1);
  }

  setPrice(i: number) 
  {    

    const selectedProduct = this.add.products.find((pro: any) => pro.id === this.selectedProducts[i]);
    
    if (selectedProduct) {
      this.qty[i] = 1; // Set quantity to 1
      this.price[i] = selectedProduct.price; // Set the price based on selected product
      this.setTotal(i); // Calculate total
    }
  }
  
  setTotal(i: number) {
    const quantity = this.qty[i] || 0;
    const price = this.price[i] || 0;
    this.total[i] = quantity * price; // Calculate total based on updated quantity and price
  }
  
  removePro(i: number) {
    this.array.splice(i, 1);
    this.selectedProducts.splice(i, 1);
    this.qty.splice(i, 1);
    this.price.splice(i, 1);
    this.total.splice(i, 1);
  }

  calculateGrandTotal() {
    return this.total.reduce((acc, curr) => acc + (curr || 0), 0);
  }

  calculateDiscountedTotal() {
    const grandTotal = this.calculateGrandTotal(); // Get the subtotal
    let discountValue = this.data.discount || 0; // Get discount value
    
    // Apply discount logic based on the selected discount type
    if (this.data.discount_type === 2) { // Percentage discount
      discountValue = (discountValue / 100) * grandTotal;
    }
    
    this.discount = discountValue;

    const discountedTotal = grandTotal - discountValue; // Subtotal after discount
    return discountedTotal < 0 ? 0 : discountedTotal; // Ensure non-negative total
  }
  
  calculateTaxAmount(taxValue: number) {
    const discountedTotal = this.calculateDiscountedTotal(); // Get discounted total
    return (taxValue / 100) * discountedTotal; // Calculate tax based on discounted total
  }
  
  calculateFinalTotalWithTax() {
    const discountedTotal = this.calculateDiscountedTotal(); // Subtotal after discount
    let totalTax = 0;
  
    // Sum up all taxes
    this.add.taxs.forEach((tax: any) => {
      totalTax += this.calculateTaxAmount(tax.tax_value);
    });
  
    return discountedTotal + totalTax; // Total after adding taxes
  }

  async close(data:any = [])
  {
    this.otherService.closeModel(data);
  }

  async addNew(data:any,id = 0)
  {
    data.prefix         = this.add.company.prefix;
    data.date_added     = this.date_added;
    data.discount_value = this.discount && this.discount > 0 ? this.discount.toFixed(2) : 0;
    data.total_amount   = this.calculateFinalTotalWithTax().toFixed(2);
    data.array          = this.array;
    data.sub_total      = this.calculateGrandTotal().toFixed(2);
    data.invoice_term   = this.add.company.invoice_term;

    this.hasClick = true;
    
    console.log(data);

    this.server.invoiceAdd(data,this.data.id ? this.data.id : id).subscribe((response:any) => {

      this.hasClick = false;

      this.close(response);

      this.otherService.toast(this.translate.instant("New Invoice Added Successfully."));

    });

    return;
  }
}

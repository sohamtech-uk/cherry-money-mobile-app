import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { InvoiceaddPageRoutingModule } from './invoiceadd-routing.module';

import { InvoiceaddPage } from './invoiceadd.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    InvoiceaddPageRoutingModule,
    TranslateModule
  ],
  declarations: [InvoiceaddPage]
})
export class InvoiceaddPageModule {}

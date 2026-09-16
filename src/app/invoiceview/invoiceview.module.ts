import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { InvoiceviewPageRoutingModule } from './invoiceview-routing.module';

import { InvoiceviewPage } from './invoiceview.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    InvoiceviewPageRoutingModule,
    TranslateModule
  ],
  declarations: [InvoiceviewPage]
})
export class InvoiceviewPageModule {}

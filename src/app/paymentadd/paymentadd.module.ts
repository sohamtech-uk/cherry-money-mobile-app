import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { PaymentaddPageRoutingModule } from './paymentadd-routing.module';

import { PaymentaddPage } from './paymentadd.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    PaymentaddPageRoutingModule,
    TranslateModule
  ],
  declarations: [PaymentaddPage]
})
export class PaymentaddPageModule {}

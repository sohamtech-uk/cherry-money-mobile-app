import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { TaxPageRoutingModule } from './tax-routing.module';

import { TaxPage } from './tax.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    TaxPageRoutingModule,
    TranslateModule
  ],
  declarations: [TaxPage]
})
export class TaxPageModule {}

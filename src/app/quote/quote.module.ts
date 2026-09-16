import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { QuotePageRoutingModule } from './quote-routing.module';

import { QuotePage } from './quote.page';
import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    QuotePageRoutingModule,
    TranslateModule
  ],
  declarations: [QuotePage]
})
export class QuotePageModule {}

import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { QuoteviewPageRoutingModule } from './quoteview-routing.module';

import { QuoteviewPage } from './quoteview.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    QuoteviewPageRoutingModule,
    TranslateModule
  ],
  declarations: [QuoteviewPage]
})
export class QuoteviewPageModule {}

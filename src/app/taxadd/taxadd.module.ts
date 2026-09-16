import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { TaxaddPageRoutingModule } from './taxadd-routing.module';

import { TaxaddPage } from './taxadd.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    TaxaddPageRoutingModule,
    TranslateModule
  ],
  declarations: [TaxaddPage]
})
export class TaxaddPageModule {}

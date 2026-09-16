import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';
import { TranslateModule } from '@ngx-translate/core';

import { CherryPayPageRoutingModule } from './cherry-pay-routing.module';
import { CherryPayPage } from './cherry-pay.page';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    TranslateModule,
    CherryPayPageRoutingModule
  ],
  declarations: [CherryPayPage]
})
export class CherryPayPageModule {}

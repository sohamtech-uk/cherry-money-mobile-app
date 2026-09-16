import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { RecaddPageRoutingModule } from './recadd-routing.module';

import { RecaddPage } from './recadd.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    RecaddPageRoutingModule,
    TranslateModule
  ],
  declarations: [RecaddPage]
})
export class RecaddPageModule {}

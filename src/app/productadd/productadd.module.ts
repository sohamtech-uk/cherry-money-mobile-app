import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { ProductaddPageRoutingModule } from './productadd-routing.module';

import { ProductaddPage } from './productadd.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    ProductaddPageRoutingModule,
    TranslateModule
  ],
  declarations: [ProductaddPage]
})
export class ProductaddPageModule {}

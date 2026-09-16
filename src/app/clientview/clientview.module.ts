import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { ClientviewPageRoutingModule } from './clientview-routing.module';

import { ClientviewPage } from './clientview.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    ClientviewPageRoutingModule,
    TranslateModule
  ],
  declarations: [ClientviewPage]
})
export class ClientviewPageModule {}

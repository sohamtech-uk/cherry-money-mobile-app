import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { ClientaddPageRoutingModule } from './clientadd-routing.module';

import { ClientaddPage } from './clientadd.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    ClientaddPageRoutingModule,
    TranslateModule
  ],
  declarations: [ClientaddPage]
})
export class ClientaddPageModule {}

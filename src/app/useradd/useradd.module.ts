import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { UseraddPageRoutingModule } from './useradd-routing.module';

import { UseraddPage } from './useradd.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    UseraddPageRoutingModule,
    TranslateModule
  ],
  declarations: [UseraddPage]
})
export class UseraddPageModule {}

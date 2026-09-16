import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { PermPageRoutingModule } from './perm-routing.module';

import { PermPage } from './perm.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    PermPageRoutingModule,
    TranslateModule
  ],
  declarations: [PermPage]
})
export class PermPageModule {}

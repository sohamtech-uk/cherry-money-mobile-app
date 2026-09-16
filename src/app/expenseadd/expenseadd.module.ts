import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { ExpenseaddPageRoutingModule } from './expenseadd-routing.module';

import { ExpenseaddPage } from './expenseadd.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    ExpenseaddPageRoutingModule,
    TranslateModule
  ],
  declarations: [ExpenseaddPage]
})
export class ExpenseaddPageModule {}

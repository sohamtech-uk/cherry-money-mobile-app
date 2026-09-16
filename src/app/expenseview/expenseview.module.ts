import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { ExpenseviewPageRoutingModule } from './expenseview-routing.module';

import { ExpenseviewPage } from './expenseview.page';

import { TranslateModule } from '@ngx-translate/core';


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    ExpenseviewPageRoutingModule,
    TranslateModule
  ],
  declarations: [ExpenseviewPage]
})
export class ExpenseviewPageModule {}

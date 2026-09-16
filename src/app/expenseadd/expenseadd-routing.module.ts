import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { ExpenseaddPage } from './expenseadd.page';

const routes: Routes = [
  {
    path: '',
    component: ExpenseaddPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ExpenseaddPageRoutingModule {}

import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { CherryPayPage } from './cherry-pay.page';

const routes: Routes = [
  {
    path: '',
    component: CherryPayPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class CherryPayPageRoutingModule {}

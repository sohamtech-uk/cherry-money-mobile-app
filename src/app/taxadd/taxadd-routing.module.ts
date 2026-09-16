import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { TaxaddPage } from './taxadd.page';

const routes: Routes = [
  {
    path: '',
    component: TaxaddPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class TaxaddPageRoutingModule {}

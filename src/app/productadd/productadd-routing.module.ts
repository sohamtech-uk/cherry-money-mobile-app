import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { ProductaddPage } from './productadd.page';

const routes: Routes = [
  {
    path: '',
    component: ProductaddPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ProductaddPageRoutingModule {}

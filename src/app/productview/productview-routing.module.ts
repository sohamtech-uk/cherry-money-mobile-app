import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { ProductviewPage } from './productview.page';

const routes: Routes = [
  {
    path: '',
    component: ProductviewPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ProductviewPageRoutingModule {}

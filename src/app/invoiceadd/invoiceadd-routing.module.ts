import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { InvoiceaddPage } from './invoiceadd.page';

const routes: Routes = [
  {
    path: '',
    component: InvoiceaddPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class InvoiceaddPageRoutingModule {}

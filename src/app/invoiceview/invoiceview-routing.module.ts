import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { InvoiceviewPage } from './invoiceview.page';

const routes: Routes = [
  {
    path: '',
    component: InvoiceviewPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class InvoiceviewPageRoutingModule {}

import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { PaymentaddPage } from './paymentadd.page';

const routes: Routes = [
  {
    path: '',
    component: PaymentaddPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class PaymentaddPageRoutingModule {}

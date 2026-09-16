import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { ClientviewPage } from './clientview.page';

const routes: Routes = [
  {
    path: '',
    component: ClientviewPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ClientviewPageRoutingModule {}

import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { ClientaddPage } from './clientadd.page';

const routes: Routes = [
  {
    path: '',
    component: ClientaddPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ClientaddPageRoutingModule {}

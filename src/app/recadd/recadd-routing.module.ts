import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { RecaddPage } from './recadd.page';

const routes: Routes = [
  {
    path: '',
    component: RecaddPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class RecaddPageRoutingModule {}

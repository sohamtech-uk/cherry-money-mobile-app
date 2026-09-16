import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { PermPage } from './perm.page';

const routes: Routes = [
  {
    path: '',
    component: PermPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class PermPageRoutingModule {}

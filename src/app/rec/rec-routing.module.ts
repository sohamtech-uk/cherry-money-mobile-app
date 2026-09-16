import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { RecPage } from './rec.page';

const routes: Routes = [
  {
    path: '',
    component: RecPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class RecPageRoutingModule {}

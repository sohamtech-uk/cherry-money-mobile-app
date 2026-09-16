import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { QuoteviewPage } from './quoteview.page';

const routes: Routes = [
  {
    path: '',
    component: QuoteviewPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class QuoteviewPageRoutingModule {}

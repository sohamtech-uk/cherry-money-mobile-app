import { NgModule } from '@angular/core';
import { PreloadAllModules, RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  {
    path: '',
    redirectTo: 'folder/Inbox',
    pathMatch: 'full'
  },
  {
    path: 'folder/:id',
    loadChildren: () => import('./folder/folder.module').then( m => m.FolderPageModule)
  },
  {
    path: 'login',
    loadChildren: () => import('./login/login.module').then( m => m.LoginPageModule)
  },
  {
    path: 'signup',
    loadChildren: () => import('./signup/signup.module').then( m => m.SignupPageModule)
  },
  {
    path: 'forgot',
    loadChildren: () => import('./forgot/forgot.module').then( m => m.ForgotPageModule)
  },
  {
    path: 'otp/:id/:type',
    loadChildren: () => import('./otp/otp.module').then( m => m.OtpPageModule)
  },
  {
    path: 'password',
    loadChildren: () => import('./password/password.module').then( m => m.PasswordPageModule)
  },
  {
    path: 'home',
    loadChildren: () => import('./home/home.module').then( m => m.HomePageModule)
  },
  {
    path: 'client',
    loadChildren: () => import('./client/client.module').then( m => m.ClientPageModule)
  },
  {
    path: 'setting',
    loadChildren: () => import('./setting/setting.module').then( m => m.SettingPageModule)
  },
  {
    path: 'user',
    loadChildren: () => import('./user/user.module').then( m => m.UserPageModule)
  },
  {
    path: 'sub',
    loadChildren: () => import('./sub/sub.module').then( m => m.SubPageModule)
  },
  {
    path: 'temp',
    loadChildren: () => import('./temp/temp.module').then( m => m.TempPageModule)
  },
  {
    path: 'product',
    loadChildren: () => import('./product/product.module').then( m => m.ProductPageModule)
  },
  {
    path: 'tax',
    loadChildren: () => import('./tax/tax.module').then( m => m.TaxPageModule)
  },
  {
    path: 'quote',
    loadChildren: () => import('./quote/quote.module').then( m => m.QuotePageModule)
  },
  {
    path: 'invoice',
    loadChildren: () => import('./invoice/invoice.module').then( m => m.InvoicePageModule)
  },
  {
    path: 'rec',
    loadChildren: () => import('./rec/rec.module').then( m => m.RecPageModule)
  },
  {
    path: 'payment',
    loadChildren: () => import('./payment/payment.module').then( m => m.PaymentPageModule)
  },
  {
    path: 'cherry-pay',
    loadChildren: () => import('./cherry-pay/cherry-pay.module').then( m => m.CherryPayPageModule)
  },
  {
    path: 'expense',
    loadChildren: () => import('./expense/expense.module').then( m => m.ExpensePageModule)
  },
  {
    path: 'welcome',
    loadChildren: () => import('./welcome/welcome.module').then( m => m.WelcomePageModule)
  },
  {
    path: 'clientadd',
    loadChildren: () => import('./clientadd/clientadd.module').then( m => m.ClientaddPageModule)
  },
  {
    path: 'clientview',
    loadChildren: () => import('./clientview/clientview.module').then( m => m.ClientviewPageModule)
  },
  {
    path: 'taxadd',
    loadChildren: () => import('./taxadd/taxadd.module').then( m => m.TaxaddPageModule)
  },
  {
    path: 'productadd',
    loadChildren: () => import('./productadd/productadd.module').then( m => m.ProductaddPageModule)
  },
  {
    path: 'productview',
    loadChildren: () => import('./productview/productview.module').then( m => m.ProductviewPageModule)
  },
  {
    path: 'expenseadd',
    loadChildren: () => import('./expenseadd/expenseadd.module').then( m => m.ExpenseaddPageModule)
  },
  {
    path: 'expenseview',
    loadChildren: () => import('./expenseview/expenseview.module').then( m => m.ExpenseviewPageModule)
  },
  {
    path: 'quoteadd',
    loadChildren: () => import('./quoteadd/quoteadd.module').then( m => m.QuoteaddPageModule)
  },
  {
    path: 'quoteview',
    loadChildren: () => import('./quoteview/quoteview.module').then( m => m.QuoteviewPageModule)
  },
  {
    path: 'invoiceadd',
    loadChildren: () => import('./invoiceadd/invoiceadd.module').then( m => m.InvoiceaddPageModule)
  },
  {
    path: 'invoiceview',
    loadChildren: () => import('./invoiceview/invoiceview.module').then( m => m.InvoiceviewPageModule)
  },
  {
    path: 'recadd',
    loadChildren: () => import('./recadd/recadd.module').then( m => m.RecaddPageModule)
  },
  {
    path: 'paymentadd',
    loadChildren: () => import('./paymentadd/paymentadd.module').then( m => m.PaymentaddPageModule)
  },
  {
    path: 'useradd',
    loadChildren: () => import('./useradd/useradd.module').then( m => m.UseraddPageModule)
  },
  {
    path: 'perm',
    loadChildren: () => import('./perm/perm.module').then( m => m.PermPageModule)
  },
  {
    path: 'contact',
    loadChildren: () => import('./contact/contact.module').then( m => m.ContactPageModule)
  },
  {
    path: 'language',
    loadChildren: () => import('./language/language.module').then( m => m.LanguagePageModule)
  }
];

@NgModule({
  imports: [
    RouterModule.forRoot(routes, { preloadingStrategy: PreloadAllModules })
  ],
  exports: [RouterModule]
})
export class AppRoutingModule {}

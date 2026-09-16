import { Injectable } from '@angular/core';
import { HttpHeaders,HttpClient } from '@angular/common/http';

import { map,catchError } from 'rxjs/operators';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ServerService {

  url = environment.apiUrl;

  private authOptions() {
    return {
      headers: new HttpHeaders({
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + localStorage.getItem('_token')
      })
    };
  }

  constructor(private http: HttpClient) { }

  welcome()
  {
    return this.http.get(this.url+'welcome')
             .pipe(map(results => results));
  }

  signup(data:any)
  {
    return this.http.post(this.url+"signup",data)
             .pipe(map(results => results));
  }

  login(data:any)
  {
    return this.http.post(this.url+"login",data)
             .pipe(map(results => results));
  }

  loginGoogle(data:any)
  {
    return this.http.post(this.url+"loginGoogle",data)
             .pipe(map(results => results));
  }

  resendCode(id:any)
  {
    return this.http.get(this.url+"resendCode?id="+id)
             .pipe(map(results => results));
  }

  verifyOtp(data:any,id:any)
  {
    return this.http.post(this.url+"verifyOtp?id="+id,data)
             .pipe(map(results => results));
  }

  forgot(data:any)
  {
    return this.http.post(this.url+"forgot",data)
             .pipe(map(results => results));
  }

  resetPassword(data:any,id:any)
  {
    return this.http.post(this.url+"resetPassword?id="+id,data)
             .pipe(map(results => results));
  }

  language()
  {
    return this.http.get(this.url+"language")
             .pipe(map(results => results));
  }

  page(slug:any)
  {
    return this.http.get(this.url+"page?slug="+slug)
             .pipe(map(results => results));
  }

  deleteAccount(data:any)
  {
    return this.http.post(this.url+"deleteAccount",data,this.authOptions())
             .pipe(map(results => results));
  }

  home() {
    return this.http.get(this.url + "homepage", this.authOptions())
             .pipe(
               map(results => results),
               catchError(error => {

                 return [{'fail' : error}];
               })
             );
  }

  setting()
  {
    return this.http.get(this.url+"setting",this.authOptions())
             .pipe(map(results => results));
  }

  updateSetting(data:any)
  {
    return this.http.post(this.url+"updateSetting?mobile=true",data,this.authOptions())
             .pipe(map(results => results));
  }

  client(page:any = 1)
  {
    return this.http.get(this.url+"client?page="+page,this.authOptions())
             .pipe(map(results => results));
  }

  clientAdd(data:any,id:any = 0)
  {
    return this.http.post(this.url+"clientAdd?id="+id,data,this.authOptions())
             .pipe(map(results => results));
  }

  removeClient(id:any)
  {
    return this.http.get(this.url+"removeClient?id="+id,this.authOptions())
             .pipe(map(results => results));
  }

  tax(page:any = 1)
  {
    return this.http.get(this.url+"tax",this.authOptions())
             .pipe(map(results => results));
  }

  taxAdd(data:any,id:any = 0)
  {
    return this.http.post(this.url+"taxAdd?id="+id,data,this.authOptions())
             .pipe(map(results => results));
  }

  removeTax(id:any)
  {
    return this.http.get(this.url+"removeTax?id="+id,this.authOptions())
             .pipe(map(results => results));
  }

  product(page:any = 1)
  {
    return this.http.get(this.url+"product?page="+page,this.authOptions())
             .pipe(map(results => results));
  }

  productAdd(data:any,id:any = 0)
  {
    return this.http.post(this.url+"productAdd?id="+id,data,this.authOptions())
             .pipe(map(results => results));
  }

  removeProduct(id:any)
  {
    return this.http.get(this.url+"removeProduct?id="+id,this.authOptions())
             .pipe(map(results => results));
  }

  expense(page:any = 1)
  {
    return this.http.get(this.url+"expense?page="+page,this.authOptions())
             .pipe(map(results => results));
  }

  expenseAdd(data:any,id:any = 0)
  {
    return this.http.post(this.url+"expenseAdd?id="+id,data,this.authOptions())
             .pipe(map(results => results));
  }

  removeExpense(id:any)
  {
    return this.http.get(this.url+"removeExpense?id="+id,this.authOptions())
             .pipe(map(results => results));
  }

  quote(page:any = 1,status:any = 'all')
  {
    return this.http.get(this.url+"quote?page="+page+"&status="+status,this.authOptions())
             .pipe(map(results => results));
  }

  quoteAdd(data:any,id:any = 0)
  {
    return this.http.post(this.url+"quoteAdd?id="+id+"&mobile=true",data,this.authOptions())
             .pipe(map(results => results));
  }

  removeQuote(id:any)
  {
    return this.http.get(this.url+"removeQuote?id="+id,this.authOptions())
             .pipe(map(results => results));
  }

  editQuote(id:any)
  {
    return this.http.get(this.url+"editQuote?id="+id,this.authOptions())
             .pipe(map(results => results));
  }

  sendEmailQuote(data:any,id:any)
  {
    return this.http.post(this.url+"sendEmailQuote?id="+id,data,this.authOptions())
             .pipe(map(results => results));
  }

  makeInvoice(id:any)
  {
    return this.http.get(this.url+"makeInvoice?id="+id,this.authOptions())
             .pipe(map(results => results));
  }

  invoice(page:any = 1,status:any = 'all')
  {
    return this.http.get(this.url+"invoice?page="+page+"&status="+status,this.authOptions())
             .pipe(map(results => results));
  }

  invoiceAdd(data:any,id:any = 0)
  {
    return this.http.post(this.url+"invoiceAdd?id="+id+"&mobile=true",data,this.authOptions())
             .pipe(map(results => results));
  }

  removeInvoice(id:any)
  {
    return this.http.get(this.url+"removeInvoice?id="+id,this.authOptions())
             .pipe(map(results => results));
  }

  editInvoice(id:any)
  {
    return this.http.get(this.url+"editInvoice?id="+id,this.authOptions())
             .pipe(map(results => results));
  }

  sendEmailInvoice(data:any,id:any)
  {
    return this.http.post(this.url+"sendEmailInvoice?id="+id,data,this.authOptions())
             .pipe(map(results => results));
  }

  stopRec(id:any,type:any = 0)
  {
    return this.http.get(this.url+"stopRec?id="+id+"&type="+type,this.authOptions())
             .pipe(map(results => results));
  }

  recAdd(data:any)
  {
    return this.http.post(this.url+"recAdd",data,this.authOptions())
             .pipe(map(results => results));
  }

  rec(page:any = 1)
  {
    return this.http.get(this.url+"rec?page="+page,this.authOptions())
             .pipe(map(results => results));
  }

  payment(page:any = 1,status:any = 'all')
  {
    return this.http.get(this.url+"payment?page="+page+'&payment_method='+status,this.authOptions())
             .pipe(map(results => results));
  }

  paymentAdd(data:any,id:any = 0)
  {
    return this.http.post(this.url+"paymentAdd?id="+id,data,this.authOptions())
             .pipe(map(results => results));
  }

  createCherryPayRequest(data:any)
  {
    return this.http.post(this.url+"cherryPay/payment-request",data,this.authOptions())
             .pipe(map(results => results));
  }

  removePayment(id:any)
  {
    return this.http.get(this.url+"removePayment?id="+id,this.authOptions())
             .pipe(map(results => results));
  }

  getUnpaid(id:any)
  {
    return this.http.get(this.url+"getUnpaid",this.authOptions())
             .pipe(map(results => results));
  }

  sub()
  {
    return this.http.get(this.url+"sub",this.authOptions())
             .pipe(map(results => results));
  }

  user()
  {
    return this.http.get(this.url+"user",this.authOptions())
             .pipe(map(results => results));
  }

  userAdd(data:any,id:any = 0)
  {
    return this.http.post(this.url+"userAdd?id="+id,data,this.authOptions())
             .pipe(map(results => results));
  }

  removeUser(id:any)
  {
    return this.http.get(this.url+"removeUser?id="+id,this.authOptions())
             .pipe(map(results => results));
  }

  assignPerm(data:any)
  {
    return this.http.post(this.url+"assignPerm",data,this.authOptions())
             .pipe(map(results => results));
  }

  logout()
  {
    return this.http.get(this.url+"logout",this.authOptions())
             .pipe(map(results => results));
  }

  contact(data:any)
  {
    return this.http.post(this.url+"contact",data,this.authOptions())
             .pipe(map(results => results));
  }

  scanReceipt(data:any)
  {
    return this.http.post(this.url+"scanReceipt",data,this.authOptions())
             .pipe(map(results => results));
  }
}

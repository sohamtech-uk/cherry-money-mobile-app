import { Component, OnInit } from '@angular/core';
import { LoadingController } from '@ionic/angular';
import { environment } from '../../environments/environment';
import { OtherService } from '../service/other.service';
import { ServerService } from '../service/server.service';

type CherryPayMode = 'standalone' | 'invoice';

@Component({
  selector: 'app-cherry-pay',
  templateUrl: './cherry-pay.page.html',
  styleUrls: ['./cherry-pay.page.scss'],
})
export class CherryPayPage implements OnInit {

  mode: CherryPayMode = 'standalone';
  invoices:any[] = [];
  selectedInvoice:any;
  loadingInvoices = false;
  hasClick = false;

  amount:any = null;
  currency = 'GBP';
  reference = '';
  description = 'Cherry Pay payment request';
  payerName = '';
  payerEmail = '';

  paymentLink = '';
  qrCodeUrl = '';
  whatsappShareUrl = '';
  emailShareUrl = '';
  smsShareUrl = '';
  requestStatus = '';
  currencySymbol = '\u00a3';

  constructor(
    public server: ServerService,
    public otherService: OtherService,
    public loadingController: LoadingController
  ) {
    this.otherService.statusBar('#AD1929', 2);
    this.reference = this.defaultReference();
  }

  ngOnInit() {
    this.loadInvoices();
  }

  modeChanged() {
    this.clearResult();

    if (this.mode === 'standalone') {
      this.selectedInvoice = null;
      this.reference = this.defaultReference();
      this.description = 'Cherry Pay payment request';
      return;
    }

    if (!this.invoices.length) {
      this.loadInvoices();
    }
  }

  async loadInvoices() {
    this.loadingInvoices = true;

    this.server.invoice(1, 'all').subscribe({
      next: (response:any) => {
        this.invoices = Array.isArray(response.data) ? response.data : [];
        this.currencySymbol = response.add?.currency || this.currencySymbol;
        this.currency = this.currencyCodeFrom(response.add?.currency_code || response.add?.currency || this.currency);
        this.loadingInvoices = false;
      },
      error: () => {
        this.loadingInvoices = false;
        this.otherService.toast('Invoices could not be loaded.');
      }
    });
  }

  selectInvoice() {
    this.clearResult();

    if (!this.selectedInvoice) {
      return;
    }

    const invoice = this.selectedInvoice;
    const invoiceNumber = this.invoiceNumber(invoice);
    const clientName = this.clientName(invoice);

    this.amount = this.toMoney(invoice.balance || invoice.due_amount || invoice.total_amount || 0);
    this.reference = invoiceNumber || this.defaultReference();
    this.description = invoiceNumber
      ? `Payment for invoice ${invoiceNumber}${clientName ? ' - ' + clientName : ''}`
      : 'Cherry Pay invoice payment';

    if (invoice.email) {
      this.payerEmail = invoice.email;
    }
  }

  async createRequest() {
    if (!this.amount || Number(this.amount) <= 0) {
      this.otherService.toast('Please enter a valid amount.');
      return;
    }

    const payload = this.payload();
    this.hasClick = true;

    const loading = await this.loadingController.create({
      spinner: 'dots',
      cssClass: 'loader-css-class'
    });

    await loading.present();

    this.server.createCherryPayRequest(payload).subscribe({
      next: (response:any) => {
        this.hasClick = false;
        loading.dismiss();

        const link = this.extractPaymentLink(response) || this.buildHostedCherryPayUrl(payload);
        this.setPaymentLink(link, this.extractStatus(response) || 'Ready to share');

        if (!this.extractPaymentLink(response)) {
          this.otherService.toast('Cherry Pay link prepared with the hosted page.');
        }
      },
      error: () => {
        this.hasClick = false;
        loading.dismiss();
        this.setPaymentLink(this.buildHostedCherryPayUrl(payload), 'Ready to share');
        this.otherService.toast('Cherry Pay API is not available yet. Hosted page link prepared.');
      }
    });
  }

  async shareNative() {
    if (!this.paymentLink) {
      return;
    }

    const nav = navigator as Navigator & { share?: (data: ShareData) => Promise<void> };

    if (nav.share) {
      await nav.share({
        title: 'Cherry Pay',
        text: this.shareMessage(),
        url: this.paymentLink
      });
      return;
    }

    this.copyLink();
  }

  async copyLink() {
    if (!this.paymentLink) {
      return;
    }

    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(this.paymentLink);
      this.otherService.toast('Payment link copied.');
      return;
    }

    const input = document.createElement('textarea');
    input.value = this.paymentLink;
    document.body.appendChild(input);
    input.select();
    document.execCommand('copy');
    document.body.removeChild(input);
    this.otherService.toast('Payment link copied.');
  }

  openPaymentPage() {
    if (this.paymentLink) {
      window.open(this.paymentLink, '_blank');
    }
  }

  openHostedCherryPay() {
    window.open(this.buildHostedCherryPayUrl(this.payload()), '_blank');
  }

  invoiceLabel(invoice:any) {
    const amount = this.toMoney(invoice.balance || invoice.due_amount || invoice.total_amount || 0);
    const client = this.clientName(invoice);
    const parts = [this.invoiceNumber(invoice), client, `${this.currencySymbol}${amount}`].filter(Boolean);

    return parts.join(' - ');
  }

  private payload() {
    return {
      mode: this.mode,
      invoice_id: this.mode === 'invoice' && this.selectedInvoice ? this.selectedInvoice.id : null,
      amount: Number(this.amount),
      currency: this.currency,
      reference: this.reference,
      description: this.description,
      payer_name: this.payerName,
      payer_email: this.payerEmail,
      mobile: true
    };
  }

  private setPaymentLink(link:string, status:string) {
    this.paymentLink = link;
    this.requestStatus = status;
    this.qrCodeUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=320x320&data=' + encodeURIComponent(link);

    const message = this.shareMessage();
    this.whatsappShareUrl = 'https://wa.me/?text=' + encodeURIComponent(message);
    this.emailShareUrl = 'mailto:?subject=' + encodeURIComponent('Cherry Pay payment request') + '&body=' + encodeURIComponent(message);
    this.smsShareUrl = 'sms:?&body=' + encodeURIComponent(message);
  }

  private shareMessage() {
    const amount = this.amount ? `${this.currency} ${this.toMoney(this.amount)}` : '';
    const reference = this.reference ? ` for ${this.reference}` : '';

    return `Cherry Pay request${reference}${amount ? ' - ' + amount : ''}: ${this.paymentLink}`;
  }

  private buildHostedCherryPayUrl(payload:any) {
    const url = new URL('dashboard/cherry-pay', environment.webUrl);

    Object.keys(payload).forEach((key) => {
      const value = payload[key];
      if (value !== null && value !== undefined && value !== '') {
        url.searchParams.set(key, String(value));
      }
    });

    return url.toString();
  }

  private extractPaymentLink(response:any) {
    const data = response?.data || response || {};

    return data.payment_url || data.paymentUrl || data.url || data.link || data.checkout_url || data.public_url || '';
  }

  private extractStatus(response:any) {
    const data = response?.data || response || {};

    return data.status || data.message || response?.message || '';
  }

  private clearResult() {
    this.paymentLink = '';
    this.qrCodeUrl = '';
    this.whatsappShareUrl = '';
    this.emailShareUrl = '';
    this.smsShareUrl = '';
    this.requestStatus = '';
  }

  private defaultReference() {
    return 'CPAY-' + new Date().getTime().toString().slice(-8);
  }

  private invoiceNumber(invoice:any) {
    return `${invoice.prefix || ''}${invoice.invo_no || invoice.invoice_no || invoice.id || ''}`;
  }

  private clientName(invoice:any) {
    return `${invoice.first_name || ''} ${invoice.last_name || ''}`.trim();
  }

  private toMoney(value:any) {
    const amount = Number(value || 0);

    return amount.toFixed(2);
  }

  private currencyCodeFrom(value:any) {
    const text = String(value || '').trim().toUpperCase();

    if (text === '\u00a3' || text === 'GBP') {
      return 'GBP';
    }

    if (text === '$' || text === 'USD') {
      return 'USD';
    }

    if (text === '\u20ac' || text === 'EUR') {
      return 'EUR';
    }

    return /^[A-Z]{3}$/.test(text) ? text : 'GBP';
  }
}

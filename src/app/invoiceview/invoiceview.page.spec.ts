import { ComponentFixture, TestBed } from '@angular/core/testing';
import { InvoiceviewPage } from './invoiceview.page';

describe('InvoiceviewPage', () => {
  let component: InvoiceviewPage;
  let fixture: ComponentFixture<InvoiceviewPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(InvoiceviewPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

import { ComponentFixture, TestBed } from '@angular/core/testing';
import { InvoiceaddPage } from './invoiceadd.page';

describe('InvoiceaddPage', () => {
  let component: InvoiceaddPage;
  let fixture: ComponentFixture<InvoiceaddPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(InvoiceaddPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

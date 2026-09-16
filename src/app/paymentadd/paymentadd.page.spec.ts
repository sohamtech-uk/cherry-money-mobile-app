import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PaymentaddPage } from './paymentadd.page';

describe('PaymentaddPage', () => {
  let component: PaymentaddPage;
  let fixture: ComponentFixture<PaymentaddPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(PaymentaddPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

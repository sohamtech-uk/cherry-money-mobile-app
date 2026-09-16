import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TaxPage } from './tax.page';

describe('TaxPage', () => {
  let component: TaxPage;
  let fixture: ComponentFixture<TaxPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(TaxPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

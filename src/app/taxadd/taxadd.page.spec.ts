import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TaxaddPage } from './taxadd.page';

describe('TaxaddPage', () => {
  let component: TaxaddPage;
  let fixture: ComponentFixture<TaxaddPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(TaxaddPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

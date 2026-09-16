import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ProductaddPage } from './productadd.page';

describe('ProductaddPage', () => {
  let component: ProductaddPage;
  let fixture: ComponentFixture<ProductaddPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(ProductaddPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

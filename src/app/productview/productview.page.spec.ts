import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ProductviewPage } from './productview.page';

describe('ProductviewPage', () => {
  let component: ProductviewPage;
  let fixture: ComponentFixture<ProductviewPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(ProductviewPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

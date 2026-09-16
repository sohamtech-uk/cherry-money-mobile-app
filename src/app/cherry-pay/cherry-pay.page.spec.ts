import { ComponentFixture, TestBed } from '@angular/core/testing';
import { CherryPayPage } from './cherry-pay.page';

describe('CherryPayPage', () => {
  let component: CherryPayPage;
  let fixture: ComponentFixture<CherryPayPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(CherryPayPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

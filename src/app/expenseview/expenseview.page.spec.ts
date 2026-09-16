import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ExpenseviewPage } from './expenseview.page';

describe('ExpenseviewPage', () => {
  let component: ExpenseviewPage;
  let fixture: ComponentFixture<ExpenseviewPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(ExpenseviewPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

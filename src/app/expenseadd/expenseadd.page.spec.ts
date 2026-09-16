import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ExpenseaddPage } from './expenseadd.page';

describe('ExpenseaddPage', () => {
  let component: ExpenseaddPage;
  let fixture: ComponentFixture<ExpenseaddPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(ExpenseaddPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

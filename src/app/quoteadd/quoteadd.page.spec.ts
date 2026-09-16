import { ComponentFixture, TestBed } from '@angular/core/testing';
import { QuoteaddPage } from './quoteadd.page';

describe('QuoteaddPage', () => {
  let component: QuoteaddPage;
  let fixture: ComponentFixture<QuoteaddPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(QuoteaddPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

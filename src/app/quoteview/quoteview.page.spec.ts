import { ComponentFixture, TestBed } from '@angular/core/testing';
import { QuoteviewPage } from './quoteview.page';

describe('QuoteviewPage', () => {
  let component: QuoteviewPage;
  let fixture: ComponentFixture<QuoteviewPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(QuoteviewPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

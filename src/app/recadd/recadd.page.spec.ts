import { ComponentFixture, TestBed } from '@angular/core/testing';
import { RecaddPage } from './recadd.page';

describe('RecaddPage', () => {
  let component: RecaddPage;
  let fixture: ComponentFixture<RecaddPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(RecaddPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

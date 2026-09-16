import { ComponentFixture, TestBed } from '@angular/core/testing';
import { RecPage } from './rec.page';

describe('RecPage', () => {
  let component: RecPage;
  let fixture: ComponentFixture<RecPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(RecPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

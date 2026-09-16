import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PermPage } from './perm.page';

describe('PermPage', () => {
  let component: PermPage;
  let fixture: ComponentFixture<PermPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(PermPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

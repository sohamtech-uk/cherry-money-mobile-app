import { ComponentFixture, TestBed } from '@angular/core/testing';
import { UseraddPage } from './useradd.page';

describe('UseraddPage', () => {
  let component: UseraddPage;
  let fixture: ComponentFixture<UseraddPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(UseraddPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

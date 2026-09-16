import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ClientaddPage } from './clientadd.page';

describe('ClientaddPage', () => {
  let component: ClientaddPage;
  let fixture: ComponentFixture<ClientaddPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(ClientaddPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

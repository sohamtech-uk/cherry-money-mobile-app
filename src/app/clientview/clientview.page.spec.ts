import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ClientviewPage } from './clientview.page';

describe('ClientviewPage', () => {
  let component: ClientviewPage;
  let fixture: ComponentFixture<ClientviewPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(ClientviewPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

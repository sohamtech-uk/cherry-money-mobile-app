import { Component, OnInit } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-language',
  templateUrl: './language.page.html',
  styleUrls: ['./language.page.scss'],
})
export class LanguagePage implements OnInit {

lang:any;

  constructor(private translate: TranslateService) {

  if(localStorage.getItem('app_lang') && localStorage.getItem('app_lang') != undefined)
  {
      this.lang = localStorage.getItem('app_lang');
  }
  else
  {
    this.lang = 'en';
  }

   }

  ngOnInit() {
  }

  setLang(val:any)
  {
    this.lang = val;
  }

  switchLanguage(language: string) 
  {
    this.translate.use(language);

    localStorage.setItem('app_lang',language);

    window.location.href = "/home";
  }
}

import { Component, OnInit,ViewChild,ElementRef,NgZone } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule,Platform,NavParams } from '@ionic/angular';
import { OtherService } from '../service/other.service';
import { ServerService } from '../service/server.service';
import { TranslateService } from '@ngx-translate/core';
import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';


@Component({
  selector: 'app-expenseadd',
  templateUrl: './expenseadd.page.html',
  styleUrls: ['./expenseadd.page.scss'],
})
export class ExpenseaddPage implements OnInit {

  data:any;
  hasClick = false;
  text:any;
  date_added:any = new Date();
  hasImg:any;
  imagePreview: string = '';


  constructor(private translate: TranslateService,public navParams: NavParams,public otherService : OtherService,public server : ServerService) { 
  
    this.data       = navParams.get('data');

    if(this.data.date_added)
    {
      this.date_added = this.data.date_added;
    }
  }

  ngOnInit() {
  } 


  async close(data:any = [])
  {
    this.otherService.closeModel(data);
  }

  async addNew(data:any,id = 0)
  {
    data.date_added = this.date_added;

    this.hasClick = true;
    
    const formData = new FormData();

    if(this.hasImg)
    {
      formData.append('file', this.hasImg, this.hasImg.name);
      formData.append('data', JSON.stringify(data));
    }
    else
    {
      formData.append('data', JSON.stringify(data));
    }

    this.server.expenseAdd(formData,this.data.id ? this.data.id : id).subscribe((response:any) => {

      this.hasClick = false;

      this.close(response);

      this.otherService.toast(this.translate.instant("New Expense Added Successfully."));

    });

    return;
  }

  onFileSelected(event:any) 
  {
    this.hasImg = event.target.files[0];
  }

  removeImg()
  {
    this.hasImg = null;

    const fileInput = document.getElementById('fileInput') as HTMLInputElement;

    fileInput.value = '';
  }

  async captureReceipt() {
    

    try {
      const image = await Camera.getPhoto({
        quality: 80,
        allowEditing: false,
        resultType: CameraResultType.Base64,
        source: CameraSource.Prompt
      });

      const base64Image:any = image.base64String;
      this.imagePreview = `data:image/jpeg;base64,${base64Image}`;

      // Convert base64 to Blob
      const blob = this.base64ToBlob(base64Image, `image/${image.format}`);
      this.hasImg = new File([blob], `receipt.${image.format}`, { type: `image/${image.format}` });

      // Call your backend to analyze image and get title and amount
      this.hasClick = true;
      this.server.scanReceipt({ image: base64Image }).subscribe((res: any) => {
        if (res.title) this.data.title = res.title;
        if (res.total_amount) this.data.amount = res.total_amount;

        this.hasClick = false;
      });

    } catch (error) {
      console.error('Camera error:', error);
    }
  }

  base64ToBlob(base64: string, mime: string): Blob {
    const byteCharacters = atob(base64);
    const byteArrays = [];

    for (let offset = 0; offset < byteCharacters.length; offset += 512) {
      const slice = byteCharacters.slice(offset, offset + 512);
      const byteNumbers = new Array(slice.length);

      for (let i = 0; i < slice.length; i++) {
        byteNumbers[i] = slice.charCodeAt(i);
      }

      byteArrays.push(new Uint8Array(byteNumbers));
    }

    return new Blob(byteArrays, { type: mime });
  }
}

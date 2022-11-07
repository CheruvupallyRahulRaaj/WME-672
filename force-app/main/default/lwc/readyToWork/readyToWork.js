import { LightningElement, api } from 'lwc';
import Id from '@salesforce/schema/FulfillmentOrder.Id';
import FOPickerId from '@salesforce/schema/FulfillmentOrder.associateID__c';
import FOStatus from '@salesforce/schema/FulfillmentOrder.Status';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReadyToWork extends LightningElement {
    showPickerId = false;
    pickerId = '';
    @api
    recordId;
    showPicker(event){
        this.showPickerId = true;
    }
    updatePickerIdToDB(event){
        const fields = {};
        fields[Id.fieldApiName] = this.recordId;
        fields[FOPickerId.fieldApiName] = this.pickerId;
        fields[FOStatus.fieldApiName] = 'Ready to Pick';
        console.log(JSON.stringify(fields));
        updateRecord({fields: fields}).then(rec => {
            this.showToast('Succcess!!!','Picker Id is Updated','success');
            this.pickerId = '';
            this.showPickerId = false;
        }).catch(error => {
            console.log('error'+JSON.stringify(error));
            this.showToast('Error!!!','Record is not Successfully Updated','error');
        })
    }
    updatePickerId(event){
        this.pickerId = event.target.value;
    }
    showToast(tit,mes,vari){
        const event = new ShowToastEvent({
            title: tit,
            message:mes,
            variant: vari
        });
        this.dispatchEvent(event);
    }
}
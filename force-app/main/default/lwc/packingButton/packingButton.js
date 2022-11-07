/*
Created By    : Manohar Alla 
User Story    : WME-614
Created Date  : 7th Nov 2022
*/

import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/FulfillmentOrder.Status';
import ID_FIELD from '@salesforce/schema/FulfillmentOrder.Id';
export default class PackingButton extends LightningElement {
    @track error;
   @api recordId;

   handleChange() {
          // Create the recordInput object
       const fields = {};
       fields[ID_FIELD.fieldApiName] = this.recordId;
       fields[STATUS_FIELD.fieldApiName] = 'Packing';
   

       const recordInput = { fields };

       updateRecord(recordInput)
           .then(() => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: 'Success',
                       message: 'FO Status updated to Packing',
                       variant: 'success'
                   })
               );
             
              
           })
           .catch(error => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: 'Error Updating record',
                       message: error.body.message,
                       variant: 'error'
                   })
               );
           });
       }

}
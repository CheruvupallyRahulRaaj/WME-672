import { LightningElement,wire, api} from 'lwc';
import { getRelatedListRecords ,getRelatedListCount } from 'lightning/uiRelatedListApi';	
import baseurl from '@salesforce/label/c.BaseURL';
import { NavigationMixin } from 'lightning/navigation';
const COLS = [
    {
        label: 'Shipment Number',  fieldName:'recurl' , type:'url',
        typeAttributes: {
            label: { 
                fieldName: 'shipName' 
            }
         
        }
       
    }]
export default class ShipmentRelatedListRecords extends NavigationMixin(LightningElement) {
    error;
    recordsModified;
@api recordId;
columns=COLS;
responseData;
errorCount;
label={baseurl};
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Shipments__r',
        fields: ['zkmulti__MCShipment__c.Id','zkmulti__MCShipment__c.Name']
      
    })listInfo({ error, data }) {
        if (data) {
console.log('data'+JSON.stringify(data));
      this.recordsModified=data.records.map((rec)=>{
        let recurl=this.label.baseurl+rec.fields.Id.value;
        let shipName=rec.fields.Name.value;
              return{...rec,recurl,shipName}
            })
          console.log(JSON.stringify( this.recordsModified));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }


    @wire(getRelatedListCount, {
        parentRecordId: '$recordId',
        relatedListId: 'Shipments__r'
    })countInfo({ error, data }) {
        if (data) {
            this.responseData = data.count;
            this.errorCount = undefined;
        } else if (error) {
            this.errorCount = error;
            this.responseData = undefined;
        }
    }

get title(){
     return `Pick and Pack (${this.responseData})`
}
 
}
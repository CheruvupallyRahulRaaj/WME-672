import { LightningElement, api, track } from 'lwc';

export default class CreateOrderScreen extends LightningElement {

    account = {};
    transactiontype = 'Auth';
    taxlocaletype = 'Net';
    products = [];
    activeSections = ['accountSection','productSection'];

    @track adjustment = 0.0;
    @track deliverymethod = 'USPS';
    @track saleschannel = 'Webstore';

    @api accountId;
    
    get transactionTypeOptions() {
        return [
            { label: 'Auth', value: 'Auth' },
            { label: 'Capture', value: 'Capture' }
        ];
    }
    
    get taxLocaleTypeOptions() {
        return [
            { label: 'Gross', value: 'Gross' },
            { label: 'Net', value: 'Net' }
        ]
    }

    getJsonPayload = () => {
        const req = { SOMOrderRequest :{
            name: this.account.name,
            email: this.account.email,
            account: 'Person',
            saleschannel: this.saleschannel,
            ProductRequests: this.products,
            adjustment: new Number(this.adjustment).valueOf(),
            deliverymethod: this.deliverymethod,
            taxlocaletype: this.taxlocaletype,
            transactiontype: this.transactiontype
        }};
        return req;
    }

    @api
    resetValues() {
        this.taxlocaletype = 'Net';
        this.transactiontype = 'Auth';
        this.saleschannel = 'Webstore';
        this.deliverymethod = 'USPS';
        this.adjustment = 0.0;
        this.products = [];
        this.account = {};

        this.template.querySelector('c-person-account').reset();
        this.template.querySelector('c-product').reset();
    }

    handleChangeValue(evt) {
        evt.stopPropagation();
        evt.preventDefault();

        switch(evt.target.name) {
            case 'taxLocaleType':
                this.taxlocaletype = evt.detail.value;
                break;
            case 'paymentTransaction':
                this.transactiontype = evt.detail.value;
                break;
            case 'saleschannel':
                this.saleschannel = evt.detail.value;
                break;
            case 'deliverymethod':
                this.deliverymethod = evt.detail.value;
                break;
            case 'adjustment':
                this.adjustment = evt.detail.value;
                break;
        }
        this.fireChangeEvent();
    }

    handleTaxChange(evt) {
        this.taxlocaletype = evt.detail.value;
        this.fireChangeEvent();
    }

    handleTransactionChange(evt) {
        this.transactiontype = evt.detail.value;
        this.fireChangeEvent();
    }

    handleAccountChange(evt) {
        this.account = evt.detail.value;
        this.fireChangeEvent();
    }

    handleProductChange = (evt) => {
        if (evt.detail.type === 'product') {
            this.products = evt.detail.value;
        }
        this.fireChangeEvent();
    }

    fireChangeEvent = () => {
        const event = new CustomEvent("change", {
            composed: true,
            bubbles: true,
            detail: {
                type: 'createorder',
                value: this.getJsonPayload()
            },
        });
        this.dispatchEvent(event);
    }
}
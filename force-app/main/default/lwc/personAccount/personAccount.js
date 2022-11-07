import { LightningElement, wire, api, track } from 'lwc';
import getAccountList from '@salesforce/apex/AccountController.getAccountList';

export default class PersonAccount extends LightningElement {

    account = { id: '' };
    showNewAccountFields = false;
    accountFieldList = ['firstName', 'lastName'];
    @track accountOptions = [{label: 'NEW ACCOUNT', value:'new'}];
    @track showAccountComboBox = false;

    @api 
    selectedId = '';

    @api
    reset = () => {
        this.account = { id: '' };
        this.selectedId = '';
        this.showNewAccountFields = false;
    }

    @wire(getAccountList)
    onGetAccountList({error, data}) {
        if (data) {
            const list = [{label: 'NEW ACCOUNT', value:'new'}];
            data.forEach(d => {
                let acct = {
                    name: d.Name,
                    label: d.Name + ' (' + d.PersonEmail + ')',
                    value: d.Id,
                    id: d.Id,
                    email: d.PersonEmail
                };
                list.push(acct);
                if (acct.id === this.selectedId) {
                    this.account = acct;
                    this.fireChangeEvent();
                }
            });
            this.accountOptions = list;
            this.showNewAccountFields = list.length === 1;
            this.showAccountComboBox = list.length > 1;
        } else if (error) {
            console.log(error);
        }
    }
    
    handleOptionChange(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        this.showNewAccountFields = evt.detail.value === 'new';
        if (this.showNewAccountFields) {
            this.account = { id: evt.detail.value };
        } else {
            this.account = this.accountOptions.find(f => { return f.value === evt.detail.value });
        }
        this.fireChangeEvent();
    }

    handleAccountNameChange(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        this.account.name = evt.detail.firstName + ' ' + evt.detail.lastName;
        this.fireChangeEvent();
    }

    handleEmailFieldChange(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        this.account.email = evt.detail.value;
        this.fireChangeEvent();
    }

    fireChangeEvent = () => {
        const event = new CustomEvent("change", {
            composed: true,
            bubbles: true,
            detail: {
                value: this.account
            },
        });
        this.dispatchEvent(event);
    }

    @api
    getAccount() {
        return this.account;
    }

    renderedCallback() {
        if (this.selectedId) {
            const acct = this.accountOptions.find(f => { return f.value === this.selectedId });
            if (acct) {
                this.account = acct;
                this.fireChangeEvent();
            }
        }
    }
    
}
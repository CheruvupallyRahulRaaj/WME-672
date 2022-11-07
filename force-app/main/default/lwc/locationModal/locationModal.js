import { LightningElement, api, track } from 'lwc';

export default class LocationModal extends LightningElement {
    @track location;
    @track locationType;
    @track locationGroup;
    @track isEnabled = true;
    @track externalReference;

    @api groupId;
    @api isModalOpen = false;
    @api isLocationGroup = false;

    locationTypes = [
        {label: 'Fulfillment Center', value: 'Fulfillment Center'},
        {label: 'Warehouse', value:'Warehouse'},
        {label: 'Store', value: 'Store'},
        {label: 'Dropship', value: 'Dropship'},
        {label: 'Partner', value: 'Partner'},
        {label: 'Vendor', value: 'Vendor'}];
    title;

    connectedCallback() {
        this.title = this.isLocationGroup ? 'New Group Location' : 'New Location';
    }
    renderedCallback() {
        this.title = this.isLocationGroup ? 'New Group Location' : 'New Location';
    }

    handleChange = (evt) => {
        switch(evt.target.name) {
            case 'location':
                this.location = evt.detail.value;
                break;
            case 'locationGroup':
                this.locationGroup = evt.detail.value;
                break;
            case 'locationType':
                this.locationType = evt.detail.value;
                break;
            case 'externalReference':
                this.externalReference = evt.detail.value;
            case 'isenabled':
                this.isEnabled = evt.returnValue;
                break;
        }
    }

    @api
    openModal = () => {
        this.isModalOpen = true;
    }
    @api
    closeModal = () => {
        this.isModalOpen = false;
    }
    handleSave = () => {
        this.fireSaveEvent();
    }
    fireSaveEvent = () => {
        const obj = this.getValue();
        const event = new CustomEvent("save", {
            composed: true,
            bubbles: true,
            detail: {
                type: obj.type,
                value: obj
            },
        });
        this.dispatchEvent(event);
        this.clearFields();
    }
    getValue = () => {
        if (this.isLocationGroup) {
            const groupId = 'new_grp_'+Date.now();
            return { 
                type: 'LocationGroup',
                name: this.locationGroup,
                id: groupId,
                cssClass: groupId,
                isEnabled: this.isEnabled,
                externalReference: this.externalReference
            };
        }
        return {
            name: this.location,
            type: this.locationType,
            id: 'new_loc_'+Date.now(),
            groupId: this.groupId,
            externalReference: this.externalReference
        }
    }
    clearFields = () => {
        this.location = '';
        this.locationType = '';
        this.locationGroup = '';
        this.isEnabled = true;
        this.externalReference = '';
    }
}
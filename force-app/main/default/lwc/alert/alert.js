import { LightningElement, api, track } from 'lwc';

export default class Alert extends LightningElement {
    @api value;
    @api theme;

    @track isWarning;

    handleClose = () => {
        const event = new CustomEvent("closealert", {
            composed: true,
            bubbles: true,
            detail: {
                value: true
            },
        });
        this.dispatchEvent(event);
    }

    renderedCallback() {
        this.isWarning = this.theme === 'warning';
    }
}
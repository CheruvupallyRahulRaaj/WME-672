import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getEnabled from '@salesforce/apex/WM_Fullstory.getEnabled';
import getSessions from '@salesforce/apex/WM_Fullstory.getSessions';
import getChannelName from '@salesforce/apex/WM_Fullstory.getChannelName';
import EMAIL_FIELD from '@salesforce/schema/OrderSummary.BillingEmailAddress';
import EMAIL_FIELD_ACCOUNT from '@salesforce/schema/Account.PersonEmail';
import EMAIL_FIELD_ACCOUNT_PRO from '@salesforce/schema/Account.Email__c';
import EMAIL_FIELD_CONTACT from '@salesforce/schema/Contact.Email';
import CHANNEL_FIELD from '@salesforce/schema/OrderSummary.SalesChannelId';

const FIELDS = [
    EMAIL_FIELD,
    EMAIL_FIELD_ACCOUNT,
    EMAIL_FIELD_ACCOUNT_PRO,
    EMAIL_FIELD_CONTACT,
    CHANNEL_FIELD
];

export default class WM_Fullstory_Sessions extends LightningElement {
    @api recordId;
    @wire(getRecord, {recordId: '$recordId', optionalFields: FIELDS})
    wiredEmail({error, data}) {
        if (error) {
            console.log('error', JSON.parse(JSON.stringify(error)));
            this.error = 'Unable to retrieve email';
            this.fsDown = true;
        } else if (data) {
            if (data.apiName == 'OrderSummary') {
                getChannelName({
                    recordId: getFieldValue(data, CHANNEL_FIELD)
                })
                .then(response => {
                    this.channel = response;
                });
                this.email = getFieldValue(data, EMAIL_FIELD);
            }
            if (data.apiName == 'Account') {
                this.channel = 'WestMarine';
                this.email = getFieldValue(data, EMAIL_FIELD_ACCOUNT);
            }
            if (data.apiName == 'Account' && !this.email) {
                this.channel = 'WestMarinePro';
                this.email = getFieldValue(data, EMAIL_FIELD_ACCOUNT_PRO);
            }
            if (data.apiName == 'Contact') {
                this.channel = 'WestMarinePro';
                this.email = getFieldValue(data, EMAIL_FIELD_CONTACT);
            }
        }
    };

    initialLoad;
    fetched;
    fsEnabled;
    fsDown;
    channel;
    email;
    data;
    message;
    columns = [
        { label: 'Session Date', fieldName: 'createdTime', type: 'date', typeAttributes: {
            weekday: "long",
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }},
        { label: 'Session Url', fieldName: 'fsUrl', type: 'url'}
    ];

    handleClickGetSessions() {
        if (this.channel && this.email) {
            getSessions({
                channel: this.channel,
                email: this.email
            })
            .then(response => {
                try {
                    var body = JSON.parse(response);
                    if (body.sessions) {
                        this.data = body.sessions.map(session => {
                            session.createdTime = session.createdTime * 1000;
                            return session
                        });
                    }
                    this.fetched = true;
                } catch (error) {
                    this.fsDown = true;
                    console.error(error);
                }
            });
        } else {
            console.log('fullstory session not available for this record');
        }
    }

    connectedCallback() {
        if (!this.initialLoad) {
            this.initialLoad = true;
            getEnabled()
            .then(response => {
                this.fsEnabled = response;
            });
        }
    }
}
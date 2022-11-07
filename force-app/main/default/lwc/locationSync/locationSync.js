import { LightningElement, api, track, wire } from 'lwc';
import getData from '@salesforce/apex/LocationSyncController.getData';

export default class LocationSync extends LightningElement {

    @api allLocations = [];
    @api allGroups = [];
    modal;
    selectedItems = [];
    newObject;

    @track hasData; // determines if the wire adaptor is finished retrieving data
    @track processing; // set when the handleSync event is triggered
    @track uploadId;
    @track syncStatusDisabled;
    @track syncLocationsDisabled;
    @track displayInfoMessage = true;
    @track displayWarningMessage;
    
    @wire(getData)
    onGetData({error, data}) {
        if(data) {
            const obj = JSON.parse(data);
            this.syncData(obj);
        }
    }

    @api
    setProcessing(val) {
        this.processing = val;
    }

    @api
    getPayload = () => {
        const req = {
            SOMLocationRequest : {
                locationGroups: this.allGroups
            }
        };
        return req;
    }

    @api syncData(obj) {
        this.hasData = false;
        this.processing = false;
        this.allGroups = [];
        this.allLocations = [];

        obj.groups.forEach(g => {
            this.allGroups.push({
                name: g.LocationGroupName,
                id: g.Id,
                isEnabled: g.IsEnabled,
                externalReference: g.ExternalReference,
                cssClass: 'grp_' + g.Id,
                locations: []
            })
        });

        obj.locations.forEach(l => {
            this.allLocations.push({
                name: l.Name,
                id: l.Id,
                type: l.LocationType,
                externalReference: l.ExternalReference,
            })
        });

        obj.assignments.forEach(a => {
            const group = this.allGroups.find(g => { return g.id === a.LocationGroup.Id; });
            const location = this.allLocations.find(l => { return l.id === a.Location.Id; });
            group.locations.push(location);
            group.hasLocations = true;
        });
        this.hasData = true;
        this.uploadId = obj.uploadId;
        this.syncStatusDisabled = (this.isEmpty(this.uploadId) || this.uploadId === 'NOT_APPLICABLE');
        this.syncLocationsDisabled = this.allGroups.length === 0;
    }

    @api closeModal(id) {
        this.setNewObject(id);
        this.modal.isModalOpen = false;
    }
    
    // get location data:
    connectedCallback() {
        this.prepareData();
    }

    renderedCallback() {
        this.modal = this.template.querySelector('c-location-modal');
    }

    clearSelection() {
        const items = this.template.querySelectorAll('.selected-item');
        items.forEach(ele => {
            ele.classList.remove('selected-item');
            ele.style.opacity = '1.0';
        });
        this.selectedItems = [];
    }

    setNewObject(id) {
        const val = this.newObject;
        val.id = id;
        if (val.type === 'LocationGroup') {
            this.allGroups.push({
                name: val.name, 
                id: val.id, 
                isEnabled: val.isEnabled, 
                externalReference: val.externalReference,
                cssClass: val.cssClass,
                locations: []});
        } else {
            const loc = {
                name: val.name, 
                id: val.id,
                type: val.type,
                externalReference: val.externalReference,
            };
            this.allLocations.push(loc);
            if (val.groupId) {
                const group = this.allGroups.find(g => { return g.id === val.groupId });
                group.locations.push(loc);
            }
        }
        this.prepareData(true, true);
    }

    addToSelection(evt, ondrag) {
        const id = evt.target.dataset.id;

        const item = this.allLocations.find(l => { return l.id.toString() === id });
        if (item) {
            if (!this.selectedItems.find(i => { return i.id.toString() === id })) {
                this.selectedItems.push(item);
                evt.target.classList.add('selected-item');
            } else if (!ondrag) {
                this.selectedItems = this.selectedItems.filter(i => { return i.id.toString() !== id });
                evt.target.classList.remove('selected-item');
            }
        }
    }

    hasModifier(e) {
        return (e.ctrlKey || e.metaKey || e.shiftKey);
    }

    handleItemSelection(evt) {
        console.log("handleItemSelection");
        if (!this.hasModifier(evt)) {
            this.clearSelection();
        }
        this.addToSelection(evt);
    }

    dragover(evt) {
        evt.preventDefault();
        evt.dataTransfer.dropEffect = 'move';
        this.setOverEffect(evt, false);
    }

    drop(evt) {
        evt.preventDefault();
        const groupId = evt.target.dataset.id;
        const group = this.allGroups.find(g => { return g.id.toString() === groupId });

        if (group) {

            this.selectedItems.forEach(location => {
                const matchedLocation = group.locations.find(l => { return l.id === location.id });
                if (!matchedLocation) {
                    group.locations.push(location);
                }
            });
            this.prepareData(true);
            this.setOverEffect(evt, true);
            this.clearSelection();

            if (typeof this.displayWarningMessage === 'undefined') {
                this.displayWarningMessage = true;
            }
        }
    }

    dragstart(evt) {
        console.log("dragstart");
        evt.dataTransfer.setData("text", evt.target.dataset.id);
        this.addToSelection(evt, true);

        const items = this.template.querySelectorAll('.selected-item');
        items.forEach(ele => {
            ele.style.opacity = '0.4';
        });
    }

    dragenter(evt) {
        this.setOverEffect(evt, false);
    }

    dragleave(evt) {
        this.setOverEffect(evt, true);
    }

    dragend(evt) {
        evt.target.style.opacity = '1.0';
    }

    setOverEffect(evt, remove) {
        const groupId = evt.target.dataset.group || evt.target.dataset.id;
        if (groupId) {
            const cssClass = groupId.indexOf('new_grp_') > -1 ? '.' + groupId : '.grp_' + groupId;

            const div = this.template.querySelector(cssClass);
            if (div) {
                if (remove) {
                    div.classList.remove('dnd-over');
                } else {
                    div.classList.add('dnd-over');
                }
            }
        }
    }

    removeLocation(evt) {
        const groupId = evt.target.dataset.group;
        const locationId = evt.target.dataset.id;
        const group = this.allGroups.find(g => { return g.id === groupId });
        const locs = [];
        if (group) {
            group.locations.forEach(l => {
                if (l.id.toString() !== locationId) {
                    locs.push(l);
                }
            });
            group.locations = locs;
        }
        this.prepareData(true);
    }

    prepareData(refresh, includeAllLocations) {
        this.allGroups.forEach(g => {
            g.hasLocations = (g.locations.length > 0);
        });
        if (refresh) {
            this.allGroups = [].concat(this.allGroups);
        }
        if (includeAllLocations) {
            this.allLocations = [].concat(this.allLocations);
        }
        this.syncLocationsDisabled = this.allGroups.length === 0;
    }

    handleNewLocation(evt) {
        if (!this.modal) {
            this.modal = this.template.querySelector('c-location-modal');
        }
        this.modal.groupId = evt.target.dataset.id;
        this.modal.isLocationGroup = false;
        this.modal.isModalOpen = true;
    }

    handleNewGroup() {
        if (!this.modal) {
            this.modal = this.template.querySelector('c-location-modal');
        }
        this.modal.isLocationGroup = true;
        this.modal.isModalOpen = true;
    }

    handleSave(evt) {
        this.newObject = evt.detail.value;
    }

    handleAssignments() {
        this.processing = true;

        const event = new CustomEvent("sync", {
            composed: true,
            bubbles: true,
            detail: {
                type: 'assignment',
                value: this.getPayload()
            },
        });
        this.dispatchEvent(event);
    }

    handleSync() {
        this.processing = true;

        const event = new CustomEvent("sync", {
            composed: true,
            bubbles: true,
            detail: {
                type: 'sync',
                value: this.getPayload()
            },
        });
        this.dispatchEvent(event);
    }

    handleSyncStatus() {
        this.processing = true;

        const event = new CustomEvent("checkstatus", {
            composed: true,
            bubbles: true,
            detail: {
                type: 'status',
                value: this.uploadId
            },
        });
        this.dispatchEvent(event);
    }

    handleInfoAlertClose() {
        this.displayInfoMessage = false;
    }

    handleWarningAlertClose() {
        this.displayWarningMessage = false;
    }

    isEmpty = (obj) => {
        return obj === undefined || obj === null || (typeof obj === 'string' && obj.trim() === '');
    }
}
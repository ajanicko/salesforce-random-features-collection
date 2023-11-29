import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class DragAndDropCard extends NavigationMixin(LightningElement) {
    @api status;
    @api objectapiname;
    @track itemStyle = 'slds-item slds-var-m-around_small';
    @track clonedRecord;
    @api set record(value) {
        this.clonedRecord = JSON.parse(JSON.stringify(value));
        this.clonedRecord.EpicName = this.clonedRecord.Epic__r?.Name.substring(0, 35);
        if (this.clonedRecord.Priority__c === 'High') {
            this.itemStyle = 'slds-item slds-var-m-around_small red-border';
        } else if (this.clonedRecord.Priority__c === 'Medium') {
            this.itemStyle = 'slds-item slds-var-m-around_small yellow-border';
        } else if (this.clonedRecord.Priority__c === 'Low') {
            this.itemStyle = 'slds-item slds-var-m-around_small white-border';
        }
    }
    get record() {
        return this.clonedRecord;
    }

    get isSameStatus() {
        return this.status === this.record.Status__c;
    }

    navigateHandler(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: event.target.dataset.object,
                actionName: event.target.dataset.mode
            }
        });
    }

    itemDragStart() {
        const event = new CustomEvent('itemdrag', {
            detail: this.record.Id
        });
        this.dispatchEvent(event);
    }

    sendWorklogEvent() {
        const event = new CustomEvent('worklogopen', {
            detail: this.record.Id
        });
        this.dispatchEvent(event);
    }

    get assigneeName() {
        return this.clonedRecord?.Assignee__r?.Name || '';
    }
}

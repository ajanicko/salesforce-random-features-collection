import { LightningElement, api, track } from 'lwc';

export default class DragAndDropList extends LightningElement {
    @api records;
    @api status;
    @api columnhighlightlimit;
    @api objectapiname;
    @track headingStyle = 'column-heading blue-background';

    renderedCallback() {
        let itemCount = 0;
        for (const record of this.records) {
            if (record.Status__c === this.status) {
                itemCount++;
            }
        }

        if (this.status === 'In Progress' && itemCount >= this.columnhighlightlimit) {
            this.headingStyle = 'column-heading red-background';
        } else {
            this.headingStyle = 'column-heading blue-background';
        }
    }

    handleItemDrag(evt) {
        const event = new CustomEvent('listitemdrag', {
            detail: evt.detail
        });
        this.dispatchEvent(event);
    }

    handleWorklogOpen(evt) {
        const event = new CustomEvent('listworklogopen', {
            detail: evt.detail
        });
        this.dispatchEvent(event);
    }

    handleDragOver(evt) {
        evt.preventDefault();
    }

    handleDrop() {
        const event = new CustomEvent('itemdrop', {
            detail: this.status
        });
        this.dispatchEvent(event);
    }
}

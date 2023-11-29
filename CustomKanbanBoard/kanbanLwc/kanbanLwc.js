import { LightningElement, wire, track, api } from 'lwc';
import getAllRecords from '@salesforce/apex/KanbanLwcController.getAllRecords';
import getCurrentUserName from '@salesforce/apex/KanbanLwcController.getCurrentUserName';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import WORKLOG_OBJECT from '@salesforce/schema/WorklogItem__c';
import EPIC_FIELD from '@salesforce/schema/WorklogItem__c.Epic__c';
import TASK_FIELD from '@salesforce/schema/WorklogItem__c.Task__c';
import TEAMROLE_FIELD from '@salesforce/schema/WorklogItem__c.TeamRole__c';
import CASE_FIELD from '@salesforce/schema/WorklogItem__c.Case2__c';
import WORKER_FIELD from '@salesforce/schema/WorklogItem__c.Worker__c';
import ISBILLABLE_FIELD from '@salesforce/schema/WorklogItem__c.IsBillable__c';
import WORKDATE_FIELD from '@salesforce/schema/WorklogItem__c.WorkDate__c';
import DURATION_FIELD from '@salesforce/schema/WorklogItem__c.DurationInMinutes__c';
import DESCRIPTION_FIELD from '@salesforce/schema/WorklogItem__c.Description__c';
export default class KanbanLwc extends LightningElement {
    @api columnHighlightLimit = 5;
    @api hideBacklog = false;
    //if component is placed on Epic record page
    @api recordId = null;
    @api kanbanObjectApiName = 'Task__c';
    @api closedTicketsDayLimit = 7;
    initialized = false;
    firstRecordWire = true;
    dragRecordId;
    chosenRecord;
    statusVals = [];
    priorityVals = [{ label: 'All', value: 'all' }];
    priorityValue = 'all';
    typeVals = [{ label: 'All', value: 'all' }];
    typeValue = 'all';
    assigneeValue = '';
    customerValue = '';
    projectValue = '';
    epicValue = '';
    allRecords = [];
    allRecordsMap = {};
    @track visibleRecords = [];
    wiredRecords;
    assignees = [{ Id: 'dash', Name: '-' }];
    customers = [];
    projects = [];
    epics = [];
    today = new Date().toISOString();
    workLogObject = WORKLOG_OBJECT;
    epicField = EPIC_FIELD;
    taskField = TASK_FIELD;
    teamRoleField = TEAMROLE_FIELD;
    caseField = CASE_FIELD;
    workerField = WORKER_FIELD;
    isBillableField = ISBILLABLE_FIELD;
    workdateField = WORKDATE_FIELD;
    durationField = DURATION_FIELD;
    descriptionField = DESCRIPTION_FIELD;
    @track showModal = false;
    objectInfo;
    fullStatusField;
    fullPriorityField;
    fullTypeField;
    hideTypeFilter = false;

    renderedCallback() {
        //to link input with datalist due to generated ids
        if (!this.initialized) {
            this.initialized = true;
            let assigneeListId = this.template.querySelector('datalist[data-id="assigneeList"]').id;
            this.template.querySelector('input[data-id="assigneeInput"]').setAttribute('list', assigneeListId);

            let customerListId = this.template.querySelector('datalist[data-id="customerList"]').id;
            this.template.querySelector('input[data-id="customerInput"]').setAttribute('list', customerListId);

            let projectListId = this.template.querySelector('datalist[data-id="projectList"]').id;
            this.template.querySelector('input[data-id="projectInput"]').setAttribute('list', projectListId);

            if (!this.recordId) {
                let epicListId = this.template.querySelector('datalist[data-id="epicList"]').id;
                this.template.querySelector('input[data-id="epicInput"]').setAttribute('list', epicListId);
            }
        }
    }

    @wire(getAllRecords, { epicRecordId: '$recordId', objectApiName: '$kanbanObjectApiName', dayLimit: '$closedTicketsDayLimit' })
    wiredControllerRecords(value) {
        //for refresh apex
        this.wiredRecords = value;
        const { data, error } = value;
        if (data) {
            for (const record of data) {
                this.allRecordsMap[record.Id] = record;
            }
            this.allRecords = JSON.parse(JSON.stringify(data));
            //removing duplicates by checking, if record is already in an array
            for (const record of this.allRecords) {
                if (record.Assignee__c != null && !this.assignees.some((e) => e.Name === record.Assignee__r.Name)) {
                    this.assignees.push({
                        Id: record.Assignee__c,
                        Name: record.Assignee__r.Name
                    });
                }
                if (record.Customer__c != null && !this.customers.some((e) => e.Name === record.Customer__c)) {
                    this.customers.push({
                        Id: record.Customer__c,
                        Name: record.Customer__c
                    });
                }
                if (record.Project__c != null && !this.projects.some((e) => e.Name === record.Project__c)) {
                    this.projects.push({
                        Id: record.Project__c,
                        Name: record.Project__c
                    });
                }
                if (record.Epic__c != null && !this.epics.some((e) => e.Name === record.Epic__r.Key__c)) {
                    this.epics.push({
                        Id: record.Epic__c,
                        Name: record.Epic__r.Key__c
                    });
                }
            }
            //needed to call here so that we can filter records for the first time as soon as we have user data
            if (this.firstRecordWire) {
                this.firstRecordWire = false;
                getCurrentUserName()
                    .then((result) => {
                        this.assigneeValue = result;
                        this.filterData();
                    })
                    .catch((err) => {
                        console.log(err);
                    });
            }
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: '$kanbanObjectApiName' })
    getObjectData({ error, data }) {
        if (data) {
            this.objectInfo = data;
            this.fullStatusField = this.kanbanObjectApiName + '.Status__c';
            this.fullPriorityField = this.kanbanObjectApiName + '.Priority__c';
            if (this.kanbanObjectApiName !== 'CaseBBT__c') {
                this.fullTypeField = this.kanbanObjectApiName + '.Type__c';
            } else {
                this.hideTypeFilter = true;
            }
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.defaultRecordTypeId',
        fieldApiName: '$fullStatusField'
    })
    statusPicklistValues({ data, error }) {
        if (data) {
            this.statusVals = data.values.map((item) => item.value);
            if (this.hideBacklog) {
                this.statusVals.splice(this.statusVals.indexOf('Backlog'), 1);
            }
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.defaultRecordTypeId',
        fieldApiName: '$fullPriorityField'
    })
    priorityPicklistValues({ data, error }) {
        if (data) {
            this.priorityVals = this.priorityVals.concat(
                data.values.map((item) => ({
                    label: item.label,
                    value: item.value
                }))
            );
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.defaultRecordTypeId',
        fieldApiName: '$fullTypeField'
    })
    typePicklistValues({ data, error }) {
        if (data) {
            this.typeVals = this.typeVals.concat(
                data.values.map((item) => ({
                    label: item.label,
                    value: item.value
                }))
            );
        } else if (error) {
            console.log(error);
        }
    }

    /****getter to calculate the  width dynamically*/
    get calcWidth() {
        let len = this.statusVals.length + 1;
        return `width: calc(100vw/ ${len})`;
    }

    handleListItemDrag(event) {
        this.dragRecordId = event.detail;
        this.setChosenRecord(this.dragRecordId);
    }

    handleListWorklogOpen(event) {
        this.setChosenRecord(event.detail);
        this.showModal = true;
    }

    setChosenRecord(recordId) {
        this.chosenRecord = JSON.parse(JSON.stringify(this.allRecordsMap[recordId]));
        if (this.kanbanObjectApiName === 'Task__c' && this.chosenRecord) {
            this.chosenRecord.taskId = this.chosenRecord.Id;
        } else if (this.kanbanObjectApiName === 'CaseBBT__c' && this.chosenRecord) {
            this.chosenRecord.caseId = this.chosenRecord.Id;
        }
    }

    handleItemDrop(event) {
        let status = event.detail;
        this.updateHandler(status);
        if (status !== this.chosenRecord.Status__c) {
            this.showModal = true;
        }
    }

    updateHandler(status) {
        const fields = {};
        fields.Id = this.dragRecordId;
        fields.Status__c = status;
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                console.log('Updated Successfully');
                this.showToast();
                refreshApex(this.wiredRecords).then(() => {
                    this.filterData();
                    if (status === 'Done') {
                        this.showModal = true;
                    }
                });
            })
            .catch((error) => {
                console.log(error);
            });
    }

    showToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Status updated Successfully',
                variant: 'success'
            })
        );
    }

    handleAssigneeChange(event) {
        this.assigneeValue = event.target.value.trim();
        this.filterData();
    }

    handleCustomerChange(event) {
        this.customerValue = event.target.value.trim();
        this.filterData();
    }

    handleProjectChange(event) {
        this.projectValue = event.target.value.trim();
        this.filterData();
    }

    handleEpicChange(event) {
        this.epicValue = event.target.value.trim();
        this.filterData();
    }

    handlePriorityChange(event) {
        this.priorityValue = event.detail.value;
        this.filterData();
    }

    handleTypeChange(event) {
        this.typeValue = event.detail.value;
        this.filterData();
    }

    filterData() {
        this.visibleRecords = this.allRecords;
        if (this.assigneeValue.length !== 0) {
            if (this.assigneeValue === '-') {
                this.visibleRecords = this.visibleRecords.filter((record) => record.Assignee__c == null);
            } else {
                this.visibleRecords = this.visibleRecords.filter((record) => record.Assignee__r?.Name === this.assigneeValue);
            }
        }
        if (this.priorityValue !== 'all') {
            this.visibleRecords = this.visibleRecords.filter((record) => record.Priority__c === this.priorityValue);
        }
        if (this.typeValue !== 'all') {
            this.visibleRecords = this.visibleRecords.filter((record) => record.Type__c === this.typeValue);
        }
        if (this.customerValue.length !== 0) {
            this.visibleRecords = this.visibleRecords.filter((record) => record.Customer__c === this.customerValue);
        }
        if (this.projectValue.length !== 0) {
            this.visibleRecords = this.visibleRecords.filter((record) => record.Project__c === this.projectValue);
        }
        if (this.epicValue.length !== 0) {
            this.visibleRecords = this.visibleRecords.filter((record) => record.Epic__r.Key__c === this.epicValue);
        }
        this.sortData();
    }

    sortData() {
        this.visibleRecords.sort((a, b) => {
            let bDate = b.DueDate__c;
            let aDate = a.DueDate__c;
            if (bDate != null && aDate != null) {
                let dateSortValue = new Date(aDate) - new Date(bDate);
                if (dateSortValue === 0) {
                    return this.prioritySort(a, b);
                }
                return dateSortValue;
            } else if (bDate != null) {
                return 1;
            } else if (aDate != null) {
                return -1;
            }
            return this.prioritySort(a, b);
        });
    }

    prioritySort(itemA, itemB) {
        let defaultValue = Infinity;
        let sortObj = { High: 1, Medium: 2, Low: 3 };
        return (sortObj[itemA.Priority__c] || defaultValue) - (sortObj[itemB.Priority__c] || defaultValue);
    }

    closeModal() {
        this.showModal = false;
    }

    handleSubmit(event) {
        event.preventDefault();
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    handleSuccess() {
        this.showModal = false;
    }
}

import { LightningElement, api } from 'lwc';
import ICONS from "@salesforce/resourceUrl/HMIcons";

export default class HmSearchableCombobox extends LightningElement {
    @api disabled = false;
    @api classes;
    @api label;
    @api placeholder;
    @api helptext;
    @api options;
    @api selectedValue = '';

    isOpen = false;
    searchIcon = `${ICONS}/Search.svg`;
    showClearButton = false;
    _handleDocumentClick;

    constructor() {
        super();
        this._handleDocumentClick = this.handleDocumentClick.bind(this);
    }

    connectedCallback() {
        document.addEventListener('click', this._handleDocumentClick);
    }

    disconnectedCallback() {
        document.removeEventListener('click', this._handleDocumentClick);
    }

    //searching in parent allows greater flexibility, like calling an API
    handleSearchKeyChange(event) {
        let value = event.target.value;
        this.showClearButton = !!value?.length;
        const custEvent = new CustomEvent(
            'inputchange', {
            detail: { value }
        });
        this.dispatchEvent(custEvent);
        this.selectedValue = value;
    }

    //selection in parent also allows greater flexibility, like running additional business logic
    handleSelectOption(event) {
        this.stopClickPropagation(event);

        const custEvent = new CustomEvent(
            'selectoption', {
            detail: {
                value: event.currentTarget.dataset.id
            }
        });
        this.dispatchEvent(custEvent);
    }

    stopClickPropagation(event) {
        /* we need to stop the event from propagating to the document click handler
        so that we can use the document click handler to detect outside clicks */
        event.stopImmediatePropagation();
    }

    handleDocumentClick() {
        if (this.isDropdownVisible) {
            this.isOpen = false;
            this.sendClearEvent();
        }
    }

    handleInputCommit(event) {
        //this detects if user clicked the input clear button
        if (!event.target?.value.length) {
            this.sendClearEvent();
        }
    }

    handleFocus() {
        this.isOpen = true;
        this.dispatchEvent(new CustomEvent('inputfocus'));
    }

    handleClear() {
        this.selectedValue = '';
        this.showClearButton = false;
        this.sendClearEvent();

        this.dispatchEvent(new CustomEvent(
            'selectoption', {
            detail: {
                value: this.selectedValue
            }
        }));
    }

    sendClearEvent() {
        this.dispatchEvent(new CustomEvent('clear'));
    }

    get dropdownClasses() {
        let dropdownClasses = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';

        if (this.isDropdownVisible) {
            dropdownClasses += ' slds-is-open';
        }

        return dropdownClasses;
    }

    get isDropdownVisible() {
        return this.isOpen && this.options?.length;
    }

    get inputType() {
        return this.disabled ? 'text' : 'search';
    }

    @api 
    validateCombobox(){
        if(!this.selectedValue){
            return false;
        }
        return true;
    }
}
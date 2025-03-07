import { LightningElement, api } from 'lwc';
import ICONS from "@salesforce/resourceUrl/HMIcons";

export default class HmBaseCombobox extends LightningElement {
    @api disabled = false;
    @api classes;
    @api label;
    @api placeholder;
    @api helptext;
    @api options;

    _selectedValue = '';
    _isOpen = false;
    _chevronIcon = `${ICONS}/ChevronDownGreen.svg`;
    _handleDocumentClick;
    _focusItem = false;

    @api
    get selectedValue() {
        return this._selectedValue;
    }
    set selectedValue(value) {
        if (value !== undefined && value !== this._selectedValue) {
            this._selectedValue = value;
        }
    }

    @api
    validateCombobox() {
        return !!this._selectedValue;
    }

    get displayValue() {
        return this._selectedValue || this.placeholder;
    }

    get comboboxClasses() {
        let comboboxClasses = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click hm-combobox';

        if (this.isDropdownVisible) {
            comboboxClasses += ' slds-is-open';
        }

        return comboboxClasses;
    }

    get isDropdownVisible() {
        return this._isOpen && this.options?.length;
    }

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

    renderedCallback() {
        // ensure the DOM is updated when we try to focus an item
        if (this._focusItem) {
            this.setItemFocus();
            this._focusItem = false;
        }
    }

    handleSelectOption(event) {
        this.stopClickPropagation(event);

        this._selectedValue = event.currentTarget.dataset.text;
        this._isOpen = false;
        this.refs.combobox1.focus();

        const custEvent = new CustomEvent('selectoption', {
            detail: {
                value: event.currentTarget.dataset.value
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
            this._isOpen = false;
        }
    }

    handleInputClick(event) {
        this.stopClickPropagation(event);

        this._isOpen = !this._isOpen;

        if (this._isOpen) {
            this._focusItem = true;
        }
    }

    handleInputKeyDown(event) {
        switch (event.key) {
            case 'ArrowDown':
                event.currentTarget.click();
                break;
            case 'Enter':
                event.currentTarget.click();
                break;
            default:
                break;
        }
    }

    handleListboxKeyDown(event) {
        const items = this.template.querySelectorAll('li');
        let index = Array.prototype.indexOf.call(items, this.template.activeElement);

        switch (event.key) {
            case 'ArrowDown':
                index = (index + 1) % items.length;
                items[index].focus();
                break;
            case 'ArrowUp':
                index = (index - 1 + items.length) % items.length;
                items[index].focus();
                break;
            case 'Enter':
                items[index].click();
                break;
            case 'Escape':
                this._isOpen = false;
                break;
            default:
                break;
        }
    }

    setItemFocus() {
        if (this._selectedValue) {
            const items = this.template.querySelectorAll('li');
            items.forEach(item => {
                if (item.dataset.text === this._selectedValue) {
                    item.focus();
                }
            });
        } else {
            const firstListItem = this.template.querySelector('li');
            if (firstListItem) {
                firstListItem.focus();
            }
        }
    }
}
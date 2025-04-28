import { LightningElement, api } from 'lwc';

export default class ItemDetailsModal extends LightningElement {
    @api isOpen = false;

    @api item;

    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}
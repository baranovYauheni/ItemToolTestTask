import { LightningElement, api } from 'lwc';

export default class ItemList extends LightningElement {
    @api items;

    handleDetails(event) {
        const itemId = event.target.dataset.id;

        this.dispatchEvent(new CustomEvent('showdetails', { detail: { itemId } }));
    }

    handleAdd(event) {
        const itemId = event.target.dataset.id;

        this.dispatchEvent(new CustomEvent('addtocart', { detail: { itemId } }));
    }
}
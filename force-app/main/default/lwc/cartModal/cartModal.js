import { LightningElement, api } from 'lwc';

export default class CartModal extends LightningElement {
    @api isOpen;
    _cartItems = [];

    @api
    set cartItems(value) {
        this._cartItems = value ? JSON.parse(JSON.stringify(value)) : [];
    }

    get cartItems() {
        return this._cartItems;
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    checkoutCart() {
        this.dispatchEvent(new CustomEvent('checkout', { detail: { cartItems: this.cartItems } }));
    }

    renderedCallback() {
    }
}
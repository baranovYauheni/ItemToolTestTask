import { LightningElement, api } from 'lwc';

export default class FlowModal extends LightningElement {
    @api isOpen = false;

    @api flowApiName;

    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleFlowSuccess(event) {
        this.closeModal();
        this.dispatchEvent(new CustomEvent('flowfinished', { detail: event.detail }));
    }

    handleFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED' || event.detail.status === 'FINISHED_SCREEN') {
            console.log('Flow completed. Automatically closing modal.');
            this.closeModal();
            this.dispatchEvent(new CustomEvent('flowfinished', { detail: event.detail }));
        }
    }
}
import { LightningElement, api } from 'lwc';

export default class ItemFilters extends LightningElement {
    @api familyOptions;
    @api typeOptions;
    @api filteredItemCount;

    handleTypeFilter(event) {
        const selectedType = event.target.value;

        this.dispatchEvent(new CustomEvent('filtertypechange', {
            detail: selectedType
        }));
    }

    handleFamilyFilter(event) {
        const selectedFamily = event.target.value;

        this.dispatchEvent(new CustomEvent('filterfamilychange', {
            detail: selectedFamily
        }));
    }
}
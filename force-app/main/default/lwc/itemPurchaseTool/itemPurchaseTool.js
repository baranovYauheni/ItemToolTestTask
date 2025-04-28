import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAccountDetails from '@salesforce/apex/AccountController.getAccountDetails';
import getAllItems from '@salesforce/apex/ItemController.getAllItems';
import createPurchase from '@salesforce/apex/PurchaseController.createPurchase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import isManager from '@salesforce/apex/UserController.isManager';
import updateItemImage from '@salesforce/apex/UnsplashAPI.updateItemImage';

export default class ItemPurchaseTool extends NavigationMixin(LightningElement) {
    recordId;
    accountDetails = { data: null, error: null };
    isManager = false;

    items = [];
    filteredItems = [];
    cartItems = [];

    isFlowModalOpen = false;

    isCartModalOpen = false;

    isDetailsModalOpen = false;
    selectedItem = null;

    searchQuery = '';
    familyOptions = [];
    typeOptions = [];
    familyFilter = null;
    typeFilter = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference?.state?.c__recordId) {
            this.recordId = currentPageReference.state.c__recordId;
            this.loadAccountDetails();
            this.loadItems();
            this.checkManagerStatus();
        }
    }

    loadAccountDetails() {
        getAccountDetails({ accountId: this.recordId })
            .then(result => {
                this.accountDetails = { data: result, error: null };
            })
            .catch(error => {
                this.accountDetails = { data: null, error };
            });
    }

    checkManagerStatus() {
            isManager()
                .then(result => {
                    this.isManager = result;
                })
                .catch(error => {
                    this.isManager = false;
                });
        }

    loadItems() {
        getAllItems()
            .then(result => {
                console.log('Loaded Items:', result);
                this.items = result;
                this.filteredItems = result;
                this.updateFilters(result);
            })
            .catch(error => {
                console.error('Error loading items:', error);
            });
    }

    updateFilters(items) {
        this.familyOptions = [...new Set(items.map(item => item.Family__c))].filter(Boolean).map(family => ({ label: family, value: family }));
        this.typeOptions = [...new Set(items.map(item => item.Type__c))].filter(Boolean).map(type => ({ label: type, value: type }));
    }

    openFlowModal() {
        this.isFlowModalOpen = true;
    }

    closeFlowModal() {
        this.isFlowModalOpen = false;
    }

    handleFlowFinished(event) {
            const outputVariables = event?.detail?.outputVariables;

            if (!outputVariables || !Array.isArray(outputVariables)) {
                return;
            }

            const itemIdVariable = outputVariables.find(variable => variable.name === 'ItemId');
            const itemNameVariable = outputVariables.find(variable => variable.name === 'itemName');

            const itemId = itemIdVariable?.value || null;
            const itemName = itemNameVariable?.value || null;

            if (!itemId || !itemName) {
                return;
            }

            this.selectedItem = {
                Id: itemId,
                Name: itemName,
            };

            updateItemImage({ itemId, itemName })
                .then(() => {
                    console.log('Image updated successfully');
                })
                .catch((error) => {
                    this.showToast('Error', 'Failed to update the image. Please check logs.', 'error');
                });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `New Item "${itemName}" has been created.`,
                    variant: 'success',
                    mode: 'sticky',
                })
            );

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: itemId,
                    actionName: 'view',
                },
            });

            this.loadItems();
            this.closeFlowModal();
        }

    openCartModal() {
        this.isCartModalOpen = true;
    }

    closeCartModal() {
        this.isCartModalOpen = false;
    }

    handleCheckout(event) {
        const cartItems = event.detail.cartItems.map(item => item.Id);
        const accountId = this.accountDetails.data?.Id;

        if (!cartItems.length || !accountId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Checkout Failed',
                    message: 'Please verify the cart and account information.',
                    variant: 'error',
                })
            );
            return;
        }

        createPurchase({ itemIds: cartItems, accountId: accountId })
            .then(purchaseId => {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Checkout Successful',
                        message: `Purchase created successfully. ID: ${purchaseId}`,
                        variant: 'success',
                    })
                );

                this.cartItems = [];
                this.closeCartModal();
            })
            .catch(error => {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Checkout Failed',
                        message: 'An error occurred during checkout. Please try again.',
                        variant: 'error',
                    })
                );
            });
    }

    handleDetails(event) {
        const itemId = event.detail.itemId;
        const selectedItem = this.filteredItems.find(item => item.Id === itemId);
        if (selectedItem) {
            this.selectedItem = selectedItem;
            this.isDetailsModalOpen = true;
        }
    }

    closeDetailsModal() {
        this.isDetailsModalOpen = false;
        this.selectedItem = null;
    }

    handleAdd(event) {
        const itemId = event.detail.itemId;

        const selectedItem = { ...this.filteredItems.find(item => item.Id === itemId) };
        this.selectedItem = selectedItem;

        if (selectedItem && !this.cartItems.some(cartItem => cartItem.Id === selectedItem.Id)) {
            this.cartItems = [...this.cartItems, selectedItem];

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `${selectedItem.Name} has been added to the cart.`,
                    variant: 'success',
                })
            );
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Info',
                    message: `${selectedItem.Name} is already in the cart.`,
                    variant: 'info',
                })
            );
        }
    }

    handleSearch(event) {
        this.searchQuery = event.target.value.trim().toLowerCase();
        this.filterItems();
    }

    handleFamilyChange(event) {
        this.familyFilter = event.detail;
        this.filterItems();
    }

    handleTypeChange(event) {
        this.typeFilter = event.detail;
        this.filterItems();
    }

    filterItems() {
        this.filteredItems = this.items.filter(item => {
            const matchesFamily = this.familyFilter ? item.Family__c === this.familyFilter : true;
            const matchesType = this.typeFilter ? item.Type__c === this.typeFilter : true;
            const matchesSearch = this.searchQuery
                ? item.Name.toLowerCase().includes(this.searchQuery) || (item.Description__c && item.Description__c.toLowerCase().includes(this.searchQuery))
                : true;
            return matchesFamily && matchesType && matchesSearch;
        });
    }
}
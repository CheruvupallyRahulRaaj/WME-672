import { LightningElement, wire, track, api } from 'lwc';
import getProductList from '@salesforce/apex/ProductController.getProductList';

export default class Product extends LightningElement {

    PRODUCT_ERROR_MESSAGE = 'A product name and sku are required as well as price and quantity greater than zero.';
    columns = [
        { label: 'Name', fieldName: 'name', editable: true, required: true },
        { label: 'SKU', fieldName: 'sku', editable: true, required: true },
        { label: 'Qty', fieldName: 'quantity', type:'number', editable: true, required: true },
        { label: 'Price', fieldName: 'price', type:'number', formatter:'decimal', editable: true, required: true },
        { label: 'Adjustment', fieldName: 'adjustment', type:'number', formatter:'decimal', editable: true, required:true },
    ];

    newProductMessage = null;
    updateProductMessage = null;
    existingProducts = [];
    newProduct = { 
        name: '',
        sku: '',
        price: 0.0,
        adjustment: 0.0,
        quantity: 1
    };
    @track products = [];
    @track selectedProduct;
    @track displayProductCombobox = true;
    @track displayNewProduct = false;

    @api
    reset = () => {
        this.newProduct = { 
            name: '',
            sku: '',
            price: 0.0,
            adjustment: 0.0
        }
        this.products = [];
        this.selectedProduct = null;
        this.newProductMessage = null;
        this.updateProductMessage = null;
        this.displayNewProduct = this.existingProducts.length === 1;
    }

    @wire(getProductList)
    onGetProductList({error, data}) {
        if (data) {
            this.existingProducts = [{label: 'NEW ACCOUNT', value:'new'}];
            data.forEach(p => {
                const id = p.Id + '_' + p.Product2.Id + '_' + Date.now();
                this.existingProducts.push({
                    label: p.Product2.Name + ' (' + p.Product2.ProductCode + ')',
                    value: id,
                    id: id,
                    name: p.Product2.Name,
                    sku: p.Product2.ProductCode,
                    price: p.UnitPrice,
                    adjustment: 0.0,
                    quantity: 1
                });
            });
        } else if (error) {
            console.log(error);
        }
        this.displayProductCombobox = this.existingProducts.length > 1;
        this.displayNewProduct = this.existingProducts.length === 1;
    }

    getProducts = () => {
        const prods = [];
        this.products.forEach(d => {
            prods.push({
                name: d.name,
                sku: d.sku,
                price: d.price,
                adjustment: d.adjustment,
                quantity: d.quantity
            })
        });
        return prods;
    }

    handleExistingProduct = (evt) => {
        evt.stopPropagation();
        evt.preventDefault();
        const id = evt.detail.value;
        this.displayNewProduct = id === 'new';
        
        if (this.displayNewProduct) {
            return;
        }

        const selectedProducts = this.existingProducts.filter(p => { return p.id === id });

        this.products = this.products.concat(selectedProducts);

        this.newProductMessage = null;
        this.fireChangeEvent();
    }

    handleCancel = () => {
        this.updateProductMessage = null;
    }

    handleSave = (evt) => {
        evt.stopPropagation();
        evt.preventDefault();
        const draftValues = evt.detail.draftValues;

        // first validate the values before presisting them
        let valid = true;
        for (let idx = 0; idx < draftValues.length; idx++) {
            let dv = draftValues[idx];
            let selectedProduct = this.products.find(p => { return p.id.toString() === dv.id });
            let prod = Object.assign(selectedProduct, dv);
            valid = this.validate(prod);
            if (!valid) {
                this.updateProductMessage = this.PRODUCT_ERROR_MESSAGE;
                break;
            }
        }

        if (valid) {
            draftValues.forEach(dv => {
                if(!this.isUndefinedOrNull(dv.adjustment)) {
                    dv.adjustment = new Number(dv.adjustment).valueOf();
                }
                if (!this.isUndefinedOrNull(dv.price)) {
                    dv.price = new Number(dv.price).valueOf();
                }
                if (!this.isUndefinedOrNull(dv.quantity)) {
                    dv.quantity = new Number(dv.quantity).valueOf();
                }

                let selectedProduct = this.products.find(p => { return p.id.toString() === dv.id });
                selectedProduct = Object.assign(selectedProduct, dv);
            });
            this.template.querySelector('lightning-datatable').draftValues = null;
            this.updateProductMessage = null;
            this.fireChangeEvent();
        }
    }

    validate = (product) => {
        let valid = true;
        if (this.isEmpty(product.name)) {
            valid = false;
        }
        else if (this.isEmpty(product.sku)) {
            valid = false;
        }
        else if (!(new Number(product.price).valueOf() > 0)) {
            valid = false;
        }
        else if (!(new Number(product.quantity).valueOf() >= 1)) {
            valid = false;
        }
        return valid;
    }

    isEmpty = (obj) => {
        return obj === undefined || obj === null || (typeof obj === 'string' && obj.trim() === '');
    }

    isUndefinedOrNull = (obj) => {
        return typeof obj === 'undefined' || obj === null;
    } 

    handleNewProductChange = (evt) => {
        evt.stopPropagation();
        evt.preventDefault();
        switch(evt.target.name) {
            case 'newProductName':
                this.newProduct.name = evt.detail.value;
                break;
            case 'newProductSku':
                this.newProduct.sku = evt.detail.value;
                break;
            case 'newProductPrice':
                this.newProduct.price = evt.detail.value;
                break;
            case 'newProductAdjustment':
                this.newProduct.adjustment = evt.detail.value;
                break;
            case 'newProductQuantity':
                this.newProduct.quantity = evt.detail.value;
        }
    }

    handleNewProduct = (evt) => {
        evt.stopPropagation();
        evt.preventDefault();

        if (!this.validate(this.newProduct)) {
            this.newProductMessage = this.PRODUCT_ERROR_MESSAGE;
            return false;
        } else {
            this.newProductMessage = null;
        }

        const prod = Object.assign( this.newProduct, { id: Date.now()});
        this.products = this.products.concat([prod]);

        // reset the values
        this.newProduct = { 
            name: '',
            sku: '',
            price: 0.0,
            adjustment: 0.0,
            quantity: 1
        };

        this.template.querySelectorAll('lightning-input').forEach(li => {
            li.value = (li.name === 'newProductPrice' || 
                li.name === 'newProductAdjustment') ? 0.0 : null;
        });

        this.fireChangeEvent();
    }

    fireChangeEvent = () => {
        const event = new CustomEvent("change", {
            composed: true,
            bubbles: true,
            detail: {
                type: 'product',
                value: this.getProducts()
            },
        });
        this.dispatchEvent(event);
    }

    displayNewProductMessage = () => {
        return this.newProductMessage === null;
    }

    displayUpdateProductMessage = () => {
        return this.updateProductMessage === null;
    }
}
import { LightningElement, wire } from 'lwc';
import getFooterData from '@salesforce/apex/FooterController.getFooterData';

export default class AppFooter extends LightningElement {
    footerData;
    error;

    @wire(getFooterData)
    wiredFooterData({ error, data }) {
        if (data) {
            this.footerData = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.footerData = undefined;
        }
    }

    get showFooter() {
        return this.footerData !== undefined;
    }

    get formattedBudget() {
        return this.formatCurrency(this.footerData?.trainingBudget);
    }

    get formattedRoi() {
        return this.formatPercent(this.footerData?.avgTrainingRoi);
    }

    formatCurrency(value) {
        const numeric = value ? Number(value) : 0;
        return new Intl.NumberFormat('fr-FR', {
            style: 'currency',
            currency: 'EUR',
            maximumFractionDigits: 0
        }).format(numeric);
    }

    formatPercent(value) {
        const numeric = value ? Number(value) : 0;
        return `${Math.round(numeric)}%`;
    }
}
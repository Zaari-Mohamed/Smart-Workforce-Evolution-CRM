import { LightningElement, track, wire } from 'lwc';
import getAlerts from '@salesforce/apex/AlertsController.getAlerts';
import markAlertHandled from '@salesforce/apex/AlertsController.markAlertHandled';
import { refreshApex } from '@salesforce/apex';

export default class RealTimeAlerts extends LightningElement {
    @track criticalAlerts = [];
    @track warningAlerts = [];
    @track infoAlerts = [];
    @track isLoading = false;
    @track error = '';
    @track lastRefresh = '';

    alertsWire;
    @wire(getAlerts)
    wiredAlerts(result) {
        this.alertsWire = result;
        if (result.data) {
            this.buildAlerts(result.data);
        } else if (result.error) {
            this.error = 'Erreur de chargement';
        }
    }

    connectedCallback() {
        this.updateLastRefresh();
    }

    get totalAlerts() {
        return this.criticalAlerts.length + this.warningAlerts.length + this.infoAlerts.length;
    }

    refreshAlerts() {
        this.isLoading = true;
        Promise.all([refreshApex(this.alertsWire)])
            .finally(() => {
                this.isLoading = false;
                this.updateLastRefresh();
            });
    }

    handleManualRefresh() {
        this.refreshAlerts();
    }

    buildAlerts(list) {
        const critical = [];
        const warning = [];
        const info = [];
        list.forEach((alertItem) => {
            const severity = alertItem.Severity__c || 'Info';
            const mapped = this.mapAlert(alertItem);
            if (severity === 'Critical') {
                critical.push(mapped);
            } else if (severity === 'Important') {
                warning.push(mapped);
            } else {
                info.push(mapped);
            }
        });

        this.criticalAlerts = critical;
        this.warningAlerts = warning;
        this.infoAlerts = info;
    }

    updateLastRefresh() {
        this.lastRefresh = new Intl.DateTimeFormat('fr-FR', {
            hour: '2-digit',
            minute: '2-digit'
        }).format(new Date());
    }

    async markHandled(event) {
        const recordId = event.currentTarget.dataset.id;
        if (!recordId) {
            return;
        }

        this.isLoading = true;
        this.error = '';

        try {
            await markAlertHandled({ alertId: recordId });
            await this.refreshAlerts();
        } catch (e) {
            // garde l'UI actuelle, mais affiche une erreur
            this.error = 'Impossible de marquer comme traité.';
            console.error(e);
        } finally {
            this.isLoading = false;
        }
    }

    mapAlert(alertItem) {
        return {
            ...alertItem,
            displayName: alertItem.Employee__r?.Name || alertItem.Title__c || 'Alerte',
            displayTitle: alertItem.Title__c || 'Alerte',
            employeeTitle: alertItem.Employee__r?.Job_Title__c,
            employeeDept: alertItem.Employee__r?.Department__c,
            initials: this.getInitials(alertItem.Employee__r?.Name || alertItem.Title__c),
            avatarClass: `avatar ${this.getDepartmentClass(alertItem.Employee__r?.Department__c)}`
        };
    }

    getInitials(name) {
        if (!name) {
            return 'SW';
        }
        return name
            .split(' ')
            .filter(Boolean)
            .map((part) => part[0])
            .join('')
            .substring(0, 2)
            .toUpperCase();
    }

    getDepartmentClass(name) {
        const classes = {
            IT: 'dept-it',
            Finance: 'dept-finance',
            Marketing: 'dept-marketing',
            DRH: 'dept-drh',
            Operations: 'dept-ops'
        };
        return classes[name] || 'dept-it';
    }

}
import { LightningElement, track, wire } from 'lwc';
import getCriticalAlerts from '@salesforce/apex/AlertsController.getCriticalAlerts';
import getSkillAlerts from '@salesforce/apex/AlertsController.getSkillAlerts';
import { refreshApex } from '@salesforce/apex';

export default class RealTimeAlerts extends LightningElement {
    @track criticalAlerts = [];
    @track warningAlerts = [];
    @track infoAlerts = [];
    @track isLoading = false;
    @track error = '';

    criticalWire;
    skillWire;
    refreshTimer;

    @wire(getCriticalAlerts)
    wiredCritical(result) {
        this.criticalWire = result;
        if (result.data) {
            this.buildCritical(result.data);
        } else if (result.error) {
            this.error = 'Erreur de chargement';
        }
    }

    @wire(getSkillAlerts)
    wiredSkills(result) {
        this.skillWire = result;
        if (result.data) {
            this.buildInfo(result.data);
        } else if (result.error) {
            this.error = 'Erreur de chargement';
        }
    }

    connectedCallback() {
        this.refreshTimer = setInterval(() => {
            this.refreshAlerts();
        }, 300000);
    }

    disconnectedCallback() {
        if (this.refreshTimer) {
            clearInterval(this.refreshTimer);
        }
    }

    get totalAlerts() {
        return this.criticalAlerts.length + this.warningAlerts.length + this.infoAlerts.length;
    }

    refreshAlerts() {
        this.isLoading = true;
        Promise.all([refreshApex(this.criticalWire), refreshApex(this.skillWire)])
            .finally(() => {
                this.isLoading = false;
            });
    }

    buildCritical(list) {
        const critical = [];
        const warning = [];
        list.forEach((emp) => {
            const risk = this.toNumber(emp.Turnover_Risk__c);
            const mapped = this.mapAlert(emp);
            if (risk > 75) {
                critical.push(mapped);
            } else if (risk >= 60) {
                warning.push(mapped);
            }
        });
        this.criticalAlerts = critical;
        this.warningAlerts = warning;
    }

    buildInfo(list) {
        this.infoAlerts = list.map((emp) => this.mapAlert(emp));
    }

    markHandled(event) {
        const recordId = event.currentTarget.dataset.id;
        if (!recordId) {
            return;
        }
        this.criticalAlerts = this.criticalAlerts.filter((item) => item.Id !== recordId);
        this.warningAlerts = this.warningAlerts.filter((item) => item.Id !== recordId);
        this.infoAlerts = this.infoAlerts.filter((item) => item.Id !== recordId);
    }

    mapAlert(emp) {
        return {
            ...emp,
            initials: this.getInitials(emp.Name),
            avatarClass: `avatar ${this.getDepartmentClass(emp.Department__c)}`
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

    toNumber(value) {
        return value ? Number(value) : 0;
    }
}
import { LightningElement, track, wire } from 'lwc';
import getAllTrainings from '@salesforce/apex/TrainingDashboardController.getAllTrainings';
import getTrainingStats from '@salesforce/apex/TrainingDashboardController.getTrainingStats';

export default class TrainingDashboard extends LightningElement {
    @track trainings = [];
    @track stats = {
        totalInProgress: 0,
        totalCompleted: 0,
        totalPlanned: 0,
        avgRoi: 0,
        totalCost: 0,
        avgCompletion: 0
    };
    @track isLoading = false;
    @track error = '';

    statusFilter = '';
    typeFilter = '';

    @wire(getAllTrainings)
    wiredTrainings({ data, error }) {
        this.isLoading = true;
        if (data) {
            this.trainings = data.map((item) => ({
                ...item,
                completionStyle: `width: ${this.toNumber(item.Post_Score__c)}%;`,
                durationHours: this.computeDurationHours(item.Start_Date__c, item.End_Date__c)
            }));
            this.error = '';
        } else if (error) {
            this.error = 'Erreur de chargement';
        }
        this.isLoading = false;
    }

    @wire(getTrainingStats)
    wiredStats({ data, error }) {
        if (data) {
            this.stats = { ...this.stats, ...data };
        } else if (error) {
            this.error = 'Erreur de chargement';
        }
    }

    get statusOptions() {
        const options = [{ label: 'Tous', value: '' }];
        const statuses = new Set(this.trainings.map((item) => item.Status__c).filter(Boolean));
        statuses.forEach((status) => options.push({ label: status, value: status }));
        return options;
    }

    get typeOptions() {
        const options = [{ label: 'Tous', value: '' }];
        const types = new Set(this.trainings.map((item) => item.Training_Type__c).filter(Boolean));
        types.forEach((type) => options.push({ label: type, value: type }));
        return options;
    }

    get filteredTrainings() {
        let filtered = [...this.trainings];
        if (this.statusFilter) {
            filtered = filtered.filter((item) => item.Status__c === this.statusFilter);
        }
        if (this.typeFilter) {
            filtered = filtered.filter((item) => item.Training_Type__c === this.typeFilter);
        }
        return filtered;
    }

    get avgRoi() {
        return this.roundValue(this.stats.avgRoi);
    }

    get totalCost() {
        return this.roundValue(this.stats.totalCost);
    }

    get avgCompletion() {
        return this.roundValue(this.stats.avgCompletion);
    }

    get roiByType() {
        const group = {};
        this.trainings.forEach((item) => {
            const key = item.Training_Type__c || 'Autre';
            const value = this.toNumber(item.ROI__c);
            group[key] = group[key] ? [...group[key], value] : [value];
        });
        const rows = Object.keys(group).map((type) => {
            const values = group[type];
            const avg = values.reduce((sum, val) => sum + val, 0) / values.length;
            return { type, roi: Math.round(avg) };
        });
        const max = Math.max(...rows.map((row) => row.roi), 1);
        return rows.map((row) => ({
            ...row,
            barStyle: `width: ${Math.round((row.roi / max) * 100)}%;`
        }));
    }

    handleStatusChange(event) {
        this.statusFilter = event.detail.value;
    }

    handleTypeChange(event) {
        this.typeFilter = event.detail.value;
    }

    computeDurationHours(startValue, endValue) {
        if (!startValue || !endValue) {
            return '';
        }
        const start = new Date(startValue);
        const end = new Date(endValue);
        const diffMs = Math.max(0, end.getTime() - start.getTime());
        const hours = Math.round(diffMs / 3600000);
        return hours;
    }

    roundValue(value) {
        return value ? Math.round(value) : 0;
    }

    toNumber(value) {
        return value ? Number(value) : 0;
    }
}
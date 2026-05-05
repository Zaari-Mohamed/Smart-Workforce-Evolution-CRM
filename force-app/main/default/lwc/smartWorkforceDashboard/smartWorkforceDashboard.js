import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import USER_NAME_FIELD from '@salesforce/schema/User.Name';
import getEmployees from '@salesforce/apex/EmployeeDashboardController.getEmployees';
import { refreshApex } from '@salesforce/apex';

export default class SmartWorkforceDashboard extends NavigationMixin(LightningElement) {
    @track displayedEmployees = [];
    @track allEmployees = [];
    @track departments = [];
    @track departmentStats = [];
    @track criticalAlerts = [];
    @track topPerformers = [];
    @track riskSegments = [];
    @track riskSignals = [];
    @track isLoading = false;
    @track error = '';
    @track showEmpty = false;

    @track totalEmployees = 0;
    @track highRiskCount = 0;
    @track avgPerformance = 0;
    @track avgTurnoverRisk = 0;
    @track avgSkillMatch = 0;

    @track currentDate = '';
    @track userInitials = '';
    @track lastRefresh = '';
    userName = '';

    searchTerm = '';
    selectedDept = '';
    viewMode = 'table';
    growthHint = 12;
    employeesWireResult;

    connectedCallback() {
        this.currentDate = new Intl.DateTimeFormat('fr-FR', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        }).format(new Date());
        this.userInitials = this.getInitials(this.userName);
    }

    @wire(getRecord, { recordId: USER_ID, fields: [USER_NAME_FIELD] })
    wiredUser({ data }) {
        if (data) {
            this.userName = data.fields.Name.value;
            this.userInitials = this.getInitials(this.userName);
        }
    }

    @wire(getEmployees)
    wiredEmployees({ data, error }) {
        this.employeesWireResult = { data, error };
        this.isLoading = true;
        if (data) {
            this.prepareEmployees(data);
            this.error = '';
        } else if (error) {
            this.error = 'Erreur de chargement';
            this.allEmployees = [];
            this.displayedEmployees = [];
        }
        this.updateLastRefresh();
        this.isLoading = false;
    }

    get isTableView() {
        return this.viewMode === 'table';
    }

    get isCardView() {
        return this.viewMode === 'cards';
    }

    get filterAllClass() {
        return this.selectedDept ? '' : 'active';
    }

    get tableToggleClass() {
        return this.viewMode === 'table' ? 'active' : '';
    }

    get cardToggleClass() {
        return this.viewMode === 'cards' ? 'active' : '';
    }

    prepareEmployees(employees) {
        const deptCount = {};

        this.allEmployees = employees.map((emp) => {
            const perfScore = this.toNumber(emp.Performance_Score__c);
            const turnoverRisk = this.toNumber(emp.Turnover_Risk__c);
            const skillMatch = this.toNumber(emp.Skill_Match_Score__c);
            const department = emp.Department__c || 'Autre';

            deptCount[department] = (deptCount[department] || 0) + 1;

            const riskColor = this.getRiskColor(turnoverRisk);
            const avatarClass = `avatar ${this.getDepartmentClass(department)}`;

            return {
                ...emp,
                initials: this.getInitials(emp.Name),
                statusClass: this.getStatusClass(emp.Status__c),
                perfStyle: `width: ${perfScore}%;`,
                riskStyle: `width: ${turnoverRisk}%; background: ${riskColor};`,
                skillStyle: `width: ${skillMatch}%;`,
                riskDash: `stroke-dasharray: ${turnoverRisk} 100;`,
                riskGaugeClass: this.getRiskGaugeClass(turnoverRisk),
                avatarClass
            };
        });

        this.totalEmployees = employees.length;
        this.highRiskCount = employees.filter((e) => this.toNumber(e.Turnover_Risk__c) > 60).length;
        this.avgPerformance = this.roundAvg(employees, 'Performance_Score__c');
        this.avgTurnoverRisk = this.roundAvg(employees, 'Turnover_Risk__c');
        this.avgSkillMatch = this.roundAvg(employees, 'Skill_Match_Score__c');

        this.departments = Object.keys(deptCount).map((name) => ({
            name,
            activeClass: this.selectedDept === name ? 'active' : ''
        }));

        const total = this.totalEmployees || 1;
        this.departmentStats = Object.keys(deptCount).map((name) => {
            const count = deptCount[name];
            const percent = Math.round((count / total) * 100);
            return {
                name,
                count,
                style: `width: ${percent}%; background: ${this.getDepartmentColor(name)};`
            };
        });

        this.criticalAlerts = this.allEmployees
            .filter((e) => this.toNumber(e.Turnover_Risk__c) > 60)
            .slice(0, 5);

        this.topPerformers = [...this.allEmployees]
            .sort((a, b) => this.toNumber(b.Performance_Score__c) - this.toNumber(a.Performance_Score__c))
            .slice(0, 5);

        this.computeRiskSegments();
        this.computeRiskSignals();
        this.filterEmployees();
    }

    computeRiskSegments() {
        const total = this.allEmployees.length || 1;
        const low = this.allEmployees.filter((e) => this.toNumber(e.Turnover_Risk__c) <= 40).length;
        const mid = this.allEmployees.filter((e) => {
            const value = this.toNumber(e.Turnover_Risk__c);
            return value > 40 && value <= 60;
        }).length;
        const high = this.allEmployees.filter((e) => this.toNumber(e.Turnover_Risk__c) > 60).length;

        const lowPct = Math.round((low / total) * 100);
        const midPct = Math.round((mid / total) * 100);
        const highPct = Math.max(0, 100 - lowPct - midPct);

        let offset = 0;
        this.riskSegments = [
            {
                label: 'low',
                className: 'donut-segment low',
                style: `stroke-dasharray: ${lowPct} ${100 - lowPct}; stroke-dashoffset: -${offset};`
            },
            {
                label: 'mid',
                className: 'donut-segment mid',
                style: `stroke-dasharray: ${midPct} ${100 - midPct}; stroke-dashoffset: -${offset + lowPct};`
            },
            {
                label: 'high',
                className: 'donut-segment high',
                style: `stroke-dasharray: ${highPct} ${100 - highPct}; stroke-dashoffset: -${offset + lowPct + midPct};`
            }
        ];
    }

    filterEmployees() {
        let filtered = [...this.allEmployees];
        if (this.searchTerm) {
            const term = this.searchTerm.toLowerCase();
            filtered = filtered.filter((emp) =>
                (emp.Name || '').toLowerCase().includes(term) ||
                (emp.Job_Title__c || '').toLowerCase().includes(term)
            );
        }
        if (this.selectedDept) {
            filtered = filtered.filter((emp) => emp.Department__c === this.selectedDept);
        }
        this.displayedEmployees = filtered;
        this.showEmpty = filtered.length === 0;
    }

    handleRefresh() {
        if (!this.employeesWireResult) {
            return;
        }
        this.isLoading = true;
        refreshApex(this.employeesWireResult)
            .finally(() => {
                this.isLoading = false;
                this.updateLastRefresh();
            });
    }

    handleFocusSummary() {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    handleExport() {
        window.open('/apex/EmployeeReport', '_blank');
    }

    updateLastRefresh() {
        this.lastRefresh = new Intl.DateTimeFormat('fr-FR', {
            hour: '2-digit',
            minute: '2-digit'
        }).format(new Date());
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.filterEmployees();
    }

    filterAllEmployees() {
        this.selectedDept = '';
        this.filterEmployees();
    }

    filterByDepartment(event) {
        this.selectedDept = event.currentTarget.dataset.dept;
        this.filterEmployees();
    }

    showTable(event) {
        this.viewMode = 'table';
        this.blurButton(event);
    }

    showCards(event) {
        this.viewMode = 'cards';
        this.blurButton(event);
    }

    viewEmployee(event) {
        const recordId = event.currentTarget.dataset.id;
        if (!recordId) {
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                actionName: 'view'
            }
        });
    }

    blurButton(event) {
        if (event && event.currentTarget) {
            event.currentTarget.blur();
        }
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

    getStatusClass(status) {
        if (status === 'Actif') {
            return 'status-pill status-active';
        }
        if (status === 'En congé') {
            return 'status-pill status-warning';
        }
        return 'status-pill status-inactive';
    }

    getRiskColor(value) {
        if (value > 60) {
            return '#EF4444';
        }
        if (value > 40) {
            return '#F59E0B';
        }
        return '#1D9E75';
    }

    getRiskGaugeClass(value) {
        if (value > 60) {
            return 'gauge-fill danger';
        }
        if (value > 40) {
            return 'gauge-fill warning';
        }
        return 'gauge-fill safe';
    }

    getDepartmentColor(name) {
        const colors = {
            IT: '#1e7ec8',
            Finance: '#1D9E75',
            Marketing: '#7c3aed',
            DRH: '#ec4899',
            Operations: '#f97316'
        };
        return colors[name] || '#1e7ec8';
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

    computeRiskSignals() {
        const satisfaction = this.avgNormalizedScore(this.allEmployees, 'Job_Satisfaction__c', 10);
        const balance = this.avgNormalizedScore(this.allEmployees, 'Work_Life_Balance__c', 10);
        const support = this.avgNormalizedScore(this.allEmployees, 'Manager_Support_Score__c', 10);
        const skillMatch = this.avgNormalizedScore(this.allEmployees, 'Skill_Match_Score__c', 100);

        const signals = [
            this.buildRiskSignal('Overview', this.avgTurnoverRisk),
            this.buildRiskSignal('Satisfaction', this.scoreToRisk(satisfaction)),
            this.buildRiskSignal('Equilibre', this.scoreToRisk(balance)),
            this.buildRiskSignal('Support', this.scoreToRisk(support)),
            this.buildRiskSignal('Skills', this.scoreToRisk(skillMatch))
        ];
        this.riskSignals = signals;
    }

    buildRiskSignal(label, value) {
        const bounded = this.clamp(value, 0, 100);
        return {
            label,
            value: bounded,
            levelClass: this.getSignalClass(bounded),
            style: `width: ${bounded}%;`
        };
    }

    getSignalClass(value) {
        if (value > 60) {
            return 'signal-fill danger';
        }
        if (value > 40) {
            return 'signal-fill warning';
        }
        return 'signal-fill safe';
    }

    avgNormalizedScore(list, field, maxValue) {
        if (!list || list.length === 0) {
            return 0;
        }
        const sum = list.reduce((total, item) => total + this.toNumber(item[field]), 0);
        const avg = sum / list.length;
        return Math.round((avg / maxValue) * 100);
    }

    scoreToRisk(normalizedScore) {
        return 100 - this.clamp(normalizedScore, 0, 100);
    }

    clamp(value, min, max) {
        return Math.min(max, Math.max(min, value));
    }

    roundAvg(list, field) {
        if (!list || list.length === 0) {
            return 0;
        }
        const sum = list.reduce((total, item) => total + this.toNumber(item[field]), 0);
        return Math.round(sum / list.length);
    }

    toNumber(value) {
        return value ? Number(value) : 0;
    }
}
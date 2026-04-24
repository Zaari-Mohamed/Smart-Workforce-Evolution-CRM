import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getEmployeeDetails from '@salesforce/apex/EmployeeProfileController.getEmployeeDetails';
import getEmployeeSkills from '@salesforce/apex/EmployeeProfileController.getEmployeeSkills';
import getEmployeeEvaluations from '@salesforce/apex/EmployeeProfileController.getEmployeeEvaluations';
import getEmployeeTrainings from '@salesforce/apex/EmployeeProfileController.getEmployeeTrainings';
import getEmployeeRecommendations from '@salesforce/apex/EmployeeProfileController.getEmployeeRecommendations';
import acceptRecommendationApex from '@salesforce/apex/EmployeeProfileController.acceptRecommendation';
import { refreshApex } from '@salesforce/apex';

export default class EmployeeProfileCard extends NavigationMixin(LightningElement) {
    @api recordId;

    @track employee = {};
    @track skills = [];
    @track evaluations = [];
    @track trainings = [];
    @track recommendations = [];

    @track isLoading = false;
    @track error = '';

    detailsWire;
    skillsWire;
    evaluationsWire;
    trainingsWire;
    recommendationsWire;

    loadingStates = {
        details: true,
        skills: true,
        evaluations: true,
        trainings: true,
        recommendations: true
    };

    @wire(getEmployeeDetails, { employeeId: '$recordId' })
    wiredEmployee(result) {
        this.detailsWire = result;
        this.loadingStates.details = false;
        if (result.data) {
            this.employee = result.data;
        } else if (result.error) {
            this.error = 'Erreur de chargement';
        }
        this.updateLoading();
    }

    @wire(getEmployeeSkills, { employeeId: '$recordId' })
    wiredSkills(result) {
        this.skillsWire = result;
        this.loadingStates.skills = false;
        if (result.data) {
            this.skills = result.data.map((skill) => this.mapSkill(skill));
        } else if (result.error) {
            this.error = 'Erreur de chargement';
        }
        this.updateLoading();
    }

    @wire(getEmployeeEvaluations, { employeeId: '$recordId' })
    wiredEvaluations(result) {
        this.evaluationsWire = result;
        this.loadingStates.evaluations = false;
        if (result.data) {
            this.evaluations = result.data
                .slice(0, 3)
                .map((item) => ({
                    ...item,
                    formattedDate: this.formatDate(item.Evaluation_Date__c || item.CreatedDate),
                    displayType: item.Evaluation_Type__c || item.Name,
                    displayScore: item.Overall_Score__c ? `${item.Overall_Score__c}%` : 'N/A',
                    promoClass: item.Promotion_Recommended__c ? 'badge promo' : 'badge hidden'
                }));
        } else if (result.error) {
            this.error = 'Erreur de chargement';
        }
        this.updateLoading();
    }

    @wire(getEmployeeTrainings, { employeeId: '$recordId' })
    wiredTrainings(result) {
        this.trainingsWire = result;
        this.loadingStates.trainings = false;
        if (result.data) {
            this.trainings = result.data
                .slice(0, 3)
                .map((training) => ({
                    ...training,
                    completionStyle: `width: ${this.toNumber(training.Post_Score__c)}%;`
                }));
        } else if (result.error) {
            this.error = 'Erreur de chargement';
        }
        this.updateLoading();
    }

    @wire(getEmployeeRecommendations, { employeeId: '$recordId' })
    wiredRecommendations(result) {
        this.recommendationsWire = result;
        this.loadingStates.recommendations = false;
        if (result.data) {
            this.recommendations = result.data.slice(0, 3);
        } else if (result.error) {
            this.error = 'Erreur de chargement';
        }
        this.updateLoading();
    }

    get employeeInitials() {
        return this.getInitials(this.employee.Name);
    }

    get avatarClass() {
        return `avatar ${this.getDepartmentClass(this.employee.Department__c)}`;
    }

    get statusClass() {
        return this.getStatusClass(this.employee.Status__c);
    }

    get startDate() {
        return this.formatDate(this.employee.Start_Date__c);
    }

    get riskValue() {
        return this.toNumber(this.employee.Turnover_Risk__c);
    }

    get perfValue() {
        return this.toNumber(this.employee.Performance_Score__c);
    }

    get skillValue() {
        return this.toNumber(this.employee.Skill_Match_Score__c);
    }

    get satisfactionValue() {
        return this.toNumber(this.employee.Job_Satisfaction__c);
    }

    get headerStyle() {
        return `background: ${this.getRiskGradient(this.riskValue)};`;
    }

    get perfGaugeStyle() {
        return `stroke-dasharray: ${this.perfValue} 100;`;
    }

    get riskGaugeStyle() {
        return `stroke-dasharray: ${this.riskValue} 100;`;
    }

    get skillGaugeStyle() {
        return `stroke-dasharray: ${this.skillValue} 100;`;
    }

    get satisfactionGaugeStyle() {
        return `stroke-dasharray: ${this.satisfactionValue} 100;`;
    }

    get riskGaugeClass() {
        if (this.riskValue > 60) {
            return 'gauge-fill danger';
        }
        if (this.riskValue > 40) {
            return 'gauge-fill warning';
        }
        return 'gauge-fill safe';
    }

    get satisfactionGaugeClass() {
        if (this.satisfactionValue > 60) {
            return 'gauge-fill safe';
        }
        if (this.satisfactionValue > 40) {
            return 'gauge-fill warning';
        }
        return 'gauge-fill danger';
    }

    get skillsEmpty() {
        return this.skills.length === 0;
    }

    get evaluationsEmpty() {
        return this.evaluations.length === 0;
    }

    get trainingsEmpty() {
        return this.trainings.length === 0;
    }

    get recommendationsEmpty() {
        return this.recommendations.length === 0;
    }

    updateLoading() {
        this.isLoading = Object.values(this.loadingStates).some((value) => value);
    }

    mapSkill(skill) {
        const current = this.toNumber(skill.Current_Level__c);
        const target = this.toNumber(skill.Target_Level__c);
        const percent = target ? Math.min(100, Math.round((current / target) * 100)) : 0;
        return {
            ...skill,
            currentStyle: `width: ${percent}%;`,
            criticalClass: skill.Is_Critical__c ? 'badge critical' : 'badge hidden',
            trendClass: this.getTrendClass(skill.Trend__c),
            trendLabel: this.getTrendLabel(skill.Trend__c)
        };
    }

    acceptRecommendation(event) {
        const recId = event.currentTarget.dataset.id;
        if (!recId) {
            return;
        }
        this.isLoading = true;
        acceptRecommendationApex({ recommendationId: recId })
            .then(() => refreshApex(this.recommendationsWire))
            .catch(() => {
                this.error = 'Impossible de valider la recommandation';
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    viewRecommendation(event) {
        const recId = event.currentTarget.dataset.id;
        if (!recId) {
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                actionName: 'view'
            }
        });
    }

    formatDate(value) {
        if (!value) {
            return '';
        }
        return new Intl.DateTimeFormat('fr-FR').format(new Date(value));
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
            return 'badge status active';
        }
        if (status === 'En congé') {
            return 'badge status warning';
        }
        return 'badge status inactive';
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

    getTrendClass(value) {
        if (value === 'Up') {
            return 'badge trend up';
        }
        if (value === 'Down') {
            return 'badge trend down';
        }
        return 'badge trend stable';
    }

    getTrendLabel(value) {
        if (value === 'Up') {
            return 'Hausse';
        }
        if (value === 'Down') {
            return 'Baisse';
        }
        return 'Stable';
    }

    getRiskGradient(value) {
        if (value > 60) {
            return 'linear-gradient(135deg, rgba(239,68,68,0.3), rgba(13,30,46,0.9))';
        }
        if (value > 40) {
            return 'linear-gradient(135deg, rgba(245,158,11,0.3), rgba(13,30,46,0.9))';
        }
        return 'linear-gradient(135deg, rgba(29,158,117,0.3), rgba(13,30,46,0.9))';
    }

    toNumber(value) {
        return value ? Number(value) : 0;
    }
}
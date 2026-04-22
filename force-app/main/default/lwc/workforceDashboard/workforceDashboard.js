import { LightningElement, track } from 'lwc';
import getEmployees from '@salesforce/apex/EmployeeDashboardController.getEmployees';

export default class WorkforceDashboard extends LightningElement {
    @track displayedEmployees = [];
    @track totalEmployees = 0;
    @track highRiskCount = 0;
    @track avgPerformance = 0;
    @track avgTurnoverRisk = 0;
    @track avgSkillMatch = 0;
    @track currentDate = new Date().toLocaleDateString('fr-FR');
    @track loading = false;
    @track showEmpty = false;
    
    @track departments = [
        { name: 'Sales', active: false, activeClass: '' },
        { name: 'Finance', active: false, activeClass: '' },
        { name: 'HR', active: false, activeClass: '' },
        { name: 'Marketing', active: false, activeClass: '' },
        { name: 'Operations', active: false, activeClass: '' }
    ];
    
    @track filterAllClass = 'active';
    searchTerm = '';
    selectedDept = '';
    
    allEmployees = [];

    connectedCallback() {
        this.loadEmployees();
    }

    loadEmployees() {
        this.loading = true;
        getEmployees()
            .then(result => {
                this.processEmployees(result);
                this.loading = false;
            })
            .catch(error => {
                console.error('Error loading employees:', error);
                this.loading = false;
            });
    }

    processEmployees(employees) {
        this.allEmployees = employees.map(emp => {
            // Calculer les styles ici au lieu de dans le template
            const perfScore = emp.Performance_Score__c || 0;
            const turnoverRisk = emp.Turnover_Risk__c || 0;
            const skillMatch = emp.Skill_Match_Score__c || 0;
            
            let riskColor = '#10B981';
            if (turnoverRisk > 60) riskColor = '#EF4444';
            else if (turnoverRisk > 40) riskColor = '#F59E0B';
            
            return {
                ...emp,
                initials: this.getInitials(emp.Name),
                statusClass: emp.Status__c === 'Actif' ? 'status-active' : 'status-inactive',
                perfStyle: `width: ${perfScore}%;`,
                riskStyle: `width: ${turnoverRisk}%; background: ${riskColor};`,
                skillStyle: `width: ${skillMatch}%;`
            };
        });
        
        this.totalEmployees = employees.length;
        this.highRiskCount = employees.filter(e => (e.Turnover_Risk__c || 0) > 60).length;
        this.avgPerformance = Math.round(employees.reduce((a,b) => a + (b.Performance_Score__c || 0), 0) / employees.length);
        this.avgTurnoverRisk = Math.round(employees.reduce((a,b) => a + (b.Turnover_Risk__c || 0), 0) / employees.length);
        this.avgSkillMatch = Math.round(employees.reduce((a,b) => a + (b.Skill_Match_Score__c || 0), 0) / employees.length);
        
        this.filterEmployees();
    }

    getInitials(name) {
        return name ? name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase() : '??';
    }

    filterEmployees() {
        let filtered = [...this.allEmployees];
        
        if (this.searchTerm) {
            filtered = filtered.filter(emp => 
                emp.Name?.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
                emp.Job_Title__c?.toLowerCase().includes(this.searchTerm.toLowerCase())
            );
        }
        
        if (this.selectedDept) {
            filtered = filtered.filter(emp => emp.Department__c === this.selectedDept);
        }
        
        this.displayedEmployees = filtered;
        this.showEmpty = filtered.length === 0;
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.filterEmployees();
    }

    filterAllEmployees() {
        this.selectedDept = '';
        this.filterAllClass = 'active';
        this.departments = this.departments.map(d => ({ ...d, active: false, activeClass: '' }));
        this.filterEmployees();
    }

    filterByDepartment(event) {
        const deptName = event.currentTarget.dataset.dept;
        this.selectedDept = deptName;
        this.filterAllClass = '';
        this.departments = this.departments.map(d => ({
            ...d,
            active: d.name === deptName,
            activeClass: d.name === deptName ? 'active' : ''
        }));
        this.filterEmployees();
    }

    viewEmployee(event) {
        const empId = event.currentTarget.dataset.id;
        console.log('View employee:', empId);
    }
}
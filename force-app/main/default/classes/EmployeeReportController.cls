public with sharing class EmployeeReportController {
    public List<Employe__c> employees { get; private set; }
    public Integer totalEmployees { get; private set; }
    public Integer highRiskCount { get; private set; }
    public Integer avgPerformance { get; private set; }
    public Integer avgTurnoverRisk { get; private set; }
    public Integer avgSkillMatch { get; private set; }

    public EmployeeReportController() {
        employees = [
            SELECT Id, Name, Employee_ID__c, Email__c, Department__c,
                   Job_Title__c, Job_Level__c, Start_Date__c,
                   Contract_Type__c, Status__c, Performance_Score__c,
                   Turnover_Risk__c, Skill_Match_Score__c,
                   Monthly_Income__c, Years_at_Company__c,
                   Absence_Days_YTD__c
            FROM Employe__c
            ORDER BY Name ASC
            LIMIT 2000
        ];

        totalEmployees = employees.size();
        highRiskCount = countHighRisk(employees);
        avgPerformance = avgScore(employees, 'Performance_Score__c');
        avgTurnoverRisk = avgScore(employees, 'Turnover_Risk__c');
        avgSkillMatch = avgScore(employees, 'Skill_Match_Score__c');
    }

    private Integer countHighRisk(List<Employe__c> listEmp) {
        Integer count = 0;
        for (Employe__c emp : listEmp) {
            if (emp.Turnover_Risk__c != null && emp.Turnover_Risk__c > 60) {
                count++;
            }
        }
        return count;
    }

    private Integer avgScore(List<Employe__c> listEmp, String fieldName) {
        if (listEmp.isEmpty()) {
            return 0;
        }
        Decimal total = 0;
        Integer count = 0;
        for (Employe__c emp : listEmp) {
            Object value = emp.get(fieldName);
            if (value != null) {
                total += (Decimal) value;
                count++;
            }
        }
        if (count == 0) {
            return 0;
        }
        return Integer.valueOf(Math.round(total / count));
    }
}

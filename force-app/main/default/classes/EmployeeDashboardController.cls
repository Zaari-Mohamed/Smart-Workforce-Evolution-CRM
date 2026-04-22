public with sharing class EmployeeDashboardController {
    @AuraEnabled(cacheable=true)
    public static List<Employe__c> getEmployees() {
        return [
            SELECT Id, Name, Job_Title__c, Department__c,
                   Performance_Score__c, Turnover_Risk__c,
                   Status__c, Skill_Match_Score__c,
                   Job_Satisfaction__c, Monthly_Income__c,
                   Employee_ID__c
            FROM Employe__c
            WHERE Status__c = 'Actif'
            ORDER BY Turnover_Risk__c DESC NULLS LAST
            LIMIT 200
        ];
    }
}
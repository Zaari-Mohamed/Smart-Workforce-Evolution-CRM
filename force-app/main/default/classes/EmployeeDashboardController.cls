public with sharing class EmployeeDashboardController {
    @AuraEnabled(cacheable=true)
    public static List<Employe__c> getEmployees() {
        try {
            return [
                SELECT Id, Name, Employee_ID__c, Email__c, Department__c,
                       Job_Title__c, Job_Level__c, Job_Role__c, Age__c,
                       Start_Date__c, Contract_Type__c, Status__c,
                       Monthly_Income__c, Performance_Score__c,
                       Job_Satisfaction__c, Work_Life_Balance__c,
                       Tenure_Months__c, Years_at_Company__c,
                       Training_Count__c, Absence_Days_YTD__c,
                       Internal_Mobility_Requests__c, Manager_Support_Score__c,
                       Turnover_Risk__c, Skill_Match_Score__c, Departed__c,
                       Manager__c
                FROM Employe__c
                WHERE Status__c = 'Actif'
                ORDER BY Turnover_Risk__c DESC NULLS LAST
                LIMIT 500
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to load employees.');
        }
    }
}
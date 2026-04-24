public with sharing class AlertsController {
    @AuraEnabled(cacheable=true)
    public static List<Employe__c> getCriticalAlerts() {
        try {
            return [
                SELECT Id, Name, Employee_ID__c, Department__c,
                       Job_Title__c, Turnover_Risk__c, Skill_Match_Score__c,
                       Status__c
                FROM Employe__c
                WHERE Turnover_Risk__c > 60
                ORDER BY Turnover_Risk__c DESC NULLS LAST
                LIMIT 500
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to load alerts.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Employe__c> getSkillAlerts() {
        try {
            return [
                SELECT Id, Name, Employee_ID__c, Department__c,
                       Job_Title__c, Turnover_Risk__c, Skill_Match_Score__c,
                       Status__c
                FROM Employe__c
                WHERE Skill_Match_Score__c < 50
                ORDER BY Skill_Match_Score__c ASC NULLS LAST
                LIMIT 500
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to load skill alerts.');
        }
    }
}
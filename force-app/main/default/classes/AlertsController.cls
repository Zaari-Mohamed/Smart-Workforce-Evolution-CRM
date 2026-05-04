public with sharing class AlertsController {
    @AuraEnabled(cacheable=true)
    public static List<Alert__c> getAlerts() {
        try {
            return [
                SELECT Id, Title__c, Message__c, Severity__c, Employee__c,
                       Employee__r.Name, Employee__r.Employee_ID__c,
                       Employee__r.Department__c, Employee__r.Job_Title__c,
                       Created_Date__c, Is_Read__c, Is_Dismissed__c
                FROM Alert__c
                WHERE Is_Dismissed__c = false
                ORDER BY Created_Date__c DESC NULLS LAST
                LIMIT 500
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to load alerts.');
        }
    }

    @AuraEnabled
    public static void markAlertHandled(Id alertId) {
        if (alertId == null) {
            return;
        }
        Alert__c alertItem = [
            SELECT Id, Is_Read__c, Is_Dismissed__c
            FROM Alert__c
            WHERE Id = :alertId
            LIMIT 1
        ];

        alertItem.Is_Read__c = true;
        alertItem.Is_Dismissed__c = true;
        update alertItem;
    }
}
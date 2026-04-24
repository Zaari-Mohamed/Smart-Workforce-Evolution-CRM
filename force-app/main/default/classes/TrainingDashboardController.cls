public with sharing class TrainingDashboardController {
    public class TrainingStats {
        @AuraEnabled public Integer totalInProgress;
        @AuraEnabled public Integer totalCompleted;
        @AuraEnabled public Integer totalPlanned;
        @AuraEnabled public Decimal avgRoi;
        @AuraEnabled public Decimal totalCost;
        @AuraEnabled public Decimal avgCompletion;
    }

    @AuraEnabled(cacheable=true)
    public static List<Training__c> getAllTrainings() {
        try {
            return [
                SELECT Id, Name, Employee__c, Employee__r.Name,
                       Training_Type__c, Status__c,
                       Cost__c, Pre_Score__c, Post_Score__c, ROI__c,
                       Start_Date__c, End_Date__c
                FROM Training__c
                ORDER BY ROI__c DESC NULLS LAST
                LIMIT 500
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to load trainings.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static TrainingStats getTrainingStats() {
        try {
            TrainingStats stats = new TrainingStats();
            stats.totalInProgress = 0;
            stats.totalCompleted = 0;
            stats.totalPlanned = 0;
            stats.avgRoi = 0;
            stats.totalCost = 0;
            stats.avgCompletion = 0;

            List<AggregateResult> statusAgg = [
                SELECT Status__c status, COUNT(Id) total
                FROM Training__c
                GROUP BY Status__c
                LIMIT 500
            ];
            for (AggregateResult ar : statusAgg) {
                String status = (String) ar.get('status');
                Integer total = (Integer) ar.get('total');
                if (status == 'In Progress') {
                    stats.totalInProgress = total;
                } else if (status == 'Completed') {
                    stats.totalCompleted = total;
                } else if (status == 'Planned') {
                    stats.totalPlanned = total;
                }
            }

            AggregateResult totals = [
                SELECT AVG(ROI__c) avgRoi,
                       SUM(Cost__c) totalCost,
                       AVG(Post_Score__c) avgCompletion
                FROM Training__c
            ];
            stats.avgRoi = (Decimal) totals.get('avgRoi');
            stats.totalCost = (Decimal) totals.get('totalCost');
            stats.avgCompletion = (Decimal) totals.get('avgCompletion');

            return stats;
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to load training stats.');
        }
    }
}
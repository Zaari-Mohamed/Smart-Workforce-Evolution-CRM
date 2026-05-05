public with sharing class FooterController {
    @AuraEnabled(cacheable=true)
    public static FooterData getFooterData() {
        FooterData data = new FooterData();
        data.appName = 'Smart Workforce';
        data.appVersion = '2.0.0';
        data.currentYear = Date.today().year();
        data.orgName = UserInfo.getOrganizationName();
        data.totalEmployees = [SELECT COUNT() FROM Employe__c WHERE Status__c = 'Actif'];
        data.highRiskEmployees = [
            SELECT COUNT()
            FROM Employe__c
            WHERE Status__c = 'Actif'
              AND Turnover_Risk__c > 60
        ];
        data.criticalRiskEmployees = [
            SELECT COUNT()
            FROM Employe__c
            WHERE Status__c = 'Actif'
              AND Turnover_Risk__c > 75
        ];
        data.skillGapEmployees = [
            SELECT COUNT()
            FROM Employe__c
            WHERE Status__c = 'Actif'
              AND Skill_Match_Score__c < 50
        ];

        AggregateResult[] deptResults = [SELECT COUNT_DISTINCT(Department__c) deptCount FROM Employe__c];
        data.totalDepartments = deptResults.isEmpty() ? 0 : (Integer) deptResults[0].get('deptCount');

        Map<String, Integer> trainingCounts = new Map<String, Integer>();
        for (AggregateResult ar : [
            SELECT Status__c status, COUNT(Id) total
            FROM Training__c
            GROUP BY Status__c
            LIMIT 500
        ]) {
            trainingCounts.put((String) ar.get('status'), (Integer) ar.get('total'));
        }

        data.hipaaTrainings = sumStatuses(trainingCounts, new List<String>{ 'HIPAA' });
        data.gdprTrainings = sumStatuses(trainingCounts, new List<String>{ 'GDPR' });
        data.pciTrainings = sumStatuses(trainingCounts, new List<String>{ 'PCI' });
        data.coppaTrainings = sumStatuses(trainingCounts, new List<String>{ 'COPPA' });
        data.ccpaTrainings = sumStatuses(trainingCounts, new List<String>{ 'CCPA' });

        AggregateResult trainingTotals = [
            SELECT AVG(ROI__c) avgRoi,
                   SUM(Cost__c) totalCost
            FROM Training__c
        ];
        data.avgTrainingRoi = (Decimal) trainingTotals.get('avgRoi');
        data.trainingBudget = (Decimal) trainingTotals.get('totalCost');

        data.userName = UserInfo.getName();
        data.today = Date.today().format();
        data.lastRefresh = Datetime.now().format('dd MMM yyyy HH:mm');
        return data;
    }

    private static Integer sumStatuses(Map<String, Integer> counts, List<String> statuses) {
        Integer total = 0;
        for (String status : statuses) {
            if (counts.containsKey(status)) {
                total += counts.get(status);
            }
        }
        return total;
    }

    public class FooterData {
        @AuraEnabled public String appName;
        @AuraEnabled public String appVersion;
        @AuraEnabled public Integer currentYear;
        @AuraEnabled public String orgName;
        @AuraEnabled public Integer totalEmployees;
        @AuraEnabled public Integer totalDepartments;
        @AuraEnabled public Integer highRiskEmployees;
        @AuraEnabled public Integer criticalRiskEmployees;
        @AuraEnabled public Integer skillGapEmployees;
        @AuraEnabled public Integer hipaaTrainings;
        @AuraEnabled public Integer gdprTrainings;
        @AuraEnabled public Integer pciTrainings;
        @AuraEnabled public Integer coppaTrainings;
        @AuraEnabled public Integer ccpaTrainings;
        @AuraEnabled public Decimal avgTrainingRoi;
        @AuraEnabled public Decimal trainingBudget;
        @AuraEnabled public String userName;
        @AuraEnabled public String today;
        @AuraEnabled public String lastRefresh;
    }
}
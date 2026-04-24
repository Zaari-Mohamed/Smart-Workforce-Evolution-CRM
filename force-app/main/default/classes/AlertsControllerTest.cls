@IsTest
public class AlertsControllerTest {
    @testSetup
    static void setup() {
        List<Employe__c> employees = new List<Employe__c>{
            new Employe__c(
                Name = 'Risk High',
                Employee_ID__c = 'EMP-2001',
                Status__c = 'Actif',
                Department__c = 'Finance',
                Contract_Type__c = 'CDI',
                Turnover_Risk__c = 80,
                Skill_Match_Score__c = 65
            ),
            new Employe__c(
                Name = 'Risk Medium',
                Employee_ID__c = 'EMP-2002',
                Status__c = 'Actif',
                Department__c = 'Marketing',
                Contract_Type__c = 'CDD',
                Turnover_Risk__c = 62,
                Skill_Match_Score__c = 45
            ),
            new Employe__c(
                Name = 'Skill Low',
                Employee_ID__c = 'EMP-2003',
                Status__c = 'Actif',
                Department__c = 'Operations',
                Contract_Type__c = 'Stage',
                Turnover_Risk__c = 20,
                Skill_Match_Score__c = 40
            )
        };
        insert employees;
    }

    @IsTest
    static void testGetCriticalAlerts() {
        Test.startTest();
        List<Employe__c> results = AlertsController.getCriticalAlerts();
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Should return employees with risk > 60.');
    }

    @IsTest
    static void testGetSkillAlerts() {
        Test.startTest();
        List<Employe__c> results = AlertsController.getSkillAlerts();
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Should return employees with skill match < 50.');
    }
}
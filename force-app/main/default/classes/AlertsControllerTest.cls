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

        List<Alert__c> alerts = new List<Alert__c>{
            new Alert__c(
                Title__c = 'Risque critique',
                Message__c = 'Turnover risk eleve',
                Severity__c = 'Critical',
                Employee__c = employees[0].Id,
                Created_Date__c = System.now()
            ),
            new Alert__c(
                Title__c = 'Risque important',
                Message__c = 'Risque a surveiller',
                Severity__c = 'Important',
                Employee__c = employees[1].Id,
                Created_Date__c = System.now()
            ),
            new Alert__c(
                Title__c = 'Skill gap',
                Message__c = 'Skill match faible',
                Severity__c = 'Info',
                Employee__c = employees[2].Id,
                Created_Date__c = System.now()
            )
        };
        insert alerts;
    }

    @IsTest
    static void testGetAlerts() {
        Test.startTest();
        List<Alert__c> results = AlertsController.getAlerts();
        Test.stopTest();

        System.assertEquals(3, results.size(), 'Should return all non-dismissed alerts.');
    }

    @IsTest
    static void testMarkAlertHandled() {
        Alert__c alertItem = [
            SELECT Id, Is_Read__c, Is_Dismissed__c
            FROM Alert__c
            WHERE Is_Dismissed__c = false
            LIMIT 1
        ];

        Test.startTest();
        AlertsController.markAlertHandled(alertItem.Id);
        Test.stopTest();

        Alert__c updated = [
            SELECT Id, Is_Read__c, Is_Dismissed__c
            FROM Alert__c
            WHERE Id = :alertItem.Id
        ];

        System.assertEquals(true, updated.Is_Read__c, 'markAlertHandled should set Is_Read__c to true.');
        System.assertEquals(true, updated.Is_Dismissed__c, 'markAlertHandled should set Is_Dismissed__c to true.');
    }
}
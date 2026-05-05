@IsTest
public class EmployeeDashboardControllerTest {
    @testSetup
    static void setup() {
        List<Employe__c> employees = new List<Employe__c>{
            new Employe__c(
                Name = 'Alice Active',
                Employee_ID__c = 'EMP-1001',
                Status__c = 'Actif',
                Department__c = 'Engineering',
                Contract_Type__c = 'CDI',
                Turnover_Risk__c = 75,
                Performance_Score__c = 90,
                Skill_Match_Score__c = 80
            ),
            new Employe__c(
                Name = 'Bob Active',
                Employee_ID__c = 'EMP-1002',
                Status__c = 'Actif',
                Department__c = 'Sales',
                Contract_Type__c = 'CDD',
                Turnover_Risk__c = 30,
                Performance_Score__c = 70,
                Skill_Match_Score__c = 60
            ),
            new Employe__c(
                Name = 'Carol Inactive',
                Employee_ID__c = 'EMP-1003',
                Status__c = 'Inactif',
                Department__c = 'HR',
                Contract_Type__c = 'Stage',
                Turnover_Risk__c = 95,
                Performance_Score__c = 40,
                Skill_Match_Score__c = 20
            )
        };
        insert employees;
    }

    @IsTest
    static void testGetEmployees() {
        Test.startTest();
        List<Employe__c> results = EmployeeDashboardController.getEmployees();
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Should return only active employees.');
        System.assert(results[0].Turnover_Risk__c >= results[1].Turnover_Risk__c, 'Results should be ordered by risk desc.');
    }
}
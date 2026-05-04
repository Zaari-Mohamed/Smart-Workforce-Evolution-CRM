@IsTest
public class EmployeeProfileControllerTest {
    @testSetup
    static void setup() {
        Employe__c employee = new Employe__c(
            Name = 'Diana Profile',
            Employee_ID__c = 'EMP-3001',
            Status__c = 'Actif',
            Department__c = 'Engineering',
            Contract_Type__c = 'CDI',
            Turnover_Risk__c = 55,
            Performance_Score__c = 85,
            Skill_Match_Score__c = 78
        );
        insert employee;

        Skill_Inventory__c skill = new Skill_Inventory__c(
            Name = 'Apex Skill',
            Employee__c = employee.Id,
            Skill_Category__c = 'Technical',
            Skill_Name__c = 'Apex',
            Current_Level__c = 3,
            Target_Level__c = 5,
            Is_Critical__c = true,
            Assessment_Source__c = 'Manager'
        );
        insert skill;

        Training__c training = new Training__c(
            Name = 'Apex Bootcamp',
            Employee__c = employee.Id,
            Training_Type__c = 'Technical',
            Status__c = 'In Progress',
            Cost__c = 1200,
            ROI__c = 15,
            Pre_Score__c = 60,
            Post_Score__c = 85,
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(-5)
        );
        insert training;

        Recommendation__c rec = new Recommendation__c(
            Name = 'Rec 1',
            Employee__c = employee.Id,
            Recommendation_Type__c = 'Training',
            Priority__c = 'High',
            Status__c = 'New',
            AI_Confidence_Score__c = 90,
            Expected_Impact__c = 12,
            Expiration_Date__c = Date.today().addDays(30)
        );
        insert rec;

        Evaluation__c eval = new Evaluation__c(
            Name = 'Evaluation 1'
        );
        insert eval;
    }

    @IsTest
    static void testGetEmployeeDetails() {
        Employe__c employee = [SELECT Id FROM Employe__c LIMIT 1];
        Test.startTest();
        Employe__c result = EmployeeProfileController.getEmployeeDetails(employee.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Employee details should load.');
    }

    @IsTest
    static void testGetEmployeeSkills() {
        Employe__c employee = [SELECT Id FROM Employe__c LIMIT 1];
        Test.startTest();
        List<Skill_Inventory__c> results = EmployeeProfileController.getEmployeeSkills(employee.Id);
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Should return employee skills.');
    }

    @IsTest
    static void testGetEmployeeEvaluations() {
        Employe__c employee = [SELECT Id FROM Employe__c LIMIT 1];
        Test.startTest();
        List<Evaluation__c> results = EmployeeProfileController.getEmployeeEvaluations(employee.Id);
        Test.stopTest();
        System.assert(results.size() > 0, 'Should return evaluations.');
    }

    @IsTest
    static void testGetEmployeeTrainings() {
        Employe__c employee = [SELECT Id FROM Employe__c LIMIT 1];
        Test.startTest();
        List<Training__c> results = EmployeeProfileController.getEmployeeTrainings(employee.Id);
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Should return trainings.');
    }

    @IsTest
    static void testGetEmployeeRecommendations() {
        Employe__c employee = [SELECT Id FROM Employe__c LIMIT 1];
        Test.startTest();
        List<Recommendation__c> results = EmployeeProfileController.getEmployeeRecommendations(employee.Id);
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Should return recommendations.');
    }

    @IsTest
    static void testAcceptRecommendation() {
        Recommendation__c rec = [SELECT Id, Status__c FROM Recommendation__c LIMIT 1];
        Test.startTest();
        Recommendation__c updated = EmployeeProfileController.acceptRecommendation(rec.Id);
        Test.stopTest();
        System.assertEquals('Accepted', updated.Status__c, 'Recommendation should be accepted.');
    }
}
@IsTest
public class SmartWorkforceCoverageTest {
    @IsTest
    static void testNullInputs() {
        Test.startTest();
        Employe__c details = EmployeeProfileController.getEmployeeDetails(null);
        List<Skill_Inventory__c> skills = EmployeeProfileController.getEmployeeSkills(null);
        List<Evaluation__c> evals = EmployeeProfileController.getEmployeeEvaluations(null);
        List<Training__c> trainings = EmployeeProfileController.getEmployeeTrainings(null);
        List<Recommendation__c> recs = EmployeeProfileController.getEmployeeRecommendations(null);
        Recommendation__c accepted = EmployeeProfileController.acceptRecommendation(null);
        Test.stopTest();

        System.assertEquals(null, details, 'Null employee should return null details.');
        System.assertEquals(0, skills.size(), 'Null employee should return empty skills.');
        System.assertEquals(0, evals.size(), 'Null employee should return empty evaluations.');
        System.assertEquals(0, trainings.size(), 'Null employee should return empty trainings.');
        System.assertEquals(0, recs.size(), 'Null employee should return empty recommendations.');
        System.assertEquals(null, accepted, 'Null recommendation should return null.');
    }

    @IsTest
    static void testNoActiveEmployees() {
        Test.startTest();
        List<Employe__c> results = EmployeeDashboardController.getEmployees();
        Test.stopTest();
        System.assertEquals(0, results.size(), 'Should return empty when no active employees.');
    }
}
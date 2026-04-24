@IsTest
public class TrainingDashboardControllerTest {
    @testSetup
    static void setup() {
        Employe__c employee = new Employe__c(
            Name = 'Ethan Training',
            Employee_ID__c = 'EMP-4001',
            Status__c = 'Actif',
            Department__c = 'Operations',
            Contract_Type__c = 'CDD'
        );
        insert employee;

        List<Training__c> trainings = new List<Training__c>{
            new Training__c(
                Name = 'Training A',
                Employee__c = employee.Id,
                Training_Type__c = 'Technical',
                Status__c = 'In Progress',
                Cost__c = 500,
                ROI__c = 10,
                Post_Score__c = 70,
                Start_Date__c = Date.today().addDays(-6),
                End_Date__c = Date.today().addDays(-4)
            ),
            new Training__c(
                Name = 'Training B',
                Employee__c = employee.Id,
                Training_Type__c = 'Leadership',
                Status__c = 'Completed',
                Cost__c = 800,
                ROI__c = 20,
                Post_Score__c = 85,
                Start_Date__c = Date.today().addDays(-12),
                End_Date__c = Date.today().addDays(-9)
            ),
            new Training__c(
                Name = 'Training C',
                Employee__c = employee.Id,
                Training_Type__c = 'Soft Skills',
                Status__c = 'Planned',
                Cost__c = 300,
                ROI__c = 5,
                Post_Score__c = 50,
                Start_Date__c = Date.today().addDays(3),
                End_Date__c = Date.today().addDays(5)
            )
        };
        insert trainings;
    }

    @IsTest
    static void testGetAllTrainings() {
        Test.startTest();
        List<Training__c> results = TrainingDashboardController.getAllTrainings();
        Test.stopTest();
        System.assertEquals(3, results.size(), 'Should return all trainings.');
    }

    @IsTest
    static void testGetTrainingStats() {
        Test.startTest();
        TrainingDashboardController.TrainingStats stats = TrainingDashboardController.getTrainingStats();
        Test.stopTest();

        System.assertEquals(1, stats.totalInProgress, 'Should count In Progress.');
        System.assertEquals(1, stats.totalCompleted, 'Should count Completed.');
        System.assertEquals(1, stats.totalPlanned, 'Should count Planned.');
        System.assert(stats.totalCost > 0, 'Should compute total cost.');
    }
}
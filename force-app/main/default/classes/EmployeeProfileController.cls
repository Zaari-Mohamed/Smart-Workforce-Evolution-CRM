public with sharing class EmployeeProfileController {
    @AuraEnabled(cacheable=true)
    public static Employe__c getEmployeeDetails(Id employeeId) {
        try {
            if (employeeId == null) {
                return null;
            }
            return [
                SELECT Id, Name, Employee_ID__c, Email__c, Department__c,
                       Job_Title__c, Job_Level__c, Job_Role__c, Age__c,
                       Start_Date__c, Contract_Type__c, Status__c,
                       Monthly_Income__c, Performance_Score__c,
                       Job_Satisfaction__c, Work_Life_Balance__c,
                       Tenure_Months__c, Years_at_Company__c,
                       Training_Count__c, Absence_Days_YTD__c,
                       Internal_Mobility_Requests__c, Manager_Support_Score__c,
                       Turnover_Risk__c, Skill_Match_Score__c, Departed__c,
                       Manager__c
                FROM Employe__c
                WHERE Id = :employeeId
                LIMIT 1
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to load employee details.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Skill_Inventory__c> getEmployeeSkills(Id employeeId) {
        try {
            if (employeeId == null) {
                return new List<Skill_Inventory__c>();
            }
            return [
                SELECT Id, Name, Employee__c, Skill_Category__c, Skill_Name__c,
                      Current_Level__c, Target_Level__c, Is_Critical__c,
                       Assessment_Source__c, Last_Assessed_Date__c
                FROM Skill_Inventory__c
                WHERE Employee__c = :employeeId
                ORDER BY Last_Assessed_Date__c DESC NULLS LAST
                LIMIT 500
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to load employee skills.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Evaluation__c> getEmployeeEvaluations(Id employeeId) {
        try {
            if (employeeId == null) {
                return new List<Evaluation__c>();
            }
            Map<String, Schema.SObjectField> fieldsMap = Evaluation__c.SObjectType.getDescribe().fields.getMap();
            List<String> selectFields = new List<String>{ 'Id', 'Name' };

            if (fieldsMap.containsKey('Evaluation_Date__c')) {
                selectFields.add('Evaluation_Date__c');
            }
            if (fieldsMap.containsKey('Evaluation_Type__c')) {
                selectFields.add('Evaluation_Type__c');
            }
            if (fieldsMap.containsKey('Overall_Score__c')) {
                selectFields.add('Overall_Score__c');
            }
            if (fieldsMap.containsKey('Promotion_Recommended__c')) {
                selectFields.add('Promotion_Recommended__c');
            }
            if (!selectFields.contains('CreatedDate')) {
                selectFields.add('CreatedDate');
            }

            String soql = 'SELECT ' + String.join(selectFields, ', ') + ' FROM Evaluation__c';
            if (fieldsMap.containsKey('Employee__c')) {
                soql += ' WHERE Employee__c = :employeeId';
            }
            if (fieldsMap.containsKey('Evaluation_Date__c')) {
                soql += ' ORDER BY Evaluation_Date__c DESC NULLS LAST';
            } else {
                soql += ' ORDER BY CreatedDate DESC';
            }
            soql += ' LIMIT 500';

            return Database.query(soql);
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to load employee evaluations.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Training__c> getEmployeeTrainings(Id employeeId) {
        try {
            if (employeeId == null) {
                return new List<Training__c>();
            }
            return [
                SELECT Id, Name, Employee__c, Training_Type__c, Status__c,
                       Cost__c, Pre_Score__c, Post_Score__c, ROI__c,
                       Start_Date__c, End_Date__c, Title__c
                FROM Training__c
                WHERE Employee__c = :employeeId
                ORDER BY Start_Date__c DESC NULLS LAST
                LIMIT 500
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to load employee trainings.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Recommendation__c> getEmployeeRecommendations(Id employeeId) {
        try {
            if (employeeId == null) {
                return new List<Recommendation__c>();
            }
            return [
                SELECT Id, Name, Employee__c, Recommendation_Type__c, Priority__c,
                       Status__c, AI_Confidence_Score__c, Reason__c,
                       Expected_Impact__c, Training__c, Expiration_Date__c
                FROM Recommendation__c
                WHERE Employee__c = :employeeId
                ORDER BY Expiration_Date__c DESC NULLS LAST
                LIMIT 500
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to load employee recommendations.');
        }
    }

    @AuraEnabled
    public static Recommendation__c acceptRecommendation(Id recommendationId) {
        try {
            if (recommendationId == null) {
                return null;
            }
            Recommendation__c rec = [
                SELECT Id, Status__c
                FROM Recommendation__c
                WHERE Id = :recommendationId
                LIMIT 1
            ];
            rec.Status__c = 'Accepted';
            update rec;
            return rec;
        } catch (Exception ex) {
            throw new AuraHandledException('Unable to accept recommendation.');
        }
    }
}
public class EmployeeScoreCalculator {

    // ------------------------------------------------
    // Méthode 1 : Calcul du score de performance
    // Pondération : technique 40%, comportemental 30%, objectifs 30%
    // ------------------------------------------------
    public static Decimal calculatePerformanceScore(Employe__c emp) {
        Decimal technical = emp.Technical_Score__c != null ? emp.Technical_Score__c : 0;
        Decimal behavioral = emp.Behavioral_Score__c != null ? emp.Behavioral_Score__c : 0;
        Decimal objectives = emp.Objectives_Achievement__c != null ? emp.Objectives_Achievement__c : 0;
        
        return (technical * 0.4) + (behavioral * 0.3) + (objectives * 0.3);
    }

    // ------------------------------------------------
    // Méthode 2 : Calcul du risque de turnover
    // Algorithme multicritères
    // Note : Einstein Discovery calcule aussi ce score
    // Cette méthode sert de calcul de secours
    // ------------------------------------------------
    public static Decimal calculateTurnoverRisk(Employe__c emp) {
        Decimal risk = 0;
        
        // Ancienneté sans promotion > 24 mois
        if (emp.Tenure_Months__c != null && emp.Tenure_Months__c > 24) {
            risk += 30;
        }
        
        // Score de satisfaction faible
        if (emp.Job_Satisfaction__c != null && emp.Job_Satisfaction__c < 5) {
            risk += 25;
        }
        
        // Demandes de mobilité sans suite
        if (emp.Internal_Mobility_Requests__c != null && emp.Internal_Mobility_Requests__c > 2) {
            risk += 20;
        }
        
        // Absences élevées
        if (emp.Absence_Days_YTD__c != null && emp.Absence_Days_YTD__c > 15) {
            risk += 15;
        }
        
        // Work life balance faible
        if (emp.Work_Life_Balance__c != null && emp.Work_Life_Balance__c < 5) {
            risk += 10;
        }
        
        return Math.min(risk, 100);
    }

    // ------------------------------------------------
    // Méthode 3 : Mise à jour du Skill Match Score
    // Requête SOQL sur Skill_Inventory__c
    // Note : Flow 1 calcule aussi ce score
    // Cette méthode permet un calcul programmatique
    // ------------------------------------------------
    public static Decimal updateSkillMatchScore(Id employeeId) {
        List<Skill_Inventory__c> skills = [
            SELECT Current_Level__c, Target_Level__c
            FROM Skill_Inventory__c
            WHERE Employee__c = :employeeId
        ];
        
        Decimal sumCurrent = 0;
        Decimal sumTarget = 0;
        
        for (Skill_Inventory__c s : skills) {
            sumCurrent += s.Current_Level__c != null ? s.Current_Level__c : 0;
            sumTarget += s.Target_Level__c != null ? s.Target_Level__c : 0;
        }
        
        return sumTarget > 0 ? (sumCurrent / sumTarget) * 100 : 0;
    }

    // ------------------------------------------------
    // Méthode 4 : Mise à jour des recommandations
    // Appelée depuis EmployeeTrigger
    // ------------------------------------------------
    public static void mettreAJourRecommandations(List<Id> employeeIds) {
        List<Employe__c> employes = [
            SELECT Id, Turnover_Risk__c, Job_Satisfaction__c,
                   Tenure_Months__c, Internal_Mobility_Requests__c,
                   Absence_Days_YTD__c, Work_Life_Balance__c
            FROM Employe__c
            WHERE Id IN :employeeIds
        ];
        
        List<Recommendation__c> recommendations = new List<Recommendation__c>();
        
        for (Employe__c emp : employes) {
            Decimal newRisk = calculateTurnoverRisk(emp);
            
            if (newRisk > 60) {
                Recommendation__c rec = new Recommendation__c();
                rec.Employee__c = emp.Id;
                rec.Recommendation_Type__c = 'Retention';
                rec.Priority__c = newRisk > 75 ? 'Critical' : 'High';
                rec.Status__c = 'New';
                rec.Reason__c = 'Risque de départ élevé - Score : ' + newRisk + '%';
                recommendations.add(rec);
            }
        }
        
        if (!recommendations.isEmpty()) {
            insert recommendations;
        }
    }
}
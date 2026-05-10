public class TrainingROICalculator {

    // ------------------------------------------------
    // Fonctionnalité 1 : Calcul du ROI d'une formation
    // ROI = ((Post_Score - Pre_Score) / Pre_Score) * 100
    // ------------------------------------------------
    public static Decimal calculateROI(Training__c training) {
        if (training.Pre_Score__c == null || training.Pre_Score__c == 0) {
            return 0;
        }
        
        Decimal preScore = training.Pre_Score__c;
        Decimal postScore = training.Post_Score__c != null ? training.Post_Score__c : 0;
        
        return ((postScore - preScore) / preScore) * 100;
    }

    // ------------------------------------------------
    // Fonctionnalité 2 : Mise à jour du ROI après completion
    // ------------------------------------------------
    public static void updateROIAfterCompletion(List<Training__c> trainings) {
        List<Training__c> toUpdate = new List<Training__c>();
        
        for (Training__c t : trainings) {
            if (t.Status__c == 'Completed' 
                && t.Pre_Score__c != null 
                && t.Post_Score__c != null) {
                    
                Decimal roi = calculateROI(t);
                t.ROI__c = roi;
                toUpdate.add(t);
            }
        }
        
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    // ------------------------------------------------
    // Fonctionnalité 3 : Agrégation ROI moyen par type de formation
    // Pour les dashboards
    // ------------------------------------------------
    public static Map<String, Decimal> calculateAverageROIByType() {
        Map<String, Decimal> roiByType = new Map<String, Decimal>();
        Map<String, Integer> countByType = new Map<String, Integer>();
        
        List<Training__c> trainings = [
            SELECT Training_Type__c, ROI__c
            FROM Training__c
            WHERE Status__c = 'Completed'
            AND ROI__c != null
        ];
        
        // Calculer la somme des ROI par type
        for (Training__c t : trainings) {
            String type = t.Training_Type__c;
            
            if (!roiByType.containsKey(type)) {
                roiByType.put(type, 0);
                countByType.put(type, 0);
            }
            
            roiByType.put(type, roiByType.get(type) + t.ROI__c);
            countByType.put(type, countByType.get(type) + 1);
        }
        
        // Calculer la moyenne par type
        for (String type : roiByType.keySet()) {
            Decimal moyenne = roiByType.get(type) / countByType.get(type);
            roiByType.put(type, moyenne);
        }
        
        return roiByType;
    }
}
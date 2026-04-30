trigger RecommendationTrigger on Recommendation__c (after insert) {

    // Collecter les IDs des employés via le champ Employee__c
    Set<Id> employeeIds = new Set<Id>();
    for (Recommendation__c rec : Trigger.new) {
        if (rec.Employee__c != null) {
            employeeIds.add(rec.Employee__c);
        }
    }

    // Récupérer les employés depuis l'objet Employe__c
    Map<Id, Employe__c> employeesMap = new Map<Id, Employe__c>(
        [SELECT Id, Name, Manager__c
         FROM Employe__c
         WHERE Id IN :employeeIds]
    );

    // Notification a envoyer 
    // À activer quand la partie Einstein sera terminée
    // -------------------------------------------------------
    /*
    List<FeedItem> chatterPosts = new List<FeedItem>();

    for (Recommendation__c rec : Trigger.new) {
        Employe__c emp = employeesMap.get(rec.Employee__c);

        if (emp != null) {
            FeedItem postEmploye = new FeedItem();
            postEmploye.ParentId = rec.Employee__c;
            postEmploye.Body = ' Nouvelle recommandation IA générée pour vous : '
                + rec.Recommendation_Type__c
                + ' | Priorité : ' + rec.Priority__c
                + ' | Confiance IA : ' + rec.AI_Confidence_Score__c + '%'
                + '\n Consultez votre profil pour plus de détails.';
            chatterPosts.add(postEmploye);

            if (emp.Manager__c != null) {
                FeedItem postManager = new FeedItem();
                postManager.ParentId = emp.Manager__c;
                postManager.Body = ' Une recommandation IA a été générée pour '
                    + emp.Name
                    + ' | Type : ' + rec.Recommendation_Type__c
                    + ' | Priorité : ' + rec.Priority__c
                    + '\n Action requise : consultez le profil de votre collaborateur.';
                chatterPosts.add(postManager);
            }
        }
    }

    if (!chatterPosts.isEmpty()) {
        insert chatterPosts;
    }
    */

    /*
    List<AI_Log__c> logs = new List<AI_Log__c>();

    for (Recommendation__c rec : Trigger.new) {

        Employe__c emp = employeesMap.get(rec.Employee__c);

        // Log IA
        AI_Log__c log = new AI_Log__c();
        log.Recommendation__c = rec.Id;
        log.Event_Type__c = 'Recommendation Generated';
        log.Recommendation_Type__c = rec.Recommendation_Type__c;
        log.AI_Confidence_Score__c = rec.AI_Confidence_Score__c;
        log.Priority__c = rec.Priority__c;
        log.Generated_Date__c = rec.Generated_Date__c;

        if (emp != null) {
            log.Description__c = 'Recommandation générée automatiquement par Einstein AI'
                + ' pour l\'employé : ' + emp.Name
                + ' | Type : ' + rec.Recommendation_Type__c;
        } else {
            log.Description__c = 'Recommandation générée automatiquement par Einstein AI'
                + ' | Type : ' + rec.Recommendation_Type__c;
        }

        logs.add(log);
    }

    if (!logs.isEmpty()) {
        insert logs;
    }
    */
}
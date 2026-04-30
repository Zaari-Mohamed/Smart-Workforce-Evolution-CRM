trigger EmployeeTrigger on Employe__c (before insert, before update, after update) {

    if (Trigger.isBefore) {
        for (Employe__c emp : Trigger.new) {
            
            if (emp.Email__c == null || emp.Email__c == '') {
                emp.addError('L\'email professionnel est obligatoire.');
            }
            if (emp.Department__c == null || emp.Department__c == '') {
                emp.addError('Le département est obligatoire.');
            }
            if (emp.Job_Title__c == null || emp.Job_Title__c == '') {
                emp.addError('L\'intitulé du poste est obligatoire.');
            }
            if (emp.Start_Date__c == null) {
                emp.addError('La date d\'entrée est obligatoire.');
            }
            if (emp.Contract_Type__c == null || emp.Contract_Type__c == '') {
                emp.addError('Le type de contrat est obligatoire.');
            }

            if (emp.Employee_ID__c != null) {
                emp.Employee_ID__c = emp.Employee_ID__C.toUpperCase().trim();
            }
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        
        List<Id> employeesARecalculer = new List<Id>();

        for (Employe__c emp : Trigger.new) {
            Employe__c ancien = Trigger.oldMap.get(emp.Id);

            if (emp.Turnover_Risk__c != ancien.Turnover_Risk__c) {
                employeesARecalculer.add(emp.Id);
            }
        }

        //A faire: décommenter quand EmployeeScoreCalculator sera créé
        //if (!employeesARecalculer.isEmpty()) {
        //    EmployeeScoreCalculator.mettreAJourRecommandations(employeesARecalculer);
        //}
    }
}
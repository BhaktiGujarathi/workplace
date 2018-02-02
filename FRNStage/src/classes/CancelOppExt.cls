global class CancelOppExt {

    webservice static string CancelOpp(Id oppId,String stage,String proName) {
        List<Insurance_Benefit__c> benefitUpdateList = new List<Insurance_Benefit__c>();
        Set<Id> insuranceIdSet = new Set<Id>();

        if(oppId != null){
            //if(proName == 'FRN - Admissions Coordinator (AC) Manager'){
                System.debug('inside if');
                Opportunity oppObj= [Select Id,StageName,Benefits_Status__c,Probability from Opportunity where ID=:oppId];
                Opportunity opp = new Opportunity();
                if(oppObj.Probability >=10 && oppObj.Probability <=100){
                    opp.StageName = 'Benefits Submitted';
                    opp.Benefits_Status__c = 'Benefits Submitted';
                    opp.Id = oppObj.Id;
                    update opp;

                    List<Patient_Insurance__c> piList = new List<Patient_Insurance__c>();
                    for(Patient_Insurance__c pi:[SELECT Id,VOB_status__c,Opportunity__c  FROM Patient_Insurance__c where Opportunity__c =:opp.id]){
                        if(pi.VOB_status__c != 	'VOB over 10 days') {
                            Patient_Insurance__c p = new Patient_Insurance__c();
                            p.Id = pi.Id;
                            p.VOB_status__c = 'Benefits Submitted';
                            piList.add(p);
                            insuranceIdSet.add(pi.Id);
                        }
                    }

                    List<Pay_Agreement_Worksheet__c> pawList = new List<Pay_Agreement_Worksheet__c>();
                    for(Pay_Agreement_Worksheet__c p:[SELECT Id,Status__c,Opportunity__c  FROM Pay_Agreement_Worksheet__c where Opportunity__c =:opp.id]){
                        Pay_Agreement_Worksheet__c paw = new Pay_Agreement_Worksheet__c();
                        paw.Id = p.Id;
                        paw.Status__c = 'Cancelled';
                        pawList.add(paw);
                    }

                    List<Quote> estimateList = new List<Quote>();
                    for(Quote e :[SELECT Id,Status__c,OpportunityId FROM Quote where OpportunityId =:opp.id]){
                        Quote est = new Quote();
                        est.Id = e.Id;
                        est.Status__c = 'Cancelled';
                        estimateList.add(est);
                    }

                    for(Insurance_Benefit__c benefitInstance : [SELECT Id,
                                                                         Disposition__c,
                                                                         Patient_Insurance__c
                                                                  FROM Insurance_Benefit__c
                                                                  WHERE Patient_Insurance__c IN :insuranceIdSet
                                                                  AND Disposition__c = 'Weekend / Weeknight / Holiday']) {
                          benefitInstance.Disposition__c = '';
                          benefitUpdateList.add(benefitInstance);
                    }

                    if(pawList.size() > 0){
                        update pawList;
                    }
                    if(piList.size() > 0){
                        update piList;
                    }
                    if(estimateList.size() > 0){
                        update estimateList;
                    }
                    if(!benefitUpdateList.isEmpty() && benefitUpdateList.size() > 0) {
                        update benefitUpdateList;
                    }
                }else{
                    return 'Request Denied : Opportunity Stage not valid';
                }
            //}
        }
        return null;
    }
}
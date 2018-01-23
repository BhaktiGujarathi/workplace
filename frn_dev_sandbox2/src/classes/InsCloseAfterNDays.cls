global class InsCloseAfterNDays implements Database.Batchable<sObject>{


        List<String> lstOppStage;

        global InsCloseAfterNDays()
        {
              //Batch Constructor

              lstOppStage = new List<String>();
              for(OpportunityStage oppStage : [SELECT MasterLabel,
                                                      IsActive,
                                                      IsClosed,
                                                      IsWon
                                                      FROM OpportunityStage
                                                              WHERE IsClosed = false
                                                                  AND IsActive = true])
              {
                    lstOppStage.add(oppStage.MasterLabel);
              }



        }

        // Start Method
        global Database.QueryLocator start(Database.BatchableContext BC)
        {

            date d = system.today().addDays(Integer.valueof(Label.InsCloseAfterNDays.trim()));
            system.debug('@@@@@@ '+database.query('SELECT id,Date_Benefits_Check_Completed__c,Opportunity__r.stageName FROM Patient_Insurance__c WHERE Date_Benefits_Check_Completed__c <= :d AND Opportunity__r.stageName IN: lstOppStage AND VOB_status__c != \'VOB over 10 days\''));
            return Database.getQueryLocator('SELECT id,Date_Benefits_Check_Completed__c,Opportunity__r.stageName , Opportunity__r.Step_Down__c FROM Patient_Insurance__c WHERE Date_Benefits_Check_Completed__c <= :d AND Opportunity__r.stageName IN: lstOppStage AND VOB_status__c != \'VOB over 10 days\' AND Opportunity__r.Step_Down__c = False');

        }

       // Execute Logic
       global void execute(Database.BatchableContext BC, List<sObject> scope)
       {
             Map<Id,Patient_Insurance__c> patMap = new Map<Id,Patient_Insurance__c>();
             Map<Id,Pay_Agreement_Worksheet__c> payMap = new Map<Id,Pay_Agreement_Worksheet__c>();
             Map<Id,Quote> qoteMap = new Map<Id,Quote>();

            //Updating Patient Insurance Record.
            for(Sobject s : scope)
            {
                Patient_Insurance__c patIns = (Patient_Insurance__c)s;
                patIns.VOB_status__c = 'VOB over 10 days';
                patMap.put(patIns.Id,patIns);

            }

            for(Pay_Agreement_Worksheet__c payAgree : [SELECT Status__c FROM Pay_Agreement_Worksheet__c WHERE Patient_Insurance__c =: patMap.keySet()])
            {
               payAgree.Status__c = 'Closed';
               payMap.put(payAgree.Id,payAgree);

            }

           for(Quote qote : [SELECT Status__c FROM Quote WHERE Pay_Agreement_Worksheet__c =: payMap.keySet()])
            {
               qote.Status__c = 'Closed';
               qoteMap.put(qote.Id,qote);

            }


           update patMap.values();
           update payMap.values();
           update qoteMap.values();


       }

       global void finish(Database.BatchableContext BC)
       {

       }
    }
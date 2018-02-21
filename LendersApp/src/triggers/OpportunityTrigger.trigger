trigger OpportunityTrigger on Opportunity (after insert, after update, before delete, before insert, before update) {

    public static Boolean alreadyDone = false; //Prevents wf rules to fire it twice
    public Map<Id, Opportunity> mapOpp;
    //public List<OpportunityValidationRule__c> validationRule;
    
    //if blank
    if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert) && CheckRecursive.runOnceForBefore()) {

        /*validationRule = [SELECT Activate__c, Default_Underwriting_Stage__c FROM OpportunityValidationRule__c LIMIT 1];
        
        if (trigger.isUpdate && validationRule!=null && validationRule[0].Activate__c) {

            Set<String> setStatus = new Set<String> {'Completed', 'Cancelled', 'Deferred','Canceled'};
            mapOpp = new  Map<Id, Opportunity>( [SELECT Id, Name, Underwriting_Stage__c, StageName, UnderwritingStage__c,
                        (SELECT Id FROM McaApp__Items_Needed__r WHERE McaApp__Status__c NOT IN: setStatus), 
                        (SELECT Id FROM Verifications__r WHERE Status__c NOT IN: setStatus),
                        (SELECT Id FROM Merchant_Interview_Questions__r WHERE Completed__c != true)
                        FROM Opportunity WHERE Id=: Trigger.newMap.keyset()] );
        }*/

        for (Opportunity opp : trigger.new) {

            if (Trigger.isUpdate) {

                OpportunityTriggerHandler.checkAssignmentRuleMemberForCapacity(trigger.new);

                if (opp.Verifications_Completed__c == null) {

                    opp.Verifications_Completed__c = 0;
                }

                if (opp.Verifications_Total__c == null) {

                    opp.Verifications_Total__c = 0;
                }

                if (opp.Interview_Completed_Count__c == null) {

                    opp.Interview_Completed_Count__c = 0;
                }

                if (opp.Interview_Total_Count__c == null) {

                    opp.Interview_Total_Count__c = 0;
                }

               /* //Validation to prevent Opportunity from update
                if (validationRule != null && validationRule[0].Activate__c) {
                
	                if (mapOpp.get(opp.Id).McaApp__Items_Needed__r.size() > 0 || mapOpp.get(opp.Id).Verifications__r.size() > 0 || 
	                                            mapOpp.get(opp.Id).Merchant_Interview_Questions__r.size() > 0) {
	                
	                	System.debug('aaa' + Trigger.oldMap.get(opp.Id).Underwriting_Stage__c + 'bbb' + opp.Underwriting_Stage__c + 'ccc' + validationRule[0].Default_Underwriting_Stage__c + 'ddd' + mapOpp.get(opp.Id).UnderwritingStage__c);
                        
                        if (Trigger.oldMap.get(opp.Id).Underwriting_Stage__c != null 
                            && Trigger.oldMap.get(opp.Id).Underwriting_Stage__c != opp.Underwriting_Stage__c 
                            && (opp.Underwriting_Stage__c != validationRule[0].Default_Underwriting_Stage__c
                            || mapOpp.get(opp.Id).UnderwritingStage__c != false)) {
                            
                        	System.debug('111111111111111111');
                            Trigger.newMap.get(opp.Id).addError('Please complete all open stips, verifications and merchant interview questions before moving to next stage.');
                                
                            
                        }
                       
                        if (opp.StageName == 'Funded') {
                       
                            Trigger.newMap.get(opp.Id).addError('Please complete all open stips, verifications and merchant interview questions before moving to next stage.');
                        }
                
                        if (Trigger.newMap.get(opp.Id).Underwriting_Stage__c == validationRule[0].Default_Underwriting_Stage__c
                        && mapOpp.get(opp.Id).UnderwritingStage__c == false) {
                        
                           opp.UnderwritingStage__c = true;
                        }      
	                }
                }*/
            }
            else {

                opp.Verifications_Completed__c = 0;
                opp.Verifications_Total__c = 0;
                opp.Interview_Completed_Count__c = 0;
                opp.Interview_Total_Count__c = 0;
            }
        }
    }

    else {

        if ((Trigger.isInsert || Trigger.isUpdate) && CheckRecursive.runOnceForAfter()) {
           
            String typeStr ='';
            Set<String> setStage = new Set<String>();
            List<Opportunity> lstDealToProcess = new List<Opportunity>();
            List<UWVerification__c> lstVeriToInsert = new List<UWVerification__c>();
            List<MerchantInterviewQuestion__c> lstQuestionToInsert = new List<MerchantInterviewQuestion__c>();
            List<McaApp__Stips__c> lstStipToInsert = new List<McaApp__Stips__c>();

            Map<String,List<VerificationMaster__c>> mapTypeVerification = new Map<String,List<VerificationMaster__c>>();
            Map<String,List<StipMaster__c>> mapTypeStip = new Map<String,List<StipMaster__c>>();
            Map<String,List<MerchantInterviewQMaster__c>> mapTypeQuestion = new Map<String,List<MerchantInterviewQMaster__c>>();

            //Get Verification record type by name
            Schema.DescribeSObjectResult sd = Schema.SObjectType.UWVerification__c;
            Map<String,Schema.RecordTypeInfo> rtVerMapByName = sd.getRecordTypeInfosByName();

            //To track existing verifications,stips and questions and avoid re-creation
            Map<Id,Set<Id>> mapExistingVer = new Map<Id,Set<Id>>();
            Map<Id,Set<Id>> mapExistingStip = new Map<Id,Set<Id>>();
            Map<Id,Set<Id>> mapExistingQues = new Map<Id,Set<Id>>();
            Set<Id> setDealId = new Set<Id>();


            //Collect all types of deal
            for (Opportunity opp : Trigger.New) {

                if ((Trigger.isInsert || Trigger.oldMap.get(opp.id).Underwriting_Stage__c != opp.Underwriting_Stage__c || Trigger.oldMap.get(opp.id).ProgramType__c != opp.ProgramType__c)) {
                    //&& (opp.Underwriting_Stage__c == 'Underwriting' || opp.Underwriting_Stage__c == 'PreQualification')) {

                    if (opp.ProgramType__c != null) {

                        for (String s : opp.ProgramType__c.split(';')) {

                            typeStr += s.trim() + ',';
                        }
                    }

                    if (opp.Underwriting_Stage__c != null) 
                        setStage.add(opp.Underwriting_Stage__c);
                    lstDealToProcess.add(opp);
                    setDealId.add(opp.id);

                    //Initialize maps
                    mapExistingVer.put(opp.id, new Set<Id>());
                    mapExistingStip.put(opp.id, new Set<Id>());
                    mapExistingQues.put(opp.id, new Set<Id>());
                }
            }

            if (typeStr != null) {

                typeStr = typeStr.removeEnd(',');
            }


            //Query all deals and fetch existing verification,stip, question master ids to avoid re-creation
            for (Opportunity opp : [SELECT (SELECT StipMaster__c FROM McaApp__Items_Needed__r),
                                           (SELECT Id, VerificationMaster__c, Sort_Order__c, Action_Link__c FROM Verifications__r),
                                           (SELECT Id,  MerchantInterviewQuestionMaster__c, Sort_Order__c FROM Merchant_Interview_Questions__r)
                                      FROM Opportunity WHERE Id IN :setDealId]) {

                for (UWVerification__c uwver : opp.Verifications__r) {

                    mapExistingVer.get(opp.id).add(uwver.VerificationMaster__c);
                }

                for (McaApp__Stips__c uwstip : opp.McaApp__Items_Needed__r) {

                    mapExistingStip.get(opp.id).add(uwstip.StipMaster__c);
                }

                for (MerchantInterviewQuestion__c uwQ : opp.Merchant_Interview_Questions__r) {

                    mapExistingQues.get(opp.id).add(uwQ.MerchantInterviewQuestionMaster__c);
                }
            }

            //Get respective type verification master records
            if (lstDealToProcess.size() > 0) {

                mapTypeVerification = DealTriggerUtility.getTypeVerification(typeStr,setStage);
            }

            //GET respective type Stip master records
            if (lstDealToProcess.size() > 0) {

                system.debug('#############'+typeStr+setStage);
                mapTypeStip = DealTriggerUtility.getTypeStip(typeStr,setStage);
            }

            //GET respective type question master records
            if (lstDealToProcess.size() > 0) {

                mapTypeQuestion = DealTriggerUtility.getTypeQuestion(typeStr, setStage);
            }

            //for deals with status UNDERWRITING/PreQualification
            for (Opportunity opp : lstDealToProcess) {

                if (opp.ProgramType__c != null) {

                    for (String dealType : opp.ProgramType__c.split(';')) {

                        if (mapTypeVerification.keyset().contains(dealType + '' + opp.Underwriting_Stage__c)) {

                            //Create verification records
                            for (VerificationMaster__c objVerMas : mapTypeVerification.get(dealType + '' + opp.Underwriting_Stage__c)) {


                                if ((objVerMas.Renewal__c || !opp.Renewal__c) && !mapExistingVer.get(opp.id).contains(objVerMas.id)) {

                                    //create new verification records
                                    UWVerification__c objVer = new UWVerification__c(
                                        Name = objVerMas.Name,
                                        Status__c = 'Pending',
                                        Notes__c = objVerMas.Notes__c,
                                        Opportunity__c = opp.id,
                                        Sort_Order__c = objVerMas.Sort_Order__c
                                        //Action_Link__c = objVerMas.Action_Link__c
                                    );


                                    objVer.stage__c = opp.Underwriting_Stage__c;
                                    objVer.VerificationMaster__c = objVerMas.id;

                                    //set record type id
                                    if (objVerMas.recordtype.Name != null && rtVerMapByName.keyset().contains(objVerMas.recordtype.Name)) {

                                        objVer.RecordTypeId = rtVerMapByName.get(objVerMas.recordtype.Name).getRecordTypeId();
                                    }

                                    mapExistingVer.get(opp.id).add(objVerMas.id);

                                    lstVeriToInsert.add(objVer);
                                }
                            }
                        }

                        System.debug('!!!!!!!!!!!!!!!!!!' + mapExistingStip);
                        
                        if (mapTypeStip.keyset().contains(dealType + '' + opp.Underwriting_Stage__c)) {

                            //Create stip records
                            for (StipMaster__c objStipMas : mapTypeStip.get(dealType + '' + opp.Underwriting_Stage__c)) {

                                if ((objStipMas.Renewal__c || !opp.Renewal__c || objStipMas.Add_to_all_Deals__c) && !mapExistingStip.get(opp.id).contains(objStipMas.id)) {

                                    McaApp__Stips__c objStip= new McaApp__Stips__c(
                                        Name = objStipMas.Name,
                                        McaApp__Status__c = 'Pending',
                                        Notes__c = objStipMas.Notes__c,
                                        McaApp__Opportunity__c = opp.id,
                                        Stage__c = opp.Underwriting_Stage__c,
                                        StipMaster__c = objStipMas.Id
                                    );

                                    lstStipToInsert.add(objStip);

                                    mapExistingStip.get(opp.id).add(objStipMas.id);
                                }
                            }
                        }

                        if (mapTypeStip.Keyset().contains('any')) {

                            for (StipMaster__c objStipMas : mapTypeStip.get('any')) {

                                if (objStipMas.Add_to_all_Deals__c && !mapExistingStip.get(opp.id).contains(objStipMas.id)) {

                                    McaApp__Stips__c objStip= new McaApp__Stips__c(
                                        Name = objStipMas.Name,
                                        McaApp__Status__c = 'Pending',
                                        Notes__c = objStipMas.Notes__c,
                                        McaApp__Opportunity__c = opp.id,
                                        Stage__c = opp.Underwriting_Stage__c,
                                        StipMaster__c = objStipMas.Id
                                    );

                                    lstStipToInsert.add(objStip);

                                    mapExistingStip.get(opp.id).add(objStipMas.id);
                                }
                            }
                        }

                        if (mapTypeQuestion.keyset().contains(dealType + '' + opp.Underwriting_Stage__c)) {

                            //Create Question records
                            for (MerchantInterviewQMaster__c objQMas : mapTypeQuestion.get(dealType + '' + opp.Underwriting_Stage__c)) {

                                if (objQMas.type__c.contains(dealType) && !mapExistingQues.get(opp.id).contains(objQMas.id)) {

                                    MerchantInterviewQuestion__c objQuestion = new MerchantInterviewQuestion__c(
                                        Category__c = objQMas.Category__c,
                                        Question__c = objQMas.Question__c,
                                        Opportunity__c = opp.Id,
                                        Sort_Order__c = objQMas.Sort_Order__c,
                                        MerchantInterviewQuestionMaster__c = objQMas.Id
                                    );

                                    lstQuestionToInsert.add(objQuestion);

                                    mapExistingQues.get(opp.id).add(objQMas.id);
                                }
                            }
                        }
                    }
                }

                else {

                    if (mapTypeVerification.keyset().contains(opp.Underwriting_Stage__c)) {

                            //Create verification records
                            for (VerificationMaster__c objVerMas : mapTypeVerification.get(opp.Underwriting_Stage__c)) {

                                if ((objVerMas.Renewal__c || !opp.Renewal__c) && !mapExistingVer.get(opp.id).contains(objVerMas.id)) {

                                    //create new verification record
                                    UWVerification__c objVer = new UWVerification__c(
                                        Name = objVerMas.Name,
                                        Status__c = 'Pending',
                                        Notes__c = objVerMas.Notes__c,
                                        Opportunity__c = opp.Id,
                                        Sort_Order__c = objVerMas.Sort_Order__c
                                    );

                                    objVer.stage__c = opp.Underwriting_Stage__c;
                                    objVer.VerificationMaster__c = objVerMas.Id;

                                    //set record type id
                                    if (objVerMas.recordtype.Name != null && rtVerMapByName.keyset().contains(objVerMas.recordtype.Name)) {

                                        objVer.RecordTypeId = rtVerMapByName.get(objVerMas.recordtype.Name).getRecordTypeId();
                                    }

                                    mapExistingVer.get(opp.Id).add(objVerMas.Id);

                                    lstVeriToInsert.add(objVer);
                                }
                            }
                        }

                        System.debug('000001111111111' + mapTypeStip + opp.Underwriting_Stage__c);

                        if (mapTypeStip.keyset().contains(opp.Underwriting_Stage__c)) {

                            //Create stip records
                            for (StipMaster__c objStipMas : mapTypeStip.get(opp.Underwriting_Stage__c)) {

                                if(objStipMas.Renewal__c || !opp.Renewal__c || objStipMas.Add_to_all_Deals__c && !mapExistingStip.get(opp.id).contains(objStipMas.id)) {

                                    McaApp__Stips__c objStip= new McaApp__Stips__c(
                                        Name = objStipMas.Name,
                                        McaApp__Status__c = 'Pending',
                                        Notes__c = objStipMas.Notes__c,
                                        McaApp__Opportunity__c = opp.Id,
                                        Stage__c = opp.Underwriting_Stage__c,
                                        StipMaster__c = objStipMas.Id
                                    );

                                    lstStipToInsert.add(objStip);
                                    System.debug('00000000000' + lstStipToInsert);
                                    mapExistingStip.get(opp.Id).add(objStipMas.Id);
                                }
                            }
                        }
                        if (mapTypeStip.Keyset().contains('any')) {

                            for (StipMaster__c objStipMas : mapTypeStip.get('any')) {

                                if (objStipMas.Add_to_all_Deals__c && !mapExistingStip.get(opp.id).contains(objStipMas.id)) {

                                    McaApp__Stips__c objStip= new McaApp__Stips__c(
                                        Name = objStipMas.Name,
                                        McaApp__Status__c = 'Pending',
                                        Notes__c = objStipMas.Notes__c,
                                        McaApp__Opportunity__c = opp.id,
                                        Stage__c = opp.Underwriting_Stage__c,
                                        StipMaster__c = objStipMas.Id
                                    );

                                    lstStipToInsert.add(objStip);

                                    mapExistingStip.get(opp.id).add(objStipMas.id);
                                }
                            }
                        }



                        if (mapTypeQuestion.keyset().contains(opp.Underwriting_Stage__c)) {

                            //Create Question records
                            for (MerchantInterviewQMaster__c objQMas : mapTypeQuestion.get(opp.Underwriting_Stage__c)) {

                                if (!mapExistingQues.get(opp.id).contains(objQMas.id)) {

                                    MerchantInterviewQuestion__c objQuestion = new MerchantInterviewQuestion__c(
                                        Category__c = objQMas.Category__c,
                                        Question__c = objQMas.Question__c,
                                        Opportunity__c = opp.Id,
                                        Sort_Order__c = objQMas.Sort_Order__c,
                                        MerchantInterviewQuestionMaster__c = objQMas.Id
                                    );

                                    lstQuestionToInsert.add(objQuestion);

                                    mapExistingQues.get(opp.id).add(objQMas.id);
                                }
                            }
                        }








                }
            }

            //insert verifications
            if (lstVeriToInsert.size() > 0) {

                insert lstVeriToInsert;
            }

            //insert stips
            if (lstStipToInsert.size() > 0) {

                insert lstStipToInsert;
            }

            //insert questions
            if (lstQuestionToInsert.size() > 0) {

                insert lstQuestionToInsert;
            }

            alreadyDone = true;

        }
        else if (trigger.isDelete) {

            Set<Id> dealIds = new Set<Id>();

            for (Opportunity deal : Trigger.old) {

                dealIds.add(deal.Id);
            }

            McaApp__Stips__c[] stips = [SELECT Id FROM McaApp__Stips__c WHERE McaApp__Opportunity__c IN :dealIds];

            if (!stips.isEmpty()) {

                delete stips;
            }

            UWVerification__c[] verifications = [SELECT Id FROM UWVerification__c WHERE Opportunity__c IN :dealIds];

            if (!verifications.isEmpty()) {

                delete verifications;
            }

            MerchantInterviewQuestion__c[] interviewQuestions = [SELECT Id FROM MerchantInterviewQuestion__c WHERE Opportunity__c IN :dealIds];

            if (!interviewQuestions.isEmpty()) {

                delete interviewQuestions;
            }

        }
    }


    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) && !System.isBatch() ) {

        Opportunity[] reassignOpportunities = new Opportunity[]{};

        for (Opportunity opportunity : Trigger.new) {

            if (opportunity.Reassign_Underwriter__c) {

                reassignOpportunities.add(opportunity);
            }
        }

        if (!reassignOpportunities.isEmpty()) {

            UnderwriterAssignmentBatch batch = new UnderwriterAssignmentBatch(reassignOpportunities);
            
            Database.executeBatch(batch, 1);
        }
    }
}
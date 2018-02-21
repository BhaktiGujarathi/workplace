trigger VerificationAfterInsertUpdate on UWVerification__c (after insert, after update) {

    public static Boolean isRunning = false;

    /*List<MerchantInterviewQuestion__c> lstQuestionsToInsert = new List<MerchantInterviewQuestion__c>();

    for (UWVerification__c uw : Trigger.new) {

        if (!uw.Is_WF_Firing_Trigger__c) {

            if (Trigger.isInsert && uw.interview__c) {

                MerchantInterviewQuestion__c ques = new MerchantInterviewQuestion__c(Question__c = uw.Notes__c,
                                                        Opportunity__c = uw.Opportunity__c, Verification__c = uw.id);

                lstQuestionsToInsert.add(ques);
            }

            if (Trigger.isUpdate && uw.interview__c && !Trigger.oldMap.get(uw.id).interview__c) {

                MerchantInterviewQuestion__c ques = new MerchantInterviewQuestion__c(Question__c = uw.Notes__c,
                                                        Opportunity__c = uw.Opportunity__c, Verification__c = uw.id);

                lstQuestionsToInsert.add(ques);
            }
        }
    }


    //insert flaged questions
    if (lstQuestionsToInsert.size() > 0) {

        insert lstQuestionsToInsert;
    }*/


    if (Trigger.isUpdate) {

        UWVerification__c[] verifications = new UWVerification__c[]{};

        for (UWVerification__c uw : Trigger.new) {

            if (uw.Is_WF_Firing_Trigger__c) {

                verifications.add(new UWVerification__c(Id = uw.Id, Is_WF_Firing_Trigger__c = false));
            }
        }

        if (!verifications.isEmpty() && !isRunning) {
            
            isRunning = true;
            update verifications;
            isRunning = false;
        }
    }
}
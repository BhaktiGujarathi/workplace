trigger StipAfterInsertUpdate on McaApp__Stips__c (after insert, after update) {

    public static Boolean isRunning = false;

    List<MerchantInterviewQuestion__c> lstQuestionsToInsert = new List<MerchantInterviewQuestion__c>();


    for (McaApp__Stips__c uw : Trigger.new) {

        if (!uw.Is_WF_Firing_Trigger__c) {

            if (Trigger.isInsert && uw.interview__c) {

                MerchantInterviewQuestion__c ques = new MerchantInterviewQuestion__c(Question__c = uw.Notes__c,
                                                        Opportunity__c = uw.McaApp__Opportunity__c, Stips__c = uw.id);

                lstQuestionsToInsert.add(ques);
        }

            if (Trigger.isUpdate && uw.interview__c && !Trigger.oldMap.get(uw.id).interview__c) {

                MerchantInterviewQuestion__c ques = new MerchantInterviewQuestion__c(Question__c = uw.Notes__c,
                                                        Opportunity__c = uw.McaApp__Opportunity__c, Stips__c = uw.id);

                lstQuestionsToInsert.add(ques);
            }
        }


    }

    //insert flaged questions
    if (lstQuestionsToInsert.size() > 0) {

        insert lstQuestionsToInsert;
    }


    if (Trigger.isUpdate) {

        McaApp__Stips__c[] stips = new McaApp__Stips__c[]{};

        for (McaApp__Stips__c uw : Trigger.new) {

            if (uw.Is_WF_Firing_Trigger__c) {

                stips.add(new McaApp__Stips__c(Id = uw.Id, Is_WF_Firing_Trigger__c = false));
            }
        }

        if (!stips.isEmpty() && !isRunning) {

            isRunning = true;
            update stips;
            isRunning = false;
        }
    }
}
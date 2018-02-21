global class GenerateOffers {

    webservice static String processDetails(String oppID) {

        system.debug('**************in the class');
        Set<Integer> setTerms;
        Set<String> setTypes = new Set<String>();
        String message='';

        List<McaApp__Offer__c> lstOffer = new List<McaApp__Offer__c>();

        Opportunity opp = [SELECT Id, Account.Name, Deal_Rating__c, McaApp__Gross_monthly_Sales__c,
                                Account.McaApp__Years_in_Business__c, McaApp__Credit_Score__c,
                                ProgramType__c, Terms_to_Offer__c, Max_Gross__c, Open_Positions__c,
                                McaApp__Funding_Amount__c, Name FROM Opportunity  WHERE Id = :oppId];

        system.debug('**************in the opp ' + opp);

        if (opp.ProgramType__c == null) {

            message += 'Program Type';

            system.debug('**** message *****' + message);
        }

        if (opp.Terms_to_Offer__c == null) {

            message += '\nTerm(s) To Offer';
            system.debug('**** message *****' + message);
        }

        //if(opp.McaApp__Funding_Amount__c == NULL)
             //message += '\nFunded $';

        if (opp.Deal_Rating__c == NULL) {

            message += '\nDeal Rating';
            system.debug('**** message *****' + message);
        }

        if (opp.Open_Positions__c == NULL) {

            message += '\nOpen Positions';
            system.debug('**** message *****' + message);
        }

        if (opp.McaApp__Credit_Score__c == NULL) {

            message += '\nCredit Score';
            system.debug('**** message *****' + message);
        }

        if (opp.McaApp__Gross_monthly_Sales__c == NULL) {

            message += '\nGross monthly Sales';
            system.debug('**** message *****' + message);
        }

        if (opp.Account.McaApp__Years_in_Business__c == NULL) {

            message += '\nAccount:Years in Business';
            system.debug('**** message *****' + message);

            system.debug('**** message length*****' + message.length());
        }

        if (message.length() <= 0) {

            system.debug('**** message *****' + message.length());

            McaApp__Submission__c[] submission = [SELECT Id, McaApp__Opportunity__c FROM McaApp__Submission__c WHERE McaApp__Opportunity__c = :opp.Id];

            system.debug('***submission ***********in the submission ' + submission );

            if (submission.isEmpty()) {

                DealDefaultFieldValue__c customSetting = DealDefaultFieldValue__c.getOrgDefaults();
                McaApp__Submission__c auxSubmission = new McaApp__Submission__c();
                auxSubmission.McaApp__Opportunity__c = opp.Id;
                auxSubmission.McaApp__Funder__c = customSetting.Account_Id__c;
                auxSubmission.McaApp__Program__c = customSetting.Bank_Program_Id__c;

                insert auxSubmission;
                submission.add(auxSubmission);
            }
            //split terms and create set for query
            if (opp.Terms_to_Offer__c != null) {

                setTerms = new Set<Integer>();

                for (String i : opp.Terms_to_Offer__c.split(';')) {

                    setTerms.add(Integer.valueOf(i.trim()));
                }
            }
        //split deal types  and create set for query
            if (opp.ProgramType__c != null) {

                for (String i : opp.ProgramType__c.split(';')) {

                    setTypes.add(i.trim());
                }
            }

            List<ProgramMaster__c> lstProgramMaster = new List<ProgramMaster__c>();

            String query = 'SELECT Id, Name, DealScore__c, Term__c, Program_Type__c, BuyRateNew__c, Upfront_Fee_Percentage__c,' +
                            'Upfront_Fees__c, Min_Credit_Score__c, Min_Monthly_Gross_Sales__c, Min_Time_in_business__c,' +
                            'Max_Gross__c, Max_Open_Positions__c, Min_Offer_Amount__c FROM ProgramMaster__c WHERE Active__c = true ';

            query += (setTypes != NULL && setTypes.size() > 0) ? ' AND (Program_Type__c IN : setTypes OR Program_Type__c=NULL)' : '';
            query += (setTerms != NULL && setTerms.size() > 0) ? ' AND (Term__c IN : setTerms OR Term__c=NULL)' : '';
            //query += opp.McaApp__Funding_Amount__c != NULL?' AND Min_Offer_Amount__c<='+opp.McaApp__Funding_Amount__c:'';
            query += opp.Deal_Rating__c != NULL ? ' AND DealScore__c INCLUDES (\'' + opp.Deal_Rating__c + '\')' : '';
            //system.debug('22222222222'+setOverrideFilter);
            //if(!setOverrideFilter){
            query += opp.Open_Positions__c != NULL ? ' AND ( Max_Open_Positions__c>=' + opp.Open_Positions__c + ' OR Max_Open_Positions__c=NULL)' : '';
            query += opp.McaApp__Credit_Score__c != NULL ? ' AND (Min_Credit_Score__c<=' +  opp.McaApp__Credit_Score__c + ' OR Min_Credit_Score__c=NULL)' : '';
            query += opp.McaApp__Gross_monthly_Sales__c != NULL ? ' AND (Min_Monthly_Gross_Sales__c<=' +  opp.McaApp__Gross_monthly_Sales__c + ' OR Min_Monthly_Gross_Sales__c=NULL)' : '';
            query += opp.Account.McaApp__Years_in_Business__c != NULL ? ' AND (Min_Time_in_business__c<=' + opp.Account.McaApp__Years_in_Business__c + ' OR Min_Time_in_business__c=NULL)' : '';
            //}
            query += ' order by name';

            system.debug('11111 query 111111111' + query);

            lstProgramMaster = database.query(query);
            system.debug('22222222222' + lstProgramMaster);

            for (ProgramMaster__c objProgram : lstProgramMaster) {

                McaApp__Offer__c objOffer = new McaApp__Offer__c(McaApp__Term_Months__c = Integer.valueOf(objProgram.Term__c), McaApp__Rate__c = objProgram.BuyRateNew__c,
                                            McaApp__Deal_Type__c = objProgram.Program_Type__c, Orig_Fee_Percentage__c = objProgram.Upfront_Fee_Percentage__c,
                                            Orig_Fee__c = objProgram.Upfront_Fees__c,
                                            McaApp__Opportunity__c = opp.Id, McaApp__Submission__c = submission[0].Id);//, McaApp__Submission__c = submission[0].Id);

                if (objProgram.Max_Gross__c != null) {

                    objOffer.Max_Gross__c = objProgram.Max_Gross__c;
                    lstOffer.add(objOffer);
                }
                else {

                    objOffer.Max_Gross__c = opp.Max_Gross__c;
                    lstOffer.add(objOffer);
                }
            }

            insert lstOffer;
            system.debug('333333333333'+lstOffer);

            if (lstOffer != NULL && lstOffer.size() > 0) {

                message = 'Offers are generated successfully.';
            }
            else {

                message = 'Criteria not matches.';
            }

            return message;
        }
        else {

            return 'Please fill below information:\n' + message;
        }
    }
}
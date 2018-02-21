/*
 *
 * Narrative
 * As a user, I need to know the count of leads per agent, so that I can calculate his total workload.
 * 
 * Context
 * Refer to attachment in BFI-242.
 * 
 * Acceptance Criteria
 * Create a trigger / batch / etc. that will automatically update the Lead Count field depending on the Count_Against_Pipeline__c formula checkbox as per #7 - #11.
 *
 */
public class UpdateOpportunityCount{
    public static boolean firstRun = true; 

    /*
     *
     *  12. When an Opportunity is created with a given Opportunity Stage,
     *      the Count of that Stage under the Category column on the Opportunity Owner’s Sales Rep Scorecard record will increase by 1.
     *      The Total Work columns will automatically recalculate.
     *
     */
    public static void incrementOpportunityCountForNewLeadsOnScorecard(List<Opportunity> newOpportunities){
        if(!newOpportunities.isEmpty() && newOpportunities != null){
            List<Sales_Rep_Report_Card__c> scorecardsToUpdate = new List<Sales_Rep_Report_Card__c>();
            List<String> ownerIdsList = new List<String>();
            Map<String,AWDynamicCategories__c>  mapOfCustSet = new Map<String,AWDynamicCategories__c>();

            for(Opportunity currentOpportunity : newOpportunities){
                ownerIdsList.add(currentOpportunity.OwnerId);
            }

            Map<String, Schema.SObjectField> scorecardsFieldsMap = Schema.SObjectType.Sales_Rep_Report_Card__c.fields.getMap();

            String query = 'select ';

            Set<String> fieldsSet = scorecardsFieldsMap.keySet();

            List<String> fieldsList = new List<String>(fieldsSet);

            Integer index = 1;
        
            for(Schema.SObjectField fld: scorecardsFieldsMap.values()){
                if(index < fieldsSet.size()){
                    query += fld.getDescribe().getName() + ',';
                    index++;
                }else{
                    query += fld.getDescribe().getName();
                }
            }

            query += ' from Sales_Rep_Report_Card__c where Sales_Rep__c IN :ownerIdsList';

            List<Sales_Rep_Report_Card__c> scorecardsForThisOpportunities = new List<Sales_Rep_Report_Card__c>();

            System.debug('\n\n###: ' + query);

            scorecardsForThisOpportunities = (Sales_Rep_Report_Card__c[]) Database.query(query);

            Map<Id, Sales_Rep_Report_Card__c> scorecardsMap = new Map<Id, Sales_Rep_Report_Card__c>();

            for(Sales_Rep_Report_Card__c scorecard : scorecardsForThisOpportunities){
                scorecardsMap.put(scorecard.Sales_Rep__c, scorecard);               
            }

            List<AWDynamicCategories__c> agentWorkLoadDynamicCategories = new List<AWDynamicCategories__c>();

            agentWorkLoadDynamicCategories = [select name,Count__c,Average_Min__c,Total_Work_Min__c,Total_Work_Hours__c,order__c from AWDynamicCategories__c order by order__c];
        
            //Get all the categories dynamically
            for(AWDynamicCategories__c scCust : agentWorkLoadDynamicCategories){
            
                mapOfCustSet.put(scCust.name,scCust);            
            }


            for(Opportunity currentOpportunity : newOpportunities){

                //If we have a scorecard for that user.
                if(scorecardsMap.containsKey(currentOpportunity.OwnerId)){

                    //Grab the scorecard for the user.
                    Sales_Rep_Report_Card__c scorecard = scorecardsMap.get(currentOpportunity.OwnerId);

                    // If there is a value in the Custom Setting for such stage.
                    if(mapOfCustSet.containsKey(currentOpportunity.StageName)){
                        AWDynamicCategories__c scCust = mapOfCustSet.get(currentOpportunity.StageName);

                        //Get the value for the count corresponding to the stage of the Opportunity
                        Integer count = Integer.valueOf(scorecard.get(scCust.Count__c));

                        //Increment the count value for the stage of the Opportunity.
                        count++;

                        //Add the new count value to the scorecard 
                        scorecard.put(scCust.Count__c,count);

                        //Add our current scorecard to the list to be updated later.
                        scorecardsToUpdate.add(scorecard);
                    }
                }
            }

            //Update all of the scorecards with their new values.
            update scorecardsToUpdate;
        }
    }

    /*
     * 13.  When an Opportunity Stage changes, the Count of the new Stage under the Category column on the Opportunity Owner’s Sales Rep Scorecard record will increase by 1.
     *      The Count of the old Stage under the Category column on the Opportunity Owner’s Sales Rep Scorecard record will decrease by 1. 
     *      The Total Work columns will automatically recalculate.
     *
     */
    public static void updateScorecardsForChangedOpportunityOwners(List<Opportunity> newOpportunities, List<Opportunity> oldOpportunities){
        if(!newOpportunities.isEmpty() && !oldOpportunities.isEmpty() && newOpportunities != null && oldOpportunities != null){
            List<String> newOwnersIdsList = new List<String>();
            List<String> oldOwnersIdsList = new List<String>();
            Map<Id, Sales_Rep_Report_Card__c>   scorecardsToUpdate = new Map<id,Sales_Rep_Report_Card__c>();
            Map<String,AWDynamicCategories__c>  mapOfCustSet = new Map<String,AWDynamicCategories__c>();

            for(Opportunity currentOpportunity : newOpportunities){
                newOwnersIdsList.add(currentOpportunity.OwnerId);
            }

            for(Opportunity currentOpportunity : oldOpportunities){
                oldOwnersIdsList.add(currentOpportunity.OwnerId);
            }       

            Map<String, Schema.SObjectField> scorecardsFieldsMap = Schema.SObjectType.Sales_Rep_Report_Card__c.fields.getMap();

            String queryNew = 'select ';
            String queryOld = 'select ';

            Set<String> fieldsSet = scorecardsFieldsMap.keySet();

            List<String> fieldsList = new List<String>(fieldsSet);

            Integer index = 1;
        
            for(Schema.SObjectField fld: scorecardsFieldsMap.values()){
                if(index < fieldsSet.size()){
                    queryNew += fld.getDescribe().getName() + ',';
                    queryOld += fld.getDescribe().getName() + ',';
                    index++;
                }else{
                    queryNew += fld.getDescribe().getName();
                    queryOld += fld.getDescribe().getName();
                }
            }

            queryNew += ' from Sales_Rep_Report_Card__c where Sales_Rep__c IN :newOwnersIdsList';
            queryOld += ' from Sales_Rep_Report_Card__c where Sales_Rep__c IN :oldOwnersIdsList';

            List<Sales_Rep_Report_Card__c> scorecardsForNewOpportunities = new List<Sales_Rep_Report_Card__c>();
            List<Sales_Rep_Report_Card__c> scorecardsForOldOpportunities = new List<Sales_Rep_Report_Card__c>();

            scorecardsForNewOpportunities = (Sales_Rep_Report_Card__c[]) Database.query(queryNew);
            scorecardsForOldOpportunities = (Sales_Rep_Report_Card__c[]) Database.query(queryOld);

            if(scorecardsForNewOpportunities != null && !scorecardsForNewOpportunities.isEmpty()){
                Map<Id, Sales_Rep_Report_Card__c> scorecardsMapNew = new Map<Id, Sales_Rep_Report_Card__c>();

                for(Sales_Rep_Report_Card__c scorecard : scorecardsForNewOpportunities){
                    scorecardsMapNew.put(scorecard.Sales_Rep__c, scorecard);                
                }

                List<AWDynamicCategories__c> agentWorkLoadDynamicCategories = new List<AWDynamicCategories__c>();

                agentWorkLoadDynamicCategories = [select name,Count__c,Average_Min__c,Total_Work_Min__c,Total_Work_Hours__c,order__c from AWDynamicCategories__c order by order__c];
        
                //Get all the categories dynamically
                for(AWDynamicCategories__c scCust : agentWorkLoadDynamicCategories){
            
                    mapOfCustSet.put(scCust.name,scCust);            
                }


                for(Opportunity currentOpportunity : newOpportunities){

                    //If we have a scorecard for that user.
                    if(scorecardsMapNew.containsKey(currentOpportunity.OwnerId)){

                        //Grab the scorecard for the user.
                        Sales_Rep_Report_Card__c scorecard = scorecardsMapNew.get(currentOpportunity.OwnerId);

                        // If there is a value in the Custom Setting for such stage.
                        if(mapOfCustSet.containsKey(currentOpportunity.StageName)){
                            AWDynamicCategories__c scCust = mapOfCustSet.get(currentOpportunity.StageName);

                            //Get the value for the count corresponding to the stage of the Opportunity
                            Integer count = Integer.valueOf(scorecard.get(scCust.Count__c));

                            //Increment the count value for the stage of the Opportunity.
                                count++;
                           

                            //Add the new count value to the scorecard 
                            scorecard.put(scCust.Count__c,count);

                            //Add our current scorecard to the map to be updated later.
                            if(!scorecardsToUpdate.containsKey(scorecard.id)){
                                scorecardsToUpdate.put(scorecard.id,scorecard);
                            }
                        }
                    }
                }
            }


            if(scorecardsForOldOpportunities != null && !scorecardsForOldOpportunities.isEmpty()){
                Map<Id, Sales_Rep_Report_Card__c> scorecardsMapOld = new Map<Id, Sales_Rep_Report_Card__c>();

                for(Sales_Rep_Report_Card__c scorecard : scorecardsForOldOpportunities){
                    scorecardsMapOld.put(scorecard.Sales_Rep__c, scorecard);                
                }

                List<AWDynamicCategories__c> agentWorkLoadDynamicCategories = new List<AWDynamicCategories__c>();

                agentWorkLoadDynamicCategories = [select name,Count__c,Average_Min__c,Total_Work_Min__c,Total_Work_Hours__c,order__c from AWDynamicCategories__c order by order__c];
        
                //Get all the categories dynamically
                for(AWDynamicCategories__c scCust : agentWorkLoadDynamicCategories){
            
                    mapOfCustSet.put(scCust.name,scCust);            
                }


                for(Opportunity currentOpportunity : oldOpportunities){

                    //If we have a scorecard for that user.
                    if(scorecardsMapOld.containsKey(currentOpportunity.OwnerId)){

                        //Grab the scorecard for the user.
                        Sales_Rep_Report_Card__c scorecard = scorecardsMapOld.get(currentOpportunity.OwnerId);

                        // If there is a value in the Custom Setting for such stage.
                        if(mapOfCustSet.containsKey(currentOpportunity.StageName)){
                            AWDynamicCategories__c scCust = mapOfCustSet.get(currentOpportunity.StageName);

                            // Get the value for the count corresponding to the stage of the Opportunity
                            Integer count = Integer.valueOf(scorecard.get(scCust.Count__c));

                            // This shouldn't actually happen, but checking just in case.
                            if(count > 0){
                                // Decrease the count value for the stage of the Opportunity.
                                count--;                                
                            }


                            //Add the new count value to the scorecard 
                            scorecard.put(scCust.Count__c,count);

                            //Add our current scorecard to the list to be updated later.
                            if(!scorecardsToUpdate.containsKey(scorecard.id)){
                                scorecardsToUpdate.put(scorecard.id,scorecard);
                            }
                        }
                    }
                }
            }

            update scorecardsToUpdate.values();
        }
    }


     /*
      *
      * 14. When an Opportunity Owner changes, the Count of the Stage under the Category column on the new Opportunity Owner’s Sales Rep Scorecard record will increase by 1.
      * The Count of the Stage under the Category column on the old Opportunity Owner’s Sales Rep Scorecard record will decrease by 1.
      * The Total Work columns will automatically recalculate.
      *
      */
    public static void updateScorecardsForChangedOpportunityStage(List<Opportunity> newOpportunities, List<Opportunity> oldOpportunities){
        if(!newOpportunities.isEmpty() && !oldOpportunities.isEmpty() && newOpportunities != null && oldOpportunities != null){
            List<String> ownersIdsList = new List<String>();
            Map<Id, Sales_Rep_Report_Card__c> scorecardsToUpdate = new Map<id,Sales_Rep_Report_Card__c>();
            Map<String,AWDynamicCategories__c>  mapOfCustSet = new Map<String,AWDynamicCategories__c>();

            for(Opportunity currentOpportunity : newOpportunities){
                ownersIdsList.add(currentOpportunity.OwnerId);
            }       


            Map<String, Schema.SObjectField> scorecardsFieldsMap = Schema.SObjectType.Sales_Rep_Report_Card__c.fields.getMap();

            String query = 'select ';

            Set<String> fieldsSet = scorecardsFieldsMap.keySet();

            List<String> fieldsList = new List<String>(fieldsSet);

            Integer index = 1;
        
            for(Schema.SObjectField fld: scorecardsFieldsMap.values()){
                if(index < fieldsSet.size()){
                    query += fld.getDescribe().getName() + ',';
                    index++;
                }else{
                    query += fld.getDescribe().getName();
                }
            }

            query += ' from Sales_Rep_Report_Card__c where Sales_Rep__c IN :ownersIdsList';

            List<Sales_Rep_Report_Card__c> scorecardsForOpportunities = new List<Sales_Rep_Report_Card__c>();

            scorecardsForOpportunities = (Sales_Rep_Report_Card__c[]) Database.query(query);

            if(scorecardsForOpportunities != null && !scorecardsForOpportunities.isEmpty()){
                Map<Id, Sales_Rep_Report_Card__c> scorecardsMap = new Map<Id, Sales_Rep_Report_Card__c>();

                for(Sales_Rep_Report_Card__c scorecard : scorecardsForOpportunities){
                    scorecardsMap.put(scorecard.Sales_Rep__c, scorecard);               
                }

                List<AWDynamicCategories__c> agentWorkLoadDynamicCategories = new List<AWDynamicCategories__c>();

                agentWorkLoadDynamicCategories = [select name,Count__c,Average_Min__c,Total_Work_Min__c,Total_Work_Hours__c,order__c from AWDynamicCategories__c order by order__c];
        
                //Get all the categories dynamically
                for(AWDynamicCategories__c scCust : agentWorkLoadDynamicCategories){
            
                    mapOfCustSet.put(scCust.name,scCust);            
                }


                for(Opportunity currentOpportunity : newOpportunities){

                    //If we have a scorecard for that user.
                    if(scorecardsMap.containsKey(currentOpportunity.OwnerId)){

                        //Grab the scorecard for the user.
                        Sales_Rep_Report_Card__c scorecard = scorecardsMap.get(currentOpportunity.OwnerId);

                        // If there is a value in the Custom Setting for such stage.
                        if(mapOfCustSet.containsKey(currentOpportunity.StageName)){
                            AWDynamicCategories__c scCust = mapOfCustSet.get(currentOpportunity.StageName);

                            //Get the value for the count corresponding to the stage of the Opportunity
                            Integer count = Integer.valueOf(scorecard.get(scCust.Count__c));
                            
                            if (count == null) {
                                count = 0;
                            }
                            //Increment the count value for the stage of the Opportunity.
                            count++;

                            //Add the new count value to the scorecard 
                            scorecard.put(scCust.Count__c,count);

                            //Add our current scorecard to the map to be updated later.
                            if(!scorecardsToUpdate.containsKey(scorecard.id)){
                                scorecardsToUpdate.put(scorecard.id,scorecard);
                            }
                        }
                    }
                }

                for(Opportunity currentOpportunity : oldOpportunities){

                    //If we have a scorecard for that user.
                    if(scorecardsMap.containsKey(currentOpportunity.OwnerId)){

                        //Grab the scorecard for the user.
                        Sales_Rep_Report_Card__c scorecard = scorecardsMap.get(currentOpportunity.OwnerId);

                        // If there is a value in the Custom Setting for such stage.
                        if(mapOfCustSet.containsKey(currentOpportunity.StageName)){
                            AWDynamicCategories__c scCust = mapOfCustSet.get(currentOpportunity.StageName);

                            // Get the value for the count corresponding to the stage of the Opportunity
                            Integer count = Integer.valueOf(scorecard.get(scCust.Count__c));

                            // This shouldn't actually happen, but checking just in case.
                            if(count > 0){
                                // Decrease the count value for the stage of the Opportunity.
                                count--;                                
                            }


                            //Add the new count value to the scorecard 
                            scorecard.put(scCust.Count__c,count);

                            //Add our current scorecard to the list to be updated later.
                            if(!scorecardsToUpdate.containsKey(scorecard.id)){
                                scorecardsToUpdate.put(scorecard.id,scorecard);
                            }
                        }
                    }
                }
            }

            update scorecardsToUpdate.values();
        }
    }

    /*
     *
     * 15.  When an Opportunity is deleted, the Count of the Opportunity’s Stage before deletion under the Category column on the Opportunity Owner’s Sales Rep Scorecard record will decrease by 1.
     *      The Total Work columns will automatically recalculate.
     *
     */
    public static void updateScorecardsForDeletedOpportunities(List<Opportunity> deletedOpportunities){
        if(!deletedOpportunities.isEmpty() && deletedOpportunities != null){
            List<String> ownerIdsList = new List<String>();
            List<Sales_Rep_Report_Card__c> scorecardsToUpdate = new List<Sales_Rep_Report_Card__c>();
            Map<String,AWDynamicCategories__c>  mapOfCustSet = new Map<String,AWDynamicCategories__c>();

            for(Opportunity currentOpportunity : deletedOpportunities){
                ownerIdsList.add(currentOpportunity.OwnerId);
            }

            Map<String, Schema.SObjectField> scorecardsFieldsMap = Schema.SObjectType.Sales_Rep_Report_Card__c.fields.getMap();

            String query = 'select ';

            Set<String> fieldsSet = scorecardsFieldsMap.keySet();

            List<String> fieldsList = new List<String>(fieldsSet);

            Integer index = 1;
        
            for(Schema.SObjectField fld: scorecardsFieldsMap.values()){
                if(index < fieldsSet.size()){
                    query += fld.getDescribe().getName() + ',';
                    index++;
                }else{
                    query += fld.getDescribe().getName();
                }
            }

            query += ' from Sales_Rep_Report_Card__c where Sales_Rep__c IN :ownerIdsList';

            List<Sales_Rep_Report_Card__c> scorecardsForThisOpportunities = new List<Sales_Rep_Report_Card__c>();

            scorecardsForThisOpportunities = (Sales_Rep_Report_Card__c[]) Database.query(query);

            if(scorecardsForThisOpportunities != null && !scorecardsForThisOpportunities.isEmpty()){
                Map<Id, Sales_Rep_Report_Card__c> scorecardsMap = new Map<Id, Sales_Rep_Report_Card__c>();

                for(Sales_Rep_Report_Card__c scorecard : scorecardsForThisOpportunities){
                    scorecardsMap.put(scorecard.Sales_Rep__c, scorecard);               
                }

                List<AWDynamicCategories__c> agentWorkLoadDynamicCategories = new List<AWDynamicCategories__c>();

                agentWorkLoadDynamicCategories = [select name,Count__c,Average_Min__c,Total_Work_Min__c,Total_Work_Hours__c,order__c from AWDynamicCategories__c order by order__c];
        
                //Get all the categories dynamically
                for(AWDynamicCategories__c scCust : agentWorkLoadDynamicCategories){
            
                    mapOfCustSet.put(scCust.name,scCust);            
                }

                for(Opportunity currentOpportunity : deletedOpportunities){

                    //If we have a scorecard for that user.
                    if(scorecardsMap.containsKey(currentOpportunity.OwnerId)){

                        //Grab the scorecard for the user.
                        Sales_Rep_Report_Card__c scorecard = scorecardsMap.get(currentOpportunity.OwnerId);

                        // If there is a value in the Custom Setting for such stage.
                        if(mapOfCustSet.containsKey(currentOpportunity.StageName)){
                            AWDynamicCategories__c scCust = mapOfCustSet.get(currentOpportunity.StageName);

                            // Get the value for the count corresponding to the stage of the Opportunity
                            Integer count = Integer.valueOf(scorecard.get(scCust.Count__c));

                            // This shouldn't actually happen, but checking just in case.
                            if(count > 0){
                                // Decrease the count value for the stage of the Opportunity.
                                count--;
                            }


                            //Add the new count value to the scorecard 
                            scorecard.put(scCust.Count__c,count);

                            //Add our current scorecard to the list to be updated later.
                            scorecardsToUpdate.add(scorecard);
                        }
                    }
                }

                update scorecardsToUpdate;              
            }
        }
    }   
}
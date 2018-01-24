/*

Created by:Srikanth Pinnamaneni

*/
global class MCAExtensionCommissionEngine implements McaApp.MCAExtensionInterface_version {
    
    public static string QueryString;
    
    
    /* Method being called from CreateContractcontroller from calcuating commission
    for respective Commission rules using entry Criteria's on various sObjects
    Param : opportunity Id
    Return : List of payable records inserted.
    */
    
    global static List < McaApp__Payable__c > commissioncal(id oppid)
    {
        
        
        Set < Id > Accid = new Set < Id > ();
        Set < Id > secondAccid = new Set < Id > ();
        Set < Id > opptyTeamIds = new Set < Id > ();
        Set < Id > userids = new Set < Id > ();
        Set < ID > groupIdsForPublicGrp = new  Set < ID >();
        List < McaApp__Payable__c > payableList = new list < McaApp__Payable__c > ();
        List < McaApp__Payable__c > payableListInternal = new list < McaApp__Payable__c > ();
        List < McaApp__Payable__c > payableListExternal = new list < McaApp__Payable__c > ();
        Map < Id, boolean > accbooleanMap = new map < Id, boolean > ();
        Map < String, Schema.SObjectType > gd = Schema.getGlobalDescribe();
        Boolean Accountspopulated = false;
        Boolean isIsoAccount = false;
        Boolean canCurrentUserCallCE = false;
        
        
        //Getting Queue name, Which has public group.
        // List<Group> listGroup = [Select id,type from Group where name = 'CEPayableCreation' AND type='Queue' limit 1];
        List<Group> listGroup = database.query('Select id,type from Group where name = \''+Label.CEPayableCreationLabel+'\' AND type=\'Queue\' limit 1');
        
        if(listGroup != null && listGroup.size() > 0)
        {
             //fetching the dummy record with name CEPayableCreation and grp owner CEPayableCreation
             //List<MCACE__CEPayableCreation__c> listCEPayableCreation = [SELECT id FROM MCACE__CEPayableCreation__c WHERE name = 'CEPayableCreation' AND ownerID =: listGroup[0].id limit 1];
              List<MCACE__CEPayableCreation__c> listCEPayableCreation = database.query('SELECT id FROM MCACE__CEPayableCreation__c WHERE name = \''+Label.CEPayableCreationLabel+'\' AND ownerID =\''+listGroup[0].id+'\' limit 1');
              if(listCEPayableCreation != null && listCEPayableCreation.size() > 0)
              {
                   list<UserRecordAccess> listUserRecordAccess = new list<UserRecordAccess>();
                   listUserRecordAccess = [SELECT  RecordId,
                                                   HasReadAccess,
                                                   HasEditAccess,
                                                   HasDeleteAccess
                                            FROM   UserRecordAccess
                                            WHERE UserId = :UserInfo.getUserId() AND
                                                  RecordId =: listCEPayableCreation[0].id];
                                                  
                   if(listUserRecordAccess != Null && listUserRecordAccess.size() > 0 && listUserRecordAccess[0].HasReadAccess)
                   {
                      canCurrentUserCallCE = listUserRecordAccess[0].HasReadAccess;
                   }

                   
               
              }
             
                
        }
        
        //Check point whether current logged in user present in public group name:CEPayableCreation
        // if((PublicGroupInfo.getUserIdsByGroupId(groupIdsForPublicGrp)).contains(UserInfo.getUserID()))
        system.debug('@@@@@ chk poinnt1');
        if(canCurrentUserCallCE)
        {
            
            QueryString = generateSOQLString('opportunity',gd);
            List < opportunity > opptyList = database.query(QueryString + '  Where id = : oppid ');
         system.debug('@@@@@ chk poinnt2');    
            if(opptyList != null && opptyList.size()>0)
            {
                opportunity oppty = opptyList[0];
                if (oppty.ISO_1_Lead_Source__c != null || oppty.ISO_2__c != null || oppty.ISO_3__c != null || oppty.ISO_4__c != null)
                {
                    Accountspopulated = true;
                    system.debug('@@@@@ chk poinnt3');  
                }
                
                QueryString = generateSOQLString('OpportunityTeamMember',gd);
                List < OpportunityTeamMember > opptyteamList = database.query(QueryString + ' where OpportunityId =: oppid ');
                if(opptyteamList != null && opptyteamList.size() > 0)
                {
                    for (OpportunityTeamMember optyTm: opptyteamList)
                    {
                        
                        userids.add(optyTm.userid);
                        
                    }
                }   
                    
                    List < RecordType > recordtypeList = [select id, name, sobjectType from recordType where name = : 'ISO' and sobjectType = : 'Account'];
                    Id recordid = recordtypeList[0].id;
                    Querystring = generateSOQLString('Account',gd);
                    List < Account > AccList = database.query(QueryString + ' WHERE RecordtypeId =: recordid  AND McaApp__User__c In : userids ');
                    
                    if( oppty.ISO_1_Lead_Source__c != null)
                    {
                        accbooleanMap.put(oppty.ISO_1_Lead_Source__c, true);
                        
                    }
                    
                    if(oppty.ISO_2__c != null)
                    {
                        accbooleanMap.put(oppty.ISO_2__c, true);
                    }
                    
                    if( oppty.ISO_3__c != null)
                    {
                        accbooleanMap.put(oppty.ISO_3__c, true);
                    }
                    
                    if( oppty.ISO_4__c != null)
                    {
                        accbooleanMap.put(oppty.ISO_4__c, true);
                    }
                    
                    
                    
                    // Map to check External Iso and Add those accounts  into Map
                    for (Account acc: AccList)
                    {
                        if (acc.Type != null && acc.Type == 'Internal')
                            AccBooleanMap.put(Acc.id,false);
                    }
                    
                    for (id tempid: accbooleanMap.keyset())
                    {
                        if (accbooleanMap.get(tempid))
                            Accid.add(tempid);
                        else
                            secondAccid.add(tempid);
                        
                    }
                    system.debug('@@@@@ chk poinnt4');  
                   // Setting the save ppoint
                   Savepoint sp = Database.setSavepoint();
                   system.debug('@@@@@ chk poinnt5'); 
                   try
                   {          
                            system.debug('####### Accountspopulated '+Accountspopulated );
                            system.debug('####### accid '+accid);
                          
                            // Accid set of All Accounts with External ISo's
                            if (Accountspopulated && accid.size() > 0 && accid != null)
                            {
                               
                                payableListExternal.addAll(analyzemethod(accid, opptyList,gd));
                               
                                system.debug('####### payableListExternal'+payableListExternal);
                                if(payableListExternal.size() > 0)
                                {
                                  insert payableListExternal;
                                  payableList.addall(payableListExternal);
                                }
                              
                                
                                
                            }
                            
                            // SecondAccid set of All accounts with Internal Iso's
                            if (secondAccid.size() > 0 && secondAccid != null)
                            {
                                QueryString = generateSOQLString('opportunity',gd);
                                List < opportunity > NewopptyList = database.query(QueryString + '  Where id = : oppid ');
                               
                                payableListInternal.addAll(analyzemethod(secondAccid, NewopptyList,gd));
                                
                                if(payableListInternal.size() > 0)
                                {
                                  insert payableListInternal;
                                  payableList.addall(payableListInternal);
                                }
                                
                            }
                   
                   }
                   catch(Exception e)
                   {
                   
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));  
                        Database.rollback( sp );
                   }
                    
                    
                    
                    
                
                
            } 
            
            
            
        }
        /*try
        {
          
          insert payableList;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));  
        
        }*/
        
        return payableList;
        
    }
    
    
    public static list < McaApp__Payable__c > analyzemethod(set < id > accid, list < opportunity > opptyList,Map<String,Schema.SObjectType > gd) {
        
        
        Map < string, string > structAccMap = new map < string, string > ();
        Set < Id > StructureId = new Set < Id > ();
        Set < Id > ruleids = new Set < Id > ();
        id oppid= opptyList[0].id;
        QueryString = generateSOQLString('MCACE__Commission_Agreement__c',gd);
        List < MCACE__Commission_Agreement__c > CommList = database.query(QueryString + '  Where Account__c In : Accid ');
        
        if (CommList != null && CommList.size() > 0)
        {
            
            for (MCACE__Commission_Agreement__c ca: CommList)
            {
                if (ca.Active__c)
                {
                    StructureId.add(ca.Structure__c);
                    structAccMap.put(ca.structure__c, ca.Account__c);
                }
                
            }
            
        }
        
        QueryString = generateSOQLString('MCACE__Commission_Rule__c',gd);
        
        List < MCACE__Commission_Rule__c > ruleList = database.query(QueryString + '  Where Commission_Structure__c IN : StructureId ');
        
        if (ruleList != null && ruleList.size() > 0)
        {
            
            for (MCACE__Commission_Rule__c rule: ruleList)
            {
                
                ruleids.add(rule.id);
                
            }
            
        }
        
        QueryString = generateSOQLString('MCACE__Commission_Rule_Entry__c',gd);
        
        List < MCACE__Commission_Rule_Entry__c > entryList = database.query(QueryString + ' where MCACE__Commission_Rule__c IN : ruleids ');
        
        QueryString = generateSOQLString('McaApp__Payable__c',gd); // Check if there exist any previous payable records
        List < McaApp__Payable__c > Payableexist = database.query(QueryString + ' Where McaApp__Opportunity__c = : oppid  And  McaApp__Account__c  In : accid');
        
        
        QueryString = generateSoqlString('McaApp__Receivable__c',gd); // Check if there exsist any previous receivable records
        List < McaApp__Receivable__c > receivables = database.query(QueryString + ' Where McaApp__Opportunity__c = : oppid ');
        
        List < McaApp__Payable__c > payableList = new List < McaApp__Payable__c > ();
        
        // Loop around the Rule and its respective Criteria
        // entries to check if all the Entry criteria are satisfied with Allentries as a boolean
        
        if(CommList.size() > 0 && CommList !=null )
        {
            for(MCACE__Commission_Agreement__c  ca : CommList )
            { // loop over Commission Agreement to Incorporate using same Structure for multiple Accounts
                
                if (ruleList != null && ruleList.size() > 0)
                {
                    
                    for (MCACE__Commission_Rule__c rule: ruleList)
                    {
                        if(ca.Structure__c == rule.Commission_Structure__c )
                        {
                            boolean allentries = false;
                            
                            if (entryList != null && entryList.size() > 0)
                            {
                                
                                for (MCACE__Commission_Rule_Entry__c entry: entryList)
                                {
                                    
                                    if (entry.MCACE__Commission_Rule__c == rule.id)
                                    {
                                        
                                        if (Entry.Object_API__c == 'opportunity')
                                        {
                                            
                                            // if (payableExist.size() < 1 || payableexist == null)
                                            {
                                                
                                                allentries = checkOperations(opptyList[0], entry, rule);
                                                
                                                if (!allentries)
                                                {
                                                    
                                                    break;
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                }
                                
                                
                            }
                            
                            
                            if (allentries)
                            {
                                if(ca.Active__c)
                                {
                                    
                                    McaApp__Payable__c payable = createPayablePerEntry(rule, opptyList[0], receivables, structAccMap ,ca);
                                    
                                    // keep amount due check
                                    if(payable != null && payable.McaApp__Amount_Due__c != 0.0 && payable.McaApp__Amount_Due__c != null)
                                    payableList.add(payable);
                                    
                                    
                                }
                                
                                
                            }
                        }
                    }
                    
                    
                }
                
            }
        }
        
        //insert payableList;
        updateDueDate(payableList);
        return payableList;
        
    }
    
    /* Method being invoked  to check whether the entry criteria on the Commission rule object
    is being satisfied using dynamic field API on the sObject
    
    Param : Sobject , CommissionRuleEntry , CommissionRule
    
    Return: Boolean result(if the entry criteria was satisfied)
    
    */
    
    
    public static Boolean checkOperations(sobject sobj, MCACE__Commission_Rule_Entry__c entry, MCACE__Commission_Rule__c rule) {
        
        Boolean enrtyCrteria = false;
        
        try {
            MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper responseContainer = new MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper();
            responseContainer = MCACEFieldConvertorAndComparator.getDatatypeAndValidate(entry);
            if(responseContainer.isValid ) 
            {
                //if(sobj.get(entry.Field_API__c) != null) 
                //{
                
                     if(responseContainer.datatypeName.equalsIgnoreCase('String')) {
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareString(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('Decimal')) {
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareDecimal(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('Datetime')) {
                        //enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareDateTime(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                        List<String> dateList = string.valueOf(entry.Text__c).split('/');
                        Date strDate= Date.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]));
                        Date dateInstance = date.valueOf(datetime.valueOf(sobj.get(entry.Field_API__c)).date());
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareDate(String.valueOf(strDate), dateInstance, entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('REFERENCE')){
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareLookUp(responseContainer, entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('Boolean')) {
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareString(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('Date')) {
                        List<String> dateList = string.valueOf(entry.Text__c).split('/');
                        Date strDate= Date.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]));
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareDate(String.valueOf(strDate), sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('PickList')) {
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareString(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('Percent')) {
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareDecimal(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('Currency')) {
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareDecimal(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('Double')) {
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareDecimal(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('Integer')) {
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareDecimal(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('URL')) {
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareString(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('Email')) {
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareString(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    } else if(responseContainer.datatypeName.equalsIgnoreCase('Phone')) {
                        enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndComparePhone(entry.Text__c, sobj.get(entry.Field_API__c), entry.Operator__c);
                    }
                
                
                
                //}
                
                
             }
            else
            {    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Payable not generated with Commision Rule Entry:'+entry.Id+'.Error Reason:'+responseContainer.errorString));
            }
            /*
            if (entry.Operator__c == 'equals') {
                
                if (entry.Text__c == (string) sobj.get(entry.Field_API__c))
                {
                    
                    enrtyCrteria = true;
                    
                }
                
            } else if (entry.Operator__c == 'not equals to')
            {
                
                if (entry.Text__c != (string) sobj.get(entry.Field_API__c))
                {
                    
                    enrtyCrteria = true;
                    
                }
                
            } else if (entry.Operator__c == 'greater than') {
                
                if (decimal.valueof(entry.Text__c) < (decimal) sobj.get(entry.Field_API__c))
                {
                    
                    enrtyCrteria = true;
                    
                }
                
            } else if (entry.Operator__c == 'less than') {
                
                if (decimal.valueof(entry.Text__c) > (decimal) sobj.get(entry.Field_API__c))
                {
                    
                    enrtyCrteria = true;
                    
                }
                
            } else if (entry.Operator__c == 'greater or equal') {
                
                if (decimal.valueof(entry.Text__c) <= (decimal) sobj.get(entry.Field_API__c))
                {
                    
                    enrtyCrteria = true;
                    
                }
                
            }
            
            
            if (entry.Operator__c == 'less or equal') {
                
                if (decimal.valueof(entry.Text__c) >= (decimal) sobj.get(entry.Field_API__c))
                {
                    
                    enrtyCrteria = true;
                    
                }
                
            }*/
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        }    
        return enrtyCrteria;
        
    }
    
    
    
    
    public static McaApp__Payable__c createPayablePerEntry(MCACE__Commission_Rule__c rule, sobject sobj, List < McaApp__Receivable__c > receivables, map < string, string > StrAccMap , MCACE__Commission_Agreement__c  ca)
    {
        
        McaApp__Payable__c payable = new McaApp__Payable__c();
        
        
        decimal amount = 0;
        
        
        payable.McaApp__Account__c = ca.Account__c; // Needs to be changed if not Opportunity.
        
        payable.McaApp__Type__c = rule.Payable_Type__c;
        
        payable.McaApp__Status__c = 'Open - Needs Review';
        
        payable.McaApp__Opportunity__c = (id) sobj.get(schema.opportunity.id); // Needs to be changed if not Opportunity
        
        payable.McaApp__Percentage__c = rule.Commission_Percentage__c;
        
        payable.McaApp__Payback_Funded__c = rule.Percentage_Of__c;
        
        payable.MCACE__Commission_Rule__c = rule.id; //To populate the commission rule on payable record
        
        // Check if the rule consists Percentage as the criteria
        
        if (rule.commission_type__c == 'Percent') {
            
            if (rule.Percentage_Of__c == 'All Revenue')
            {
                payable.McaApp__Amount_Due__c = (((treateNullAsZero((decimal)sobj.get(schema.opportunity.McaApp__Total_Receivables__c))) * (rule.Commission_Percentage__c)) / 100);
            }
            
            if (rule.Percentage_Of__c == 'Commission Revenue')
            {
               payable.McaApp__Amount_Due__c = (((treateNullAsZero((decimal)sobj.get(schema.opportunity.McaApp__Total_Commissions_Receivable__c))) * (rule.Commission_Percentage__c)) / 100);
                
            }
            
            if (rule.Percentage_Of__c == 'Funded')
            {
                payable.McaApp__Amount_Due__c = (((treateNullAsZero((decimal)sobj.get(schema.opportunity.McaApp__Funding_Amount__c))) * (rule.Commission_Percentage__c)) / 100);
                
            }
            
            if (rule.Percentage_Of__c == 'Payback')
            {
                payable.McaApp__Amount_Due__c = (((treateNullAsZero((decimal)sobj.get(Schema.opportunity.McaApp__Payback_Amount__c))) * (rule.Commission_Percentage__c)) / 100);
                
            }
            
            if (rule.Percentage_Of__c == 'Origination Fee')
            {
                /* Decimal originationFee = (sobj.get(Schema.opportunity.McaApp__Total_Origination_Fees_Receivable__c) != null ?
                (decimal) sobj.get(Schema.opportunity.McaApp__Total_Origination_Fees_Receivable__c) :0);    */
                payable.McaApp__Amount_Due__c = (((treateNullAsZero((decimal)sobj.get(Schema.opportunity.McaApp__Total_Origination_Fees_Receivable__c))) * (rule.Commission_Percentage__c)) / 100);
                
            }
            
            if (rule.Percentage_Of__c == 'Net Commission Revenue')
            {
                
                payable.McaApp__Amount_Due__c = (((treateNullAsZero((decimal)sobj.get(Schema.opportunity.Total_Remaining_Recievables_Amount__c))) * (rule.Commission_Percentage__c)) / 100);
            }
            
            if (rule.Percentage_Of__c == 'Net Origination Fee')
            {
                
                payable.McaApp__Amount_Due__c = (((treateNullAsZero((decimal)sobj.get(Schema.opportunity.Remaining_Origination_Fees_Receivable__c))) * (rule.Commission_Percentage__c)) / 100);
                
            }
            if(rule.Percentage_Of__c == 'Net Funded Amount')
            {
                Decimal netFundAmt = treateNullAsZero((decimal)sobj.get(Schema.opportunity.McaApp__Funding_Amount__c)) - treateNullAsZero((decimal)sobj.get(Schema.opportunity.McaApp__Payoff_Amount__c));
                payable.McaApp__Amount_Due__c = (((netFundAmt) * (rule.Commission_Percentage__c)) / 100);
                
            }
            
        }
        
        //  if the rule is a  fixed amount
        else if (rule.commission_type__c == 'Fixed') {
            
            payable.McaApp__Amount_Due__c = rule.Fixed_Amount__c;
            
        }
        
        
        // Set the recievable dependency for each Payable record
        
        // with the highest recievable as the record for a particular Type
        
        for (McaApp__Receivable__c recieve: receivables) {
            
            if (recieve.McaApp__Type__c == rule.Payable_Type__c) {
                
                if (recieve.McaApp__Amount__c > amount) {
                    
                    payable.McaApp__Receivable_Dependency__c = recieve.id;
                    
                    amount = recieve.McaApp__Amount__c;
                    
                }
                
            }
            
        }
        
        return payable;
        
    }
    
    
    
    /*Method to generate SOQL string for any object name with all the fields
    
    param : objectname
    
    result : Querystring
    
    */
    
    public static string generateSOQLString(String objname,Map<String,Schema.SObjectType > gd) 
    {
        
        // Map < String, Schema.SObjectType > gd = Schema.getGlobalDescribe();
        
        Schema.SObjectType sobjType = gd.get(objname);
        
        Schema.DesCribeSobjectResult ObjectResult = sobjType.getDescribe();
        
        Map < String, Schema.SObjectField > mapFields = ObjectResult.fields.getMap();
        
        String ResultString = 'Select ';
        
        Boolean ContainsId = false;
        
        if (mapFields != null && containsId != true) 
        {
            
            for (Schema.SobjectField FieldName: mapFields.values()) {
                
                string name = string.valueof(FieldName);
                
                ResultString = ResultString + '' + name + ',';
                
                if (name == 'Id') 
                {
                    
                    containsId = true;
                    
                }
                
            }
            
            if (!containsId) ResultString = ResultString + ' ' + 'Id';
            
            if (ResultString.endsWith(',')) {
                
                ResultString = ResultString.substring(0, ResultString.length() - 1);
                
            }
            
            Resultstring = ResultString + ' from ' + objname;
            
        }
        
        return ResultString;
        
    }
    
    
    public static void updateDueDate(list<McaApp__Payable__c > listpayables)
    {
        Set <Id> setIds = new set<Id>();
        Set <Id> opptyids = new set<Id>();
        
        for(McaApp__Payable__c  payable : listpayables){
            setids.add(payable.MCACE__Commission_Rule__c);
            opptyids.add(payable.McaApp__Opportunity__c);
            
        }
        
        List<opportunity> opptyList = [select id , name , McaApp__Date_Funded__c from opportunity  where id in : opptyids ];
        
        Map<id , opportunity> opptyMap = new map<id, opportunity>(opptyList);
        
        List<MCACE__Commission_Rule__c> strcList = [ select id , name  , Commission_Structure__c from MCACE__Commission_Rule__c where id In : setids ] ;
        
        Set<id> strucids = new set<id>();
        
        for(MCACE__Commission_Rule__c rule : strcList){
            strucids.add(rule.Commission_Structure__c);
            
        }
        
        List<MCACE__Commission_Agreement__c> commAgreeList = [select id , name , Account__c ,First_Payroll_Cycle_End_Date__c , First_Payroll_Pay_Date__c , Pay_Period_Frequency__c , Structure__c  from MCACE__Commission_Agreement__c where structure__c in : strucids and Active__c = true];
        integer daysPastCE =0;
        integer daysBetweenPayDateAndCycleEnd =0;
        for (MCACE__Commission_Agreement__c Agreement : commAgreeList){
            
            if(strucids.contains(agreement.Structure__c  )){
                
                for( McaApp__Payable__c   payable : listpayables){
                    
                    if(payable.McaApp__Account__c == agreement.Account__c){
                        opportunity opty = opptyMap.get(payable.McaApp__Opportunity__c);
                        if(opty.McaApp__Date_Funded__c > agreement.First_Payroll_Cycle_End_Date__c  )
                        {
                            
                            Integer daysSinceCE  = agreement.First_Payroll_Cycle_End_Date__c.daysBetween(opty.McaApp__Date_Funded__c);
                            daysPastCE = (integer)((math.mod(daysSinceCE, Agreement.MCACE__Pay_Period_Frequency__c.intValue() )) * -1);
                            date lastCE = opty.McaApp__Date_Funded__c.addDays(daysPastCE);
                            Date currentCE = lastCE.addDays((integer)(Agreement.MCACE__Pay_Period_Frequency__c));
                            if(Agreement.MCACE__First_Payroll_Pay_Date__c <> Null && agreement.MCACE__First_Payroll_Cycle_End_Date__c <> Null)
                                daysBetweenPayDateAndCycleEnd = agreement.MCACE__First_Payroll_Cycle_End_Date__c.daysBetween(Agreement.MCACE__First_Payroll_Pay_Date__c);
                            else
                                daysBetweenPayDateAndCycleEnd = 0;
                            payable.McaApp__Due_Date__c= currentCE.addDays(daysBetweenPayDateAndCycleEnd);
                            
                        }
                        else
                        {
                            payable.McaApp__Due_Date__c = Agreement.MCACE__First_Payroll_Pay_Date__c;
                        }
                    }
                    
                }
            }
            
            
        }
        
        
    }
   
    
    public static decimal treateNullAsZero(Decimal pValue)
    {
        return (pValue == null) ?  0.00 : pValue  ;
    }
    
    
}
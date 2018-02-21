/* The Handler class will update Developer Name and Developer Company based on the Name present in Person
 * Field of Time Entry Record and will populate Error field when there are multiple contact with
 * Same Contact Name and Account Name or No Contact on creation or Updation of Time Entry record.
 *
 *
 * Revision History:
 *
 * Version         Author                                Date                              Description
 * 1.0             Ajay Singh Solanki                    26/06/2013                        Initial Draft
 */

public with sharing class TimeEntryTriggerHandler {

    //CONSTANTS (Error Messages)
    private static final String ERROR_MESSAGE_DUPLICATES =
        'Multiple entries found matching the Contact Name and Account, please associate it with the correct Contact of Account: ';
    private static final String ERROR_MESSAGE_WRONG_PERSON_NAME =
        'The Person Name is not mentioned in the correct format.';
    private static final String ERROR_MESSAGE_NO_CONTACT_OR_ACCOUNT =
        'There is no such Contact with Contact Name : ';

    private static final String ERROR_MESSAGE_BLANK_PERSON_NAME =
        'Please provide value in Person Name field to populate Developer Name and Developer Company.';

    //PROPERTIES
    private set<String> setDeveloperNames = new set<String>();      //set will contain developer Names.
    private set<String> setDeveloperCompanies = new set<String>();  //set will contain developer Company Names.
    //Set will contain Developer Name and Company appended by ( symbol.
    private set<String> setDeveloperNameNCompany = new set<String>();
    private String developerName;    //String will contain Name of Developer.
    private String developerCompany; //String will contain developer Company.
    /* Map 'mapNameNCmpnyWithCount' will contain 'contact + account' Name as key and count of contact
     * records that has same Contact Name and Account Name as value.
     */
    map<String, Integer> mapNameNCmpnyWithCount = new map<String, Integer>();
    /* Map 'mapNameNCmpnyWithCount' will contain 'contact + account' Name as key and contact
     * records as value.
     */
    map<String, Contact> mapNameNCmpnyWithContact = new map<String, Contact>();
    /* String will contain 'contact + account' Name which will be used as key for mapNameNCmpnyWithCount
     * and mapNameNCmpnyWithContact.
     */
    private String keyForMap;
    /* String 'countofContactRecords' will contain count of Contact Records that have same Contact Name and
     * Account Name.
     */
    Integer countofContactRecords;




    //METHODS

    /* The method will update Developer Name and Developer Company based on the Name present in Person
     * Field of Time Entry Record and will populate Error field when there are multiple contact with
     * Same Contact Name and Account Name or No Contact on creation of Time Entry record.
     */
    public void onInsertPopulateDeveloperNameAndCompany(List<HarvestTimeEntry__c> pLstHarvestTimeEntry){
        //Iterating TimeEntry records to populate setDeveloperNames and setDeveloperCompanies.
        for(HarvestTimeEntry__c timeEntry : pLstHarvestTimeEntry){

            jiraIssueParsing(timeEntry);
            if(timeEntry.Person__c <> null){
                developerName = timeEntry.Person__c.substringBefore('(');          //Fetching Developer Name.
                developerCompany = timeEntry.Person__c.substringBetween('(',')');  //Fetching Developer Company Name.
                if(developerName <> null && developerCompany <> null){
                    setDeveloperNames.add('%' + developerName.trim().toLowerCase() + '%');
                    setDeveloperCompanies.add('%' + developerCompany.trim().toLowerCase() + '%');
                    setDeveloperNameNCompany.add(developerName.trim().toLowerCase() + '(' +
                                                 developerCompany.trim().toLowerCase());
                }//End if inner.
            }//End if.
        }//End for.


        //Calling populateMapsOfContact to populate mapNameNCmpnyWithContact and mapNameNCmpnyWithCount
        this.populateMapsOfContact(setDeveloperNames, setDeveloperCompanies);

        //Iterating TimeEntry records to populate Developer Name and Company.
        for(HarvestTimeEntry__c timeEntry : pLstHarvestTimeEntry){
            //Calling returnUpdatedTimeEntry method to update Time Entry record.
            timeEntry = this.returnUpdatedTimeEntry(timeEntry);
        }//End for.
    }//End onInsertPopulateDeveloperNameAndCompany method.



    /* The method will update Developer Name and Developer Company based on the Name present in Person
     * Field of Time Entry Record and will populate Error field when there are multiple contact with
     * Same Contact Name and Account Name or No Contact on update of Time Entry record.
     */
    public void onUpdatePopulateDeveloperNameAndCompany(Map<Id, HarvestTimeEntry__c> pMapNewHarvestTimeEntry,
                                                        Map<Id, HarvestTimeEntry__c> pMapOldHarvestTimeEntry){
        if(CheckRecursive.runOnceForBefore()){
            //Iterating TimeEntry records to populate setDeveloperNames and setDeveloperCompanies.
            for(HarvestTimeEntry__c newTimeEntry : pMapNewHarvestTimeEntry.values()){
                   // to update Jira Key and Jira Issue on change of Notes
                jiraIssueParsing(newTimeEntry);
                HarvestTimeEntry__c oldTimeEntry = pMapOldHarvestTimeEntry.get(newTimeEntry.Id);

                if((oldTimeEntry.Person__c <> newTimeEntry.Person__c || newTimeEntry.Developer_Name__c == null ||
                    newTimeEntry.Developer_Company__c == null ) && newTimeEntry.Person__c <> null){
    
                    developerName = newTimeEntry.Person__c.substringBefore('(');          //Fetching Developer Name.
                    developerCompany = newTimeEntry.Person__c.substringBetween('(',')');  //Fetching Developer Company Name.
                    if(developerName <> null && developerCompany <> null){
                        setDeveloperNames.add('%' + developerName.trim().toLowerCase() + '%');
                        setDeveloperCompanies.add('%' + developerCompany.trim().toLowerCase() + '%');
                        setDeveloperNameNCompany.add(developerName.trim().toLowerCase() + '(' +
                                                     developerCompany.trim().toLowerCase());
                    }//End if inner.
                }//End if.
    
            }//End for.
    
    
            //Calling populateMapsOfContact to populate mapNameNCmpnyWithContact and mapNameNCmpnyWithCount
            this.populateMapsOfContact(setDeveloperNames, setDeveloperCompanies);
    
            //Iterating TimeEntry records to populate Developer Name and Company.
            for(HarvestTimeEntry__c newTimeEntry : pMapNewHarvestTimeEntry.values()){
                HarvestTimeEntry__c oldTimeEntry = pMapOldHarvestTimeEntry.get(newTimeEntry.Id);
                if(newTimeEntry.Person__c <> oldTimeEntry.Person__c || newTimeEntry.Developer_Name__c == null ||
                   newTimeEntry.Developer_Company__c == null){
                    //Calling returnUpdatedTimeEntry method to update Time Entry record.
                    newTimeEntry = this.returnUpdatedTimeEntry(newTimeEntry);
                }//End if.
            }//End for.
        }//End If.
    }//End onUpdatePopulateDeveloperNameAndCompany method.

    /*This method parse the Time Entry Notes to Jira Key and Jira Issue*/
    public void jiraIssueParsing(HarvestTimeEntry__c newTimeEntry){
        if(newTimeEntry.Notes__c != null && newTimeEntry.Notes__c != '' &&
                    newTimeEntry.Notes__c.contains('[#') && newTimeEntry.Notes__c.contains(']')) {
                String jiraKeySubString = newTimeEntry.Notes__c.substringAfter('[#').substringBefore(']');
                
                if(jiraKeySubString != '')
                    newTimeEntry.Jira_Key__c = jiraKeySubString;

                String jiraIssueString = newTimeEntry.Notes__c.split('\n')[0];
                
                if(jiraIssueString.contains('.') 
                   && jiraIssueString.split('\\.')[0] != '' 
                   && jiraIssueString.split('\\.')[0].contains('[#')) {
                   
                   jiraIssueString = jiraIssueString.split('\\.')[0].removeEnd('\\.');
                }
                
                newTimeEntry.Jira_issue__c = jiraIssueString;
        } 
                    
        
        /*if(newTimeEntry.Notes__c != null && newTimeEntry.Notes__c != '' && newTimeEntry.Notes__c.contains('[') &&
                    newTimeEntry.Notes__c.contains('[#') && newTimeEntry.Notes__c.contains(']')) {

            system.debug('>>> newTimeEntry.Notes__c : '+newTimeEntry.Notes__c);
               String jiraKeySubString = newTimeEntry.Notes__c.substringAfter('[#');
            system.debug('>>> jiraKeySubString: '+jiraKeySubString);
               if(jiraKeySubString != '' && jiraKeySubString.contains(']'))
                    newTimeEntry.Jira_Key__c = jiraKeySubString.substringBefore(']');
            system.debug('>>> newTimeEntry.Jira_Key__c : '+newTimeEntry.Jira_Key__c);
            
            
            system.debug('>>>newTimeEntry.Notes__c.contains : '+newTimeEntry.Notes__c.contains('\n'));
            system.debug('>>>newTimeEntry.Notes__c.split()[0] : '+newTimeEntry.Notes__c.split('\n')[0]);
            system.debug('>>>newTimeEntry.Notes__c.split()[0].contains() : '+newTimeEntry.Notes__c.split('\n')[0].contains('[#'));
            
               if(newTimeEntry.Notes__c.contains('\n') && newTimeEntry.Notes__c.split('\n')[0] != ''
                                                     && newTimeEntry.Notes__c.split('\n')[0].contains('[#')) {
                    newTimeEntry.Jira_issue__c = newTimeEntry.Notes__c.split('\n')[0];
            system.debug('>>>if  newTimeEntry.Jira_issue__c : '+newTimeEntry.Jira_issue__c);
                }
               else if(newTimeEntry.Notes__c.contains('.') && newTimeEntry.Notes__c.split('\\.')[0] != '' && newTimeEntry.Notes__c.split('\\.')[0].contains('[#'))
               {
                   newTimeEntry.Jira_issue__c = newTimeEntry.Notes__c.split('\\.')[0];
            system.debug('>>>else if newTimeEntry.Jira_issue__c : '+newTimeEntry.Jira_issue__c);
               }
               else
                {
                    system.debug('>>> newTimeEntry.Notes__c.split( ) : '+newTimeEntry.Notes__c.split(' '));
                    List<String> jiraIssueParts =  newTimeEntry.Notes__c.split(' ');
                    system.debug('jiraIssueParts.size(): ' +jiraIssueParts.size());
                    if(jiraIssueParts.size() > 5)
                    {
                        newTimeEntry.Jira_issue__c = newTimeEntry.Notes__c.split(' ')[1]+' '+newTimeEntry.Notes__c.split(' ')[2]+' '+newTimeEntry.Notes__c.split(' ')[3]
                                                +' '+newTimeEntry.Notes__c.split(' ')[4]+' '+newTimeEntry.Notes__c.split(' ')[5];
                    }
                    else
                    {
                        newTimeEntry.Jira_issue__c = '';
                        for(Integer i=1; i<jiraIssueParts.size();++i )
                        {
                            newTimeEntry.Jira_issue__c = newTimeEntry.Jira_issue__c + jiraIssueParts[i] + ' ';
                        }
                    }
                 }
            }*/
    }

    /* The method will populate mapNameNCmpnyWithContact and mapNameNCmpnyWithCount.
     */
     public void populateMapsOfContact(set<String> pSetDeveloperNames,
                                       set<String> pSetDeveloperCompanies){

        //Iterating contact records to populate mapNameNCmpnyWithContact and mapNameNCmpnyWithCount.
        for(Contact contactRecord : [Select Id, Name, AccountId, Account.Name
                                     From Contact
                                     Where Name LIKE : pSetDeveloperNames
                                     AND Account.Name LIKE : pSetDeveloperCompanies]){

            for(String devNameNCompany : setDeveloperNameNCompany){
                //Checking if the Contact Name contains Developer Name and Account Name contains Developer Company.
                if(contactRecord.Name.toLowerCase().contains(devNameNCompany.substringBefore('(')) &&
                   contactRecord.Account.Name.toLowerCase().contains(devNameNCompany.substringAfter('('))){

                    keyForMap = devNameNCompany.substringBefore('(') + '(' + devNameNCompany.substringAfter('(');  //Preparing key for Map.
                    mapNameNCmpnyWithContact.put(keyForMap, contactRecord);        //populating mapNameNCmpnyWithContact.
                    //Checking if the contact Record already present in the Map and increment the value by 1.
                    if(mapNameNCmpnyWithCount.containsKey(keyForMap))
                        mapNameNCmpnyWithCount.put(keyForMap, mapNameNCmpnyWithCount.get(keyForMap) + 1);
                    //else populating mapNameNCmpnyWithCount with count 1 as value.
                    else
                        mapNameNCmpnyWithCount.put(keyForMap, 1); //populating mapNameNCmpnyWithCount.

                }//End  if inner.
            }//End for inner.
        }//End for.
     }//End populateMapsOfContact method.



    /* The method will return an Updated Time Entry record by populating Developer Name,
     * Developer Company and Error Field.
     */
     public HarvestTimeEntry__c returnUpdatedTimeEntry(HarvestTimeEntry__c pTimeEntry){

        if(pTimeEntry.Person__c == null){
                pTimeEntry.Developer_Name__c = null;     //Updating Developer Name.
                pTimeEntry.Developer_Company__c = null;  //Updating Developer Company.
                pTimeEntry.Error__c = ERROR_MESSAGE_BLANK_PERSON_NAME;
        }//End if.

        else{
            countofContactRecords = 0;
            developerName = pTimeEntry.Person__c.substringBefore('(');          //Fetching Developer Name.
            developerCompany = pTimeEntry.Person__c.substringBetween('(',')');  //Fetching Developer Company Name.
            if(developerName <> null && developerCompany <> null){
                keyForMap = developerName.trim().toLowerCase() + '(' + developerCompany.trim().toLowerCase(); //Preparing key for Map
                countofContactRecords = mapNameNCmpnyWithCount.get(keyForMap);
                //Condition when there is only 1 Contact record.
                if(countofContactRecords == 1){
                        pTimeEntry.Developer_Name__c = (mapNameNCmpnyWithContact.get(keyForMap) <> null ?
                                                       mapNameNCmpnyWithContact.get(keyForMap).Id :
                                                       null);     //Updating Developer Name.
                        pTimeEntry.Developer_Company__c = (mapNameNCmpnyWithContact.get(keyForMap) <> null ?
                                                          mapNameNCmpnyWithContact.get(keyForMap).AccountId :
                                                          null);  //Updating Developer Company.
                        pTimeEntry.Error__c = null;
                }//End if.

                //Condition when there are more than 1 Contact records.
                else if(countofContactRecords > 0){
                    pTimeEntry.Developer_Name__c = null;            //Updating Developer Name field to Null.
                    pTimeEntry.Developer_Company__c = (mapNameNCmpnyWithContact.get(keyForMap) <> null ?
                                                      mapNameNCmpnyWithContact.get(keyForMap).AccountId :
                                                      null);        //Updating Developer Company.
                    pTimeEntry.Error__c = ERROR_MESSAGE_DUPLICATES + mapNameNCmpnyWithContact.get(keyForMap).Account.Name;  //Populating error message.
                }//End else if.

                //Condition when there are no Contact records.
                else{
                    pTimeEntry.Developer_Name__c = null;                    //Updating Developer Name field to Null.
                    pTimeEntry.Developer_Company__c = null;                 //Updating Developer Company field to Null.
                    pTimeEntry.Error__c = ERROR_MESSAGE_NO_CONTACT_OR_ACCOUNT +
                                         developerName + ' having Account : ' + developerCompany; //Populating error message.
                }//End else.

            }//End if.
            //Below else condition will be executed when Person Name is not in correct format.
            else{
                pTimeEntry.Developer_Name__c = null;                       //Updating Developer Name field to Null.
                pTimeEntry.Developer_Company__c = null;                    //Updating Developer Company field to Null.
                pTimeEntry.Error__c = ERROR_MESSAGE_WRONG_PERSON_NAME;     //Populating error message.
            }//End else inner.
     }//End else.
        return pTimeEntry;
     }//End returnUpdatedTimeEntry method.

    public void onAfterInsert() {
       // new TimeEntryTriggerHandlerService().sumTotalHoursThisMonthOnProject((List<HarvestTimeEntry__c>) trigger.new,
       //                                                                       null);
        new TimeEntryTriggerHandlerService().timeEntryRollUpOnAccount((List<HarvestTimeEntry__c>) trigger.new,
                                                                              null);
    }
    
    public void onAfterUpdate() {
       // new TimeEntryTriggerHandlerService().sumTotalHoursThisMonthOnProject((List<HarvestTimeEntry__c>) trigger.new,
      //                                                                       (List<HarvestTimeEntry__c>) trigger.old);
        new TimeEntryTriggerHandlerService().timeEntryRollUpOnAccount((List<HarvestTimeEntry__c>) trigger.new,
                                                                       (List<HarvestTimeEntry__c>) trigger.old);
    }
    
    public void onAfterDelete() {
      //  new TimeEntryTriggerHandlerService().sumTotalHoursThisMonthOnProject(null, (List<HarvestTimeEntry__c>) trigger.old);
        new TimeEntryTriggerHandlerService().timeEntryRollUpOnAccount(null, (List<HarvestTimeEntry__c>) trigger.old);
    }
}//End TimeEntryTriggerHandler class.
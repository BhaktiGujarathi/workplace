public with sharing class DETE_JobResultController extends DETE_BaseClass {
    public static final Integer THRESHOLD_RANK_VALUE         = 4;
    public static final Integer THRESHOLD_RANK_VALUE_OVERLAP = 7;

    public String userPosition              {get;set;}
    public String specificTechnologies      {get;set;}

    public DETE_JobResultController() {

        User userObj = [
            SELECT id
                 , ContactId
                 , Contact.Position_Title__c
                 , Contact.Specific_Technologies__c
              FROM User
             WHERE Username =: strUserName
             LIMIT 1
         ];

         if( userObj != null) {
             userPosition = string.escapeSingleQuotes(userObj.Contact.Position_Title__c);
             specificTechnologies = string.escapeSingleQuotes(userobj.Contact.Specific_Technologies__c);
         }

    }


    public static List<Occupation__c> getOccupList (String userPosition) {
        List<Occupation__c> occupObjList = new List<Occupation__c>();
        occupObjList = [
            SELECT Id
                , Name
                , Title__c
                , Description__c
              FROM Occupation__c
             WHERE Title__c =: userPosition
             LIMIT 1
         ];

        return occupObjList ;

    }


    @RemoteAction
    public static List<DETE_OccupationWiseJobResult> getmainOccupationJobResultList(String userPosition) {

        if( true == String.isBlank(userPosition) ) {
            return new List<DETE_OccupationWiseJobResult>();
        }

        List<Occupation__c> occupObjList= DETE_JobResultController.getOccupList(userPosition );
        List<DETE_OccupationWiseJobResult> mainOccupationJobResultList = new List<DETE_OccupationWiseJobResult>();

        if(   true == occupObjList.isEmpty()
           && null != userPosition
        ) {
            Occupation__c  occupObj = new Occupation__c ( Name     = userPosition,
                                                         Title__c = userPosition
                                                       );

           mainOccupationJobResultList =
               fetchOccupationWiseJobResult( new List<Occupation__c>{occupObj} , null, null);

        } else {
            mainOccupationJobResultList = fetchOccupationWiseJobResult( occupObjList , null, null);
        }

        return mainOccupationJobResultList;
    }


    @RemoteAction
    public static List<DETE_OccupationWiseJobResult> getrelatedOccupationJobResultList(String userPosition) {

        if( true == String.isBlank(userPosition) ) {
            return new List<DETE_OccupationWiseJobResult>();
        }

        List<Occupation__c> occupObjList= DETE_JobResultController.getOccupList(userPosition );
        List<DETE_OccupationWiseJobResult> relatedOccupationJobResultList = new List<DETE_OccupationWiseJobResult>();

        if( true == occupObjList.isEmpty() ) {
            return relatedOccupationJobResultList;
        }

        relatedOccupationJobResultList = fetchOccupationWiseJobResult(
                                            getOccupationWiseJobResults(
                                                occupObjList[0].Name
                                            ), null, null
                                        );

        return relatedOccupationJobResultList;
    }


    @RemoteAction
    public static List<DETE_OccupationWiseJobResult> getOtherOccupationJobResultList(String specificTechnologies) {

        if( true == String.isBlank(specificTechnologies) ) {
            return new List<DETE_OccupationWiseJobResult>();
        }

        List<DETE_OccupationWiseJobResult> otherOccupationJobResultList = new List<DETE_OccupationWiseJobResult>();
        Set<Id> occupationSet = DETE_JobResultController.getOtherCareers(specificTechnologies);

        if( true == occupationSet.isEmpty()  ) {
            return otherOccupationJobResultList;
        }

        otherOccupationJobResultList = fetchOccupationWiseJobResult(
                                            getOccupationsFromSet(
                                                occupationSet
                                            ), null, null
                                        );


        return otherOccupationJobResultList;
    }

    // Method to get the Job List per Occupation
    public static List<DETE_OccupationWiseJobResult> fetchOccupationWiseJobResult(List<Occupation__c> occupationList,
        String location, Decimal radius) {

        if(  occupationList == null
          || occupationList.isEmpty() == true ) {
              return new List<DETE_OccupationWiseJobResult>();
          }

        DETE_OccupationWiseJobResult occupationWiseJobResult;
        List<DETE_OccupationWiseJobResult> occupationWiseJobResultList = new List<DETE_OccupationWiseJobResult>();

        for(Occupation__c occObj : occupationList) {
            occupationWiseJobResult = new DETE_OccupationWiseJobResult();
            occupationWiseJobResult.occupation = occObj;
            occupationWiseJobResult.jobResultList =
                DETE_JobLinkService.searchAvillableJobs(occObj.Title__c, location, radius);
            System.debug('...occupationWiseJobResult.jobResultList' + occupationWiseJobResult.jobResultList);

            occupationWiseJobResultList.add(occupationWiseJobResult);
        }

        return occupationWiseJobResultList;
    }


    // Method to get Related List of Occupation
    public static List<Occupation__c> getOccupationWiseJobResults(String postionStr) {

        Set<String> socCodeSet = getRelatedOccupations(postionStr);

        List<Occupation__c> occupationList = [
            SELECT Id
                 , Name
                 , Title__c
                 , Description__c
              FROM Occupation__c
              WHERE Name IN :socCodeSet
        ];

        return occupationList;
    }

    public static List<Occupation__c> getOccupationsFromSet(Set<Id> occupationId ){
        List<Occupation__c> occupationList = [
            SELECT Id
                 , Name
                 , Title__c
                 , Description__c
              FROM Occupation__c
              WHERE Id IN :occupationId
        ];

        return occupationList;
    }


    // Method to get Set of related Occupation
    public static Set<String> getRelatedOccupations(String socCode) {

        if( true == String.isBlank(socCode) ) {
            return new Set<String>();
        }

        String requestUrl = DETE_OnetService.STR_RELATED_OCCUPATION;
        requestUrl = requestUrl.replace(DETE_OnetService.STR_SOC_CODE, socCode);

        //Set<String> socCodeSet = new Set<String>{socCode};
        Set<String> socCodeSet = new Set<String>();
        socCodeSet.addAll(DETE_OnetService.fetchDataFromOnet(requestUrl));

        System.debug('...getRelatedOccupations socCodeSet' + socCodeSet);

        return socCodeSet;
    }

    public static Set<Id> getOtherCareers(String skills) {
        if(true == String.isBlank(skills)) {
            return new Set<Id>();
        }

        Id recordTypeId = [
            SELECT Id
             FROM RecordType
             WHERE Name = 'Hot Skill'
             LIMIT 1
        ].Id;

        Set<String> hotSkillSet = new Set<String>(skills.split(','));

        Map<String, Integer> tech_OccRank;

        Map<Id, Set<Id>> technologyMappingDetails;

        System.debug('...hotSkillSet :' + hotSkillSet);
        Set<Id> occupationSet = new Set<Id>();

        for(Occupation__c occupation : [SELECT Id
                                             , Name
                                             , (SELECT Id
                                                     , Technology__r.Name
                                                     , Occupation__r.Title__c
                                                     , Rank__c
                                                  FROM OccupationTechLineItems__r
                                                 WHERE Technology__r.RecordTypeId = :recordTypeId
                                                   AND Occupation__c != null
                                                   AND Rank__c != NULL
                                                   AND Technology__r.Name IN :hotSkillSet
                                                   ORDER BY Rank__c ASC
                                                )
                                          FROM Occupation__c
                                         WHERE Id IN ( SELECT Occupation__c
                                                         FROM OccupationTechLineItem__c
                                                        WHERE Technology__r.RecordTypeId = :recordTypeId
                                                      )

        ]) {

            if( occupation.OccupationTechLineItems__r.size() > ( hotSkillSet.size() + 1) /2  ) {
                //#TODO Most overlapping technology

                for(OccupationTechLineItem__c occupationTechLineItem : occupation.OccupationTechLineItems__r) {
                    if( occupationTechLineItem.Rank__c < DETE_JobResultController.THRESHOLD_RANK_VALUE_OVERLAP ) {
                        occupationSet.add(occupation.ID);
                    }
                }

            } else {
                //#TODO Check if any of the less overlapping occupation has any of skill on high rank
                // as need to consider the same

                for(OccupationTechLineItem__c occupationTechLineItem : occupation.OccupationTechLineItems__r) {
                    if( occupationTechLineItem.Rank__c < DETE_JobResultController.THRESHOLD_RANK_VALUE ) {
                        occupationSet.add(occupation.ID);
                    }
                }

            }//end else
        }//end for

        System.debug('...occupationSet size: ' + occupationSet.size());
        System.debug('...occupationSet: ' + occupationSet);
        return occupationSet;
    }
}
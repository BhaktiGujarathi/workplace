@isTest
public class ApexDebugLog_Test
{

    testMethod
    static void createErrorLog()
    {
        try{
            Integer result = 1 / 0;
        }
        catch(Exception e)
        {
           // new ApexDebugLog().createLog(new ApexDebugLog.Error('ApexDebugLog_Test','createErrorLog',NULL,50,system.now(),ex));
              ApexDebugLog.createLog(new ApexDebugLog.Error('ConcurnintegrationBatch','test' ,' In Exception', 87 , system.now(), e));
        }
    }

    testMethod
    static void createInformationLog()
    {
           ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationBatch','Finish' ,'test', 107 , system.now(), '>>>tripIdMap in finish'));
 
    }

    testMethod
    static void test_httpRequestlog()
    {    
        //Creating Test data.
        Opportunity opp = new Opportunity(Name='test1', StageName='Open', CloseDate=system.today().addDays(5));
        insert opp;
        
        Id oppID = opp.id;
        
        Trip__c tempTrip = new Trip__c(Trip_ID__c = 'abc'/*, Opportunity__c = opp.id*/);
        insert tempTrip;
        
        Concur_Integration__c conIntAuthorization = new Concur_Integration__c(   
                                                                             name = 'Authorization',
                                                                             User_Name__c = 'sgdev@statusgonow.com',
                                                                             Password__c = 'Welcome@2',
                                                                             Consumer_Key__c = 'Lp8uH8PwUcmpcQYSjZU4qV', 
                                                                             EndPoint__c = 'https://www.concursolutions.com/net2/oauth2/accesstoken.ashx'
                                                                             );
        insert conIntAuthorization;
        
        Concur_Integration__c coniTrip = new Concur_Integration__c(   
                                                                                 name = 'ConcurTravelTrip',
                                                                                 Booking_Type__c = 'Air',
                                                                                 Userid_Type__c = 'login',
                                                                                 Userid_Value__c = 'ALL', 
                                                                                 EndPoint__c = 'https://www.concursolutions.com/api/travel/trip/v1.1'
                                                                                 );
        insert coniTrip;    
        
        Test.setMock(HttpCalloutMock.class, new CCMockHttpErrorResponseGenerator());  
        Test.startTest();
          HttpRequest httpRequestGetTrip = RestUtility.createGetRequest( coniTrip.EndPoint__c, 
                                                                    //header      
                                                                    new Map<String,String>{ 
                                                                                           'Authorization' => 'OAuth Invalid'
                                                                                          }, 
                                                                    //Params            
                                                                    new Map<String,String>{
                                                                                            'userid_type' => 'login',
                                                                                            'userid_value' => 'ALL',
                                                                                            'bookingtype' => 'Air' 
                                                                                          }
                                                                   );
           HttpResponse  httpResponseTrip = RestUtility.getResponse(httpRequestGetTrip); 
        List<Apex_Debug_Log__c> lstApxlog = new List<Apex_Debug_Log__c>(); 
        lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information(   'CCPullTripFromConcurAndSF'
                                                                            ,'pullTripFromConcurAndSFExecute'
                                                                            ,'TravelTrip_Error_RequestLog'
                                                                            , 105 
                                                                            , Datetime.now()
                                                                            , ApexDebugLog.logHTTPRequest(httpRequestGetTrip)
                                                                            )
                                                )
            );
 
 
            lstApxlog.add(ApexDebugLog.createLog(new ApexDebugLog.Information(   'CCPullTripFromConcurAndSF'
                                                                                ,'pullTripFromConcurAndSFExecute'
                                                                                ,'TravelTrip_Error_ResponseLog'
                                                                                , 116 
                                                                                , Datetime.now()
                                                                                , ApexDebugLog.logHTTPResponse(httpResponseTrip)
                                                                                )
                                                    )
            );
        insert lstApxlog;
        Test.stopTest(); 
        System.assertEquals(2, [Select Id from Apex_Debug_log__c].size());
        
    }
 
      testMethod
    static void test_httpResponselog()
    {
           ApexDebugLog.createLog(new ApexDebugLog.Information('ConcurnintegrationBatch','Finish' ,'test', 107 , system.now(), '>>>tripIdMap in finish'));
 
    }

    
}
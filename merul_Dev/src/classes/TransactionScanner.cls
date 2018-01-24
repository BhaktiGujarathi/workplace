public class TransactionScanner {


public void ramdomNum()
{


 //  system.debug('!!!!!!!  '+' ' + '12-' + String.valueOf(Math.random()).substring(2, 6) );

/*
   Date datobj=;
   Integer dy = datobj.day();
  Integer mon = datobj.month();
 Integer yr = datobj.year();*/
 
 
   Datetime cDT = System.now();


  system.debug('@@@@@@@@  '+cDT.getTime());

}




public void TransactionScannerParser()
{

       
     //  String src='<v12:transaction printIN="true"><v12:transactionID>9585248</v12:transactionID><v12:transactionDT>2014-03-03</v12:transactionDT><v12:postedDT>2014-03-03</v12:postedDT><v12:transactionCD>V</v12:transactionCD><v12:transactionType>V</v12:transactionType><v12:transactionDS>Dummy transactions for ASAL</v12:transactionDS><v12:pointsCT>1334</v12:pointsCT><v12:location><v12:locationCD>9420147522</v12:locationCD><v12:locationShortDS/></v12:location></v12:transaction>';
      // String src='<transactionInformation><![CDATA[<v12:transactions xmlns:v12="http://www.americanexpress.com/integrationservice/schema/ICS/LoyaltyTransactionsService/v1/" xmlns:date="http://exslt.org/dates-and-times" xmlns:exsl="http://exslt.org/common" xmlns:v1="http://www.americanexpress.com/integrationservice/service/ICS/LoyaltyTransactionsService/v1/" xmlns:v11="http://www.americanexpress.com/schema/ICS/GlobalData/v1/" xmlns:v13="http://www.americanexpress.com/integrationservice/schema/ICS/LoyaltyDomainSchema/v1/" loyaltyAccountNO="026000054778"><v12:transaction printIN="true"><v12:transactionID>9585248</v12:transactionID><v12:transactionDT>2014-03-03</v12:transactionDT><v12:postedDT>2014-03-03</v12:postedDT><v12:transactionCD>V</v12:transactionCD><v12:transactionType>V</v12:transactionType><v12:transactionDS>Dummy transactions for ASAL</v12:transactionDS><v12:pointsCT>1334</v12:pointsCT><v12:location><v12:locationCD>9420147522</v12:locationCD><v12:locationShortDS/></v12:location></v12:transaction></v12:transactions>]]></transactionInformation>';
       
       
       String src='<transactionInformation><v12:transactions xmlns:v12="http://www.americanexpress.com/integrationservice/schema/ICS/LoyaltyTransactionsService/v1/" xmlns:date="http://exslt.org/dates-and-times" xmlns:exsl="http://exslt.org/common" xmlns:v1="http://www.americanexpress.com/integrationservice/service/ICS/LoyaltyTransactionsService/v1/" xmlns:v11="http://www.americanexpress.com/schema/ICS/GlobalData/v1/" xmlns:v13="http://www.americanexpress.com/integrationservice/schema/ICS/LoyaltyDomainSchema/v1/" loyaltyAccountNO="026000054778"><v12:transaction printIN="true"><v12:transactionID>9585248</v12:transactionID><v12:transactionDT>2014-03-03</v12:transactionDT><v12:postedDT>2014-03-03</v12:postedDT><v12:transactionCD>V</v12:transactionCD><v12:transactionType>V</v12:transactionType><v12:transactionDS>Dummy transactions for ASAL</v12:transactionDS><v12:pointsCT>1334</v12:pointsCT><v12:location><v12:locationCD>9420147522</v12:locationCD><v12:locationShortDS/></v12:location></v12:transaction><v12:transaction printIN="true"><v12:transactionID>9585248</v12:transactionID><v12:transactionDT>2014-03-03</v12:transactionDT><v12:postedDT>2014-03-03</v12:postedDT><v12:transactionCD>V</v12:transactionCD><v12:transactionType>V</v12:transactionType><v12:transactionDS>Dummy transactions for ASAL</v12:transactionDS><v12:pointsCT>1334</v12:pointsCT><v12:location><v12:locationCD>9420147522</v12:locationCD><v12:locationShortDS/></v12:location></v12:transaction></v12:transactions></transactionInformation>'; 
       
       src=src.replaceAll('<(br|hr)>','');
       src=src.replaceAll('&nbsp;',' ');
       src=src.replaceAll('\n','');
       src=src.replaceAll(':','');
       boolean transaction_F=false;
       boolean locationCD_F=false;
       boolean locationShortDS_F=false;
       transaction__c t;
        List<transaction__c> listOfTransaction=new List<transaction__c>();

        XmlStreamReader r = new XmlStreamReader(src);
        List<String> Fields=new List<String>{'transactionID__c','transactionDT__c','postedDT__c','transactionType__c','transactionDS__c','pointsCT__c','locationCD__c','locationShortDS__c'};
        
        Map<String,boolean> transactionFieldFlag=new Map<String,boolean>();
        
        for(String s: Fields) 
        {
             transactionFieldFlag.put(s,false);
          
        }
  
    
    
        Map<String,String> fieldToXmlMap=new Map<String,String>();
        fieldToXmlMap.put('locationCD__c','v12locationCD');
        fieldToXmlMap.put('locationShortDS__c','v12locationShortDS');
        fieldToXmlMap.put('transactionID__c','v12transactionID');
        fieldToXmlMap.put('transactionDT__c','v12transactionDT');
        fieldToXmlMap.put('postedDT__c','v12postedDT');
        fieldToXmlMap.put('transactionType__c','v12transactionType');
        fieldToXmlMap.put('transactionDS__c','v12transactionDS');
        fieldToXmlMap.put('pointsCT__c','v12pointsCT');
        fieldToXmlMap.put('locationCD__c','v12locationCD');
        fieldToXmlMap.put('locationShortDS__c','v12locationShortDS');
        
        
    
    
    
     while(r.hasNext()) 
     {
     
          r.next();
          
          
           if(r.geteventtype()==xmltag.start_element && r.getlocalname()=='v12transaction') 
                { 
                  
                     transaction_F = true;
                     t=new transaction__c();
                     
                     for(String s: Fields) 
                      {
                      
                         transactionFieldFlag.put(s,false);
                      
                      }
                    
                }
           
           if(r.geteventtype()==xmltag.end_element  && r.getlocalname()=='v12transaction') 
                { 
                  
                    transaction_F = false;
                    system.debug('$$$$ '+t);
                    listOfTransaction.add(t);
                    
                }     
             
             
            for(String s: Fields) 
            {
            
            
                     
                      if(r.geteventtype()==xmltag.start_element && r.getlocalname()==fieldToXmlMap.get(s)) 
                    { 
                      
                        transactionFieldFlag.put(s,true);     
                    }
                    
                    if(r.geteventtype()==xmltag.end_element && r.getlocalname()==fieldToXmlMap.get(s)) 
                    { 
                      
                         transactionFieldFlag.put(s,false);   
                    }      
                    
                 
            }
                                                                         
              
           
             if(transaction_F &&r.geteventtype()==xmltag.characters)
             {
               
               
               
                  for(String s: Fields) 
                    {
                          
                              if(transactionFieldFlag.get(s))
                              {
                               
                                  t.put(s,r.gettext());
                              }
                              
                            
                              
                    }          
                 
                   
              }
                
       
       
            
     
     }
     


 system.debug('@@@@@@ '+listOfTransaction);




}
}






 /*  Map<String, Schema.SObjectField> transactionFieldsMap = Schema.SObjectType.transaction__c.fields.getMap();
                                               
                                               
                                               
                                                 for(Schema.SObjectField transactionFields :transactionFieldsMap.values())    
                                                 {
                                                         Schema.DescribeFieldResult describeResult = transactionFields.getDescribe();
                                                         if(describeResult.isCustom())
                                                         {
                                                              
                                                               transactionFieldsToTrack.put(describeResult.getName(), false);
                                                         
                                                         }
                                                         
                                                                       
                                                 } 
                                                
                                                
                                                
                                                system.debug('%%%%%%%   '+transactionFieldsToTrack);*/
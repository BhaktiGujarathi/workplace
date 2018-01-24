global class DemoWebService
{



  global class WebSer
  {
      webservice String studName;
      webservice String rollNo;
      webservice blob attach;
  }

 webservice static void insertRec(WebSer ws)
 {
 
    WebSer__c w=new WebSer__c();
    w.RollNo__c=ws.rollNo;
    w.StudentName__c=ws.studName;
    w.name =ws.studName;
    insert w;
    
    /*Attachment a=new Attachment();
    a.body=ws.attach;
    a.parentid=w.id;
    a.Name = 'Test Attachment for Parent';  
    insert a;
    
    */
    
    system.debug('######  object'+w);
 
 }
   


}
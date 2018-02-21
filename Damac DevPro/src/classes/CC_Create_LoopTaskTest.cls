@isTest
private class CC_Create_LoopTaskTest {

    public static testmethod void method1(){
        String milli = String.valueOf(System.now().millisecond());
     Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
     User portalAccountOwner1 = new User(ProfileId = profile1.Id, Username = 'testUser1'+milli+'@damac.ae',
        Alias = 'batman',Email='bruce.wayne@wayneenterprises.com',EmailEncodingKey='UTF-8',Firstname='Bruce',
        Lastname='Wayne',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago');
        Database.insert(portalAccountOwner1);
        
      Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
      NSIBPM__SR_Template__c objsrtemlate = new NSIBPM__SR_Template__c(name = 'Agent Registration');
         objsrtemlate.NSIBPM__Portal_Service_Request_Name__c = 'test';
         objsrtemlate.NSIBPM__Do_not_use_owner__c = false;
         objsrtemlate.NSIBPM__SR_RecordType_API_Name__c= 'General';
         objsrtemlate.ownerid =UserInfo.getUserId();
         insert objsrtemlate; 
         
      NSIBPM__Step_Template__c ST = new NSIBPM__Step_Template__c(name = 'Registrar Review');
         ST.NSIBPM__DEV_Id__c = 'testdev';
         ST.NSIBPM__Code__c = 'REGISTRAR_REVIEW1';
         ST.NSIBPM__Step_RecordType_API_Name__c= 'General';
         ST.ownerid = UserInfo.getUserId();
      Insert ST;         
         
      NSIBPM__Service_Request__c SR = new NSIBPM__Service_Request__c();
        SR.NSIBPM__Customer__c  = a.Id;
        SR.NSIBPM__Email__c = 'test@nsigulf.com';
        SR.NSIBPM__Send_SMS_to_Mobile__c= '12123';
        sr.Country_of_Sale__c = 'UAE';
        insert SR;
         
      
         
       NSIBPM__Action__c Action = New NSIBPM__Action__c();
          Action.NSIBPM__Field_Value__c = '01/01/1990';
          Action.NSIBPM__Action_Type__c = 'NSIBPM__Service_Request__c';
          Action.NSIBPM__Field_Name__c = 'Date_of_Incorporation__c';
          Action.NSIBPM__Field_Type__c = 'DATE';
          Action.NSIBPM__Value_or_Field__c = 'Value';
          insert Action;
          
       NSIBPM__Status__c status = new NSIBPM__Status__c();
            status.Name ='Awaiting Approval';
            status.NSIBPM__Code__c ='AWAITING_ADDITIONAL_INFO';
            status.NSIBPM__DEV_Id__c ='567890';
            insert status;
                      
       NSIBPM__SR_Steps__c SRS = new NSIBPM__SR_Steps__c();
         SRS.NSIBPM__Step_No__c =10.0;
         SRS.NSIBPM__Step_Template__c = ST.id;
         SRS.NSIBPM__Start_Status__c = status.id;
         SRS.ownerid = UserInfo.getUserId(); 
         SRS.NSIBPM__SR_Template__c = objsrtemlate.id;
         SRS.NSIBPM__Do_not_use_owner__c = false;
         insert SRS;
         
         
     
        
         
       NSIBPM__Step__c St1 = new  NSIBPM__Step__c();
         st1.NSIBPM__Step_No__c =10.0;
         st1.NSIBPM__SR__c = SR.id;
         st1.NSIBPM__Step_Template__c = ST.id;
         st1.NSIBPM__Status__c = status.id;
         st1.NSIBPM__SR_Step__c = SRS.id;
         st1.NSIBPM__Sys_Step_Loop_No__c ='10.0_1';
         st1.NSIBPM__Step_Notes__c = 'test area';
         st1.ownerid = UserInfo.getUserId();
         insert St1;
         
          NSIBPM__Step__c St2 = new  NSIBPM__Step__c();
         st2.NSIBPM__Step_No__c =10.0;
         st2.NSIBPM__SR__c = SR.id;
         st2.NSIBPM__Step_Template__c = ST.id;
         st2.NSIBPM__Status__c = status.id;
         st2.NSIBPM__SR_Step__c = SRS.id;
         st2.NSIBPM__Sys_Step_Loop_No__c ='10.0_1';
         st2.NSIBPM__Step_Notes__c = 'test area';
         st2.ownerid = UserInfo.getUserId();
         insert St2;
         
         
       Contact con = new Contact();
         con.AccountId = a.Id;
         con.email = 'test@gmail.com';
         con.FirstName =  'Fname';
         con.LastName = 'LName';
         insert con;
        
       
        list<NSIBPM__Step__c> lstExistingSteps = new list<NSIBPM__Step__c>();
        lstExistingSteps.add(St1);
        map<string,Id> mapStepQueues =  new map<string,Id>();
        map<Id,string> mapStepTemplateQueues = new map<Id,string>();
        map<Id,string> mapSRStepQueues = new map<Id,string>();
        map<Id,string> mapSRTemplateQueues = new map<Id,String>();
            map<id,id> mapSROwner = new map<id,id>();
            map<id,string> mapUserLicense = new map<id,string>();
            map<string,Id> mapStepRecType = new map<string,Id>();
            list<NSIBPM__SR_Steps__c> lstSRSteps = new list<NSIBPM__SR_Steps__c>();
            lstSRSteps.add(SRS);
            
    
    
  
      CC_Create_LoopTask LoopTask = new CC_Create_LoopTask();
      LoopTask.GenerateLoopTask(lstExistingSteps,mapStepQueues,mapStepTemplateQueues,mapSRStepQueues,mapSRTemplateQueues,
                                mapSROwner,mapUserLicense,mapStepRecType,lstSRSteps,Action,St1);
    
    Action.NSIBPM__Field_Value__c = '100';
    Action.NSIBPM__Field_Name__c = 'RAK_Number_of_shares_issued__c';
    Action.NSIBPM__Field_Type__c = 'DOUBLE';
    Action.NSIBPM__Value_or_Field__c = 'Value';
    update Action;
    
    Action.NSIBPM__Field_Value__c = 'true';
    Action.NSIBPM__Field_Name__c = 'RAK_Resident_in_UAE__c';
    Action.NSIBPM__Field_Type__c = 'BOOLEAN';
    Action.NSIBPM__Value_or_Field__c = 'Value';
    update Action;
    
    Action.NSIBPM__Field_Value__c = 'Test';
    Action.NSIBPM__Field_Name__c = 'NSIBPM__Summary__c';
    Action.NSIBPM__Field_Type__c = 'TEXT';
    Action.NSIBPM__Value_or_Field__c = 'Value';
    update Action;
    
    Action.NSIBPM__Field_Value__c = 'NSIBPM__Summary__c';
    Action.NSIBPM__Field_Name__c = 'NSIBPM__Summary__c';
    Action.NSIBPM__Value_or_Field__c = 'Step Field';
    update Action;
    
    Action.NSIBPM__Field_Value__c = '01/01/1990';
    Action.NSIBPM__Action_Type__c = 'NSIBPM__Step__c';
    Action.NSIBPM__Field_Name__c = 'NSIBPM__Closed_Date__c';
    Action.NSIBPM__Field_Type__c = 'DATE';
    Action.NSIBPM__Value_or_Field__c = 'Value';
    update Action;
    
    Action.NSIBPM__Field_Value__c = '100';
    Action.NSIBPM__Field_Name__c = 'NSIBPM__Step_No__c';
    Action.NSIBPM__Field_Type__c = 'DOUBLE';
    Action.NSIBPM__Value_or_Field__c = 'Value';
    update Action;
    
    Action.NSIBPM__Field_Value__c = 'Test';
    Action.NSIBPM__Field_Name__c = 'NSIBPM__Summary__c';
    Action.NSIBPM__Field_Type__c = 'TEXT';
    Action.NSIBPM__Value_or_Field__c = 'Value';
    update Action;
    
    Action.NSIBPM__Field_Value__c = 'NSIBPM__Send_SMS_to_Mobile__c';
    Action.NSIBPM__Field_Name__c = 'NSIBPM__Summary__c';
    Action.NSIBPM__Value_or_Field__c = 'SR Field';
    update Action;
    st1.NSIBPM__SR__r = SR;
    
    Action.NSIBPM__Field_Value__c = '01/01/2016';
    Action.NSIBPM__Action_Type__c = 'Account';
    Action.NSIBPM__Field_Name__c = 'Name';
    Action.NSIBPM__Field_Type__c = 'DATE';
    Action.NSIBPM__Value_or_Field__c = 'Value';
    update Action;
    
    Action.NSIBPM__Field_Value__c = '100';
    Action.NSIBPM__Field_Name__c = 'RAK_Number_of_Shares__c';
    Action.NSIBPM__Field_Type__c = 'DOUBLE';
    Action.NSIBPM__Value_or_Field__c = 'Value';
    update Action;
    
    Action.NSIBPM__Field_Value__c = 'Test';
    Action.NSIBPM__Field_Name__c = 'Name';
    Action.NSIBPM__Field_Type__c = 'TEXT';
    Action.NSIBPM__Value_or_Field__c = 'Value';
    update Action;
    
    Action.NSIBPM__Field_Value__c = 'Name';
    Action.NSIBPM__Field_Name__c = 'Name';
    Action.NSIBPM__Value_or_Field__c = 'SR Field';
    update Action;
    st1.NSIBPM__SR__r = SR;
    
    Action.NSIBPM__Field_Value__c = 'NSIBPM__Summary__c';
    Action.NSIBPM__Field_Name__c = 'Name';
    Action.NSIBPM__Value_or_Field__c = 'Step Field';
    update Action;
    st1.NSIBPM__SR__r = SR;
    
    st1.NSIBPM__SR__r.NSIBPM__Contact__c = con.Id;
    Action.NSIBPM__Field_Value__c = '01/01/1990';
    Action.NSIBPM__Action_Type__c = 'Contact';
    Action.NSIBPM__Field_Name__c = 'Birthdate';
    Action.NSIBPM__Field_Type__c = 'DATE';
    Action.NSIBPM__Value_or_Field__c = 'Value';
    update Action;
    
    Action.NSIBPM__Field_Value__c = 'Test';
    Action.NSIBPM__Field_Name__c = 'Passport_No__c';
    Action.NSIBPM__Field_Type__c = 'TEXT';
    Action.NSIBPM__Value_or_Field__c = 'Value';
    update Action;
    
    Action.NSIBPM__Field_Value__c = 'NSIBPM__Send_SMS_to_Mobile__c';
    Action.NSIBPM__Field_Name__c = 'Passport_No__c';
    Action.NSIBPM__Value_or_Field__c = 'SR Field';
    update Action;
    st1.NSIBPM__SR__r = SR;
    
    
    Action.NSIBPM__Field_Value__c = 'NSIBPM__Summary__c';
    Action.NSIBPM__Field_Name__c = 'Passport_No__c';
    Action.NSIBPM__Value_or_Field__c = 'Step Field';
    update Action;
    st1.NSIBPM__SR__r = SR;
    
    CC_Step_Assignment ObjStepAss = new CC_Step_Assignment();
    Map<String,NSIBPM__Service_Request__c> MapSRs = new Map<String,NSIBPM__Service_Request__c>();
    MapSRs.put('Test',SR); 
    List<NSIBPM__Step__c> StepList = new List<NSIBPM__Step__c>();
    Map<String,NSIBPM__SR_Steps__c> MapSRSteps = new Map<String,NSIBPM__SR_Steps__c>();
    MapSRSteps.put('Test 1',SRS);
    Map<String,NSIBPM__Step__c> MapSteps = new Map<String,NSIBPM__Step__c>();
    MapSteps.put('Testing',st1);
    stepList.add(st1);
    ObjStepAss.Assign_Step_Owner_SR_Submit(MapSRs,StepList,MapSRSteps);
    ObjStepAss.Assign_Step_Owner_Step_Closure(MapSteps,StepList,MapSRSteps);
    
    
}


    public static testmethod void method11(){
        String milli = String.valueOf(System.now().millisecond());
     Profile profile2 = [Select Id from Profile where name = 'System Administrator'];
     User portalAccountOwner2 = new User(ProfileId = profile2.Id,Username = 'testUser2'+milli+'@damac.ae',
        Alias = 'batman',Email='bruce.wayne@wayneenterprises.com',EmailEncodingKey='UTF-8',Firstname='Bruce',
        Lastname='Wayne',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago');
        Database.insert(portalAccountOwner2);
        
      Account a1 = new Account();
        a1.Name = 'Test Account';
        insert a1;
        
      NSIBPM__SR_Template__c objsrtemlate1 = new NSIBPM__SR_Template__c(name = 'New Registration');
         objsrtemlate1.NSIBPM__Portal_Service_Request_Name__c = 'test';
         objsrtemlate1.NSIBPM__SR_RecordType_API_Name__c= 'General';
         objsrtemlate1.NSIBPM__Do_not_use_owner__c=false;
         //objsrtemlate1.ownerid = '0053E000000HFrh';
         objsrtemlate1.ownerid = UserInfo.getUserId();
         insert objsrtemlate1; 
         
      NSIBPM__Step_Template__c ST3 = new NSIBPM__Step_Template__c(name = 'Registrar Review');
         ST3.NSIBPM__DEV_Id__c = 'testdev';
         ST3.NSIBPM__Code__c = 'REGISTRAR_REVIEW2';
         ST3.NSIBPM__Step_RecordType_API_Name__c= 'General';
      Insert ST3;         
         
      NSIBPM__Service_Request__c SR1 = new NSIBPM__Service_Request__c();
        SR1.NSIBPM__Customer__c  = a1.Id;
        SR1.NSIBPM__SR_Template__c = objsrtemlate1.ID;
      //SR.Sys_License_Application__c = l1.Id;
        SR1.NSIBPM__Email__c = 'test@nsigulf.com';
        SR1.NSIBPM__Send_SMS_to_Mobile__c= '12123';
        sr1.Country_of_Sale__c = 'UAE';
        sr1.Mode_of_Payment__c = 'Cash';
        insert SR1;
         
       NSIBPM__Action__c Action1 = New NSIBPM__Action__c();
          Action1.NSIBPM__Field_Value__c = '30.0';
          //Action.NSIBPM__Step_Template__c = SRT.id;
          insert Action1;
          
       NSIBPM__Status__c status1 = new NSIBPM__Status__c();
            status1.Name ='Awaiting Approval';
            status1.NSIBPM__Code__c ='AWAITING_APPROVAL2';
            status1.NSIBPM__DEV_Id__c ='567890';
            insert status1;
            
              
         Group testGroup1 = new Group(Name='Client Entry User', Type='Queue');
         insert testGroup1;
         
         GroupMember Gm1 = new GroupMember(UserOrGroupid = UserInfo.getUserId(),GroupId=testGroup1.id);

         System.runAs(new User(Id=UserInfo.getUserId()))
         {
         QueuesObject testQueue1 = new QueueSObject(QueueID = testGroup1.id, SObjectType = 'NSIBPM__SR_Steps__c');
         insert testQueue1;
         }

         map<Id,string> mapSRStepQueues1 = new map<Id,string>();
        mapSRStepQueues1.put(testgroup1.id,'Client Entry User');
        map<string,Id> mapStepRecType1 = new map<string,Id>();
        Id rtId = Schema.SObjectType.NSIBPM__Step__c.RecordTypeInfosByName.get('General').RecordTypeId;
        //mapStepRecType1.put('General','0123E0000004JnP');
        mapStepRecType1.put('General',rtId);
         
          NSIBPM__SR_Steps__c SRS11 = new NSIBPM__SR_Steps__c();
             SRS11.NSIBPM__Step_No__c =30.0;
             srs11.NSIBPM__Do_not_use_owner__c=false;
             SRS11.NSIBPM__Step_RecordType_API_Name__c = 'General';
             SRS11.NSIBPM__Step_Template__c = ST3.id;
             SRS11.NSIBPM__Start_Status__c = status1.id;
             SRS11.NSIBPM__SR_Template__c = objsrtemlate1.ID;
             //SRS11.ownerid ='0053E000000HFrh'; 
             SRS11.ownerid = UserInfo.getUserId();
             SRS11.NSIBPM__Estimated_Hours__c = 10;
             insert SRS11;
      NSIBPM__SR_Steps__c SRS12 = new NSIBPM__SR_Steps__c();
             SRS12.NSIBPM__Step_No__c =30.0;
             SRS12.NSIBPM__Step_RecordType_API_Name__c = 'General';
             SRS12.NSIBPM__Step_Template__c = ST3.id;
             SRS12.NSIBPM__Start_Status__c = status1.id;
             SRS12.NSIBPM__SR_Template__c = objsrtemlate1.ID;
             //SRS12.ownerid ='0053E000000HFrh'; 
             SRS12.ownerid = UserInfo.getUserId();
             SRS12.NSIBPM__Estimated_Hours__c = 10;
             insert SRS12;
             
             NSIBPM__SR_Steps__c SRS51 = new NSIBPM__SR_Steps__c();
         SRS51.NSIBPM__Step_No__c =30.0;
         srs51.NSIBPM__Do_not_use_owner__c=false;
         SRS51.NSIBPM__Step_Template__c = ST3.id;
         SRS51.NSIBPM__Start_Status__c = status1.id;
         SRS51.ownerid = testGroup1.id; 
         insert SRS51;
            
        NSIBPM__Step__c St11 = new  NSIBPM__Step__c();
             st11.NSIBPM__Step_No__c =30.0;
             st11.NSIBPM__SR__c = SR1.id;
             st11.NSIBPM__Step_Template__c = ST3.id;
             st11.NSIBPM__Status__c = status1.id;
             st11.NSIBPM__SR_Step__c = SRS11.id;
             st11.NSIBPM__Sys_Step_Loop_No__c ='10.0_1';
             st11.NSIBPM__Step_Notes__c = 'test area';
             st11.NSIBPM__Due_Date__c=datetime.newInstance(2017, 9, 15, 9, 30, 0);
             //sT11.OWNERID = '0053E000000HFrh';
             ST11.ownerid = UserInfo.getUserId();
             insert St11;
             //ST11.recordtypeid='0123E0000004JnP';
             update st11;
             
             NSIBPM__Step__c St12 = new  NSIBPM__Step__c();
             st12.NSIBPM__Step_No__c =30.0;
             st12.NSIBPM__Due_Date__c=datetime.newInstance(2017, 9, 15, 9, 30, 0);
           
             //ST12.recordtype.developername = 'General';
             //ST12.recordtypeid='0123E0000004JnP';
             st12.NSIBPM__SR__c = SR1.id;
             st12.NSIBPM__Step_Template__c = ST3.id;
             st12.NSIBPM__Status__c = status1.id;
             st12.NSIBPM__SR_Step__c = SRS12.id;
             st12.NSIBPM__Sys_Step_Loop_No__c ='10.0_1';
             st12.NSIBPM__Step_Notes__c = 'test area';
             //sT12.OWNERID = '0053E000000HFrh';
             ST12.ownerid = UserInfo.getUserId();
             insert St12; 
         
                      
       
         
        
         
      
         
         
       Contact con1 = new Contact();
         con1.AccountId = a1.Id;
         con1.email = 'test@gmail.com';
         con1.FirstName =  'Fname';
         con1.LastName = 'LName';
         insert con1;
        
       
        list<NSIBPM__Step__c> lstExistingSteps1 = new list<NSIBPM__Step__c>();
        lstExistingSteps1.add(St11);
        map<string,Id> mapStepQueues1 =  new map<string,Id>();
        map<Id,string> mapStepTemplateQueues1 = new map<Id,string>();
        
        map<Id,string> mapSRTemplateQueues1 = new map<Id,String>();
            map<id,id> mapSROwner1 = new map<id,id>();
            map<id,string> mapUserLicense1 = new map<id,string>();

            list<NSIBPM__SR_Steps__c> lstSRSteps1 = new list<NSIBPM__SR_Steps__c>();
            lstSRSteps1.add(SRS11);
            
     
    
  
      CC_Create_LoopTask LoopTask1 = new CC_Create_LoopTask();
      //LoopTask1.GenerateLoopTask(lstExistingSteps1,mapStepQueues1,mapStepTemplateQueues1,mapSRStepQueues1,mapSRTemplateQueues1,mapSROwner1,mapUserLicense1,mapStepRecType1,lstSRSteps1,Action1,St11);
                               
         
}

    public static testmethod void method111(){
        String milli = String.valueOf(System.now().millisecond());
     Profile profile21 = [Select Id from Profile where name = 'System Administrator'];
     User portalAccountOwner21 = new User(ProfileId = profile21.Id, Username = 'testUser21'+milli+'@damac.ae',
        Alias = 'batman',Email='bruce.wayne@wayneenterprises.com',EmailEncodingKey='UTF-8',Firstname='Bruce',
        Lastname='Wayne',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago');
        Database.insert(portalAccountOwner21);
        
      Account a11 = new Account();
        a11.Name = 'Test Account';
        insert a11;
        
          Group testGroup11 = new Group(Name='Client Entry User', Type='Queue');
         insert testGroup11;
         
         GroupMember Gm11 = new GroupMember(UserOrGroupid = UserInfo.getUserId(),GroupId=testGroup11.id);

         System.runAs(new User(Id=UserInfo.getUserId()))
         {
         QueuesObject testQueue11 = new QueueSObject(QueueID = testGroup11.id, SObjectType = 'NSIBPM__SR_Steps__c');
         insert testQueue11;
         }

      NSIBPM__SR_Template__c objsrtemlate11 = new NSIBPM__SR_Template__c(name = 'New Registration');
         objsrtemlate11.NSIBPM__Portal_Service_Request_Name__c = 'test';
         //objsrtemlate11.NSIBPM__SR_RecordType_API_Name__c= 'RAKICC_Re_Domiciliation';
         objsrtemlate11.NSIBPM__SR_RecordType_API_Name__c= 'General';
         objsrtemlate11.NSIBPM__Do_not_use_owner__c=false;
         //objsrtemlate11.ownerid = '0053E000000HFrh';
         objsrtemlate11.ownerid = UserInfo.getUserId();
         insert objsrtemlate11; 
         
      NSIBPM__Step_Template__c ST31 = new NSIBPM__Step_Template__c(name = 'Registrar Review');
         ST31.NSIBPM__DEV_Id__c = 'testdev';
         ST31.NSIBPM__Code__c = 'REGISTRAR_REVIEW3';
         ST31.NSIBPM__Step_RecordType_API_Name__c= 'General';
      Insert ST31;         
         
      NSIBPM__Service_Request__c SR11 = new NSIBPM__Service_Request__c();
        SR11.NSIBPM__Customer__c  = a11.Id;
        SR11.NSIBPM__SR_Template__c = objsrtemlate11.ID;
        SR11.NSIBPM__Ultimate_SR_Menu_Text__c = 'Company Services';
      //SR.Sys_License_Application__c = l1.Id;
        SR11.NSIBPM__Email__c = 'test@nsigulf.com';
        SR11.NSIBPM__Send_SMS_to_Mobile__c= '12123';
        SR11.Country_of_Sale__c = 'UAE';
        insert SR11;
         
       NSIBPM__Action__c Action11 = New NSIBPM__Action__c();
          Action11.NSIBPM__Field_Value__c = '73.0';
          //Action.NSIBPM__Step_Template__c = SRT.id;
          insert Action11;
          
       NSIBPM__Status__c status11 = new NSIBPM__Status__c();
            status11.Name ='Awaiting Approval';
            status11.NSIBPM__Code__c ='AWAITING_APPROVAL3';
            status11.NSIBPM__DEV_Id__c ='567890';
            insert status11;
            
         map<Id,string> mapSRStepQueues11 = new map<Id,string>();
        mapSRStepQueues11.put(testgroup11.id,'Client Entry User');
        Group testGroup111 = new Group(Name='Client Entry User', Type='Queue');
         insert testGroup111;
         
         GroupMember Gm111 = new GroupMember(UserOrGroupid = UserInfo.getUserId(),GroupId=testGroup111.id);

         System.runAs(new User(Id=UserInfo.getUserId()))
         {
         QueuesObject testQueue111 = new QueueSObject(QueueID = testGroup11.id, SObjectType = 'NSIBPM__Step__c');
         insert testQueue111;
         }
         map<string,Id> mapStepQueues11 =  new map<string,Id>();
        mapStepQueues11.put('Client Entry User',testgroup11.id);
        
       NSIBPM__SR_Steps__c SRS111 = new NSIBPM__SR_Steps__c();
             SRS111.NSIBPM__Step_No__c =73.0;
             SRS111.NSIBPM__Do_not_use_owner__c=false;
             //SRS111.NSIBPM__Step_RecordType_API_Name__c = 'General';
             SRS111.NSIBPM__Step_Template__c = ST31.id;
             SRS111.NSIBPM__Start_Status__c = status11.id;
             SRS111.NSIBPM__SR_Template__c = objsrtemlate11.ID;
             SRS111.ownerid = testgroup11.id; 
             insert SRS111;
      NSIBPM__SR_Steps__c SRS121 = new NSIBPM__SR_Steps__c();
             SRS121.NSIBPM__Step_No__c =73.0;
             //SRS121.NSIBPM__Step_RecordType_API_Name__c = 'General';
             SRS121.NSIBPM__Step_Template__c = ST31.id;
             SRS121.NSIBPM__Start_Status__c = status11.id;
             SRS121.NSIBPM__SR_Template__c = objsrtemlate11.ID;
             //SRS121.ownerid ='0053E000000HFrh'; 
             SRS121.ownerid = UserInfo.getUserId();
             SRS121.NSIBPM__Estimated_Hours__c = 10;
             insert SRS121;
            
        NSIBPM__Step__c St111 = new  NSIBPM__Step__c();
             st111.NSIBPM__Step_No__c =73.0;
             st111.NSIBPM__SR__c = SR11.id;
             st111.NSIBPM__Step_Template__c = ST31.id;
             st111.NSIBPM__Status__c = status11.id;
             st111.NSIBPM__SR_Step__c = SRS111.id;
             st111.NSIBPM__Sys_Step_Loop_No__c ='10.0_1';
             st111.NSIBPM__Step_Notes__c = 'test area';
             //sT111.OWNERID = '0053E000000HFrh';
             st111.ownerid = UserInfo.getUserId();
             insert St111;
            // ST111.recordtypeid='0123E0000004JnP';
             //update st111;
//NSIBPM__SR__c!=null && stp.NSIBPM__SR__r.NSIBPM__Ultimate_SR_Menu_Text__c!=null && stp.NSIBPM__SR__r.NSIBPM__Ultimate_SR_Menu_Text__c!='')             
             NSIBPM__Step__c St121 = new  NSIBPM__Step__c();
             st121.NSIBPM__Step_No__c =73.0;
             st121.NSIBPM__Due_Date__c=datetime.newInstance(2017, 9, 15, 9, 30, 0);
             st121.NSIBPM__Parent_Step__c = st111.id;
             //ST12.recordtype.developername = 'General';
             //ST121.recordtypeid='0123E0000004JnP';
             st121.NSIBPM__SR__c = SR11.id;
             st121.NSIBPM__Step_Template__c = ST31.id;
             st121.NSIBPM__Status__c = status11.id;
             st121.NSIBPM__SR_Step__c = SRS121.id;
             st121.NSIBPM__Sys_Step_Loop_No__c ='10.0_1';
             st121.NSIBPM__Step_Notes__c = 'test area';
             sT121.OWNERID = testGroup11.id;
             insert St121; 
         
                      
        Contact con11 = new Contact();
         con11.AccountId = a11.Id;
         con11.email = 'test@gmail.com';
         con11.FirstName =  'Fname';
         con11.LastName = 'LName';
         insert con11;
        
       
        list<NSIBPM__Step__c> lstExistingSteps11 = new list<NSIBPM__Step__c>();
        lstExistingSteps11.add(St111);

        map<Id,string> mapStepTemplateQueues11 = new map<Id,string>();
        map<Id,string> mapSRTemplateQueues11 = new map<Id,String>();
            map<id,id> mapSROwner11= new map<id,id>();
            map<id,string> mapUserLicense11 = new map<id,string>();
            map<string,Id> mapStepRecType11 = new map<string,Id>();
            list<NSIBPM__SR_Steps__c> lstSRSteps11 = new list<NSIBPM__SR_Steps__c>();
            lstSRSteps11.add(SRS111);
            
     
    
  
      CC_Create_LoopTask LoopTask11 = new CC_Create_LoopTask();
      LoopTask11.GenerateLoopTask(lstExistingSteps11,mapStepQueues11,mapStepTemplateQueues11,mapSRStepQueues11,mapSRTemplateQueues11,
                                mapSROwner11,mapUserLicense11,mapStepRecType11,lstSRSteps11,Action11,St111);
                               
         
}

}
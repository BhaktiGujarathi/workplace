public class PublicGroupInfoTestData { 
     @future
     public  static void publicGroupInfoTestDataInsert(ID userID) 
     {
        
                
         Group queueObj = new Group(Name = 'CEPayableCreation',type='Queue');
         insert queueObj;
         
         
         
         Group masterGroupObj = new Group(Name = 'CEPayableCreation');
         insert masterGroupObj;
         
         GroupMember memberObj = new GroupMember(GroupId = queueObj.Id,
                                                 UserOrGroupId = masterGroupObj.id);
         insert memberObj;
         
         
         GroupMember member2Obj = new GroupMember(GroupId = masterGroupObj.Id,
                                                 UserOrGroupId = userID);
         insert member2Obj;
         
         /*MCACE__CEPayableCreation__c tempCEcreate = new MCACE__CEPayableCreation__c(name='CEPayableCreation',
                                   ownerID = queueObj.id);
         insert tempCEcreate;*/

         
       
     }  
}
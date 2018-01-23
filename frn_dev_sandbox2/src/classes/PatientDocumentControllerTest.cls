@isTest
private class PatientDocumentControllerTest 
{
 
    Static testMethod void PatientDocumentController_Test()
    {
        Contact con =new Contact();
       
        con.LastName ='test';
         insert con; 
        
       ApexPages.StandardController asd = new ApexPages.StandardController(con);
        PatientDocumentController lcu = new PatientDocumentController(asd);
        lcu.save();
        lcu.Cancel();
        lcu.getFileExtension('filename');
        
        
    }   
}
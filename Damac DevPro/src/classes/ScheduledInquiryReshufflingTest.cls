@istest
public class ScheduledInquiryReshufflingTest{


    static testmethod void testSchCls(){
    
    
        ScheduledInquiryReshuffling cls = new ScheduledInquiryReshuffling();
        
        test.starttest();
            String sch = '0 0 23 * * ?'; 
            system.schedule('ScheduledInquiryReshuffling', sch, cls); 
        Test.stopTest(); 
 
    
    }

}
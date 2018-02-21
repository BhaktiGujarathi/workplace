public class DemoGridController{

   
    Public list<innerWrapperClass> listWrapper {get;set;}
    Public innerWrapperClass objWrapper {get;set;}    
    public DemoGridController() {
        objWrapper = new innerWrapperClass(Schema.getGlobalDescribe().get('Account').newSObject(), 'Name' );
    }
    
    public class innerWrapperClass{
         public SObject sObj {get;set;}
         public String field{get;set;}
        public innerWrapperClass(SObject sObj , String  field)
            {
                this.sObj = sObj;
                this.field = field;
            
            }
    }
}
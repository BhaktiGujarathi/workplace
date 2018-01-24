public class DynamicTypeCasting {
   
   List<sobject> s=new List<sobject>();
 public List<sobject> getS() {
        return S;
    }




public void dynamic()
{


 s=[select id,assistantname from contact limit 1];


Map<String,schema.sobjectfield> fields1=new Map<String,schema.sobjectfield>();
fields1=s[0].getsobjecttype().getdescribe().fields.getmap();

system.debug('$$$$$$ '+fields1);


}


}
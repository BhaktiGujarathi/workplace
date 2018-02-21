public class LeadStatusUpdateExt
    {
        public ApexPages.StandardController stdCtrl {get; set;}
        public LeadStatusUpdateExt(ApexPages.StandardController stdCon)
            {
                stdCtrl = StdCon;
            }
         public PageReference dosave()
             {
                  if(stdCtrl != null)
                    {
                      Lead LeadObj = (Lead)stdCtrl.getRecord();
                      stdCtrl.save();
                    }
                  return null;
             }    
    }
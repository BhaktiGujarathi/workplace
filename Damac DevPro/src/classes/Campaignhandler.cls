/*
 * Campaignhandler class
 */
public class Campaignhandler {
    
      public static Map<string,string> mpCountryCode = new Map<string,string>();
      public static Map<string,string> mpCampaignCode = new Map<string,string>();
      public static Map<string,string> mpCampaignCategoryCode = new Map<string,string>();
      public static Map<string,string> mpCC1Code = new Map<string,string>();
      public static Map<string,string> mpCC2Code = new Map<string,string>();
      public static Map<string,string> mpRTCode = new Map<string,string>();
      public static Map<string,string> mpLanguageCode = new Map<string,string>();
      public static Map<Integer,String> mpMonth = new Map<Integer,String>();
      public static Map<Id,Recordtype> mpCampaignRTs = new Map<Id,Recordtype>();  
      public static Map<Id,Campaign__c> mpParentCampaign = new Map<Id,Campaign__c>();
    
      Public static void getCode(List<Campaign__c> lstCampaigns){
        
        //Get all record types
        mpCampaignRTs = new Map<Id,Recordtype>([select id,name,developername,SobjectType from recordtype where SobjectType = 'Campaign__c']);
        set<id> stCamParentids = new set<id>();
        //prepare set of parent campaign ids
        for(Campaign__c c : lstcampaigns){
            if(c.Parent_Campaign__c != null)
            	stCamParentids.add(c.Parent_Campaign__c);
        }
        //Prepare Map of parent campaigns
        mpParentCampaign = new Map<Id,Campaign__c>([select id,Campaign_Name__c,End_Date__c,RecordType.name from Campaign__c where id in : stCamParentids]);

        //Get the list of constants
        for(Constants__c csnt : [select id,name__c,Type__c,code__c from Constants__c]){
            if(csnt.Type__c == 'Campaign'){
                mpCampaignCode.put(csnt.name__c,csnt.code__c);
            }
            if(csnt.Type__c == 'Country'){
                mpCountryCode.put(csnt.name__c,csnt.code__c);
            }
            if(csnt.Type__c == 'Language'){
                mpLanguageCode.put(csnt.name__c,csnt.code__c);
            }
            if(csnt.Type__c == 'RecordType'){
                mpRTCode.put(csnt.name__c,csnt.code__c);
            }
            if(csnt.Type__c == 'Campaign Category'){
                mpCampaignCategoryCode.put(csnt.name__c,csnt.code__c);
            }
            if(csnt.Type__c == 'Campaign Sub Category 1'){
                mpCC1Code.put(csnt.name__c,csnt.code__c);
            }
            if(csnt.Type__c == 'Campaign Sub Category 2'){
                mpCC2Code.put(csnt.name__c,csnt.code__c);
            }
            if(csnt.Type__c == 'Month'){
                mpMonth.put(Integer.valueof(csnt.name__c),csnt.code__c);
            }
            
        }
        for(Campaign__c c : lstcampaigns){
            c.Campaign_Name__c = getCampaignCode(c);
        	    
        }
    }
    
	/*
    * Method to get the campaignname based on codes for each campaign field from constants object                 
    */
    public static String getCampaignCode(Campaign__c cmpgn){
        string campaignCode = '';
		boolean isENDDateEql = false;
        if(cmpgn.Parent_Campaign__c != null && mpParentCampaign.containskey(cmpgn.Parent_Campaign__c) && mpParentCampaign.get(cmpgn.Parent_Campaign__c) != null){
            if(mpParentCampaign.get(cmpgn.Parent_Campaign__c).Campaign_Name__c != null){
                campaignCode = mpParentCampaign.get(cmpgn.Parent_Campaign__c).Campaign_Name__c+'.';
                if(cmpgn.End_Date__c != null && mpParentCampaign.get(cmpgn.Parent_Campaign__c).End_Date__c != null && mpParentCampaign.get(cmpgn.Parent_Campaign__c).End_Date__c == cmpgn.End_Date__c && mpParentCampaign.get(cmpgn.Parent_Campaign__c).RecordType.name != 'Standalone' && (mpCampaignRTs.get(cmpgn.RecordTypeId).name != 'Standalone'))
                	isENDDateEql = true;
            }
        }
        //Record Type
        if(mpCampaignRTs.containskey(cmpgn.RecordTypeId) && mpRTCode.containskey(mpCampaignRTs.get(cmpgn.RecordTypeId).name)){
            system.debug('-entering->'+cmpgn.RecordTypeId+ '--mpCampaignRTs.get(cmpgn.RecordTypeId).name->'+mpCampaignRTs.get(cmpgn.RecordTypeId).name);
            if(mpCampaignRTs.get(cmpgn.RecordTypeId).name == 'Standalone'){
                return cmpgn.Campaign_Name__c;
            }
            else{
            	campaignCode = campaignCode+mpRTCode.get(mpCampaignRTs.get(cmpgn.RecordTypeId).name)+'-';
            }
        }
        //Campaign Type
        if(cmpgn.Campaign_Type_New__c != null && mpCampaignCode.containskey(cmpgn.Campaign_Type_New__c)){
            campaignCode = campaignCode+mpCampaignCode.get(cmpgn.Campaign_Type_New__c)+'-';
        }
        //Campaign Category
        if(cmpgn.Campaign_Category_New__c != null && mpCampaignCategoryCode.containskey(cmpgn.Campaign_Category_New__c)){
            campaignCode = campaignCode+mpCampaignCategoryCode.get(cmpgn.Campaign_Category_New__c)+'-';
        }
        //Campaign Category 1
        if(cmpgn.Campaign_Sub_Category_1__c != null && mpCC1Code.containskey(cmpgn.Campaign_Sub_Category_1__c)){
            campaignCode = campaignCode+mpCC1Code.get(cmpgn.Campaign_Sub_Category_1__c)+'-';
        }
        ////Campaign Category 2
        if(cmpgn.Campaign_Sub_Category_2__c != null && mpCC2Code.containskey(cmpgn.Campaign_Sub_Category_2__c)){
            campaignCode = campaignCode+mpCC2Code.get(cmpgn.Campaign_Sub_Category_2__c)+'-';
        }
        //Campaign Country
        if(cmpgn.Country__c != null && mpCountryCode.containskey(cmpgn.Country__c)){
            system.debug('inside Country'+mpCountryCode.get(cmpgn.Country__c));
            campaignCode = campaignCode+mpCountryCode.get(cmpgn.Country__c)+'-';
        }
        //Campaign City
        if(cmpgn.City__c != null){
            List<String> strCitySplitbyspace = cmpgn.City__c.split(' ');
            if(strCitySplitbyspace.size() ==1){
                campaignCode = campaignCode+strCitySplitbyspace[0].substring(0,3)+'-';
            }
            else if (strCitySplitbyspace.size() > 1){
                for(string strCitysplit : strCitySplitbyspace){
                    campaignCode = campaignCode+strCitysplit.substring(0,1);
                }
                campaignCode = campaignCode+'-';
            }
        }
        //Campaign Language
        if(cmpgn.Language__c != null && mpLanguageCode.containskey(cmpgn.Language__c)){
            campaignCode = campaignCode+mpLanguageCode.get(cmpgn.Language__c)+'-';
        }
        
        //Campaign End Date
        if(cmpgn.End_Date__c != null && !isENDDateEql){
            campaignCode = campaignCode+mpMonth.get(cmpgn.End_Date__c.Month())+cmpgn.End_Date__c.Day()+'-';
        }
        //str.substring(0,str.length()-1)
        if(campaignCode == ''){
            return cmpgn.Campaign_Name__c;
        }
        else
        	return campaignCode.substring(0,campaignCode.length()-1);
    }
}
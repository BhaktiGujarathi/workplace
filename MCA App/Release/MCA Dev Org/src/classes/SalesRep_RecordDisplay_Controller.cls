public class SalesRep_RecordDisplay_Controller {   
    public Sales_Rep_Report_Card__c salesRepObj {get;set;}

    public SalesRep_RecordDisplay_Controller(ApexPages.StandardController controller) {       
       salesRepObj = new Sales_Rep_Report_Card__c();
         
         salesRepObj = [Select s.Id,s.Last_7_days_Prospecting__c,s.Month_to_Date_Prospecting__c,s.Last_Month_Prospecting__c,
                        s.Year_to_Date_Prospecting__c,s.Last_7_days_App_Sent__c,s.Month_to_Date_App_Sent__c,
                        s.Last_Month_App_Sent__c,s.Year_to_Date_App_Sent__c,s.App_Sent_Total__c,s.Last_7_days_App_Received__c,
                        s.Month_to_Date_App_Received__c,s.Last_Month_App_Received__c,s.Year_to_Date_App_Received__c,
                        s.App_Received_Total__c,s.Approvals_Last_7_days__c,s.Approvals_MTD__c,s.Approvals_Last_Month__c,
                        s.Approvals_YTD__c,s.Approvals_Total__c,s.Last_7_days_Signed_Contracts__c,
                        s.Month_to_Date_Signed_Contracts__c,s.Last_Month_Signed_Contracts__c,s.Year_to_Date_Signed_Contracts__c,
                        s.Signed_Contracts_Total__c,s.Last_7_days_Funded__c,s.Month_to_Date_Funded__c,s.Last_Month_Funded__c,
                        s.Year_to_Date_Funded__c,s.Funded_Total__c,s.Last_7_days_Funding_Amount__c,s.Month_to_Date_Funding_Amount__c,
                        s.Last_Month_Funding_Amount__c,s.Year_to_Date_Funding_Amount__c,s.Funded_Dollar_Total__c,
                        s.Goal_App_Sent_MTD__c,s.Goal_percent_App_Sent_MTD__c,s.Goal_percent_App_Sent_MTDImage__c,
                        s.Goal_App_Rec_vd_MTD__c,s.Goal_percent_App_Rec_vd_MTD__c,s.Goal_percent_App_Rec_vd_MTDImage__c,
                        s.Goal_Approvals_MTD__c,s.Goal_percent_Approvals_MTD__c,s.Goal_Approvals_MTD_Image__c,
                        s.Goal_Signed_Contracts_MTD__c,s.Goal_percent_Signed_Contracts_MTD__c,
                        s.Goal_percent_Signed_Contracts_MTDImage__c,s.Goal_Funded_MTD__c,s.Goal_percent_Funded_MTD__c,
                        s.Goal_percent_Funded_MTDImage__c,s.Goal_Funding_Month_to_Date__c,s.Goal_percent_Funding_Month_to_Date__c,
                        s.Goal_percent_Funding_Month_to_DateImage__c,s.Leads_App_Sent__c,s.Goal_Leads_App_Sent__c,s.Goal_Percentage_Leads_App_Sent__c,s.Goal_Leads_App_Sent_Image__c,
                        s.App_Sent_App_Received__c,s.Goal_App_Sent_App_Received__c,s.Goal_Percentage_App_Sent_App_Received__c,s.Goal_App_Sent_App_Received_Image__c,
                        s.App_Received_Approvals__c,s.Goal_App_Received_Approvals__c,s.Goal_Percentage_App_Received_Approvals__c,s.Goal_App_Received_Approvals_Image__c,
                        s.Approvals_Contract__c,s.Goal_Approvals_Contract__c,s.Goal_Percentage_Approvals_Contract__c,s.Goal_Approvals_Contract_Image__c,
                        s.Contract_Funded__c,s.Goal_Contract_Funded__c,s.Goal_Percentage_Contract_Funded__c,s.Goal_Contract_Funded_Image__c
                        From Sales_Rep_Report_Card__c s where s.Id = :ApexPages.currentPage().getParameters().get('Id')];
    }   
  
}
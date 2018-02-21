public Class SCCalculateTimeLineHelper
{

 public Sales_Rep_Report_Card__c calculateBasedOnTimeLine(Sales_Rep_Report_Card__c scoreCard,Audit_Trail__c audtrail,Map<String,SCTimeframe_Metric__c> mapOfCustSetTimeFrame)
 {
    
            
            //Yesterday
            if(SCDateConstant.isDateInRangeOfStartAndEnd(SCDateConstant.startYesterdayDate,audtrail.Date_Time_Change_Was_Made__c.Date(),SCDateConstant.endYesterdayDate))
            {
                 
                 new SCCalculateScoreCardBasedOnTypeAndStage().calculateBasedOnTypeAndStage(scoreCard,audtrail,'Yesterday__c',mapOfCustSetTimeFrame); 
            
            }
    
            //For Last 7 days
            if(SCDateConstant.isDateInRangeOfStartAndEnd(SCDateConstant.startLast7DaysDate,audtrail.Date_Time_Change_Was_Made__c.Date(),SCDateConstant.endLast7DaysDate))
            {
             
                 new SCCalculateScoreCardBasedOnTypeAndStage().calculateBasedOnTypeAndStage(scoreCard,audtrail,'Last_7_Days__c',mapOfCustSetTimeFrame); 
            
            }
            
            
            //Month To date range
            if(SCDateConstant.isDateInRangeOfStartAndEnd(SCDateConstant.startMTDDate,audtrail.Date_Time_Change_Was_Made__c.Date(),SCDateConstant.endMTDDate ))
            {
             
                 new SCCalculateScoreCardBasedOnTypeAndStage().calculateBasedOnTypeAndStage(scoreCard,audtrail,'MTD__c',mapOfCustSetTimeFrame); 
            
            }
            
            
            //For Last Month
            if(SCDateConstant.isDateInRangeOfStartAndEnd(SCDateConstant.startLastMonthDate,audtrail.Date_Time_Change_Was_Made__c.Date(),SCDateConstant.endLastMonthDate))
            {
             
               new SCCalculateScoreCardBasedOnTypeAndStage().calculateBasedOnTypeAndStage(scoreCard,audtrail,'Last_Month__c',mapOfCustSetTimeFrame); 
            
            }
            
            
            //Year to date range
            if(SCDateConstant.isDateInRangeOfStartAndEnd(SCDateConstant.startYTDDate,audtrail.Date_Time_Change_Was_Made__c.Date(),SCDateConstant.endYTDDate))
            {
             
                new SCCalculateScoreCardBasedOnTypeAndStage().calculateBasedOnTypeAndStage(scoreCard,audtrail,'YTD__c',mapOfCustSetTimeFrame); 
            
            }
            
            return scoreCard;
    
 }



}
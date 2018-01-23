public with sharing class ScoreQualityReportController {

    public static Id opportunityId {get; set;}
    public static String opportunityRecordtypeName  {get; set;}

    @RemoteAction
    public static RecordScoreCalculationService.QualityReport getScoreReportDetails(Id pOpportunityId, String pOpportunityRecordtypeName){
        List<RecordScoreCalculationService.QualityReport> qualityReportList = RecordScoreCalculationService.getOpportunityScore(pOpportunityId,pOpportunityRecordtypeName);
        RecordScoreCalculationService.QualityReport opportunityScoreQuality;
        if(!qualityReportList.isEmpty()) {
            opportunityScoreQuality = qualityReportList[0];
        }
        return opportunityScoreQuality;
    }
}
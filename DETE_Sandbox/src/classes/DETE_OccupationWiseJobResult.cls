public with sharing class DETE_OccupationWiseJobResult {
  //Wrapper of Occupation Wise Job Results

        public Occupation__c occupation                 {get; set;}
        public List<DETE_JobLinkService.JobDetails> jobResultList     {get; set;}

}
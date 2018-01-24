public with sharing class DETE_JobLinkService {

    public static final String STR_KEYWORDS   = 'keywords=';
    public static final String STR_LOCATION   = 'location=';
    public static final String STR_RADIUS     = 'radius=';
    public static final String STR_RANGE      = '&per_page=50';
    public static final String STR_ENDPONTURL = 'https://joblink.delaware.gov/ada/r/search/jobs.json?';

    public class JobDetails{
        public String id                {get; set;}
        public String title             {get; set;}
        public String description       {get; set;}
        public String url               {get; set;}
        public String employer          {get; set;}
        public String location          {get; set;}

        public JobDetails(){
            id = '';
            title = '';
            description = '';
            url = '';
            employer = '';
            location = '';
        }
    }

    public static List<JobDetails> searchAvillableJobs(String keyword, String location, Decimal radius) {

        String endPointURL = DETE_JobLinkService.STR_ENDPONTURL;

        if( false == String.isBlank(keyword) ) {
            keyword = keyword.replace(DETE_Util.STR_SPACE, DETE_Util.STR_PLUS);
            endPointURL += DETE_JobLinkService.STR_KEYWORDS + keyword + STR_RANGE;
        }

        if(  false == String.isBlank(location)
          && null != radius) {

              if(endPointURL != DETE_JobLinkService.STR_ENDPONTURL ) {
                  endPointURL = endPointURL + '&';
              }

              endPointURL += STR_LOCATION + location + '&' + STR_RADIUS + radius;
          }

          System.debug('endPointURL : '+ endPointURL);

          HttpResponse httpResp = fetchRelatedJob(endPointURL);
          System.debug('Resp : '+ httpResp.getBody());

          String reponseBody = httpResp.getBody().replace('\n', '\\n');
        //   reponseBody = reponseBody.replace('\\n\\n\\n', '\\n');
        //   reponseBody = reponseBody.replace('\\n\\n', '\\n');

          List<JobDetails> jobDeailsList = (List<JobDetails>)JSON.deserialize(reponseBody, List<JobDetails>.class);

          return jobDeailsList;

    }

    public static HttpResponse fetchRelatedJob(String endPointURL) {

        if( true == String.isBlank(endPointURL) ) {
            return new HttpResponse();
        }

       // Instantiate a new http object
       Http http = new Http();

        // Instantiate a new HTTP request
       HttpRequest httpReq = new HttpRequest();
       httpReq.setEndpoint(endPointURL);
       httpReq.setMethod(DETE_Util.STR_GETMETHOD);

       System.debug('...httpReq' + httpReq);

       // Send the request, and return a response
       HttpResponse httpRes = http.send(httpReq);
       return httpRes;
    }

}
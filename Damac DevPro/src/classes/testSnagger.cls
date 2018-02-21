public with sharing class testSnagger {

//public void sendJSON(){

       /*HttpRequest snagRequest = createDefectRequest();
       HTTPResponse SnagResponse = SnaggerResponse(snagRequest);
        system.debug('--SnagResponse --' + SnagResponse);*/
     public static list<object> lstDefectData;
     public static map<string, object> mapDefectDetail;
     public static list<SNAGs__c> lstSnag;

    //public static HttpRequest createDefectRequest(String strLocationID, map<String, SNAGs__c> mapDefectIdWithSnags) {
    public static list<SNAGs__c> createDefectRequest(Id locationId, String strLocationID, map<String, SNAGs__c> mapDefectIdWithSnags) {
        lstSnag = new list<SNAGs__c>();
        string strAPIID = 'J7JjChOyr8O6jtDVfIStyov7lHZz2gvzXMTtSZF25FdR0GRWlMTPNppR5jrjjXdw';
        //string strLocationID = '2';
        string strEndPointURL = 'http://damac.snagrweb.com/training/api/defects?key=' + strAPIID + '&LocationID=' + strLocationID;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(strEndPointURL);
        req.setMethod('GET');
        req.setHeader('ACCEPT','application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        system.debug('--req-' + req);

        Http http = new Http();
        HTTPResponse res;
        res =  http.send(req);
        system.debug('--Snag Defect Response --' + res );
        system.debug('--snag Defect body--' + res.getBody());
        
        lstDefectData = (list<Object>)JSON.deserializeUntyped(res.getBody());
        system.debug('--lstDefectData--' + lstDefectData);
        
        for(Object objItem : lstDefectData){
            mapDefectDetail = (map<string,object>)objItem;
            
            String defectId = mapDefectDetail.get('ID')!=null? string.valueof(mapDefectDetail.get('ID')) : '';
            
            SNAGs__c objSNAGs = new SNAGs__c();
            
            if (mapDefectIdWithSnags.containsKey(defectId)) {
                objSNAGs = mapDefectIdWithSnags.get(defectId);
            }

            objSNAGs.Location__c = locationId;
            objSNAGs.Defect_ID__c = defectId;
            objSNAGs.Defect_Status__c = mapDefectDetail.get('Status')!=null? string.valueof(mapDefectDetail.get('Status')) : '';
            objSNAGs.Group_Name__c = mapDefectDetail.get('GroupName')!=null? string.valueof(mapDefectDetail.get('GroupName')) : '';
            objSNAGs.LocationID__c = mapDefectDetail.get('LocationID')!=null? string.valueof(mapDefectDetail.get('LocationID')) : '';
            objSNAGs.Location_Name__c = mapDefectDetail.get('Location')!=null? string.valueof(mapDefectDetail.get('Location')) : '';
            objSNAGs.Priority__c = mapDefectDetail.get('Priority')!=null? string.valueof(mapDefectDetail.get('Priority')) : '';
            objSNAGs.Project_Title__c = mapDefectDetail.get('ProjectTitle')!=null? string.valueof(mapDefectDetail.get('ProjectTitle')) : '';
            objSNAGs.SDCategory__c = mapDefectDetail.get('SDCategory')!=null? string.valueof(mapDefectDetail.get('SDCategory')) : '';
            objSNAGs.SD_CategoryID__c = mapDefectDetail.get('SDCategoryID')!=null? string.valueof(mapDefectDetail.get('SDCategoryID')) : '';
            objSNAGs.SDCode__c = mapDefectDetail.get('SDCode')!=null? string.valueof(mapDefectDetail.get('SDCode')) : '';
            objSNAGs.SD_Description__c = mapDefectDetail.get('SDDescription')!=null? string.valueof(mapDefectDetail.get('SDDescription')) : '';
            objSNAGs.SDID__c = mapDefectDetail.get('SDID')!=null? string.valueof(mapDefectDetail.get('SDID')) : '';
            objSNAGs.SDType__c = mapDefectDetail.get('SDType')!=null? string.valueof(mapDefectDetail.get('SDType')) : '';
            objSNAGs.User_Description__c = mapDefectDetail.get('UserDescription')!=null? string.valueof(mapDefectDetail.get('UserDescription')) : '';
            objSNAGs.Defect_Current_Status__c = mapDefectDetail.get('CurrentStatus')!=null? string.valueof(mapDefectDetail.get('CurrentStatus')) : '';
            //Date dueDate = date.valueof(mapDefectDetail.get('DueBy'));
            string strDueDate = string.valueof(mapDefectDetail.get('DueBy')).replace('T', ' ');
            //DateTime dtConverted = DateTime.newInstance(orig.year(), orig.month(), orig.day());
            objSNAGs.Due_By__c = mapDefectDetail.get('DueBy')!=null? DateTime.valueOf(strDueDate): null;
            lstSnag.add(objSNAGs);
        }//End for
        
        try {
            if(lstSnag!=null && lstSnag.size()>0){
               // upsert lstSnag;
            }
        }catch(DMLException errorMessage){
            
        }
        
       // return null;
       return lstSnag;
       //return req;
    }
    
    /*public static HttpRequest createScheduleRequest() {
       string strAPIID = 'J7JjChOyr8O6jtDVfIStyov7lHZz2gvzXMTtSZF25FdR0GRWlMTPNppR5jrjjXdw';
       string strEndPointURL = 'http://damac.snagrweb.com/training/api/schedules?key=' + strAPIID ;
       HttpRequest req = new HttpRequest();
       req.setEndpoint(strEndPointURL);
       req.setMethod('GET');
       req.setHeader('ACCEPT','application/json');
       req.setHeader('Content-Type', 'application/json');
       req.setTimeout(120000);
       system.debug('--req-' + req);

       Http http = new Http();
        HTTPResponse res;
        res =  http.send(req);
        system.debug('--Snag Schedule Response --' + res );
        system.debug('--snag Schedule body--' + res.getBody());
        return null;
       //return req;
    }
    
    public static HttpRequest createInspectionRequest() {
       string strAPIID = 'J7JjChOyr8O6jtDVfIStyov7lHZz2gvzXMTtSZF25FdR0GRWlMTPNppR5jrjjXdw';
       string strEndPointURL = 'http://damac.snagrweb.com/training/api/inspections?key=' + strAPIID ;
       HttpRequest req = new HttpRequest();
       req.setEndpoint(strEndPointURL);
       req.setMethod('GET');
       req.setHeader('ACCEPT','application/json');
       req.setHeader('Content-Type', 'application/json');
       req.setTimeout(120000);
       system.debug('--req-' + req);

       Http http = new Http();
        HTTPResponse res;
        res =  http.send(req);
        system.debug('--Snag inspections Response --' + res );
        system.debug('--snag inspections body--' + res.getBody());
        return null;
       //return req;
    }
    
    public static HttpRequest createInspectionDetails() {
       string strAPIID = 'J7JjChOyr8O6jtDVfIStyov7lHZz2gvzXMTtSZF25FdR0GRWlMTPNppR5jrjjXdw';
       string strInspectionID = '2';
       string strEndPointURL = 'http://damac.snagrweb.com/training/api/inspections/'+ strInspectionID + '?key=' + strAPIID ;
       HttpRequest req = new HttpRequest();
       req.setEndpoint(strEndPointURL);
       req.setMethod('GET');
       req.setHeader('ACCEPT','application/json');
       req.setHeader('Content-Type', 'application/json');
       req.setTimeout(120000);
       system.debug('--req-' + req);

       Http http = new Http();
        HTTPResponse res;
        res =  http.send(req);
        system.debug('--Snag inspections Response --' + res );
        system.debug('--snag inspections body--' + res.getBody());
        return null;
       //return req;
    }
    /*public static HttpResponse SnaggerResponse(HttpRequest httpReq){
        Http http = new Http();
        HTTPResponse res;
        res =  http.send(httpReq);
        return res;
    }//End*/
    
    //}//end sendJSON
}
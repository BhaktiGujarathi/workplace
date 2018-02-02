global class HttpCallForOppTier{
    webservice static string  callPost(String oppID){
        String xmlOutput = '';
        
        List<String> oppfields = new List<String>( Schema.getGlobalDescribe().get( 'Opportunity' ).getDescribe().fields.getMap().keySet());
        List<String> confields = new List<String>(Contact.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> pConfields = new List<String>(Patient_Contact__c.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> insfields = new List<String>(Patient_Insurance__c.SObjectType.getDescribe().fields.getMap().keySet());
        /* dynamically concat  all fields of the Opportunity,Patient_Contact__c,Patient_Insurance__c  into query*/
        String queryOpp = 'select recordtype.name,'+ String.join(oppfields, ',') +' ,( select '+ String.join(pConfields, ',') +' from Patient_Contacts__r), ( select ' + String.join(insfields, ',') +' from Patient_Insurances__r)  from opportunity where id =: oppID';
        Opportunity opportunity = Database.Query(queryOpp);
        
        /* dynamically concat the all fields of Contact into query*/
        if(opportunity != null){
            Contact contact = new Contact();
            if(opportunity.Contact__c !=null){
                String oppConatct = opportunity.Contact__c;
                System.debug(oppConatct);
                String queryCon = 'select '+ String.join(confields, ',') + ' from Contact where id =: oppConatct';
                contact = Database.Query(queryCon); 
            } 
                System.debug('contact::::'+contact);
                XmlStreamWriter w = new XmlStreamWriter();
                w.writeStartDocument(null, '1.0');
                //w.writeProcessingInstruction('target', 'data');
                w.writeStartElement(null, 'opportunity', null);
                w.writeStartElement(null, 'PatientID', null);
                 if(opportunity.Contact__c !=null){
                    w.writeCharacters(String.isNotBlank(contact.id) ? contact.id : ' ' );
                }else{
                    w.writeCharacters(' ' );
                }
                w.writeEndElement(); 
                
                w.writeStartElement(null, 'Legacy_TIER_ID', null);
                 if(opportunity.Contact__c !=null){
                    w.writeCharacters(String.isNotBlank(contact.Legacy_TIER_ID__c) ? contact.Legacy_TIER_ID__c : ' ' );
                }else{
                    w.writeCharacters(' ' );
                }
                
                w.writeEndElement(); 
				
			    w.writeStartElement(null, 'OpportunityRecordType', null);
				w.writeCharacters(opportunity.recordtype.name);
				w.writeEndElement();
                
                w.writeStartElement(null, 'opportunityID', null);
                w.writeCharacters(opportunity.id); 
                w.writeEndElement(); 

                w.writeStartElement(null, 'OpportunityStage', null);
                w.writeCharacters(opportunity.stagename); 
                w.writeEndElement(); 
                w.writeEndElement(); 
                
                xmlOutput = w.getXmlString();
                System.debug(xmlOutput);
                w.close();
        }
        String alrtmsg = '';
        if(xmlOutput != null) {
            String username='';
            String password='';
            String Endpoint='';
            try{
                Sent_to_TIER__c TIER = Sent_to_TIER__c.getInstance('Sent to TIER');
                if(TIER.Endpoint__c != null && TIER.Password__c !=null &&  TIER.Username__c != null){
                    Endpoint = TIER.Endpoint__c; 
                    username = TIER.Username__c;
                    password = TIER.Password__c;
                }
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                HttpResponse resp = new HttpResponse();
                

                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);

                req.setEndpoint(Endpoint);
                req.setHeader('Authorization', authorizationHeader);    
                req.setHeader('Content-Type', 'text/plain');  
                string msg = xmlOutput;
                 req.setBody(msg);               
                req.setMethod('POST'); 
                resp = http.send(req); 
                System.debug(resp.getBody()); 
                System.debug(resp.getStatusCode()); 
                 
                 if(resp.getStatusCode() == 200){ 
                     alrtmsg = 'Message Successfully Sent to TIER';
                 }else{
                     alrtmsg = 'Error in Sending Message Sent to TIER';
                 }
                Task ta = new Task();
                 ta.WhatId = oppID;
                 ta.Subject = alrtmsg;
                 ta.Description = xmlOutput;
                 ta.status = 'Not Started';
                 insert ta;
            }catch(Exception e){
                alrtmsg = 'Please Contact Administrator to Check the Settings';
            }
            
            
        }
       return alrtmsg;
   } 
}
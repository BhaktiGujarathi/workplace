public with sharing class OnDeckXMLParser {


	public static String getPrequalXML(OnDeckClient.BusinessData businessData) {
        XmlStreamWriter w = new XmlStreamWriter();
            w.writeStartElement(null,'PreQualificationRequest', null);
                w.writeAttribute(null, null, 'xmlns', 'http://xml.webconnect.odc.com/XMLSchema/v2');
                w.writeAttribute(null, null, 'xmlns:xs', 'http://xml.webconnect.odc.com/XMLSchema');
				
				//Header Information
				writeHeader(w);
				
				//Business Information
                w.writeStartElement(null, 'Business', null);
                    if (businessData.businessName != null) {
                    w.writeStartElement(null, 'Name', null);
                        w.writeCharacters(businessData.businessName);
                    w.writeEndElement(); 
                    }
                    
                    if (businessData.doingBusinessAs != null) {
                    w.writeStartElement(null, 'DoingBusinessAs', null);
                        w.writeCharacters(businessData.doingBusinessAs);
                    w.writeEndElement();
                    }

                    w.writeStartElement(null, 'SelfReportedCashFlow', null);
                		if (businessData.annualRevenue != null) {                        
                        w.writeStartElement(null, 'AnnualRevenue', null);
                            w.writeCharacters(string.valueof(businessData.annualRevenue));
                        w.writeEndElement();
                		}
                	
                		if (businessData.averageBankBalance != null) {
                        w.writeStartElement(null, 'AverageBankBalance', null);
                            w.writeCharacters(string.valueof(businessData.averageBankBalance));
                        w.writeEndElement();
                		}
                	
                		if (businessData.averageCreditCardVolume != null) {
                        w.writeStartElement(null, 'AverageCreditCardVolume', null);
                            w.writeCharacters(String.valueof(businessData.averageCreditCardVolume));
                        w.writeEndElement();
                		}
                    w.writeEndElement();
					
					if (businessData.businessIndustry != null) {	
                    w.writeStartElement(null, 'SelfReportedIndustry', null);
                        w.writeCharacters(businessData.businessIndustry);
                    w.writeEndElement();
					}
					
					// Business Address
					writeAddress(w, 'Address', businessData.address);
					
					if (businessData.taxID != null) {
                    w.writeStartElement(null, 'TaxID', null);
                        w.writeCharacters(businessData.taxID);
                    w.writeEndElement();
					}
				
					if (businessData.businessPhone != null) {
                    w.writeStartElement(null, 'Phone', null);
                        w.writeCharacters(formatString(businessData.businessPhone));
                    w.writeEndElement();
					}
				
               		if (businessData.businessInceptionDate != null) {                               
                    w.writeStartElement(null, 'BusinessInceptionDate', null);
                        w.writeCharacters(Datetime.newInstance(businessData.businessInceptionDate.year(), businessData.businessInceptionDate.month(), businessData.businessInceptionDate.day()).format('yyyy-MM-dd'));
                    w.writeEndElement();
                	}
	
					if (businessData.businessID != null) {
                    w.writeStartElement(null, 'BusinessID', null);
                        w.writeCharacters(businessData.businessID);
                    w.writeEndElement();
					}
				
                w.writeEndElement();

				//Owner 1 Information
				if (businessData.owner1 != null) {
				writeOwner(w, 'Owner', businessData.owner1);
				}
				
				//Owner 2 Information
				if (businessData.owner2 != null) {
				writeOwner(w, 'OwnerTwo', businessData.owner2);
				}
                
            w.writeEndElement();
		
            String prequalXML = w.getXMLString();

        w.close();
        
        return prequalXML;	
	}
	
	
	public static String getSubmitXML(OnDeckClient.BusinessData businessData) {
		XmlStreamWriter w = new XmlStreamWriter();
           w.writeStartElement(null,'SubmitApplicationRequest', null);
                w.writeAttribute(null, null, 'xmlns', 'http://xml.submit.application.webconnect.odc.com/XMLSchema');
                w.writeAttribute(null, null, 'xmlns:xs', 'http://xml.webconnect.odc.com/XMLSchema');
            
            	writeHeader(w);
            	
             	//Owner 1 Email
             	if (businessData.owner1.email != null) {
                w.writeStartElement(null, 'ContactEmail', null);
                    w.writeCharacters(businessData.owner1.email);
                w.writeEndElement();            	
             	}
             	
                w.writeStartElement(null, 'Business', null);                    
                    if (businessData.businessName != null) {
                    w.writeStartElement(null, 'Name', null);
                        w.writeCharacters(businessData.businessName);
                    w.writeEndElement(); 
                    }

					if (businessData.doingBusinessAs != null) {
                    w.writeStartElement(null, 'DoingBusinessAs', null);
                        w.writeCharacters(businessData.doingBusinessAs);
                    w.writeEndElement();
					}
					
                    w.writeStartElement(null, 'SelfReportedCashFlow', null);
                		if (businessData.annualRevenue != null) {                        
                        w.writeStartElement(null, 'AnnualRevenue', null);
                            w.writeCharacters(String.valueOf(businessData.annualRevenue));
                        w.writeEndElement();
                		}
                	
                		if (businessData.averageBankBalance != null) {
                        w.writeStartElement(null, 'AverageBankBalance', null);
                            w.writeCharacters(String.valueOf(businessData.averageBankBalance));
                        w.writeEndElement();
                		}
                	
                		if (businessData.averageCreditCardVolume != null) {
                        w.writeStartElement(null, 'AverageCreditCardVolume', null);
                            w.writeCharacters(String.valueOf(businessData.averageCreditCardVolume));
                        w.writeEndElement();
                		}
                    w.writeEndElement();           
                    
					if (businessData.businessIndustry != null) {	
                    w.writeStartElement(null, 'SelfReportedIndustry', null);
                        w.writeCharacters(businessData.businessIndustry);
                    w.writeEndElement();
					}
				
                    //w.writeStartElement(null, 'SubIndustry', null);
                    //    w.writeCharacters(businessSubIndustry);
                    //w.writeEndElement();//close SubIndustry
                    
                    if (businessData.loanPurpose != null) {                     
                    w.writeStartElement(null, 'LoanPurpose', null);
                        w.writeCharacters(businessData.loanPurpose);
                    w.writeEndElement();                    
                    }
                    
  					// Business Address
					writeAddress(w, 'Address', businessData.address);


					if (businessData.taxID != null) {
                    w.writeStartElement(null, 'TaxID', null);
                        w.writeCharacters(businessData.taxID);
                    w.writeEndElement();
					}

					if (businessData.businessPhone != null) {
                    w.writeStartElement(null, 'Phone', null);
                        w.writeCharacters(formatString(businessData.businessPhone));
                    w.writeEndElement();
					}

					if (businessData.businessID != null) {
                    w.writeStartElement(null, 'BusinessID', null);
                        w.writeCharacters(businessData.businessID);
                    w.writeEndElement();
					}
                w.writeEndElement();

				//Owner 1 Information
				if (businessData.owner1 != null) {
				writeOwner(w, 'Owner1', businessData.owner1, 'Phone');
				}
                  
                    
                    				
				//Owner 2 Information
				if (businessData.owner2 != null) {
				writeOwner(w, 'Owner2', businessData.owner2, 'Phone');
				}               
            	
            w.writeEndElement();    
        	String submitXML = w.getXMLString();        		
		
		w.close();
		
		return submitXML;
	}
	
	
	private static void writeHeader(XmlStreamWriter w) {
		String apiId;
		
		Bank_API_Settings__c settings = Bank_API_Settings__c.getInstance('OnDeck');
		if (settings != null) {
			apiId = settings.Attribute_1__c;
		}
		
		Datetime requestDate = System.now();
        String now = String.valueOf(System.now()).substring(0, 16);

		w.writeStartElement(null, 'RequestHeader', null);
		    w.writeStartElement('xs', 'RequestID', 'http://xml.webconnect.odc.com/XMLSchema/v2');
		        w.writeCharacters('RequestID');
		    w.writeEndElement();
		
		    w.writeStartElement('xs', 'RequestDate', 'http://xml.webconnect.odc.com/XMLSchema/v2');
		        w.writeCharacters(requestDate.format('yyyy-MM-dd'));
		    w.writeEndElement(); 
		
		    w.writeStartElement('xs', 'APIUserID', 'http://xml.webconnect.odc.com/XMLSchema/v2');
		        w.writeCharacters(apiId);
		    w.writeEndElement();
		
		w.writeEndElement();      	
	}
	
	
	private static String formatString(String s) {
		if (s != null) {
			return s.replaceAll('[\\s\\-()]', '');
		}
		return '';
	}
	
	
	private static String formatDate(Date d) {
		if (d != null) {
			return Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd');	
		}
		return '';
	}
	
	
	private static void writeOwner(XmlStreamWriter w, String tagName, OnDeckClient.Owner owner) {
		writeOwner(w, tagName, owner, 'HomePhone');
	}
	
	
	private static void writeOwner(XmlStreamWriter w, String tagName, OnDeckClient.Owner owner, String phoneTagName) {
		w.writeStartElement(null, tagName, null);
		    
		if (owner.email != null) {
		    w.writeStartElement(null, 'Email', null);
		        w.writeCharacters(owner.email);
		    w.writeEndElement();
		}
		
		if (owner.phone != null) {
		    w.writeStartElement(null, phoneTagName, null);
		        w.writeCharacters(formatString(owner.phone));
		    w.writeEndElement();
		}
		
		
		if (owner.name != null) {
		    w.writeStartElement(null, 'Name', null);
		        w.writeCharacters(owner.name);
		    w.writeEndElement();
		}
		
		writeAddress(w, 'Address', owner.address);
		
		if (owner.ssn != null) {
		    w.writeStartElement(null, 'SSN', null);
		        w.writeCharacters(formatString(owner.ssn));
		    w.writeEndElement();
		}
		
		if (owner.dob != null) {                                
		    w.writeStartElement(null, 'DateOfBirth', null);
		        w.writeCharacters(formatDate(owner.dob));
		    w.writeEndElement();
		}                  
		
		if (owner.ownershipPercentage != null) {
  			w.writeStartElement(null, 'OwnershipPercentage', null);
                w.writeCharacters(String.valueOf(owner.ownershipPercentage));
            w.writeEndElement();
		}		  
		
		w.writeEndElement();
	}
	
	
	private static void writeAddress(XmlStreamWriter w, String tagName, OnDeckClient.Address address) {
		    w.writeStartElement(null, tagName, null);
		    
		    if (address.street != null) {
		        w.writeStartElement(null, 'Address1', null);
		            w.writeCharacters(address.street);
		        w.writeEndElement();
		    }
		    
		        //w.writeStartElement(null, 'Address2', null);
		        //    w.writeCharacters(owner1Address2);
		        //w.writeEndElement();
		    
		    if (address.city != null) {
		        w.writeStartElement(null, 'City', null);
		            w.writeCharacters(address.city);
		        w.writeEndElement();
		    }
		    
		    if (address.state != null) {
		        w.writeStartElement(null, 'State', null);
		            w.writeCharacters(address.state);
		        w.writeEndElement();
		    }
		    
		    if (address.zip != null) {
		        w.writeStartElement(null, 'Zip', null);
		            w.writeCharacters(address.zip);
		        w.writeEndElement();
		    }
		    w.writeEndElement();
	}
	
	
	public static void processPrequalResponse(OnDeckClient.BusinessData businessData, String xmlResponse) {
        XmlStreamReader r = new Xmlstreamreader(xmlResponse);
		businessData.errorCodes.clear();
		businessData.errorDescriptions.clear();

        try {
            while (r.hasNext())  {
				if (r.getEventType() == XmlTag.START_ELEMENT) {
                	if (r.getLocalName() == 'Prequalified') {
						r.next();
                        businessData.prequalified = r.getText();
					}
                    if (r.getLocalName() == 'LoanAmount') {
                        r.next();
                        businessData.prequalAmount = r.getText(); 
                    }
                    if (r.getLocalName() == 'Term') {
                        r.next();  
                        businessData.prequalTerm = r.getText();  
					}
                    if (r.getLocalName() == 'URL') {
                        r.next();  
                        businessData.url = r.getText();
                    }
                    if (r.getLocalName() == 'BusinessID') {
                        r.next();  
                        businessData.businessID = r.getText(); 
                    } 
                    if (r.getLocalName() == 'PulledBusinessCredit') {
                        r.next();  
                        businessData.businessCredit = r.getText(); 
                    } 
                    if (r.getLocalName() == 'PulledPersonalCredit') {
                        r.next();  
                        businessData.personalCredit = r.getText(); 
                    }    
                    if (r.getLocalName() == 'Code') {
                        r.next();  
                        businessData.errorCodes.add(r.getText());
                    }      
                    if (r.getLocalName() == 'Description') {
                        r.next();  
                        businessData.errorDescriptions.add(r.getText().replace('.', ' '));
                    }              
                    if (r.getLocalName() == 'ErrorMessages') {
                    	r.next();
                    	r.next();
                    	businessData.errorDescriptions.add(r.getText().replace('.', ' '));
                    	r.next();
                    }                                                              
                }         
                r.next();
            }
        }
        catch (Exception e) {}	
	}
	
	
	public static void processSubmitResponse(OnDeckClient.BusinessData businessData, String xmlResponse) {
        XmlStreamReader r = new Xmlstreamreader(xmlResponse);
		businessData.errorCodes.clear();
		businessData.errorDescriptions.clear();

        try {
            while (r.hasNext())  {
				if (r.getEventType() == XmlTag.START_ELEMENT) {
                        if (r.getLocalName() == 'DecisionStatus') {
                            r.next();
                            businessData.decisionStatus = r.getText();
                        }
                        if (r.getLocalName() == 'CompanyName') {
                            r.next();
                            businessData.companyName = r.getText(); 
                        }
                        if (r.getLocalName() == 'ApplicationNumber') {
                            r.next();  
                            businessData.applicationNumber = r.getText();  
                        }
                        if (r.getLocalName() == 'BusinessID') {
                            r.next();  
                            businessData.businessID = r.getText(); 
                            } 
                        if (r.getLocalName() == 'Code') {
                            r.next();  
                           businessData.errorCodes.add(r.getText().replace('.', ' '));
                        }      
                        if (r.getLocalName() == 'Description') {
                            r.next();  
                            businessData.errorDescriptions.add(r.getText().replace('.', ' '));
                        }        
	                    if (r.getLocalName() == 'ErrorMessages') {
	                    	r.next();
	                    	r.next();
	                    	businessData.errorDescriptions.add(r.getText().replace('.', ' '));
	                    	r.next();
	                    }                                                                                
                }         
                r.next();
            }
        }
        catch (Exception e) {}		
	}
}
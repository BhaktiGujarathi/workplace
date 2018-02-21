public with sharing class ApplicationSubmissionController {
	
	public String stage { get; set; }
	public String logoId { get; set; }
	public String email { get; set; }
	public String applicationNumber { get; set; }
	public String error { get; set; }
	//public String helpText { get; set; }
	
	public Application__c app { get; set; }

	public Application_Document__c bankStatement { get; set; }
	public Application_Document__c creditCardStatement { get; set; }
	public Application_Document__c driverLicense { get; set; }
	public Application_Document__c voidedCheck { get; set; }

	public transient Blob bankStatementsFileBody { get; set; }
    public transient Blob creditCardStmtsFileBody { get; set; }
    public transient Blob driversLicenseFileBody { get; set; }
    public transient Blob voidedCheckFileBody { get; set; }	
    
    public Application_Portal_Settings__c settings { get; set; }
    
    public SelectOption[] industries {get; set;}
	
	public ApplicationSubmissionController() {

        settings = Application_Portal_Settings__c.getOrgDefaults();

        if (settings == null) {
        	settings = new Application_Portal_Settings__c();
        }

        Schema.DescribeFieldResult f = Lead.Industry.getDescribe();
        List<Schema.PicklistEntry> elems = f.getPicklistValues();

        industries = new SelectOption[] {};
        for (Schema.PicklistEntry elem :elems) {
            industries.add(new SelectOption(elem.getLabel(), elem.getLabel()));
        }

		stage = 'stage1';
		
		for (Document d : [select Id from Document where DeveloperName = 'Application_Site_Logo' limit 1]) {
			logoId = d.Id;
		}		

		app = new Application__c();

		bankStatement = new Application_Document__c();
		creditCardStatement = new Application_Document__c();
		driverLicense = new Application_Document__c();
		voidedCheck = new Application_Document__c();

		queryApplicationById(ApexPages.currentPage().getParameters().get('id'));
		
		if (app.Id == null) {
			queryLead(ApexPages.currentPage().getParameters().get('lid'));
		}


		if (ApexPages.currentPage().getParameters().get('oid') != null) {

			app.Opportunity__c = ApexPages.currentPage().getParameters().get('oid');
		}
	}
	
	
	private void queryLead(String leadId) {
		Lead lead;
		if (leadId != null) {
			for (Lead l : [select Id
			                    , Street
			                    , City
			                    , State
			                    , PostalCode
			                    , Country 
			                    , Company
			                    , Email
			                    , Phone
			                    , FirstName
			                    , LastName
			                    //, Years_in_Business__c
			                    //, Monthly_Gross_Sales__c
			                    //, Average_Monthly_CC_Sale__c
			                    //, Purpose_of_Funding__c
			                    , Industry
			                 from Lead
			                where Id = : leadId]) {
				lead = l;
			}
			
			app.Business_Name__c = lead.Company; 
			app.First_Name__c = lead.FirstName;
			app.Last_Name__c = lead.LastName;
			app.Business_Phone__c = lead.Phone;
			app.Email_Address__c = lead.Email; 
			//app.Years_in_Business__c = lead.Years_in_Business__c;
			//app.Montly_Gross_Sales__c = lead.Monthly_Gross_Sales__c;
			//app.Monthly_Credit_Card_Sales__c = lead.Average_Monthly_CC_Sale__c;
			app.Address_Line_1__c = lead.Street;
			app.City__c = lead.City;
			app.State__c = lead.State;
			app.Zip_Postal_Code__c = lead.PostalCode;
			//app.Purpose_of_Funding__c = lead.Purpose_of_Funding__c;
			app.Industry__c = lead.Industry;
			app.Lead__c = lead.Id;
		}
	}


	private void queryApplicationById(String aid) {
		if (aid != null) {
			for (Application__c a : [select Business_Name__c
											, First_Name__c
											, Last_Name__c
											, Business_Phone__c   
											, Email_Address__c
											, Current_Loan_Balances__c
											, Amount_Requested__c
											, Years_in_Business__c
											, Montly_Gross_Sales__c
											, Monthly_Credit_Card_Sales__c
											, Address_Line_1__c
											, Address_Line_2__c
											, City__c
											, State__c
											, Zip_Postal_Code__c
											, Purpose_of_Funding__c
											, Industry__c
											, Federal_Tax_ID__c
											, Owner_1_First_Name__c
											, Owner_1_Last_Name__c 
											, Owner_1_Email_Address__c
											, Owner_1_Home_Phone__c
											, Owner_1_Mobile__c
											, Owner_1_SSN__c
											, Owner_1_Ownership__c
											, Owner_2_First_Name__c
											, Owner_2_Last_Name__c 
											, Owner_2_Email_Address__c
											, Owner_2_Home_Phone__c
											, Owner_2_Mobile__c
											, Owner_2_SSN__c
											, Owner_2_Ownership__c
											, Stage__c
											, Submitted_Time__c
											, Submitted_By_Client__c
										 from Application__c
										where Id = :aid]) {
				app = a;

				if (a.Stage__c == 'Business Information') {
                    stage = 'stage1';
                }
                else if (a.Stage__c == 'Personal Information') {
                    stage = 'stage2';
                }
                else if (a.Stage__c == 'Upload Attachments') {
                    stage = 'stage3';
                }
                else if (a.Stage__c == 'Submit') {
                    stage = 'stage4';
                }
			}

			for (Application_Document__c ad : [select Name
													, File_Name__c
													, Attachment_Id__c
												 from Application_Document__c
												where Application__c = :aid]) {
				if (ad.Name == 'Bank Statement') {
					bankStatement = ad;
				}
				else if (ad.Name == 'Credit Card Statement') {
					creditCardStatement = ad;
				}
				else if (ad.Name == 'Copy of Drivers License') {
					driverLicense = ad;
				}
				else if (ad.Name == 'Copy of Voided Check') {
					voidedCheck = ad;
				}
			}

		}
	}	
	
	
	public void queryApplicationByApplicationNumber() {
		String aid;
        if (applicationNumber != null) {
            for (Application__c a : [select Business_Name__c
                                            , First_Name__c
                                            , Last_Name__c
                                            , Business_Phone__c   
                                            , Email_Address__c
                                            , Current_Loan_Balances__c
                                            , Amount_Requested__c
                                            , Years_in_Business__c
                                            , Montly_Gross_Sales__c
                                            , Monthly_Credit_Card_Sales__c
                                            , Address_Line_1__c
                                            , Address_Line_2__c
                                            , City__c
                                            , State__c
                                            , Zip_Postal_Code__c
                                            , Purpose_of_Funding__c
                                            , Industry__c
                                            , Federal_Tax_ID__c
                                            , Owner_1_First_Name__c
                                            , Owner_1_Last_Name__c 
                                            , Owner_1_Email_Address__c
                                            , Owner_1_Home_Phone__c
                                            , Owner_1_Mobile__c
                                            , Owner_1_SSN__c
                                            , Owner_1_Ownership__c
                                            , Owner_2_First_Name__c
                                            , Owner_2_Last_Name__c 
                                            , Owner_2_Email_Address__c
                                            , Owner_2_Home_Phone__c
                                            , Owner_2_Mobile__c
                                            , Owner_2_SSN__c
                                            , Owner_2_Ownership__c
                                            , Stage__c
                                            , Submitted_Time__c
                                            , Submitted_By_Client__c
                                         from Application__c
                                        where Name = :applicationNumber
                                          and Email_Address__c = :email]) {
                app = a;
                aid = a.Id;

                if (a.Stage__c == 'Business Information') {
                    stage = 'stage1';
                }
                else if (a.Stage__c == 'Personal Information') {
                    stage = 'stage2';
                }
                else if (a.Stage__c == 'Upload Attachments') {
                    stage = 'stage3';
                }
                else if (a.Stage__c == 'Submit') {
                    stage = 'stage4';
                }
            }

            for (Application_Document__c ad : [select Name
                                                    , File_Name__c
                                                    , Attachment_Id__c
                                                 from Application_Document__c
                                                where Application__c = :aid]) {
                if (ad.Name == 'Bank Statement') {
                    bankStatement = ad;
                }
                else if (ad.Name == 'Credit Card Statement') {
                    creditCardStatement = ad;
                }
                else if (ad.Name == 'Copy of Drivers License') {
                    driverLicense = ad;
                }
                else if (ad.Name == 'Copy of Voided Check') {
                    voidedCheck = ad;
                }
            }

        }
        
        if (aid == null) {
        	error = '* There is no application for the email ' + email + ' or the application number ' + applicationNumber + ' is incorrect. Please review'; 
        }
        else {
        	error = '';
        }
        
    }   


	public void changeStage() {
		error = '';
		
		if (stage == 'stage4') {
			addDocument(bankStatement, 'Bank Statement', bankStatementsFileBody);						
			addDocument(creditCardStatement, 'Credit Card Statement', creditCardStmtsFileBody);						
			addDocument(driverLicense, 'Copy of Drivers License', driversLicenseFileBody);						
			addDocument(voidedCheck, 'Copy of Voided Check', voidedCheckFileBody);						
		}
	}


	private void addDocument(Application_Document__c doc, String docName, Blob file) {
		if (file != null) {
			save();

			if (doc.Application__c == null) {
				doc.Application__c = app.Id;
			}

			doc.Name = docName;
			upsert doc;

			Attachment a = (doc.Attachment_Id__c != null ? new Attachment(Id = doc.Attachment_Id__c) : new Attachment(ParentId = app.Id));
			a.Name = doc.File_Name__c;
			a.Body = file;
			upsert a;

			doc.Attachment_Id__c = a.Id;
			update doc;
		}
	}


	public void save() {
		if (stage == 'stage1') {
			app.Stage__c = 'Business Information';
		}
		else if (stage == 'stage2') {
			app.Stage__c = 'Personal Information';
			app.Owner_1_Email_Address__c = app.Email_Address__c;
            app.Owner_1_First_Name__c = app.First_Name__c;
            app.Owner_1_Last_Name__c = app.Last_Name__c;
            app.Owner_1_Home_Phone__c = app.Business_Phone__c;
		}
		else if (stage == 'stage3') {
			app.Stage__c = 'Upload Attachments';
		}
		else if (stage == 'stage4') {
			app.Stage__c = 'Submit';
		}
		upsert app;
	}


	public PageReference submitApplication() {
		app.Submitted_Time__c = DateTime.now();
		app.Submitted_By_Client__c = true;
		app.Stage__c = 'Completed';

        stage = 'stage5';
        save();

        if (settings.Return_URL__c != null) {

            PageReference p = new PageReference(settings.Return_URL__c);
            p.setRedirect(true);

            System.debug('PageReference p ' + p);
            return p;
        }
        
		
        return null;
	}

	
	public void deleteAttachment() {
		String aid = ApexPages.currentPage().getParameters().get('aid');
		
		if (aid == bankStatement.Id) {
			delete bankStatement;
			bankStatement = new Application_Document__c();
		}
		else if (aid == creditCardStatement.Id) {
			delete creditCardStatement;
			creditCardStatement = new Application_Document__c();
		}
		else if (aid == driverLicense.Id) {
			delete driverLicense;
			driverLicense = new Application_Document__c();
		}
		else if (aid == voidedCheck.Id) {
			delete voidedCheck;
			voidedCheck = new Application_Document__c();
		}
	}	
}
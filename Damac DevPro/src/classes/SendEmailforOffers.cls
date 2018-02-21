public with sharing class SendEmailforOffers {
	
	private String strOffers;
	public SendEmailforOffers(ApexPages.standardController controller){ 
        
    }//End constructor
    
    public pagereference init(){
    	 string strPageID = ApexPages.currentPage().getParameters().get('id');
    	 for (Property__c objProperty : [Select Id, Offers__c From Property__c Where Id =: strPageID]){
    		strOffers = objProperty.Offers__c;
    	}
    	 set<Id> setInventoryId = new set<Id>();
    	 
    	 for (Inventory__c objInventory : [Select Id From Inventory__c Where Property__c =: strPageID]){
    	 	setInventoryId.add(objInventory.id);
    	 }
    	 list<Booking_Unit__c> lstBU = new list<Booking_Unit__c>();
    	 list<Booking_Unit__c> lstBookingUnits = [Select Id, Area_Varied__c, Availed_Offers__c, Document_Received__c, 
    	 											Payment_Received__c, Finance_Flag__c, DSR_Flag__c, Early_Handover__c,
    	 											Eligible_For_Rental_Pool__c, Handover_Flag__c, Rental_Pool__c,
    	 											Customer_Status__c, Deposit_Received__c, Email__c, Mortgage_Applied__c
    	 										From Booking_Unit__c Where Inventory__c IN: setInventoryId];
    	 										
   		 for (Booking_Unit__c objBU : lstBookingUnits) {
   		 	objBU.Document_Received__c = true;
   		 	objBU.Payment_Received__c = true;
   		 	objBU.Deposit_Received__c = false;
   		 	objBU.Customer_Status__c = 'Payment Dues';
   		 	objBU.Offers_Available__c = strOffers;
   		 	lstBU.add(objBU);
   		 }
   		 update lstBU;
   		 decideOffers(lstBU);
    	 
    	pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
        newpg.setRedirect(true);
        return newpg;
    }
    
    
    public void decideOffers(list<Booking_Unit__c> lstBookUnits) {
    	
    	set<String> setOffers = new set<String>();
    	for (String strKey: strOffers.split(',')){
    		setOffers.add(strKey);
    	}
    	Set<String> offersForCustomer; 
    	map<Booking_Unit__c, set<String>> mapBookingUnitOffers = new map<Booking_Unit__c, set<String>>();
    	for (Booking_Unit__c objBU : lstBookUnits) {
    		offersForCustomer = new Set<String>();
    		if (objBU.Document_Received__c = false){
    			
    		} if (objBU.Payment_Received__c = false){
    			
    		}if (objBU.Availed_Offers__c != null) {
    			for (String strKey: objBU.Availed_Offers__c.split(',')){
    				if (!setOffers.contains(strKey)) {
    					offersForCustomer.add(strKey);
    				}
    			}
    		}
    		mapBookingUnitOffers.put(objBU, offersForCustomer);
    	}
    	sendEmail(mapBookingUnitOffers);
    }
    
    public void sendEmail(map<Booking_Unit__c, set<String>> mapBookingUnitOffers) {
    	list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>();
    	list<Task> lstTask = new list<Task>();
    	for (Booking_Unit__c objBU : mapBookingUnitOffers.keyset()) {
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    		string strOffersToSend;
    		for (string strOffer : mapBookingUnitOffers.get(objBU)) {
    			if (strOffersToSend == '') {
    				strOffersToSend = strOffer;
    			} else {
    				strOffersToSend = strOffersToSend + ', ' + strOffer;
    			}
    		}
    		list<String> lstEmail = new list<String>();
    		if (objBU.Email__c != null) {
	    		lstEmail.add(objBU.Email__c);
	    		String strBody = 'Following Offers are valid for you' + strOffersToSend;
	    		mail.setSubject('Offers for Unit');
	    		mail.ToAddresses = lstEmail;
	    		mail.setHtmlBody(strBody);
	    		mails.add(mail);
    		}
    		
    		Task objTask = new Task();
    		objTask.Subject = 'Call Customers for Offers';
			objTask.Status = 'Not Started';
			objTask.Priority = 'Medium';
			objTask.ownerId = '0050Y000001SC4L';
			objTask.WhatId = objBU.id;
			objTask.Process_Name__c = 'Handover';
			lstTask.add(objTask);
    	}
    	if (mails != null && mails.size() > 0) {
    		Messaging.sendEmail(mails);
    	}
    	if (lstTask != null && lstTask.size() > 0) {
    		insert lstTask;
    	}
    }
}
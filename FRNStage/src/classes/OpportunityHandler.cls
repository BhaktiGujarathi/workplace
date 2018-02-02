/**
 * Class OpportunityHandler
 *
 * Trigger Handler for the Opportunity SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class OpportunityHandler implements TriggerInterface {
    
    Map<Id,List<Legal_Offense__c>> oppLgOMap;
    Map<Id,String> recordtypename;
    Map<String,PriceBookEntry> prMap;
    Map<Id,List<Referral__c>> RefMap;
    Map<Id,List<Abused_Substance__c>> oppAsbMap;
    Map<Id,List<Medical_Problem_Symptom__c>> oppMPSMap;
    Map<Id,List<Treatment_History__c>> oppPyTHMap;
    Map<Id,List<Psychiatric_Diagnosis__c>> oppPyDMap;
    Map<Id,List<Prescription_Medication__c>> oppPMMap;
    List<Legal_Offense__c> lgOffList;
    List<Abused_Substance__c> absList;
    List<Medical_Problem_Symptom__c> mpsList;
    List<Treatment_History__c> PyTHList;
    List<Psychiatric_Diagnosis__c> PyDList;
    List<Prescription_Medication__c> PMList;
    List<OpportunityLineItem> OLIList;
    
	Map<String,Lead> maplead;    
	List<Referral__c> Reflist;
	
    List<Referral__c> Refferallist;
    List<Infectious_Disease__c> InfecDisease;
    List<Medical_Equipment__c> MedEquip;
    List<Major_Medical_Issue__c> MajMedIss;
    
    Map<String,String> oppOLIMap;
    Map<Id,List<Mental_Health_Symptom__c>> oppMentalHealthMap;
    List<Mental_Health_Symptom__c> mentalHealthList;
    List<Quote> oppQuoteList;
    List<Pay_Agreement_Worksheet__c> oppPAWList;
    Map<Id,List<Medical_Equipment__c>> oppMedEquipMap;
    Map<Id,List<Pay_Agreement_Worksheet__c>> oppPAWMap;
    Map<Id,List<Quote>> oppQuoteMap;
    List<Medical_Equipment__c> MedicalEquipmentList;
    Map<Id,List<Infectious_Disease__c>> oppInfectiousDMap;
    List<Infectious_Disease__c> InfectiousDiseaseList;
    List<Schema.PicklistEntry> ple;
    List<Schema.PicklistEntry> ple1;
    List<Schema.PicklistEntry> ple2;
    Set<Id> vobProfileId;
	
    // Constructor
    public OpportunityHandler(){
        recordtypename = new Map<Id,String>();
        prMap = new Map<String,PriceBookEntry>() ;
        RefMap = new Map<Id,List<Referral__c>>() ;
        oppLgOMap = new Map<Id,List<Legal_Offense__c>>();
        oppAsbMap = new Map<Id,List<Abused_Substance__c>>();
        oppMPSMap = new Map<Id,List<Medical_Problem_Symptom__c>>();
        oppPyTHMap = new Map<Id,List<Treatment_History__c>>();
        oppPyDMap = new Map<Id,List<Psychiatric_Diagnosis__c>>();
        oppPMMap = new Map<Id,List<Prescription_Medication__c>>();
        lgOffList = new List<Legal_Offense__c>();
        absList = new List<Abused_Substance__c>();
        mpsList = new List<Medical_Problem_Symptom__c>();
        PyTHList = new List<Treatment_History__c>();
        PyDList = new List<Psychiatric_Diagnosis__c>();
        OLIList = new List<OpportunityLineItem>();
        PMList = new List<Prescription_Medication__c>();
        maplead = new Map<String,Lead>();
        Reflist = new List<Referral__c>();
        Refferallist = new List<Referral__c>();
        InfecDisease = new List<Infectious_Disease__c>();
        MedEquip = new List<Medical_Equipment__c>();
        MajMedIss = new List<Major_Medical_Issue__c>();
        
        oppOLIMap = new Map<String,String>();
        oppMentalHealthMap = new Map<Id,List<Mental_Health_Symptom__c>>();
        mentalHealthList = new List<Mental_Health_Symptom__c>();
        oppQuoteList = new List<Quote>();
        oppPAWList = new List<Pay_Agreement_Worksheet__c>();
        oppMedEquipMap = new Map<Id,List<Medical_Equipment__c>>();
        oppPAWMap = new Map<Id,List<Pay_Agreement_Worksheet__c>>();
        oppQuoteMap = new Map<Id,List<Quote>>();
        MedicalEquipmentList = new List<Medical_Equipment__c>();
        oppInfectiousDMap = new Map<Id,List<Infectious_Disease__c>>();
        InfectiousDiseaseList = new List<Infectious_Disease__c>();
        ple = new List<Schema.PicklistEntry>();
        ple1 = new List<Schema.PicklistEntry>();
        ple2 = new List<Schema.PicklistEntry>();
		vobProfileId = new Set<Id>();
		for(Profile prf:[SELECT Id FROM Profile WHERE Name Like 'FRN - Verification of Benefits (VOB)%']){
			vobProfileId.add(prf.Id);
		}
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){        
        
    }
	
    public void bulkAfter(){               
        Set<Id> oppId = new Set<Id>();
		Set<Id> recTypeIds = new Set<Id>();
		
        Set<Id> newOppId = new Set<Id>();
        Set<Id> newOppPBId = new Set<Id>();       
		Set<Id> oppIds = new Set<Id>(); 	
		
        for(Opportunity opp:(List<Opportunity>)trigger.new){
            oppId.add(opp.Id);
            recTypeIds.add(opp.RecordTypeId);
            System.debug('oppId....>>>>>>>>>>>'+oppId);
            if(trigger.isUpdate){
                if(opp.Contact__c!=((Opportunity)trigger.oldMap.get(opp.Id)).Contact__c){
                    oppIds.add(opp.Id);
                    newOppPBId.add(opp.Pricebook2Id);
                    System.debug('oppIds....>>>>>>>>>>>'+oppIds);
                }
                newOppId.add(opp.Id);
            }
        }
		
		if(recTypeIds.size()>0){
			Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Opportunity').getDescribe();
			List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();		
			for(Schema.RecordTypeInfo info : recordTypeInfo){
				if(recTypeIds.contains(info.getRecordTypeId()))
					recordtypename.put(info.getRecordTypeId(),info.getName());
			}
		}
		System.debug('recordtypename ::>'+recordtypename);
		
		if(vobProfileId.contains(Userinfo.getProfileId())){
			//Query Pay Agreement Worksheets
			List<Pay_Agreement_Worksheet__c> PAWList;
			  for(Pay_Agreement_Worksheet__c paw:[Select Id,Status__c,Opportunity__c from Pay_Agreement_Worksheet__c WHERE Opportunity__c IN:oppId]){
				if(oppPAWMap.containsKey(paw.Opportunity__c)){
					oppPAWMap.get(paw.Opportunity__c).add(paw);
				} else {
					PAWList = new List<Pay_Agreement_Worksheet__c>();
					PAWList.add(paw);
					oppPAWMap.put(paw.Opportunity__c,PAWList);
				}               
			}
			System.debug('oppPAWMap::>>>>>>'+oppPAWMap.values());
			
			//Query Estimate of Treatment Costs
			List<Quote> QuoteList;
			  for(Quote qt:[Select Id,Status__c,OpportunityId from Quote WHERE OpportunityId IN:oppId]){
				if(oppQuoteMap.containsKey(qt.OpportunityId)){
					oppQuoteMap.get(qt.OpportunityId).add(qt);
				} else {
					QuoteList = new List<Quote>();
					QuoteList.add(qt);
					oppQuoteMap.put(qt.OpportunityId,QuoteList);
				}               
			}
			System.debug('oppQuoteMap::>>>>>>'+oppQuoteMap.values());
		}        
		
		if(Trigger.isUpdate){
			for(OpportunityLineItem oli:[Select Id,PriceBookEntry.Product2.Name,OpportunityId from OpportunityLineItem WHERE OpportunityId IN:newOppId AND PricebookEntry.Product2.Name In :recordtypename.values()]){
				if(oppOLIMap.get(oli.OpportunityId) == null){
					oppOLIMap.put(oli.OpportunityId,oli.PricebookEntry.Product2.Name);
				} else {
					String name = oppOLIMap.get(oli.OpportunityId);
					if(!name.contains(oli.PricebookEntry.Product2.Name)){
						name = name + ': '+oli.PricebookEntry.Product2.Name;
						System.debug('Oppty Product Name: '+name);
						oppOLIMap.put(oli.OpportunityId,name);
					}
				}
			}  
			
			for(PriceBookEntry pbe : [SELECT Id, Product2Id, Product2.Id,UnitPrice,Product2.Name FROM PriceBookEntry WHERE Product2.Name In :recordtypename.values() AND Pricebook2Id In : newOppPBId]){
				prMap.put(pbe.Product2.Name,pbe);
				system.debug('prMap---'+prMap);
			}
		}             
       
        System.debug('pbe.Product2.Name>>>'+prMap);
        
        List<Referral__c> ReffList;
        for(Referral__c Reff:[Select Id, Account__c, RecordTypeId, Opportunity__c,Opportunity__r.AC_Assigned__r.Name,Opportunity__r.FRN_Facility_of_Interest__r.Name,Opportunity__r.FRN_Facility_Selected__r.Name, Admission_Date__c, Benefits_Stage__c, Shift_Assigned__c, Facility_Of_Interest__c, Facility_Of_Admission__c from Referral__c where Opportunity__c IN:oppId AND RecordType.Name='Inbound Referral']){
            
            if(RefMap.containsKey(Reff.Opportunity__c)){
                RefMap.get(Reff.Opportunity__c).add(Reff);
            } else {
                ReffList = new List<Referral__c>();
                ReffList.add(Reff);
                RefMap.put(Reff.Opportunity__c, ReffList);
            }
            System.debug('RefMap---'+RefMap);
        }               
        
        if(oppIds.size()>0){
            //Query Legal Offense 
            List<Legal_Offense__c> lgList;
            for(Legal_Offense__c lo:[Select Id,Patient__c,Opportunity__c from Legal_Offense__c WHERE Opportunity__c IN:oppIds]){
                if(oppLgOMap.containsKey(lo.Opportunity__c)){
                    oppLgOMap.get(lo.Opportunity__c).add(lo);
                } else {
                    lgList = new List<Legal_Offense__c>();
                    lgList.add(lo);
                    oppLgOMap.put(lo.Opportunity__c,lgList);
                }               
            }
            
            //Query Abused Substance 
            List<Abused_Substance__c> absList;
            for(Abused_Substance__c lo:[Select Id,Patient__c,Opportunity__c from Abused_Substance__c WHERE Opportunity__c IN:oppIds]){
                if(oppAsbMap.containsKey(lo.Opportunity__c)){
                    oppAsbMap.get(lo.Opportunity__c).add(lo);
                } else {
                    absList = new List<Abused_Substance__c>();
                    absList.add(lo);
                    oppAsbMap.put(lo.Opportunity__c,absList);
                }               
            }
            
            //Query Medical Problem Symptom 
            List<Medical_Problem_Symptom__c> mpList;
            for(Medical_Problem_Symptom__c lo:[Select Id,Patient__c,Opportunity__c from Medical_Problem_Symptom__c WHERE Opportunity__c IN:oppIds]){
                if(oppMPSMap.containsKey(lo.Opportunity__c)){
                    oppMPSMap.get(lo.Opportunity__c).add(lo);
                } else {
                    mpList = new List<Medical_Problem_Symptom__c>();
                    mpList.add(lo);
                    oppMPSMap.put(lo.Opportunity__c,mpList);
                }               
            }
            
            //Query Treatment History
            List<Treatment_History__c> pyhList;
            for(Treatment_History__c lo:[Select Id,Patient__c,Opportunity__c from Treatment_History__c WHERE Opportunity__c IN:oppIds]){
                if(oppPyTHMap.containsKey(lo.Opportunity__c)){
                    oppPyTHMap.get(lo.Opportunity__c).add(lo);
                } else {
                    pyhList = new List<Treatment_History__c>();
                    pyhList.add(lo);
                    oppPyTHMap.put(lo.Opportunity__c,pyhList);
                }               
            }
            
            //Query Mental Health Symptoms
            List<Mental_Health_Symptom__c> mhsList;
            for(Mental_Health_Symptom__c mh:[Select Id,Patient__c,Opportunity__c from Mental_Health_Symptom__c WHERE Opportunity__c IN:oppIds]){
                if(oppMentalHealthMap.containsKey(mh.Opportunity__c)){
                    oppMentalHealthMap.get(mh.Opportunity__c).add(mh);
                } else {
                    mhsList = new List<Mental_Health_Symptom__c>();
                    mhsList.add(mh);
                    oppMentalHealthMap.put(mh.Opportunity__c,mhsList);
                }               
            }
            
            //Query Medical Equipment
            List<Medical_Equipment__c> medEquipList;
            for(Medical_Equipment__c me:[Select Id,Patient__c,Opportunity__c from Medical_Equipment__c WHERE Opportunity__c IN:oppIds]){
                if(oppMedEquipMap.containsKey(me.Opportunity__c)){
                    oppMedEquipMap.get(me.Opportunity__c).add(me);
                } else {
                    medEquipList = new List<Medical_Equipment__c>();
                    medEquipList.add(me);
                    oppMedEquipMap.put(me.Opportunity__c,medEquipList);
                }               
            }
			
			//Query Infectious Disease
            List<Infectious_Disease__c> ifdList;
            for(Infectious_Disease__c ifd:[Select Id,Patient__c,Opportunity__c from Infectious_Disease__c WHERE Opportunity__c IN:oppIds]){
                if(oppInfectiousDMap.containsKey(ifd.Opportunity__c)){
                    oppInfectiousDMap.get(ifd.Opportunity__c).add(ifd);
                } else {
                    ifdList = new List<Infectious_Disease__c>();
                    ifdList.add(ifd);
                    oppInfectiousDMap.put(ifd.Opportunity__c,ifdList);
                }               
            }            
            
            //Query Psychiatric Diagnosis
            List<Psychiatric_Diagnosis__c> pdList;
            for(Psychiatric_Diagnosis__c lo:[Select Id,Patient__c,Opportunity__c from Psychiatric_Diagnosis__c WHERE Opportunity__c IN:oppIds]){
                if(oppPyDMap.containsKey(lo.Opportunity__c)){
                    oppPyDMap.get(lo.Opportunity__c).add(lo);
                } else {
                    pdList = new List<Psychiatric_Diagnosis__c>();
                    pdList.add(lo);
                    oppPyDMap.put(lo.Opportunity__c,pdList);
                }               
            }
            
            //Query Prescription Medication
            List<Prescription_Medication__c> pmList;
            for(Prescription_Medication__c lo:[Select Id,Patient__c,Opportunity__c from Prescription_Medication__c WHERE Opportunity__c IN:oppIds]){
                if(oppPMMap.containsKey(lo.Opportunity__c)){
                    oppPMMap.get(lo.Opportunity__c).add(lo);
                } else {
                    pmList = new List<Prescription_Medication__c>();
                    pmList.add(lo);
                    oppPMMap.put(lo.Opportunity__c,pmList);
                }               
            }
        }
		
        // For lead converted opportunityId
        if(trigger.isUpdate){            
			System.debug('keyset>>>>>>....'+trigger.newMap.keyset());
			for(Lead ld : [Select Id,ConvertedOpportunityId  from Lead where isConverted = true and  ConvertedOpportunityId In:trigger.oldMap.keyset()]){				
				maplead.put(ld.id,ld);
			}
			System.debug('maplead....'+maplead);
			for(Referral__c ref : [Select Id,Lead__c,Opportunity__c  from Referral__c where  Lead__C In:maplead.keyset()]){
				ref.opportunity__c = maplead.get(ref.Lead__c).ConvertedOpportunityId;
				Reflist.add(ref);             
			}
			System.debug('maplead....'+Reflist);
        }
		
        Schema.DescribeFieldResult fieldResult = Infectious_Disease__c.Infectious_Disease__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        
        Schema.DescribeFieldResult fieldResult1 = Medical_Equipment__c.Equipment_Type__c.getDescribe();
        ple1 = fieldResult1.getPicklistValues();
        
        Schema.DescribeFieldResult fieldResult2 = Major_Medical_Issue__c.Major_Medical_Issue__c.getDescribe();
        ple2 = fieldResult2.getPicklistValues();
		
		
    }   
 
    public void beforeInsert(SObject so){  
        Opportunity opp = (Opportunity)so;
        if(opp.Benefits_Status__c == 'VOB Approved' && vobProfileId.contains(Userinfo.getProfileId())){
            opp.StageName = 'Determination Complete';
        }        
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
        Opportunity opp = (Opportunity)so;
        if(opp.Benefits_Status__c == 'VOB Approved' && vobProfileId.contains(Userinfo.getProfileId())){
            opp.StageName = 'Determination Complete';
        }
    }
 
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){
       
    }
 
    public void afterInsert(SObject so){ 
    
        Opportunity opp = (Opportunity)so;
        System.debug('opp....>>>>>>>>>>>'+opp);
        System.debug('opp.id....>>>>>>>>>>>'+opp.id);       

        if(RefMap.containsKey(opp.Id)){
            for(Referral__c rf : RefMap.get(opp.Id)){                    
                rf.Admission_Date__c = opp.Admission_Date__c;
                rf.Benefits_Stage__c = opp.StageName;
                rf.Shift_Assigned__c = (opp.AC_Assigned__c!=null) ? rf.Opportunity__r.AC_Assigned__r.Name : null;
                rf.Facility_Of_Interest__c = (opp.FRN_Facility_of_Interest__c!=null) ? rf.Opportunity__r.FRN_Facility_of_Interest__r.Name : null;
                rf.Facility_Of_Admission__c = (opp.FRN_Facility_Selected__c!=null) ? rf.Opportunity__r.FRN_Facility_Selected__r.Name : null;    
                Refferallist.add(rf);                
            }
        }
        /*if(recordtypename.get(opp.RecordTypeId)=='Outpatient Treatment' || recordtypename.get(opp.RecordTypeId)=='Residential Treatment'){
            for( Schema.PicklistEntry f : ple){
                Infectious_Disease__c InD = new Infectious_Disease__c();
                InD.Infectious_Disease__c= string.valueof(f.getLabel());
                InD.Opportunity__c= opp.Id;
                InD.Patient__c= opp.Contact__c;
                InD.Diagnosed__c= '';
                
                InfecDisease.add(InD);
            }
        }*/
        /*Medical_Equipment__c MeE;
        if(recordtypename.get(opp.RecordTypeId)=='Residential Treatment'){
            for( Schema.PicklistEntry f : ple1){
                MeE = new Medical_Equipment__c();            
                MeE.Equipment_Type__c= string.valueof(f.getLabel()); 
                MeE.Opportunity__c= opp.Id;                
                MeE.Patient__c= opp.Contact__c; 
                MedEquip.add(MeE);
            }
        }       
        
        Major_Medical_Issue__c MaMI;
        if(recordtypename.get(opp.RecordTypeId)=='Residential Treatment'){
            for( Schema.PicklistEntry f : ple2){
                MaMI = new Major_Medical_Issue__c();            
                MaMI.Major_Medical_Issue__c= string.valueof(f.getLabel()); 
                MaMI.Opportunity__c= opp.Id;                    
                MajMedIss.add(MaMI);
            }
        }*/
		if(opp.Benefits_Status__c == 'VOB Approved' && vobProfileId.contains(Userinfo.getProfileId())){
			if(oppPAWMap.containsKey(opp.Id)){
                for(Pay_Agreement_Worksheet__c pawup:oppPAWMap.get(opp.Id)){
                    pawup.Status__c = 'Closed';
                    oppPAWList.add(pawup);
                }
				System.debug('oppPAWList::>>>>>>'+oppPAWList);
            }if(oppQuoteMap.containsKey(opp.Id)){
                for(Quote qtup:oppQuoteMap.get(opp.Id)){
                    qtup.Status__c = 'Open';
                    oppQuoteList.add(qtup);
                }
				System.debug('oppQuoteList::>>>>>>'+oppQuoteList);
            }			
		}
    }
	
    public void afterUpdate(SObject oldSo, SObject so){ 
        Opportunity opp = (Opportunity)so;
        Opportunity oldOpp = (Opportunity)oldSo;
        String rec=recordtypename.get(opp.RecordTypeId);
        System.debug('rec....>>>>>>>>>>>'+rec);
        System.debug('opp.Pricebook2Id ::>'+opp.Pricebook2Id);		
		
        if((oppOLIMap.get(opp.Id) ==null || !(oppOLIMap.get(opp.Id)).contains(recordtypename.get(opp.RecordTypeId))) && opp.Pricebook2Id!=null){
            if(prMap.ContainsKey(rec)){
                OpportunityLineItem oli= new OpportunityLineItem();
                oli.OpportunityId=opp.Id;
                oli.PricebookEntryId=prMap.get(rec).id; 
                oli.Quantity=1;
                oli.UnitPrice=prMap.get(rec).UnitPrice;
                OLIList.add(oli); 
                System.debug('prMap.get(rec).id.....>>>'+prMap.get(rec).id);
                System.debug('prMap.get(rec).id.....>>>'+prMap.get(rec).UnitPrice);
                System.debug('OLIList.....>>>'+OLIList);
            }
        }
        
        if(opp.Contact__c!=oldOpp.Contact__c){
            if(oppLgOMap.containsKey(opp.Id)){
                for(Legal_Offense__c lg:oppLgOMap.get(opp.Id)){
                    lg.Patient__c = opp.Contact__c;
                    lgOffList.add(lg);
                }
            }
            
            if(oppAsbMap.containsKey(opp.Id)){
                for(Abused_Substance__c abs:oppAsbMap.get(opp.Id)){
                    abs.Patient__c = opp.Contact__c;
                    absList.add(abs);
                }
            }
            
            if(oppMPSMap.containsKey(opp.Id)){
                for(Medical_Problem_Symptom__c mps:oppMPSMap.get(opp.Id)){
                    mps.Patient__c = opp.Contact__c;
                    mpsList.add(mps);
                }
            }
            
            if(oppPyTHMap.containsKey(opp.Id)){
                for(Treatment_History__c PyTH:oppPyTHMap.get(opp.Id)){
                    PyTH.Patient__c = opp.Contact__c;
                    PyTHList.add(PyTH);
                }
            }
            
            if(oppMentalHealthMap.containsKey(opp.Id)){
                for(Mental_Health_Symptom__c mhealth:oppMentalHealthMap.get(opp.Id)){
                    mhealth.Patient__c = opp.Contact__c;
                    mentalHealthList.add(mhealth);
                }
            }
            
            if(oppMedEquipMap.containsKey(opp.Id)){
                for(Medical_Equipment__c mequip:oppMedEquipMap.get(opp.Id)){
                    mequip.Patient__c = opp.Contact__c;
                    MedicalEquipmentList.add(mequip);
                }
            }
            
            if(oppInfectiousDMap.containsKey(opp.Id)){
                for(Infectious_Disease__c inf:oppInfectiousDMap.get(opp.Id)){
                    inf.Patient__c = opp.Contact__c;
                    InfectiousDiseaseList.add(inf);
                }
            }
            
            if(oppPyDMap.containsKey(opp.Id)){
                for(Psychiatric_Diagnosis__c PyD:oppPyDMap.get(opp.Id)){
                    PyD.Patient__c = opp.Contact__c;
                    PyDList.add(PyD);
                }
            }
            
            if(oppPMMap.containsKey(opp.Id)){
                for(Prescription_Medication__c PM:oppPMMap.get(opp.Id)){
                    PM.Patient__c = opp.Contact__c;
                    PMList.add(PM);
                }
            }
        }   
        if(oldOpp.StageName!=opp.StageName && RefMap.containsKey(opp.Id)){           
            for(Referral__c rf : RefMap.get(opp.Id)){                   
                rf.Admission_Date__c = opp.Admission_Date__c;
                rf.Benefits_Stage__c = opp.StageName;
                rf.Shift_Assigned__c = (opp.AC_Assigned__c!=null) ? rf.Opportunity__r.AC_Assigned__r.Name : null;
                rf.Facility_Of_Interest__c = (opp.FRN_Facility_of_Interest__c!=null) ? rf.Opportunity__r.FRN_Facility_of_Interest__r.Name : null;
                rf.Facility_Of_Admission__c = (opp.FRN_Facility_Selected__c!=null) ? rf.Opportunity__r.FRN_Facility_Selected__r.Name : null;            
                Refferallist.add(rf);                   
            }
        }
		if(opp.Benefits_Status__c == 'VOB Approved' && vobProfileId.contains(UserInfo.getProfileId())){
			if(oppPAWMap.containsKey(opp.Id)){
                for(Pay_Agreement_Worksheet__c pawup:oppPAWMap.get(opp.Id)){
                    pawup.Status__c = 'Closed';
                    oppPAWList.add(pawup);
                }
            }	
			if(oppQuoteMap.containsKey(opp.Id)){
                for(Quote qtup:oppQuoteMap.get(opp.Id)){
                    qtup.Status__c = 'Open';
                    oppQuoteList.add(qtup);
                }
				System.debug('oppQuoteList::>>>>>>'+oppQuoteList);
            }
		}
    }

    public void afterDelete(SObject so){
        
    }
 
    public void afterUndelete(SObject so){
        
    }
 
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally(){
        
        //Update Legal Offense 
        if(lgOffList.size()>0){
            update lgOffList;
        }
        
        //Update Abused Substance 
        if(absList.size()>0){
            update absList;
        }
        
        //Update Medical Problem Symptom 
        if(mpsList.size()>0){
            update mpsList;
        }
        
        //Update Treatment History
        if(PyTHList.size()>0){
            update PyTHList;
        }
        
        //Update Mental Health Symptoms
        if(mentalHealthList.size()>0){
            update mentalHealthList;
        }
        
        //Update Medical Equipment
        if(MedicalEquipmentList.size()>0){
            update MedicalEquipmentList;
        }
        
        //Update Infectious Disease
        if(InfectiousDiseaseList.size()>0){
            update InfectiousDiseaseList;
        }
        
        //Update Psychiatric Diagnosis
        if(PyDList.size()>0){
            update PyDList;
        }
        
        //Update Prescription Medication
        if(PMList.size()>0){
            update PMList;
        }
        
        //Insert OpportunityLineItem whose Product Name = Opportunity Recordtype Name 
        System.debug('OLIList.....>>>'+OLIList);
        if(OLIList.size()>0 ){            
            insert OLIList;
            System.debug('OLIList.....>>>'+OLIList);
        }
        
        // update referral object
        
        if(Reflist.size()>0){
            update Reflist;
        }
        if(Refferallist.size()>0){
            update Refferallist;
        }
        if(InfecDisease.size()>0){
            insert InfecDisease;
        }
        if(MedEquip.size()>0){
            insert MedEquip;
        }
        
        if(MajMedIss.size()>0){
            insert MajMedIss;
        } 
		if(oppPAWList.size()>0){
            update oppPAWList;
        }
		if(oppQuoteList.size()>0){
            update oppQuoteList;
        }
    }
}
/* Description: Handler class for the trigger CaseTrigger
 */
public with sharing class CaseTriggerHandler {

    //method used to submit case record for approval when case is inserted
    public void onAfterInsert(List<Case> lstNewCase) 
    {   
        List<Case> lstCasesToUnlock = new List<Case>();
        Set<Id> setCaseId = new Set<Id>();

        for(Case objCase: lstNewCase) 
        {   
            system.debug('objCase.Submit_for_Approval__c  '+objCase.Submit_for_Approval__c );
            system.debug('objCase.Approving_Authorities__c  '+objCase.Approving_Authorities__c );
            system.debug('objCase.Status  '+objCase.Status );
            if( objCase.Submit_for_Approval__c 
                && String.isNotBlank(objCase.Approving_Authorities__c) 
                && objCase.Status.equalsIgnoreCase('Submitted') 
              )
            {
                if(objCase.Approving_Authorities__c != null) 
                {
                    setCaseId.add(objCase.Id);
                    lstCasesToUnlock.add(objCase);

                    String strApprovingAuthorities = objCase.Approving_Authorities__c;
                    String strRole = strApprovingAuthorities.contains(',') ?
                         strApprovingAuthorities.subString(0, strApprovingAuthorities.indexOf(',')) :
                         strApprovingAuthorities;
                    system.debug('--strRole--'+strRole);
                }
           }
       }

       if(lstCasesToUnlock != null && !lstCasesToUnlock.isEmpty()) 
       {
           for(Case objCase: lstCasesToUnlock) 
           {
               //Unlock the locked record
               Approval.UnlockResult unlockedResult = Approval.unlock(objCase);
           }

           //Call future method to send approval request to the next approver
           ApprovalHandler.processApprovals(setCaseId);
       }
    }


    //Method used to submit case record to the next approver if approved by the previous approver
    public void onAfterUpdate(Map<Id, Case> mapOldCase, List<Case> lstNewCase) {
        Set<Id> setCaseId = new Set<Id>();
        Set<Id> setCaseIdForApproval = new Set<Id>();
        Set<Id> setCaseIdForAssignmentTaskUpdation = new Set<Id>();
        Set<Id> setCaseIdForParkingTaskUpdation = new Set<Id>();
        Set<Id> setCaseIdForPromotionPackageUpdation = new Set<Id>();
        Set<Id> setCaseIdForPromotionPackageTaskUpdation = new Set<Id>();
        Set<Id> setCaseAccountTransferId = new Set<Id>();
        Set<Id> setCreateRegId1 = new Set<Id>();
        Set<Id> setCreateRegId2 = new Set<Id>();
        Set<Id> setUpdateRegStatusInProcess = new Set<Id>();
        List<Case> lstCasesToUnlock = new List<Case>();
        List<Case> lstCasesToUpdate = new List<Case>();
        List<Task> lstTaskToInsert = new List<Task>();

        //get the Assignment Record Type Id
        Id AssignmentRecordType = getRecordTypeId('Case', 'Assignment');
        Id MortgageRecordType = getRecordTypeId('Case', 'Mortgage');
        Id ParkingRecordType = getRecordTypeId('Case', 'Parking');
        Id PromotionPackageRecordType = getRecordTypeId('Case', 'Promotion_Package');
        Id idBouncedChequeRT = getRecordTypeId('Case', 'Bounced_Cheque_SR');
        Id idTokenRefundRT = getRecordTypeId('Case', 'Token_Refund');
        Id idCustomerRefundRT = getRecordTypeId('Case', 'Customer_Refund');
        Id idAOPTRT = getRecordTypeId('Case', 'AOPT');
        Id EarlyHandoverRecordType = getRecordTypeId('Case','Early_Handover');
        
        List<Case> mortgageCasesToUpdateInIPMS = new List<Case>();
        List<Booking_Unit__c> mortgageBookingUnitsToUpdate = new List<Booking_Unit__c>();

        Integer counterVal = 1;
        Integer counterRegUpdate = 1;
        for(Case objCase: lstNewCase) {
            
            if(objCase.Buyer__c != null && objCase.Buyer__c != mapOldCase.get(objCase.Id).Buyer__c
               && objCase.RecordTypeId == AssignmentRecordType) {
                setCaseIdForApproval.add(objCase.Id);
            }
            //if status is closed for Promotion Package record Type
            if(objCase.Status == 'Closed' && objCase.Status != mapOldCase.get(objCase.Id).Status
               && objCase.RecordTypeId == PromotionPackageRecordType) {
                setCaseIdForPromotionPackageUpdation.add(objCase.Id);
            }
            if(objCase.RecordTypeId == AssignmentRecordType && objCase.Document_Verified__c 
                && objCase.Payment_Verified__c && (objCase.Document_Verified__c != mapOldCase.get(objCase.Id).Document_Verified__c
                || objCase.Payment_Verified__c != mapOldCase.get(objCase.Id).Payment_Verified__c) 
                && objCase.Booking_Unit__c != null) {
                if(counterRegUpdate <= 100) {
                    setUpdateRegStatusInProcess.add(objCase.Booking_Unit__c);
                }
                else {
                    updateRegStatus(setUpdateRegStatusInProcess, 'SR processing');
                    counterRegUpdate = 1;
                    setUpdateRegStatusInProcess = new Set<Id>();
                    setUpdateRegStatusInProcess.add(objCase.Booking_Unit__c);
                }
            }
            
            //if buyer verified is true for Assignment record Type
            if(objCase.Buyer_Verified__c != mapOldCase.get(objCase.Id).Buyer_Verified__c 
                && objCase.Buyer_Verified__c && objCase.RecordTypeId == AssignmentRecordType 
                && objCase.Buyer__c != null && objCase.Seller__c != null && objCase.Booking_Unit__c != null) {
                setCaseAccountTransferId.add(objCase.Id);
                if(counterVal <= 100) {
                    setCreateRegId1.add(objCase.Id);
                }
                else {
                    setCreateRegId2.add(objCase.Id);
                }
            }
            if(objCase.Submit_for_Approval__c &&
                objCase.Approving_Authorities__c != mapOldCase.get(objCase.Id).Approving_Authorities__c) {
                //&& objCase.Status.equalsIgnoreCase('Submitted')
                if(objCase.Approving_Authorities__c != null) {
                    setCaseId.add(objCase.Id);
                    lstCasesToUnlock.add(objCase);

                    if(mapOldCase.get(objCase.Id).Approving_Authorities__c != null) {
                        String strApprovingAuthorities = mapOldCase.get(objCase.Id).Approving_Authorities__c;
                        String strRole = strApprovingAuthorities.contains(',') ?
                             strApprovingAuthorities.subString(0, strApprovingAuthorities.indexOf(',')) :
                             strApprovingAuthorities;
                        system.debug('--strRole--'+strRole);

                        Case objCaseToUpdate = new Case(Id = objCase.Id);
                        objCaseToUpdate.Approval_Status__c = 'Approved by ' + UserInfo.getUserName() + ' (' + strRole + ')';
                        lstCasesToUpdate.add(objCaseToUpdate);
                    }
                }
                //If the request is approved by all the approving authorities then update the
                //status of the case
                else {
                    Case objCaseToUpdate = new Case(Id = objCase.Id);
                    objCaseToUpdate.Approval_Status__c = 'Approved';
                    //get the case Id for Assignment to update task & update the status to 'New Buyer Approved'
                    if(objCase.RecordTypeId == idBouncedChequeRT) {
                        Task objTask = TaskUtility.getTask((SObject)objCase, 'Customer Refused To Pay, Take Legal Action', 'Legal', 
                            'Bounced Cheque', system.today().addDays(1));
                        lstTaskToInsert.add(objTask);
                    }
                    if(objCase.RecordTypeId == idTokenRefundRT || objCase.RecordTypeId == idCustomerRefundRT ) {
                        Task objTask = TaskUtility.getTask((SObject)objCase, 'Update Refund Details in IPMS', 'Finance', 
                        objCase.RecordType.Name, system.today().addDays(1));                       
                        objCaseToUpdate.Task_Created_for_Finance__c = true;
                        lstTaskToInsert.add(objTask);
                    }
                    if(objCase.RecordTypeId == AssignmentRecordType && objCase.Buyer__c != null) {
                        setCaseIdForAssignmentTaskUpdation.add(objCase.Id);
                        objCaseToUpdate.Status = 'New Buyer Approved';
                    }
                    if(objCase.RecordTypeId == ParkingRecordType) {
                        setCaseIdForParkingTaskUpdation.add(objCase.Id);
                        objCaseToUpdate.Status = 'Manager Approved';
                        Task objTask = TaskUtility.getTask((SObject)objCase, 'Generate & Send confirmation letter', 'CRE', 
                            'Parking', system.today().addDays(1));
                        lstTaskToInsert.add(objTask);
                    }
                    if(objCase.RecordTypeId == PromotionPackageRecordType) {
                        setCaseIdForPromotionPackageTaskUpdation.add(objCase.Id);
                        objCaseToUpdate.Status = 'Manager Approved';
                        Task objTask = TaskUtility.getTask((SObject)objCase, 'Generate & Send Receipt', 'CRE', 
                            'Promotion Package', system.today().addDays(1));
                        lstTaskToInsert.add(objTask);
                    }

                    if(objCase.RecordTypeId == idAOPTRT) {
                        objCaseToUpdate.Status = 'Approved';
                        Task objTask = TaskUtility.getTask((SObject)objCase, 'Generate Offer & Acceptance Letter', 'CRE', 
                            'AOPT', system.today().addDays(1));
                        lstTaskToInsert.add(objTask);
                    }
                    if (objCase.RecordTypeId == EarlyHandoverRecordType) {
                        Task objTask = TaskUtility.getTask((SObject)objCase, 'Update PDC & Security Cheque Details', 'Contracts', 
                            'Early Handover', system.today().addDays(1));
                        lstTaskToInsert.add(objTask);
                    }
                    if(objCase.RecordTypeId == MortgageRecordType && objCase.Status == 'Documents Received From Bank' && ( (objCase.IsPOA__c == true && objCase.Is_POA_Verified__c == true)
                    || objCase.IsPOA__c == false ) ){
                      objCaseToUpdate.Compliance_Approved__c = true;
                      objCaseToUpdate.Status = 'Closed';
                      objCaseToUpdate.Reason = 'Mortgage Approved';
                      mortgageCasesToUpdateInIPMS.add(objCase);
                      mortgageBookingUnitsToUpdate.add(new Booking_Unit__c(Id=objCase.Booking_Unit__c,Mortgage__c=true));
                    }
                    lstCasesToUpdate.add(objCaseToUpdate);
                }
            }
        }

        if(!setUpdateRegStatusInProcess.isEmpty()) {
            updateRegStatus(setUpdateRegStatusInProcess, 'SR processing');
        }

        if(lstTaskToInsert != null && !lstTaskToInsert.isEmpty()) {
            insert lstTaskToInsert;
        }

        //update related promotion package with allocated & blocked units
        if(!setCaseIdForPromotionPackageUpdation.isEmpty()) {
            updateRelatedPromotionPackage(setCaseIdForPromotionPackageUpdation);
        }

        //transfer account for the booking unit
        if(!setCaseAccountTransferId.isEmpty()) {
            transferAccount(setCaseAccountTransferId);
            if(!setCreateRegId1.isEmpty()) {
                createRegId(setCreateRegId1);
            }
            if(!setCreateRegId2.isEmpty()) {
                createRegId(setCreateRegId2);
            }
        }

        //update Approval Authorities to invoke approval process
        if(!setCaseIdForApproval.isEmpty()) {
            updateCaseForApproval(setCaseIdForApproval);
        }

        if(lstCasesToUnlock != null && !lstCasesToUnlock.isEmpty()) {
            for(Case objCase: lstCasesToUnlock) {
                //Unlock the locked record
                Approval.UnlockResult unlockedResult = Approval.unlock(objCase);
            }

            //Call future method to send approval request to the next approver
            ApprovalHandler.processApprovals(setCaseId);
        }

        if(!mortgageCasesToUpdateInIPMS.isEmpty()){
            MortgageIPMSCallout.updateCaseInIPMS(mortgageCasesToUpdateInIPMS);
        }

        if(!mortgageBookingUnitsToUpdate.isEmpty()){
          update mortgageBookingUnitsToUpdate;
        }

        if(lstCasesToUpdate != null && !lstCasesToUpdate.isEmpty()) {
            update lstCasesToUpdate;
            //Call method to Update Task Status related to Case
            if(!setCaseIdForAssignmentTaskUpdation.isEmpty()) {
                updateApprovalTask(setCaseIdForAssignmentTaskUpdation,'Assignment','New Buyer Approval');
            }
            if(!setCaseIdForParkingTaskUpdation.isEmpty()) {
                updateApprovalTask(setCaseIdForParkingTaskUpdation,'Parking','Manager Approval');
            }
            if(!setCaseIdForPromotionPackageTaskUpdation.isEmpty()) {
                updateApprovalTask(setCaseIdForPromotionPackageTaskUpdation,'Promotion Package','Manager Approval');
            }
        }
    }

    @future(callout=true)
    public static void updateRegStatus(set<Id> setBookingUnit, String regStatus) {
        for(Booking_Unit__c bookingInst: [select Id, Registration_ID__c from Booking_Unit__c
                where Id IN: setBookingUnit and Registration_ID__c != null]) {
            AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint objClass = new AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint();
            objClass.timeout_x = 120000;
            String strRegStatusResponse = objClass.UpdateRegistrationStatus(String.valueOf(System.currentTimeMillis()), 'UPDATE_REG_STATUS', 'SFDC', bookingInst.Registration_ID__c, regStatus);
            system.debug('strRegStatusResponse==='+strRegStatusResponse);
        }
    }

    //get Record Type Id
    public Id getRecordTypeId(String SObjectType, String RecordTypeName) {
        List<RecordType> lstRecordType = [select Id, DeveloperName from RecordType where
                                                     SobjectType =: SObjectType and DeveloperName =: RecordTypeName];
        return lstRecordType[0].Id;
    }

    //update related promotion package with allocated & blocked units
    public void updateRelatedPromotionPackage(set<Id> setCaseIdForPromotionPackageUpdation) {
        map<Id, Decimal> mapBlockedUnit = new map<Id, Decimal>();
        map<Id, Decimal> mapAllocatedUnit = new map<Id, Decimal>();
        list<Promotion_Package__c> listUpdatePromotionPackage = new list<Promotion_Package__c>(); 
        for(Promotion_Package_Allocation__c objPA: [select Id, Promotion_Package__c, Case__c, 
                                                        Promotion_Package__r.Allocated_Units__c,
                                                        Promotion_Package__r.Blocked_Units__c
                                                        from Promotion_Package_Allocation__c
                                                        where Case__c IN: setCaseIdForPromotionPackageUpdation]) {
            if(mapAllocatedUnit.containsKey(objPA.Promotion_Package__c)) {
                mapAllocatedUnit.put(objPA.Promotion_Package__c, mapAllocatedUnit.get(objPA.Promotion_Package__c) + 1);
            }
            else {
                if(objPA.Promotion_Package__r.Allocated_Units__c != null) {
                    mapAllocatedUnit.put(objPA.Promotion_Package__c, objPA.Promotion_Package__r.Allocated_Units__c + 1);
                }
                else {
                    mapAllocatedUnit.put(objPA.Promotion_Package__c, 1);
                }
            }
            if(mapBlockedUnit.containsKey(objPA.Promotion_Package__c)) {
                mapBlockedUnit.put(objPA.Promotion_Package__c, mapBlockedUnit.get(objPA.Promotion_Package__c) - 1);
            }
            else {
                mapBlockedUnit.put(objPA.Promotion_Package__c, objPA.Promotion_Package__r.Blocked_Units__c - 1);
            }
        }
        system.debug('mapBlockedUnit==='+mapBlockedUnit);
        system.debug('mapAllocatedUnit==='+mapAllocatedUnit);
        for(Id idPromoPackage: mapAllocatedUnit.keySet()) {
            Promotion_Package__c promotionObj = new Promotion_Package__c();
            promotionObj.Id = idPromoPackage;
            promotionObj.Allocated_Units__c = mapAllocatedUnit.get(idPromoPackage);
            if(mapBlockedUnit.containsKey(idPromoPackage)) {
                promotionObj.Blocked_Units__c = mapBlockedUnit.get(idPromoPackage);
            }
            listUpdatePromotionPackage.add(promotionObj);
        }
        if(!listUpdatePromotionPackage.isEmpty()) {
            update listUpdatePromotionPackage;
        }
        system.debug('listUpdatePromotionPackage==='+listUpdatePromotionPackage);
    }

    //update Approval Authorities to invoke approval process
    public void updateCaseForApproval(set<Id> setCaseIdForApproval) {
        List<Case> lstUpdateCaseForApproval = new List<Case>();
        for(Case objCase: [select Id, Submit_for_Approval__c, Approving_Authorities__c
                           from Case where Id IN: setCaseIdForApproval]) {
            Case caseObj = new Case();
            caseObj.Id = objCase.Id;
            caseObj.Approving_Authorities__c = 'VP - Operations,General Manager';
            caseObj.Submit_for_Approval__c = true;
            lstUpdateCaseForApproval.add(caseObj);
        }
        if(!lstUpdateCaseForApproval.isEmpty()) {
            update lstUpdateCaseForApproval;
        }
    }

    //Transfer the account for the booking unit
    public void transferAccount(Set<Id> setCaseAccountTransferId) {
        Integer NoOfRecords = 1;
        //Id personalAccountRecordTypeId = getRecordTypeId('Account', 'PersonAccount');
        List<Case> lstUpdateCase = new List<Case>();
        List<Account> lstBuyerAccount = new List<Account>();
        List<Booking__c> lstAccountBooking = new List<Booking__c>();
        List<Booking_Unit__c> lstAccountBookingUnit = new List<Booking_Unit__c>();
        List<Booking_Unit__c> lstUpdateBookingUnit = new List<Booking_Unit__c>();
        map<Integer, Case> mapCaseAccount = new map<Integer, Case>();
        //Get the case, Buyer related to case, Booking
        for(Case objCase: [select Id, Buyer__c, Buyer__r.Title__c, Buyer__r.Title_Arabic__c,
                Buyer__r.First_Name__c, Buyer__r.First_Name_Arabic__c, Buyer__r.Last_Name__c,
                Buyer__r.Last_Name_Arabic__c, Buyer__r.Nationality__c, Buyer__r.Nationality_Arabic__c,
                Buyer__r.Passport_Number__c, Buyer__r.Passport_Expiry_Date__c, Buyer__r.Place_of_Issue__c,
                Buyer__r.Place_of_Issue_Arabic__c, Buyer__r.Address_Line_1__c, Buyer__r.Address_Line_1_Arabic__c,
                Buyer__r.Address_Line_2__c, Buyer__r.Address_Line_2_Arabic__c, Buyer__r.Address_Line_3__c,
                Buyer__r.Address_Line_3_Arabic__c, Buyer__r.Address_Line_4__c, Buyer__r.Address_Line_4_Arabic__c,
                Buyer__r.Country__c, Buyer__r.Country_Arabic__c, Buyer__r.City__c, Buyer__r.City_Arabic__c,
                Buyer__r.Phone_Country_Code__c, Buyer__r.Phone__c, Buyer__r.Date_of_Birth__c, Buyer__r.Email__c,
                Booking_Unit__c, Booking_Unit__r.Booking__c, Booking_Unit__r.Booking__r.Deal_SR__c,
                Booking_Unit__r.Booking__r.Status__c, Booking_Unit__r.Booking__r.Booking_Channel__c,
                Booking_Unit__r.Booking__r.DP_Overdue__c, Booking_Unit__r.Booking__r.AWB_Number__c,
                Booking_Unit__r.Booking__r.Dispatch_Date__c, Booking_Unit__r.Booking_Unit_Type__c,
                Booking_Unit__r.Inventory__c
                from Case where Id IN: setCaseAccountTransferId ]) {

            Account personalAccountObj = new Account();
            personalAccountObj.PersonTitle = objCase.Buyer__r.Title__c;
            personalAccountObj.Title_Arabic__pc = objCase.Buyer__r.Title_Arabic__c;
            personalAccountObj.FirstName = objCase.Buyer__r.First_Name__c;
            personalAccountObj.First_Name_Arabic__pc = objCase.Buyer__r.First_Name_Arabic__c;
            personalAccountObj.LastName = objCase.Buyer__r.Last_Name__c;
            personalAccountObj.Last_Name_Arabic__pc = objCase.Buyer__r.Last_Name_Arabic__c;
            personalAccountObj.Nationality__pc = objCase.Buyer__r.Nationality__c;
            personalAccountObj.Nationality_Arabic__pc = objCase.Buyer__r.Nationality_Arabic__c;
            personalAccountObj.Passport_Number__pc = objCase.Buyer__r.Passport_Number__c;
            //personalAccountObj.Passport_Expiry_Date__pc = objCase.Buyer__r.Passport_Expiry_Date__c;
            personalAccountObj.Passport_Issue_Place__pc = objCase.Buyer__r.Place_of_Issue__c;
            personalAccountObj.Passport_Issue_Place_Arabic__pc = objCase.Buyer__r.Place_of_Issue_Arabic__c;
            personalAccountObj.Address_Line_1__pc = objCase.Buyer__r.Address_Line_1__c;
            personalAccountObj.Address_Line_1_Arabic__pc = objCase.Buyer__r.Address_Line_1_Arabic__c;
            personalAccountObj.Address_Line_2__pc = objCase.Buyer__r.Address_Line_2__c;
            personalAccountObj.Address_Line_2_Arabic__pc = objCase.Buyer__r.Address_Line_2_Arabic__c;
            personalAccountObj.Address_Line_3__pc = objCase.Buyer__r.Address_Line_3__c;
            personalAccountObj.Address_Line_3_Arabic__pc = objCase.Buyer__r.Address_Line_3_Arabic__c;
            personalAccountObj.Address_Line_4__pc = objCase.Buyer__r.Address_Line_4__c;
            personalAccountObj.Address_Line_4_Arabic__pc = objCase.Buyer__r.Address_Line_4_Arabic__c;
            personalAccountObj.Country__pc = objCase.Buyer__r.Country__c;
            personalAccountObj.Country_Arabic__pc = objCase.Buyer__r.Country_Arabic__c;
            personalAccountObj.City__pc = objCase.Buyer__r.City__c;
            personalAccountObj.City_Arabic__pc = objCase.Buyer__r.City_Arabic__c;
            personalAccountObj.Phone_Country_Code__c = objCase.Buyer__r.Phone_Country_Code__c;
            personalAccountObj.Phone_Encrypt__c = objCase.Buyer__r.Phone__c;
            //personalAccountObj.Date_Of_Birth__c = objCase.Buyer__r.Date_of_Birth__c;
            personalAccountObj.PersonEmail = objCase.Buyer__r.Email__c;
            lstBuyerAccount.add(personalAccountObj);

            mapCaseAccount.put(NoOfRecords, objCase);
            NoOfRecords++;
        }
        if(!lstBuyerAccount.isEmpty()) {
            insert lstBuyerAccount;
            system.debug('lstBuyerAccount==='+lstBuyerAccount);

            NoOfRecords = 1;
            for(Account objAccount: lstBuyerAccount) {
                Booking__c bookingObj = new Booking__c();
                bookingObj.Deal_SR__c = mapCaseAccount.get(NoOfRecords).Booking_Unit__r.Booking__r.Deal_SR__c;
                bookingObj.Status__c = mapCaseAccount.get(NoOfRecords).Booking_Unit__r.Booking__r.Status__c;
                bookingObj.Booking_Channel__c = mapCaseAccount.get(NoOfRecords).Booking_Unit__r.Booking__r.Booking_Channel__c;
                bookingObj.DP_Overdue__c = mapCaseAccount.get(NoOfRecords).Booking_Unit__r.Booking__r.DP_Overdue__c;
                bookingObj.AWB_Number__c = mapCaseAccount.get(NoOfRecords).Booking_Unit__r.Booking__r.AWB_Number__c;
                bookingObj.Dispatch_Date__c = mapCaseAccount.get(NoOfRecords).Booking_Unit__r.Booking__r.Dispatch_Date__c;
                bookingObj.Account__c = objAccount.Id;
                lstAccountBooking.add(bookingObj);

                Case caseObj = new Case();
                caseObj.Id = mapCaseAccount.get(NoOfRecords).Id;
                caseObj.AccountId = objAccount.Id;
                lstUpdateCase.add(caseObj);
                NoOfRecords++;
            }
            if(!lstAccountBooking.isEmpty()) {
                insert lstAccountBooking;
                update lstUpdateCase;
                system.debug('lstUpdateCase==='+lstUpdateCase);
                system.debug('lstAccountBooking==='+lstAccountBooking);

                NoOfRecords = 1;
                for(Booking__c objBooking: lstAccountBooking) {

                    Booking_Unit__c bookingUnitObj = new Booking_Unit__c();
                    bookingUnitObj.Booking__c = objBooking.Id;
                    bookingUnitObj.Inventory__c = mapCaseAccount.get(NoOfRecords).Booking_Unit__r.Inventory__c;
                    bookingUnitObj.Booking_Unit_Type__c = mapCaseAccount.get(NoOfRecords).Booking_Unit__r.Booking_Unit_Type__c;
                    bookingUnitObj.Previous_Booking_Unit__c = mapCaseAccount.get(NoOfRecords).Booking_Unit__c;
                    lstAccountBookingUnit.add(bookingUnitObj);

                    Booking_Unit__c bookingUnitUpdateObj = new Booking_Unit__c();
                    bookingUnitUpdateObj.Id = mapCaseAccount.get(NoOfRecords).Booking_Unit__c;
                    bookingUnitUpdateObj.Re_Assigned__c = true;
                    lstUpdateBookingUnit.add(bookingUnitUpdateObj);
                    NoOfRecords++;
                }
                if(!lstAccountBookingUnit.isEmpty() && !lstUpdateBookingUnit.isEmpty()) {
                    insert lstAccountBookingUnit;
                    update lstUpdateBookingUnit;
                    system.debug('lstAccountBookingUnit==='+lstAccountBookingUnit);
                }
            }
        }
        transferJointBuyer(setCaseAccountTransferId);
    }

    @future(callout=true)
    public static void createRegId(set<Id> setCaseId) {
        Boolean successFlag; 
        list<Booking_Unit__c> listUpdate = new list<Booking_Unit__c>(); 
        map<Id, Case> mapAccountCase = new map<Id, Case>();
        for(Case caseInst: [select Id, CaseNumber, Status, AccountId from Case where Id IN: setCaseId and AccountId != null]) {
            mapAccountCase.put(caseInst.AccountId, caseInst);
        }
        system.debug('mapAccountCase==='+mapAccountCase);
        for(Booking_Unit__c bookUnitInst: [select Id, Registration_ID__c, Booking__r.Account__c from Booking_Unit__c 
                                                where Booking__r.Account__c IN: mapAccountCase.keySet()]) {
            AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint assignObj = new AssignmentProcessWSDL.AssignmentHttpSoap11Endpoint();
            String registrationResponse = assignObj.CreateAssignment(
            String.valueOf(System.currentTimeMillis()), 
            'CREATE_ASSIGNMENT', 
            'SFDC', 
            mapAccountCase.get(bookUnitInst.Booking__r.Account__c).CaseNumber,
            'ZM');
            system.debug('registrationResponse==='+registrationResponse);
            registrationResponse = registrationResponse.remove('{');
            registrationResponse = registrationResponse.remove('}');
            registrationResponse = registrationResponse.remove('"');
            successFlag = false;
            for(String st : registrationResponse.split(',')) {
                String strPre = st.substringBefore(':').trim();
                String strPost = st.subStringAfter(':').trim();
                if(strPre.equalsIgnoreCase('Status') && strPre.equalsIgnoreCase('S')) {
                    successFlag = true;
                }
                if(successFlag && strPre.equalsIgnoreCase('RegistrationId') 
                    && !strPost.equalsIgnoreCase('null') && strPost != null) {
                    bookUnitInst.Registration_ID__c = strPost;
                    listUpdate.add(bookUnitInst);
                }
            }
        }
        if(!listUpdate.isEmpty()) {
            update listUpdate;
        }
        system.debug('listUpdate==='+listUpdate);
    }

    public void transferJointBuyer(Set<Id> setCaseAccountTransferId) {
        Integer NoOfRecords = 1;
        //Id personalAccountRecordTypeId = getRecordTypeId('Account', 'PersonAccount');
        List<Account> lstJointBuyerAccount = new List<Account>();
        List<Joint_Buyer_New__c> lstJointBuyerUpdates = new List<Joint_Buyer_New__c>();
        map<Integer, Joint_Buyer_New__c> mapJointBuyerAccount = new map<Integer, Joint_Buyer_New__c>();

        for(Joint_Buyer_New__c objJB: [select Id, Buyer__c, Joint_Buyer__c, Joint_Buyer__r.Title__c, Joint_Buyer__r.Title_Arabic__c,
                Joint_Buyer__r.First_Name__c, Joint_Buyer__r.First_Name_Arabic__c, Joint_Buyer__r.Last_Name__c,
                Joint_Buyer__r.Last_Name_Arabic__c, Joint_Buyer__r.Nationality__c, Joint_Buyer__r.Nationality_Arabic__c,
                Joint_Buyer__r.Passport_Number__c, Joint_Buyer__r.Passport_Expiry_Date__c, Joint_Buyer__r.Place_of_Issue__c,
                Joint_Buyer__r.Place_of_Issue_Arabic__c, Joint_Buyer__r.Address_Line_1__c, Joint_Buyer__r.Address_Line_1_Arabic__c,
                Joint_Buyer__r.Address_Line_2__c, Joint_Buyer__r.Address_Line_2_Arabic__c, Joint_Buyer__r.Address_Line_3__c,
                Joint_Buyer__r.Address_Line_3_Arabic__c, Joint_Buyer__r.Address_Line_4__c, Joint_Buyer__r.Address_Line_4_Arabic__c,
                Joint_Buyer__r.Country__c, Joint_Buyer__r.Country_Arabic__c, Joint_Buyer__r.City__c, Joint_Buyer__r.City_Arabic__c,
                Joint_Buyer__r.Phone_Country_Code__c, Joint_Buyer__r.Phone__c, Joint_Buyer__r.Date_of_Birth__c, Joint_Buyer__r.Email__c,
                Case__r.AccountId from Joint_Buyer_New__c where Case__c IN: setCaseAccountTransferId]) {

            Account personalAccountObj = new Account();
            personalAccountObj.PersonTitle = objJB.Joint_Buyer__r.Title__c;
            personalAccountObj.Title_Arabic__pc = objJB.Joint_Buyer__r.Title_Arabic__c;
            personalAccountObj.FirstName = objJB.Joint_Buyer__r.First_Name__c;
            personalAccountObj.First_Name_Arabic__pc = objJB.Joint_Buyer__r.First_Name_Arabic__c;
            personalAccountObj.LastName = objJB.Joint_Buyer__r.Last_Name__c;
            personalAccountObj.Last_Name_Arabic__pc = objJB.Joint_Buyer__r.Last_Name_Arabic__c;
            personalAccountObj.Nationality__pc = objJB.Joint_Buyer__r.Nationality__c;
            personalAccountObj.Nationality_Arabic__pc = objJB.Joint_Buyer__r.Nationality_Arabic__c;
            personalAccountObj.Passport_Number__pc = objJB.Joint_Buyer__r.Passport_Number__c;
            //personalAccountObj.Passport_Expiry_Date__pc = objJB.Joint_Buyer__r.Passport_Expiry_Date__c;
            personalAccountObj.Passport_Issue_Place__pc = objJB.Joint_Buyer__r.Place_of_Issue__c;
            personalAccountObj.Passport_Issue_Place_Arabic__pc = objJB.Joint_Buyer__r.Place_of_Issue_Arabic__c;
            personalAccountObj.Address_Line_1__pc = objJB.Joint_Buyer__r.Address_Line_1__c;
            personalAccountObj.Address_Line_1_Arabic__pc = objJB.Joint_Buyer__r.Address_Line_1_Arabic__c;
            personalAccountObj.Address_Line_2__pc = objJB.Joint_Buyer__r.Address_Line_2__c;
            personalAccountObj.Address_Line_2_Arabic__pc = objJB.Joint_Buyer__r.Address_Line_2_Arabic__c;
            personalAccountObj.Address_Line_3__pc = objJB.Joint_Buyer__r.Address_Line_3__c;
            personalAccountObj.Address_Line_3_Arabic__pc = objJB.Joint_Buyer__r.Address_Line_3_Arabic__c;
            personalAccountObj.Address_Line_4__pc = objJB.Joint_Buyer__r.Address_Line_4__c;
            personalAccountObj.Address_Line_4_Arabic__pc = objJB.Joint_Buyer__r.Address_Line_4_Arabic__c;
            personalAccountObj.Country__pc = objJB.Joint_Buyer__r.Country__c;
            personalAccountObj.Country_Arabic__pc = objJB.Joint_Buyer__r.Country_Arabic__c;
            personalAccountObj.City__pc = objJB.Joint_Buyer__r.City__c;
            personalAccountObj.City_Arabic__pc = objJB.Joint_Buyer__r.City_Arabic__c;
            personalAccountObj.Phone_Country_Code__c = objJB.Joint_Buyer__r.Phone_Country_Code__c;
            personalAccountObj.Phone_Encrypt__c = objJB.Joint_Buyer__r.Phone__c;
            //personalAccountObj.Date_Of_Birth__c = objJB.Joint_Buyer__r.Date_of_Birth__c;
            personalAccountObj.PersonEmail = objJB.Joint_Buyer__r.Email__c;
            lstJointBuyerAccount.add(personalAccountObj);

            mapJointBuyerAccount.put(NoOfRecords, objJB);
            NoOfRecords++;
        }
        if(!lstJointBuyerAccount.isEmpty()) {
            insert lstJointBuyerAccount;
            system.debug('lstJointBuyerAccount==='+lstJointBuyerAccount);
            NoOfRecords = 1;
            for(Account objAccount: lstJointBuyerAccount) {
                Joint_Buyer_New__c jointBuyerObj = new Joint_Buyer_New__c();
                jointBuyerObj.Id = mapJointBuyerAccount.get(NoOfRecords).Id;
                jointBuyerObj.Account__c = mapJointBuyerAccount.get(NoOfRecords).Case__r.AccountId;
                jointBuyerObj.Joint_Account__c = objAccount.Id;
                lstJointBuyerUpdates.add(jointBuyerObj);
                NoOfRecords++;
            }
            if(!lstJointBuyerUpdates.isEmpty()) {
                update lstJointBuyerUpdates;
            }
        }
    }

    //set the 'New Buyer Approval' Task to Completed when case buyer is approved
/*    public void updateBuyerApprovalTask(Set<Id> setCaseIdForTaskUpdation) {
        List<Task> lstUpdateApprovalTask = new List<Task>();
        for(Task objTask: [select Id, status from Task where Subject = 'New Buyer Approval'
                and whatId IN: setCaseIdForTaskUpdation]) {
            Task taskObj = new Task();
            taskObj.Id = objTask.Id;
            taskObj.status = 'Completed';
            lstUpdateApprovalTask.add(taskObj);
        }
        if(!lstUpdateApprovalTask.isEmpty()) {
            update lstUpdateApprovalTask;
        }
    }*/

    //set the Task to Completed
    public void updateApprovalTask(Set<Id> setCaseIdForTaskUpdation, String processName, 
                                    String taskSubject) {
        List<Task> lstUpdateApprovalTask = new List<Task>();
        for(Task objTask: [select Id, status from Task where Subject =: taskSubject
                and whatId IN: setCaseIdForTaskUpdation and Process_Name__c =: processName]) {
            Task taskObj = new Task();
            taskObj.Id = objTask.Id;
            taskObj.status = 'Completed';
            lstUpdateApprovalTask.add(taskObj);
        }
        if(!lstUpdateApprovalTask.isEmpty()) {
            update lstUpdateApprovalTask;
        }
    }
    
    /*private Task getTask(Case objCase, String strSubject, String strAssignedUser, String strProcessName,
        Date dtDueDate) {
        Task objTask = new Task();
        objTask.OwnerId = objCase.OwnerId;
        objTask.WhatId = objCase.Id;
        objTask.Subject = strSubject;
        objTask.ActivityDate = dtDueDate;
        objTask.Assigned_User__c = strAssignedUser;
        objTask.Process_Name__c = strProcessName;
        objTask.Priority = 'High';
        objTask.Priority = 'Not Started';
        return objTask;
        
       
    }*/
}
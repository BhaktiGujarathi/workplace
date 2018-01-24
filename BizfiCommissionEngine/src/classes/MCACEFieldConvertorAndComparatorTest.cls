/*
This is a test class for following class:

MCACEFieldConvertorAndComparator
MCACEFieldValidator
CommissionRuleEntryService
CommissionRuleEntryHandler
MCAExtensionCommissionEngine


*/


@isTest
private class MCACEFieldConvertorAndComparatorTest { 
     
     // method to test for Invalid picklist type of field
     static testMethod void testInvalidPickListtype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Text__c = 'TestCollector';
         String pString = 'ABCTesting';
         test.startTest(); 
             try {
                 insert objEntry;
                 MCACEFieldConvertorAndComparator.convertAndCompareString(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
             } catch (Exception ex) {
             
             } 
         test.stopTest();
     }
     
     // method to test for picklist type of field
     static testMethod void testPickListtype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);

         String pString = 'Funded';
         test.startTest(); 
                 insert objEntry;
                 MCACEFieldConvertorAndComparator.convertAndCompareString(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c ); 
         test.stopTest();
     }
     
     // method to test for Invalid Operator picklist type of field
     static testMethod void testInvalidOperatorPickListtype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Operator__c = 'greater than';
         String pString = 'Funded';
         test.startTest(); 
             try {
                 insert objEntry;
             } catch(exception ex) {
             }
         test.stopTest();
     }
     
     // method to test for String type of field
     static testMethod void testStringtype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'McaApp__Collector__c';
         objEntry.MCACE__Text__c = 'TestCollector';
         objEntry.MCACE__Operator__c = 'not equal to';
         
         String pString = 'TestString';
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareString(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Currency type of field
     static testMethod void testCurrencytype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'McaApp__Closing_Cost__c';
         objEntry.MCACE__Text__c = '50';
         objEntry.MCACE__Operator__c = 'greater than';
         
         Integer pString = 60;
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDecimal(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Currency type of field
     static testMethod void testInvalidCurrencytype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'McaApp__Closing_Cost__c';
         objEntry.MCACE__Text__c = 'abc';
         objEntry.MCACE__Operator__c = 'greater than';
         
         Integer pString = 60;
         test.startTest();
              try { 
                 insert objEntry;
              } catch(Exception ex) {
              }
         test.stopTest();
         
         
     }
     
     // method to test for Percent type of field
     static testMethod void testPercenttype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'Probability';
         objEntry.MCACE__Text__c = '100';
         objEntry.MCACE__Operator__c = 'equals';
         
         Integer pString = 100;
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDecimal(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Reference type of field
     static testMethod void testReferencetype() {
         Account objAccount = new Account();
         objAccount = getAccountRecord(1);
         insert objAccount;
         
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'AccountId';
         objEntry.MCACE__Text__c = 'TestAccount';
         objEntry.MCACE__Operator__c = 'equals';
         
         MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper  objWrapp = new MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper();
         objWrapp = MCACEFieldConvertorAndComparator.getDatatypeAndValidate(objEntry);
         String pString = objAccount.Id;
         
         test.startTest();
             insert objEntry;             
             MCACEFieldConvertorAndComparator.convertAndCompareLookUp(objWrapp, objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Not Equal To Reference type of field
     static testMethod void testNotEqualReferencetype() {
         Account objAccount = new Account();
         objAccount = getAccountRecord(1);
         insert objAccount;
         
         Account objAccount2 = new Account();
         objAccount2 = getAccountRecord(1);
         objAccount2.Name = 'AbcAccount';
         insert objAccount2;
         
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'AccountId';
         objEntry.MCACE__Text__c = 'TestAccount';
         objEntry.MCACE__Operator__c = 'not equal to';
         
         MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper  objWrapp = new MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper();
         objWrapp = MCACEFieldConvertorAndComparator.getDatatypeAndValidate(objEntry);
         String pString = objAccount2.Id;
         
         test.startTest();
             insert objEntry;             
             MCACEFieldConvertorAndComparator.convertAndCompareLookUp(objWrapp, objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test invalid reference type field
     static testMethod void testInvalidReferencetype() {
         Account objAccount = new Account();
         objAccount = getAccountRecord(1);
         insert objAccount;
         
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'AccountId';
         objEntry.MCACE__Text__c ='003134565';
         objEntry.MCACE__Operator__c = 'equals';
         
         test.startTest(); 
         try {
             insert objEntry;
         } catch (Exception ex) {
         }
         test.stopTest();
     }
     
     // method to test for Email type of field
     static testMethod void testEmailtype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'Account';
         objEntry.MCACE__Field_API__c = 'McaApp__Email__c';
         objEntry.MCACE__Text__c = 'abc@xyz.com';
         objEntry.MCACE__Operator__c = 'not equal to';
         
         String pString = 'xyz@abc.com';
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareString(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Invalid Operator Email type of field
     static testMethod void testInvalidOperatorEmailtype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'Account';
         objEntry.MCACE__Field_API__c = 'McaApp__Email__c';
         objEntry.MCACE__Text__c = 'abc@xyz.com';
         objEntry.MCACE__Operator__c = 'greater than';
         
         String pString = 'xyz@abc.com';
         test.startTest(); 
             try {
                 insert objEntry;
             } catch(Exception ex) {
             }
         test.stopTest();
         
     }
     
     // method to test for Invalid Email type of field
     static testMethod void testInvalidEmailtype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'Account';
         objEntry.MCACE__Field_API__c = 'McaApp__Email__c';
         objEntry.MCACE__Text__c = 'abc';
         objEntry.MCACE__Operator__c = 'not equal to';
         
         test.startTest();
         try {
             insert objEntry;
         } catch (Exception ex) {
         }
         test.stopTest();
         
     }
     
     // method to test for Boolean type of field
     static testMethod void testBooleantype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'IsPrivate';
         objEntry.MCACE__Text__c = 'false';
         objEntry.MCACE__Operator__c = 'equals';
         
         Boolean pString = False;
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareString(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Boolean type of field
     static testMethod void testInvalidOperatorBooleantype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'IsPrivate';
         objEntry.MCACE__Text__c = 'false';
         objEntry.MCACE__Operator__c = 'less than';
         
         Boolean pString = False;
         test.startTest(); 
             try {
                 insert objEntry;
             } catch(Exception ex) {
             }
         test.stopTest();
         
     }
     
     // method to test for Invalid Boolean type of field
     static testMethod void testInvalidBooleantype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'IsPrivate';
         objEntry.MCACE__Text__c = 'abc';
         objEntry.MCACE__Operator__c = 'equals';
         
         test.startTest();
         try {
             insert objEntry;
         } catch(Exception ex) {
         }
         test.stopTest();
         
     }
     
     // method to test for Double type of field
     static testMethod void testDoubletype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'McaApp__No_Bank_Statements__c';
         objEntry.MCACE__Text__c = '4';
         objEntry.MCACE__Operator__c = 'less than';
         
         Integer pString = 3;
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDecimal(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Less Or equal Double type of field
     static testMethod void testLessEqualDoubletype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'McaApp__No_Bank_Statements__c';
         objEntry.MCACE__Text__c = '4';
         objEntry.MCACE__Operator__c = 'less or equal';
         
         Integer pString = 3;
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDecimal(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Greater Or equal Double type of field
     static testMethod void testGreaterEqualDoubletype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'McaApp__No_Bank_Statements__c';
         objEntry.MCACE__Text__c = '4';
         objEntry.MCACE__Operator__c = 'greater or equal';
         
         Integer pString = 5;
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDecimal(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Not Equal Double type of field
     static testMethod void testNotEqualDoubletype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'McaApp__No_Bank_Statements__c';
         objEntry.MCACE__Text__c = '4';
         objEntry.MCACE__Operator__c = 'not equal to';
         
         Integer pString = 3;
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDecimal(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Update Double type of field
     static testMethod void testUpdateDoubletype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'McaApp__No_Bank_Statements__c';
         objEntry.MCACE__Text__c = '4';
         objEntry.MCACE__Operator__c = 'less than';
         insert objEntry;
         
         objEntry.MCACE__Field_API__c = 'McaApp__No_Bank_Statements__c';
         objEntry.MCACE__Text__c = '40';
         
         Integer pString = 4;
         test.startTest();
             update objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDecimal(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Phone type of field
     static testMethod void testPhonetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'Account';
         objEntry.MCACE__Field_API__c = 'Phone';
         objEntry.MCACE__Text__c = '1234567890';
         objEntry.MCACE__Operator__c = 'equals';
         
         String pString = '1234567890';
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndComparePhone(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Wrong Operator for Phone type of field
     static testMethod void testInvalidOperatorFoPhonetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'Account';
         objEntry.MCACE__Field_API__c = 'Phone';
         objEntry.MCACE__Text__c = '1234567890';
         objEntry.MCACE__Operator__c = 'greater than';
         
         String pString = '1234567890';
         test.startTest();
             try {
                 insert objEntry;
             } catch(Exception ex) {
             }
         test.stopTest();
         
     }
     
     // method to test for Date type of field
     static testMethod void testGreaterEqualDatetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'CloseDate';
         objEntry.MCACE__Text__c = '12/10/2016';
         objEntry.MCACE__Operator__c = 'greater or equal';
         
         Date pString = Date.ValueOf('2016-12-10');
         test.startTest();
             insert objEntry;
             List<String> dateList = string.valueOf(objEntry.MCACE__Text__c).split('/');
             Date strDate= Date.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]));
             MCACEFieldConvertorAndComparator.convertAndCompareDate(String.valueOf(strDate), (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Date type of field
     static testMethod void testLessEqualDatetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'CloseDate';
         objEntry.MCACE__Text__c = '12/10/2016';
         objEntry.MCACE__Operator__c = 'less or equal';
         
         Date pString = Date.ValueOf('2016-12-09');
         test.startTest();
             insert objEntry;
             List<String> dateList = string.valueOf(objEntry.MCACE__Text__c).split('/');
             Date strDate= Date.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]));
             MCACEFieldConvertorAndComparator.convertAndCompareDate(String.valueOf(strDate), (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Equal Date type of field
     static testMethod void testEqualDatetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'CloseDate';
         objEntry.MCACE__Text__c = '12/10/2016';
         objEntry.MCACE__Operator__c = 'equals';
         
         Date pString = Date.ValueOf('2016-12-10');
         test.startTest();
             insert objEntry;
             List<String> dateList = string.valueOf(objEntry.MCACE__Text__c).split('/');
             Date strDate= Date.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]));
             MCACEFieldConvertorAndComparator.convertAndCompareDate(String.valueOf(strDate), (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Not Equal Date type of field
     static testMethod void testNotEqualDatetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'CloseDate';
         objEntry.MCACE__Text__c = '12/11/2016';
         objEntry.MCACE__Operator__c = 'not equal to';
         
         Date pString = Date.ValueOf('2016-12-09');
         test.startTest();
             insert objEntry;
             List<String> dateList = string.valueOf(objEntry.MCACE__Text__c).split('/');
             Date strDate= Date.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]));
             MCACEFieldConvertorAndComparator.convertAndCompareDate(String.valueOf(strDate), (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     } 
     
     // method to test for Greater than Date type of field
     static testMethod void testGreaterThanDatetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'CloseDate';
         objEntry.MCACE__Text__c = '12/10/2016';
         objEntry.MCACE__Operator__c = 'greater than';
         
         Date pString = Date.ValueOf('2016-12-11');
         test.startTest();
             insert objEntry;
             List<String> dateList = string.valueOf(objEntry.MCACE__Text__c).split('/');
             Date strDate= Date.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]));
             MCACEFieldConvertorAndComparator.convertAndCompareDate(String.valueOf(strDate), (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Less than Date type of field
     static testMethod void testLessThanDatetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'CloseDate';
         objEntry.MCACE__Text__c = '12/10/2016';
         objEntry.MCACE__Operator__c = 'less than';
         
         Date pString = Date.ValueOf('2016-12-09');
         test.startTest();
             insert objEntry;
             List<String> dateList = string.valueOf(objEntry.MCACE__Text__c).split('/');
             Date strDate= Date.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]));
             MCACEFieldConvertorAndComparator.convertAndCompareDate(String.valueOf(strDate), (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Invalid Date type of field
     static testMethod void testInvalidDatetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'CloseDate';
         objEntry.MCACE__Text__c = '2015-10/23';
         objEntry.MCACE__Operator__c = 'greater or equal';
         
         test.startTest();
             try {
                 insert objEntry;
             } catch(Exception ex) {
             }
         test.stopTest();
         
     }
     
     // method to test for Less or Equal Datetime type of field
 /*    static testMethod void testLessEqualDatetimetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'McaApp__Submission__c';
         objEntry.MCACE__Field_API__c = 'McaApp__Date_Submitted__c';
         objEntry.MCACE__Text__c = '12/10/2016';
         objEntry.MCACE__Operator__c = 'less or equal';
         
         Datetime pString = Datetime.ValueOf('2016-12-09 00:00:00');
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDate(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Greater or Equal Datetime type of field
     static testMethod void testGreaterEqualDatetimetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'McaApp__Submission__c';
         objEntry.MCACE__Field_API__c = 'McaApp__Date_Submitted__c';
         objEntry.MCACE__Text__c = '12/10/2016';
         objEntry.MCACE__Operator__c = 'greater or equal';
         
         Datetime pString = Datetime.ValueOf('2016-12-11 00:00:00');
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDate(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Greater Datetime type of field
     static testMethod void testGreaterDatetimetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'McaApp__Submission__c';
         objEntry.MCACE__Field_API__c = 'McaApp__Date_Submitted__c';
         objEntry.MCACE__Text__c = '12/10/2016';
         objEntry.MCACE__Operator__c = 'greater than';
         
         Datetime pString = Datetime.ValueOf('2016-12-11 00:00:00');
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDate(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Less than Datetime type of field
     static testMethod void testLessDatetimetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'McaApp__Submission__c';
         objEntry.MCACE__Field_API__c = 'McaApp__Date_Submitted__c';
         objEntry.MCACE__Text__c = '12/10/2016';
         objEntry.MCACE__Operator__c = 'less than';
         
         Datetime pString = Datetime.ValueOf('2016-12-09 00:00:00');
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDate(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Equal Datetime type of field
     static testMethod void testEqualDatetimetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'McaApp__Submission__c';
         objEntry.MCACE__Field_API__c = 'McaApp__Date_Submitted__c';
         objEntry.MCACE__Text__c = '12/10/2016';
         objEntry.MCACE__Operator__c = 'equals';
         
         Datetime pString = Datetime.valueOf('2016-12-11 00:00:00');
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDate(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Not Equal Datetime type of field
     static testMethod void testNotEqualtimetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'McaApp__Submission__c';
         objEntry.MCACE__Field_API__c = 'McaApp__Date_Submitted__c';
         objEntry.MCACE__Text__c = '12/11/2016';
         objEntry.MCACE__Operator__c = 'not equal to';
         
         Datetime pString = Datetime.valueOf('12/11/2016 00:00:00');
         test.startTest();
             insert objEntry;
             MCACEFieldConvertorAndComparator.convertAndCompareDate(objEntry.MCACE__Text__c, (object)pString, objEntry.MCACE__Operator__c );
         test.stopTest();
         
     }
     
     // method to test for Invalid Datetime type of field
     static testMethod void testInvalidDatetimetype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Object_API__c = 'McaApp__Submission__c';
         objEntry.MCACE__Field_API__c = 'McaApp__Date_Submitted__c';
         objEntry.MCACE__Text__c = '2015/15/23';
         objEntry.MCACE__Operator__c = 'less or equal';
         
         test.startTest();
             try {
                 insert objEntry;
             } catch (Exception ex) {
             }
            
         test.stopTest();
         
     }*/
     
     // method to test for URL type of field
     static testMethod void testURLtype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'MCACE__Test_URL__c';
         objEntry.MCACE__Text__c = 'abc';
         objEntry.MCACE__Operator__c = 'equals';
         
         test.startTest();
             insert objEntry;
         test.stopTest();

     }
         
     // method to test for invalid type of field
     static testMethod void testInvalidtype() {
         MCACE__Commission_Structure__c objStruct = new MCACE__Commission_Structure__c();
         objStruct = getStructureRecord(1);
         insert objStruct;
         
         MCACE__Commission_Rule__c objRule = new MCACE__Commission_Rule__c();
         objRule =  getRuleRecord(1, objStruct.Id);
         insert objRule;
         
         MCACE__Commission_Rule_Entry__c objEntry = new MCACE__Commission_Rule_Entry__c();
         objEntry = getEntryRecord(1, objRule.Id);
         objEntry.MCACE__Field_API__c = 'McaApp__Closed_Stips__c';
         objEntry.MCACE__Text__c = '1';
         objEntry.MCACE__Operator__c = 'not equal to';
         
         test.startTest();
             insert objEntry;
         test.stopTest();

     }
     
     // method to generate commission structure of testcode
     static MCACE__Commission_Structure__c getStructureRecord(Integer pCount) {
         MCACE__Commission_Structure__c structObj = new MCACE__Commission_Structure__c();
         structObj.Name = 'TestStruct';
         structObj.MCACE__Type__c = 'Closer';
         
         return structObj;       
     }
     
     // method to generate commission Rule of testcode
     static MCACE__Commission_Rule__c getRuleRecord(Integer pCount, Id pStructureId) {
         MCACE__Commission_Rule__c ruleObj = new MCACE__Commission_Rule__c();
         ruleObj.Name = 'TestRule';
         ruleObj.MCACE__Commission_Type__c = 'Fixed';
         ruleObj.MCACE__Fixed_Amount__c = 50;
         ruleObj.MCACE__Payable_Type__c = 'Commission';
         ruleObj.MCACE__Commission_Structure__c = pStructureId;
         
         return ruleObj;       
     }
     
     // method to generate commission Rule Entry of testcode
     static MCACE__Commission_Rule_Entry__c getEntryRecord(Integer pCount, Id pRuleId) {
         MCACE__Commission_Rule_Entry__c entryObj = new MCACE__Commission_Rule_Entry__c();
         entryObj.Name = 'TestEntry';
         entryObj.MCACE__Object_API__c = 'Opportunity';
         entryObj.MCACE__Commission_Rule__c = pRuleId;
         entryObj.MCACE__Field_API__c = 'StageName';
         entryObj.MCACE__Operator__c = 'equals';
         entryObj.MCACE__Text__c = 'Funded';
         
         return entryObj;       
     }
     
     static Account getAccountRecord(Integer pCount) {
         Account accountObj = new Account();
         accountObj.Name = 'TestAccount';
         
         return accountObj;
     }
}



/*
    List<String> dateList = string.valueOf(entry.Text__c).split('/');
                    Date strDate= Date.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]));
                    enrtyCrteria = MCACEFieldConvertorAndComparator.convertAndCompareDate(String.valueOf(strDate), sobj.get(entry.Field_API__c), entry.Operator__c);
*/
@istest
public class UtilityHelperClsTest{



    static testmethod void UtilityHelperCls_Methods(){
        test.starttest();        
            //
            UtilityHelperCls.areSearchFieldsTextType(Account.getsObjectType(),'Name');
            
            //
            UtilityHelperCls.encryptMobile('abc');
            
            //
            UtilityHelperCls.decryptMobile('YluEsiQI/cSnaj8UXpYdiDkYOeyILG3+5H2zH4zFgd0=');
            
            //
            UtilityHelperCls.removeFirstZero('01234567890');
            
            //
            RecordType rt = [select Id,Name,DeveloperName from RecordType where sObjectType =:'Account' LIMIT 1];
            
            map<Id,RecordType> mapRecordTypes = new map<id,recordtype>();
            mapRecordTypes.put(rt.id,rt);
            string sObjectName = 'Account';
            Boolean isLoad = false;
            UtilityHelperCls.LoadRecordTypes(mapRecordTypes,sObjectName,isLoad);
            mapRecordTypes.clear();
            isLoad = true;
            UtilityHelperCls.LoadRecordTypes(mapRecordTypes,sObjectName,isLoad);
            
            //
            UtilityHelperCls.AcessToken();
            
            //
            UtilityHelperCls.sendsms('12345678','asdfghjkl');
        test.stoptest();

    }




}
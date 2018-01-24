@isTest(seeAllData = false)
private class WTOFieldselectioncontrol_Test
{
    Public String typeName{get;set;}
    Public String link{get;set;}
    Public boolean renderlink{get;set;}
    Public Map<String,String> mapApiLabel{get;set;}
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    Public Set<string> leftvalues = new Set<string>();
    Public List<string> rightvalues = new List<string>();
    
    
    static testmethod void WTOObjectListingGetNameTest()
    {
        
        System.Test.startTest();
        WTOObjectListing wtoObjList=new WTOObjectListing();
        wtoObjList.getName();
        wtoObjList.next();
        System.Test.stopTest();
        
    }
    
    static testmethod void WTOFieldSelectionControllOnLoadTest()
    {
        System.Test.startTest();
        
        
        WTOFieldselectioncontrol wtoFieldSelCntrl=new WTOFieldselectioncontrol();
        System.currentPagereference().getParameters().put(WTOConstants.wtoObjectListingPageUrlParamKey1,WTOUtility.convertComponentToNameSpaceComponent(WTOConstants.apiNameForTestObject ));
        
        wtoFieldSelCntrl.onload();
        wtoFieldSelCntrl.getunSelectedValues();
        wtoFieldSelCntrl.mapApiLabel.put(WTOUtility.convertComponentToNameSpaceComponent(WTOConstants.apiForNameField ),WTOConstants.labelForNameField );
        wtoFieldSelCntrl.rightvalues.add(WTOUtility.convertComponentToNameSpaceComponent(WTOConstants.apiForNameField ));
        List<SelectOption> listOfselectValues=wtoFieldSelCntrl.getSelectedValues();
        
        List<SelectOption> testSelectedValuesList=new List<SelectOption>();
        testSelectedValuesList.add(new SelectOption(WTOUtility.convertComponentToNameSpaceComponent( WTOConstants.apiForNameField ),WTOConstants.labelForNameField));
        
        System.assertEquals(testSelectedValuesList,listOfselectValues);
        System.Test.stopTest();
        
    }
    
    static testmethod void WTOFieldSelectionControlUnSelectClickTest()
    {
        System.Test.startTest();
        WTOFieldselectioncontrol wtoFieldSelCntrl=new WTOFieldselectioncontrol();
        System.currentPagereference().getParameters().put(WTOConstants.wtoObjectListingPageUrlParamKey1,WTOUtility.convertComponentToNameSpaceComponent(WTOConstants.apiNameForTestObject)  );
        
        wtoFieldSelCntrl.onload();
        wtoFieldSelCntrl.rightValues.add(WTOConstants.apiForNameField );
        wtoFieldSelCntrl.rightselected.add(WTOConstants.apiForNameField );
        wtoFieldSelCntrl.unselectclick();
        
        Set<String> testLeftValues=new  Set<String>();
        
        for(String fieldApiName : wtoFieldSelCntrl.leftValues)
        {
            testLeftValues.add(fieldApiName);
            
        }
        System.assertEquals(wtoFieldSelCntrl.leftValues,testLeftValues);
        System.Test.stopTest();
    }
    
    
    static testmethod void  WTOFieldSelectionControlSelectClickTest()
    {
        
        System.Test.startTest();
        WTOFieldselectioncontrol wtoFieldSelCntrl=new WTOFieldselectioncontrol();
        System.currentPagereference().getParameters().put(WTOConstants.wtoObjectListingPageUrlParamKey1,WTOUtility.convertComponentToNameSpaceComponent(WTOConstants.apiNameForTestObject)  );
        wtoFieldSelCntrl.onload();
        wtoFieldSelCntrl.leftselected.add(WTOConstants.apiForNameField);
        wtoFieldSelCntrl.selectclick();
        
        
        List<String> testRightValues=new  List<String>();
        
        for(String fieldApiName : wtoFieldSelCntrl.rightValues)
        {
            testRightValues.add(fieldApiName);
            
        }
        
        System.assertEquals(wtoFieldSelCntrl.rightValues,testRightValues);
        System.Test.stopTest();
    }
    
    static testmethod void WTOFieldSelectionControlUpclickTest()
    {
        
        
        WTOFieldselectioncontrol wtoFieldSelCntrl=new WTOFieldselectioncontrol();
        System.currentPagereference().getParameters().put(WTOConstants.wtoObjectListingPageUrlParamKey1,WTOUtility.convertComponentToNameSpaceComponent(WTOConstants.apiNameForTestObject)  );
        wtoFieldSelCntrl.onload();
        
        wtoFieldSelCntrl.rightvalues.add(WTOConstants.listOfAPINameForTestField[0]);
        wtoFieldSelCntrl.rightvalues.add(WTOConstants.listOfAPINameForTestField[1]);
        wtoFieldSelCntrl.rightvalues.add(WTOConstants.listOfAPINameForTestField[2]);
        
        wtoFieldSelCntrl.rightselected.add(WTOConstants.listOfAPINameForTestField[1]);
        wtoFieldSelCntrl.upclick();
        
        List<String> testRightValues=new  List<String>();
        
        
        testRightValues.add(WTOConstants.listOfAPINameForTestField[1]);
        testRightValues.add(WTOConstants.listOfAPINameForTestField[0]);
        testRightValues.add(WTOConstants.listOfAPINameForTestField[2]);
        
        System.assertEquals(wtoFieldSelCntrl.rightValues,testRightValues);
        
    }
    
    
    
    static testmethod void WTOFieldSelectionControlDownclickTest()
    {
        
        
        WTOFieldselectioncontrol wtoFieldSelCntrl=new WTOFieldselectioncontrol();
        System.currentPagereference().getParameters().put(WTOConstants.wtoObjectListingPageUrlParamKey1,WTOUtility.convertComponentToNameSpaceComponent(WTOConstants.apiNameForTestObject)  );
        wtoFieldSelCntrl.onload();
        wtoFieldSelCntrl.rightvalues.add(WTOConstants.listOfAPINameForTestField[0]);
        wtoFieldSelCntrl.rightvalues.add(WTOConstants.listOfAPINameForTestField[1]);
        wtoFieldSelCntrl.rightvalues.add(WTOConstants.listOfAPINameForTestField[2]);
        
        wtoFieldSelCntrl.rightselected.add(WTOConstants.listOfAPINameForTestField[1]);
        wtoFieldSelCntrl.downclick();
        
        List<String> testRightValues=new  List<String>();
        
        
        testRightValues.add(WTOConstants.listOfAPINameForTestField[0]);
        testRightValues.add(WTOConstants.listOfAPINameForTestField[2]);
        testRightValues.add(WTOConstants.listOfAPINameForTestField[1]);
        
        System.assertEquals(wtoFieldSelCntrl.rightValues,testRightValues);
        
    }
    
    // not sure whether to keep or not
    static testmethod void WTOonLoadSave()
    {
        
        WTOFieldselectioncontrol wtoFieldSelCntrl=new WTOFieldselectioncontrol();
        System.currentPagereference().getParameters().put(WTOConstants.wtoObjectListingPageUrlParamKey1,WTOUtility.convertComponentToNameSpaceComponent(WTOConstants.apiNameForTestObject)  );
        wtoFieldSelCntrl.onload();
        wtoFieldSelCntrl.rightvalues.add(WTOUtility.convertComponentToNameSpaceComponent('Name__c'));
        wtoFieldSelCntrl.Save();
        
    }
    
    
    static testmethod void WTOonLoadCancel()
    {
        
        WTOFieldselectioncontrol wtoFieldSelCntrl=new WTOFieldselectioncontrol();
        System.currentPagereference().getParameters().put(WTOConstants.wtoObjectListingPageUrlParamKey1,WTOUtility.convertComponentToNameSpaceComponent(WTOConstants.apiNameForTestObject)  );
        wtoFieldSelCntrl.onload();
        wtoFieldSelCntrl.Cancel();
        
    }
    /*
    // not sure whether to keep or not
    static testmethod void WTOFormcontrolOnload()
    {
    
    
    WTOFormFields__c wtoff=new WTOFormFields__c();
    wtoff.Fieldsapiname__c='infydisdespune__Name__c';
    wtoff.objectapiname__c='infydisdespune__WTOTestObject__c';
    insert wtoff;
    WTOFormcontrol wtofc=new WTOFormcontrol();
    System.currentPagereference().getParameters().put('WTOFormid',wtoff.id);
    wtofc.onload();
    wtofc.save();
    
    
    
    }
    
    
    */
    
    static testmethod void WTOFieldSelectionControlGenerateHtmlTest()
    {
        
        System.Test.startTest();
        
        WTOFieldselectioncontrol WTOFieldSelection=new WTOFieldselectioncontrol();
        WTOFieldSelection.returnURL='www.google.com';
        System.currentPagereference().getParameters().put(WTOConstants.wtoObjectListingPageUrlParamKey1,WTOUtility.convertComponentToNameSpaceComponent(WTOConstants.apiNameForTestObject ));
        WTOFieldSelection.ONload();
        WTOFieldSelection.rightValues=WTOConstants.listOfAPINameForTestField;
        WTOFieldSelection.generateHTML();
        
        System.Test.stopTest();
    }
    
    
}
@isTest
private class TestCalculateIRRController
{
    static testMethod void testIRRController()
    {
        //Test.startTest();
        calculateIrrController testCon = new calculateIrrController();
        testCon.monthsString = '10';
        testCon.fundingAmountString = '1000';
        testCon.proccessFeeString = '100';
        testCon.commissionAmtString  = '200';
        testCon.payBackAmtString ='1200';
        testCon.calc();
        testCon.downloadPdf();
        System.assertEquals('24%',testCon.calculatedIrr);
                
        //testing for negatives
        calculateIrrController testCon2 = new calculateIrrController();
        testCon2.monthsString = '-10';
        testCon2.fundingAmountString = '-10';
        testCon2.proccessFeeString = '-10';
        testCon2.commissionAmtString  = '-10';
        testCon2.payBackAmtString ='-10';
        testCon2.calc();
        System.assertEquals(false, testCon2.isValid); 
        
        //testing for type exception
        calculateIrrController testCon3 = new calculateIrrController();
        testCon3.monthsString = 'test';
        testCon3.fundingAmountString = 'test';
        testCon3.proccessFeeString = 'test';
        testCon3.commissionAmtString  = 'test';
        testCon3.payBackAmtString ='test';
        testCon3.calc();
        System.assertEquals(false, testCon3.isValid);
        
        //test for null values
        calculateIrrController testCon4 = new calculateIrrController();
        testCon4.monthsString = '10';
        testCon4.fundingAmountString = '1000';
        testCon4.payBackAmtString ='1100';
        testCon4.calc();
        System.assertEquals('26%',testCon4.calculatedIrr);
        
        //check for months >500
        calculateIrrController testCon5 = new calculateIrrController();
        testCon5.monthsString = '600';
        testCon5.fundingAmountString = '10';
        testCon5.proccessFeeString = '10';
        testCon5.commissionAmtString  = '10';
        testCon5.payBackAmtString ='10';
        testCon5.calc();
        System.assertEquals(false, testCon5.isValid);        
    } 
}
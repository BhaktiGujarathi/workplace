/*
Author: Priyanshi Agrawal
Date: Feb 2014
Description: Controller for vf page calculateIrr. Validates input and calls classes which in turn calculate XIRR and return the value
back to the controller which displays it on the page.
*/

public class CalculateIRRController {

    XIRR_MCA2 obj {get;set;}
    public boolean isIRRCalculated {get;set;}
    public String monthsString{get;set;}
    public String fundingAmountString {get;set;}
    public String proccessFeeString {get;set;}
    public String commissionAmtString {get;set;}
    public String payBackAmtString {get;set;}
    Decimal months;
    public Decimal fundingAmount {get;set;}
    public Decimal proccessFee {get;set;}
    public Decimal commissionAmt {get;set;}
    public Decimal payBackAmt {get;set;}
    public String calculatedIRR {get;set;}
    public boolean isValid;
    public String errInInput    {get;set;}
    public CalculateIRRController()
    {    
        isValid= false;
    }
   
    public PageReference calc()
    {
        isValid= true;
        try
        {
            months = Decimal.Valueof(monthsString);
            if (months <=0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Term (Months) must be greater than zero'));
                isValid= false;
            }
            else if (months>500)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Term (Months) cannot be greater than 500'));
                isValid= false;            
            }            
        }
        catch (TypeException te)
        {
            ApexPages.addMessages(te);
            isValid= false;
        }
        try
        {   
            fundingAmount = Decimal.Valueof(fundingAmountString.replaceAll('[$,]',''));
            if (fundingAmount <0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Funding Amount cannot be less than zero'));
                isValid= false;
            } 
        }
        catch (TypeException te)
        {
            ApexPages.addMessages(te);
            isValid= false;
        }
        try
        {
            if (proccessFeeString == null || proccessFeeString== '')
                proccessFeeString = '0';
            proccessFee = Decimal.ValueOf(proccessFeeString.replaceAll('[$,]',''));
            if (proccessFee<0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Fees (Revenue) cannot be less than zero'));
                isValid= false;
            }
                
        }
        catch (TypeException te)
        {
            ApexPages.addMessages(te);
            isValid= false;
        }
        try
        {
            if (commissionAmtString == null || commissionAmtString== '')
                commissionAmtString = '0';
            commissionAmt = Decimal.ValueOf(commissionAmtString.replaceAll('[$,]',''));
            if (commissionAmt <0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Commissions (Expenses) cannot be less than zero'));
                isValid= false;
            }
                
        }
        catch (TypeException te)
        {
            ApexPages.addMessages(te);
            isValid= false;
        }
        try
        {
            payBackAmt = Decimal.ValueOf(payBackAmtString.replaceAll('[$,]',''));
            if (payBackAmt <0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Repayment Amount cannot be less than zero'));
                isValid= false;
            }
        }
        catch (TypeException te)
        {
            ApexPages.addMessages(te);
            isValid= false;
        }  
                                                                              
        if (isValid == true)
        {
            obj= new XIRR_MCA2(months,fundingAmount, proccessFee, commissionAmt, payBackAmt);
            obj.cal();
            calculatedIrr = String.valueOf(obj.XIRR) + '%';
            isIrrCalculated = true;  //if calculated successfully
        }
        return null;
    }
    public pageReference downloadPdf()
    {
        PageReference pdfPage = Page.calculateIrrPdf;
        return pdfPage;       
    }
}
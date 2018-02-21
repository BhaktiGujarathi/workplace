public class GRIDOnloadStaticVariable
 {  
    public static Boolean runOnceTask = false;
    public static Boolean runOnceStips = false;
    public static Boolean runOnceSynd = false;
    public static Boolean runOnceComm = false;
    public static Boolean runOnceConRol = false;
    public static Boolean runOncePay = false;
    public static Boolean runOnceRec = false;
    public static Boolean runOnceLoanBal = false;
    public static Boolean runOnceBankStatement = false;
    public static Boolean runOnceCreditCard = false;
    public static Boolean runOnceAttachment = false;
    public static Boolean runOnceSubmission = false;
    public static Boolean runOnceOffer = false;
    
    public static Map<String, Schema.SObjectType> globalMap = Schema.getGlobalDescribe();
    
    public static Map<String, Schema.SObjectType> getGlobalMap()
    {
        return globalMap;
    }
    
    public static boolean flipTask()
    {
        if(runOnceTask)
        {
             runOnceTask = false;
             return true;
        }
        else
        {
            runOnceTask = true;
            return false;
        }
    }
    
    public static boolean flipStips()
    {
        if(runOnceStips)
        {
             runOnceStips = false;
             return true;
        }
        else
        {
            runOnceStips = true;
            return false;
        }
    }
    
    public static boolean flipSynd()
    {
        if(runOnceSynd)
        {
             runOnceSynd = false;
             return true;
        }
        else
        {
            runOnceSynd = true;
            return false;
        }
    }
    
    public static boolean flipComm()
    {
        if(runOnceComm)
        {
             runOnceComm = false;
             return true;
        }
        else
        {
            runOnceComm = true;
            return false;
        }
    }
    
     public static boolean flipContactRole()
    {
        if(runOnceConRol)
        {
             runOnceConRol = false;
             return true;
        }
        else
        {
            runOnceConRol = true;
            return false;
        }
    }
    
    public static Boolean flipPayable()
    {
        if(runOncePay)
        {
            runOncePay = false;
            return true;
        }
        else
        {
            runOncePay = true;
            return false;
        }
    }
    
    public static Boolean flipReceivable()
    {
        if(runOnceRec)
        {
            runOnceRec = false;
            return true;
        }
        else
        {
            runOnceRec = true;
            return false;
        }
    }
    
    public static Boolean flipLoanBalance()
    {
        if(runOnceLoanBal)
        {
            runOnceLoanBal = false;
            return true;
        }
        else
        {
            runOnceLoanBal = true;
            return false;
        }
    }
    
    public static Boolean flipBankStatement()
    {
        if(runOnceBankStatement)
        {
            runOnceBankStatement = false;
            return true;
        }
        else
        {
            runOnceBankStatement = true;
            return false;
        }
    }
    
    public static Boolean flipCreditCard()
    {
        if(runOnceCreditCard)
        {
            runOnceCreditCard = false;
            return true;
        }
        else
        {
            runOnceCreditCard = true;
            return false;
        }
    }

    public static Boolean flipAttachment()
    {
        if(runOnceAttachment)
        {
            runOnceAttachment = false;
            return true;
        }
        else
        {
            runOnceAttachment = true;
            return false;
        }
    }
    
    public static Boolean flipSubmission()
    {
        if(runOnceSubmission)
        {
            runOnceSubmission = false;
            return true;
        }
        else
        {
            runOnceSubmission = true;
            return false;
        }
    }
    
    public static Boolean flipOffer()
    {
        if(runOnceOffer)
        {
            runOnceOffer = false;
            return true;
        }
        else
        {
            runOnceOffer = true;
            return false;
        }
    }
 }
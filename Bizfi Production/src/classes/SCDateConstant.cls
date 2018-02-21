public Class SCDateConstant
{
    public static Date currentDate =  System.now().date();
    public static DateTime currentDateTime = System.now();
       
    public static Date startYesterdayDate = calculateStartBussinessDate();
    public static Date endYesterdayDate = calculateEndBussinessDate();
    
    //Last 7 Days range
    public static Date startLast7DaysDate = currentDate.addDays(-7) ;
    public static Date endLast7DaysDate = currentDate;
   
    //Month To date range
    public static Date startMTDDate = currentDate.toStartOfMonth();
    public static Date endMTDDate = currentDate;
   
    //Last Month range    
   //public static Date endLastMonthDate = startMTDDate.addDays(-1);
    public static Date endLastMonthDate = startMTDDate;
    public static Date startLastMonthDate = (endLastMonthDate-1).toStartOfMonth();
    
    //Year to date range
    public static Date startYTDDate = Date.newInstance(currentDate.year(),1,1);
    public static Date endYTDDate = currentDate;
    
    // Range comparator for date
    public static Boolean isDateInRangeOfStartAndEnd(Date startDate, Date todayDate, Date endDate)
    {
        return (startDate <= todayDate && todayDate < endDate);
    
    }
    
   
    public static Date calculateStartBussinessDate()
    {
        
        if(currentDateTime.format('EEEE') == 'Sunday')
        {
          return (currentDateTime-2).date();
            
        }
        else if(currentDateTime.format('EEEE') == 'Monday')
        {
          return (currentDateTime-3).date();
            
        }
        else
        {
          return (currentDateTime-1).date(); 
        }
        
    
    }
    
    public static Date calculateEndBussinessDate()
    {
        if(currentDateTime.format('EEEE') == 'Sunday')
        {
          return (currentDateTime-1).date();
            
        }
        else if(currentDateTime.format('EEEE') == 'Monday')
        {
          return (currentDateTime-2).date();
            
        }
        else
        {
          return (currentDateTime).date(); 
        }
    
    }
    
    
}
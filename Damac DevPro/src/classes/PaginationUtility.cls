public virtual class PaginationUtility {
    
    public Boolean showNext {get; set;}
    public Boolean showprevious {get; set;}
    public Integer pageNumber {get; set;}
    public String errorMessage {get; set;}
    public List<Integer> pagesToShowList {get; set;}
    public List<Id> recordsList {get; set;}
    public List<Id> recordsPerPageList {get; set;}
    public Integer totalPageNumber {get;set;}
    public static Integer PAGE_SIZE = 25;
    public static Integer MAX_PAGES = 10; 
    public List<Integer> recordsSizeList = new List<Integer>();  
    
    /*********************************************************************************************
    * @Description : Method to count total number of pages #pagination.                          *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void countTotalPages(){
        recordsPerPageList = new List<Id>();
        system.debug('#### counting pages');
        if(recordsList != null && !recordsList.isEmpty()){
            for(Id thisRecord : recordsList){
                recordsPerPageList.add(thisRecord);
                if(recordsPerPageList.size() == PAGE_SIZE){
                    break;
                }
            }
            totalPageNumber =  ((math.mod(recordsList.size(), PAGE_SIZE) == 0) ? (recordsList.size() / PAGE_SIZE) : ((recordsList.size() / PAGE_SIZE) + 1)); 
            Integer maxPagesToShow = totalPageNumber > MAX_PAGES ? MAX_PAGES : totalPageNumber;
            pagesToShowList.clear();
            for(integer i = 1; i <= maxPagesToShow ; i++){
                pagesToShowList.add(i); 
            }
            system.debug('#### counting pages = '+totalPageNumber);
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to travel next #pagination.                                          *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void next(){
        try{
            pageNumber = pageNumber + 1;
            if(pageNumber <= totalPageNumber && pageNumber >= 1){
                setPreviousNextFlags();
                showRecords();
            }else{
                pageNumber = 1;
            }
        }catch(Exception ex){
             errorMessage = '#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage();
        }
    }

    /*********************************************************************************************
    * @Description : Method to travel previoud #pagination.                                      *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void previous(){
        try{
            pageNumber = pageNumber - 1;
            if(pageNumber >= 1 && pageNumber <= totalPageNumber){
                setPreviousNextFlags();
                showRecords(); 
            }else{
                pageNumber = 1;
            }
        }catch(Exception ex){
             errorMessage = '#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage();
        }
    }
    
     /*********************************************************************************************
    * @Description : Method to limit record visibility based on set page size #pagination.       *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void showRecords(){
        Integer max = pageNumber * PAGE_SIZE;
        Integer min = max - PAGE_SIZE;
        recordsPerPageList.clear();
        system.debug('#### show records = '+recordsList);
        for(Integer i = min; i <= max; i++){
            if(recordsList != null && recordsList.size() > i){
                recordsPerPageList.add(recordsList[i]);
                if(recordsPerPageList.size() == PAGE_SIZE){
                    break;
                }
            }else{
                break;
            }
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to set the visibility flags for previous, next buttons #pagination.  *
    * @Params      : void                                                                        *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void setPreviousNextFlags(){
        if(pageNumber == totalPageNumber){
            showNext = false;
            showPrevious = true;
        }
        if(pageNumber != 1 && totalPageNumber > 1 && pageNumber != totalPageNumber){
            showNext = true;
            showPrevious = true;
        }
        if(pageNumber == 1 && totalPageNumber > 1){
            showNext = true;
            showPrevious = false;
        }
        if(pageNumber == 1 && totalPageNumber == 1){
            showNext = false;
            showPrevious = false;
        }
    }
}// End of class.
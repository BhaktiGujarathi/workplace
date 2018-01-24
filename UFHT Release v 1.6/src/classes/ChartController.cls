global class ChartController 
{
    public list<Attachment> Attachmentsize{get;set;}
    
    public List<Attachment> getAttachmentSize() {
        
        Attachmentsize = [select BodyLength
                          from Attachment
                          where ParentId IN (Select Id from UFHT__Ultra_Track_Container__c)];
        return Attachmentsize;
    }
  
}
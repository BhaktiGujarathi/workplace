/*
* Name : Pavithra Gajendra
* Date : 03/12/2017
* Purpose : Inquiry Reshuffling Scheduler which runs to Inquiry Reshuffling Batch
* Company : NSI Gulf
* 
*/
global class ScheduledInquiryReshuffling implements Schedulable {
	global void execute(SchedulableContext SC) {
		InquiryReshufflingBatch reshuffleBatch = new InquiryReshufflingBatch();
		Database.executeBatch(reshuffleBatch);  
	}
}// End of class.
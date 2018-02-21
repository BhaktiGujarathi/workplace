/**
 * Queue Members web-service will give the details of the queue members.
 */
@RestResource(urlMapping='/queueMembers/*')
global class QueueMembersWebService {

    /**
     * Method to process post request
     */
    @HttpPost
    global static void doPost() {
        QueueMembersLogic.processQueueMemberRequest();
    }
}
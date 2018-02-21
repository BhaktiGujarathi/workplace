/**
 * Logic class for QueueMembersWebService
 */
public class QueueMembersLogic {

    /**
     * Method to process request and send the response
     */
    public static void processQueueMemberRequest() {

        // Get request body
        String requestBody = RestContext.request.requestBody.toString();

        // Parse request body
        QueueMembersRequestBody request = (QueueMembersRequestBody) JSON.deserializeStrict(
            requestBody,
            QueueMembersRequestBody.Class
        );
        System.debug('===== request : ' + request);

        QueueMembersResponseBody response = new QueueMembersResponseBody();
        if (request.queueExtension != '') {
            List<String> poolNames = PoolDetail.getPoolNames(new List<String> {request.queueExtension});
            if (poolNames.size() > 0) {
                System.debug('>>>>>>>>> poolNames : ' + poolNames);
                response.poolDetail = PoolDetail.getPoolDetails(poolNames)[0];
            } else {
                response.errorCode = '400';
                response.errorMessage = 'No pools found for the extensions sent';
            }
        } else {
            response.errorCode = '400';
            response.errorMessage = 'No queue extensions found';
        }

        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    /**
     * Wrapper class for QueueMembersWebService request body
     */
    public class QueueMembersRequestBody {
        public String queueExtension {get; set;}

        public QueueMembersRequestBody() {
            this.queueExtension = '';
        }
    }

    /**
     * Wrapper class for QueueMembersWebService response body
     */
    public class QueueMembersResponseBody {
        public PoolDetail poolDetail {get; set;}
        public String status;
        public String errorCode;
        public String errorMessage;

        public QueueMembersResponseBody() {
            this.poolDetail = new PoolDetail();
            this.status = '';
            this.errorCode = '';
            this.errorMessage = '';
        }
    }
}
/**
 * Logic class for CreRoutingWebservice
 */
public class CreRoutingLogic_IdleTime {
    public static Account registeredAccount;

    /**
     * Method to process request and send the response
     */
    public static void processCreRoutingRequest() {

        // Get request body
        String requestBody = RestContext.request.requestBody.toString();

        // Parse request body
        CreRoutingRequestBody request = (CreRoutingRequestBody) JSON.deserializeStrict(
            requestBody,
            CreRoutingRequestBody.Class
        );
        System.debug('===== request : ' + request);

/*
        // Create a dummy response
        CreRoutingResponseBody response = new CreRoutingResponseBody();
        response.registeredNumber = true;
        response.isVip = true;
        response.language = 'English';
        response.creDetails = request.onlineExtensions;
        response.poolDetails.add(new PoolDetail('dummyPoolId1', 'English', request.onlineExtensions));
        response.poolDetails.add(new PoolDetail('dummyPoolId2', 'Arabic', request.onlineExtensions));
        System.debug('===== response : ' + response);

        // Set dummy response to response body
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        Restcontext.response.statusCode = 200;
*/

        if (String.isNotBlank(request.callingNumber)) {
            List<Account> registeredAccounts = getRegisteredAccount(request.callingNumber);
            System.debug('======== registeredAccounts : ' + registeredAccounts);

            // 1. Check if the calling number is for a registered account
            if (registeredAccounts.size() != 0) {

                // TODO: Considering phone number will be unique for a account
                registeredAccount = registeredAccounts[0];
                System.debug('======== registeredAccount : ' + registeredAccount);

                // 2. Check if account is a vip or not
                if (isVipAccount(registeredAccount)) {

                    List<String> availabelCres = getAvailabeCresForAccount(
                        registeredAccount,
                        request.onlineExtensions
                    );
                    System.debug('======== availabelCres : ' + availabelCres);

                    CreRoutingResponseBody response = new CreRoutingResponseBody();
                    response.registeredNumber = true;
                    response.isVip = true;
                    response.language =
                        String.isNotBlank(registeredAccount.Primary_Language__c) ? registeredAccount.Primary_Language__c : 'English';

                    // 3. Check if any of the primay, sceondry or tertiary cres available for account
                    if (availabelCres.size() > 0) {
                        response.creDetails = availabelCres;
                    } else {
                        // If cres are not available send pool(Public Groups) details
                        response.poolDetails = PoolDetail.getPoolDetails(
                            PoolDetail.getExtensionsToPoolName().values()
                        );
                    }
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
                } else {

                    // If calling number is not vip, send pool(Public Groups) details
                    CreRoutingResponseBody response = new CreRoutingResponseBody();
                    response.registeredNumber = true;
                    response.isVip = false;
                    response.language =
                        String.isNotBlank(registeredAccount.Primary_Language__c) ? registeredAccount.Primary_Language__c : 'English';
                    response.poolDetails = PoolDetail.getPoolDetails(
                        PoolDetail.getExtensionsToPoolName().values()
                    );
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
                }
            } else {
                CreRoutingResponseBody response = new CreRoutingResponseBody();
                response.registeredNumber = false;
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
            }
        } else {
            CreRoutingResponseBody response = new CreRoutingResponseBody();
            response.errorCode = '400';
            response.errorMessage = 'Calling Number not found';
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        }
    }

    /**
     * Method to get account for calling number
     */
    public static List<Account> getRegisteredAccount(String callingNumber) {
        List<Account> accounts = new List<Account>();
        accounts =
            [
                SELECT
                    Id,
                    Name,
                    AnnualRevenue,
                    Primary_Language__c,
                    Primary_CRE__c,
                    Secondary_CRE__c,
                    Tertiary_CRE__c
                FROM
                    Account
                WHERE
                    Phone =: callingNumber
            ];
        return accounts;
    }

    /**
     * Method to check if a account is vip account or not
     */
    public static Boolean isVipAccount(Account account) {

        // Get customer type of account
        String customerType = CreAllocationUtility.getCustomerType(
            account.AnnualRevenue,
            CreAllocationHandler.lstCustomerTypesSetting
        );

        if (String.isNotBlank(customerType) && customerType != 'Others') {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Method is get prefered cre extensions of account form list of online extenions
     */
    public static List<String> getAvailabeCresForAccount(
        Account registeredAccount,
        List<OnlineExtension> onlineExtensionDetails
    ) {
        List<String> preferedCreExtensions = new List<String>();

        List<String> onlineExtensions = new List<String>();
        for (OnlineExtension onlineExtension : onlineExtensionDetails) {
            onlineExtensions.add(onlineExtension.extension);
        }

        // Get accounts prefered CRE's
        Set<Id> creUserIds = new Set<Id>();
        creUserIds.add(registeredAccount.Primary_CRE__c);
        creUserIds.add(registeredAccount.Secondary_CRE__c);
        creUserIds.add(registeredAccount.Tertiary_CRE__c);
        System.debug('>>>>>>>>>>> creUserIds : ' + creUserIds);

        // Get online CRE's user records
        List<User> creUsers =
            [
                SELECT
                    Id,
                    Extension
                FROM
                    User
                WHERE
                    Extension IN :onlineExtensions
                AND
                    Id IN :creUserIds
            ];

        System.debug('>>>>>>>>>>> creUsers : ' + creUsers);

        // The preferedCreExtensions list should have extension in following order
        // 1. primary cre, 2. sceondry cre, 3.tertiary cre
        // Add primary cre to the preferedCreExtensions list
        for (User creUser : creUsers) {
            if (creUser.Id == registeredAccount.Primary_CRE__c) {
                preferedCreExtensions.add(creUser.Extension);
                break;
            }
        }

        // Add sceondry cre to the preferedCreExtensions list
        for (User creUser : creUsers) {
            if (creUser.Id == registeredAccount.Secondary_CRE__c) {
                preferedCreExtensions.add(creUser.Extension);
                break;
            }
        }

        // Add tertiary cre to the preferedCreExtensions list
        for (User creUser : creUsers) {
            if (creUser.Id == registeredAccount.Tertiary_CRE__c) {
                preferedCreExtensions.add(creUser.Extension);
                break;
            }
        }

        return preferedCreExtensions;
    }

    /**
     * Wrapper class for CreRoutingWebService request body
     */
    public class CreRoutingRequestBody {
        public String callingNumber {get; set;}
        public String calledNumber {get; set;}
        public List<OnlineExtension> onlineExtensions {get; set;}

        public CreRoutingRequestBody() {
            this.callingNumber = '';
            this.calledNumber = '';
            this.onlineExtensions = new List<OnlineExtension>();
        }
    }

    /**
     * Wrapper class for online extensions
     */
    public class OnlineExtension {
        public String extension {get; set;}
        public Double idleTime {get; set;}

        public OnlineExtension() {
            this.extension = '';
            this.idleTime = 0.0;
        }
    }

    /**
     * Wrapper class for CreRoutingWebService response body
     */
    public class CreRoutingResponseBody {
        public Boolean registeredNumber {get; set;}
        public Boolean isVip {get; set;}
        public String language {get; set;}
        public List<String> creDetails {get; set;}
        public List<PoolDetail> poolDetails {get; set;}
        public Integer flag {get; set;}
        public String errorCode;
        public String errorStatus;
        public String errorMessage;

        public CreRoutingResponseBody() {
            this.registeredNumber = false;
            this.isVip = false;
            this.language = '';
            this.creDetails = new List<String>();
            this.poolDetails = new List<PoolDetail>();
            this.flag = 0;
            this.errorCode = '';
            this.errorStatus = '';
            this.errorMessage = '';
        }
    }
}
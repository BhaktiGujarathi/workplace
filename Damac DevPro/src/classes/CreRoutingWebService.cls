/**
 * CRE Routing web-service will identify the existing contact based on the calling number and
 * send back the details to the 3CX system.
 */
@RestResource(urlMapping='/creRoutingService/*')
global class CreRoutingWebService {

    /**
     * Method to process post request
     */
    @HttpPost
    global static void doPost() {
        CreRoutingLogic_IdleTime.processCreRoutingRequest();
    }
}
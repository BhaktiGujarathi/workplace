//Generated by wsdl2apex

public class AsyncUnitDetailsController {
    public class getUnitDetailValuesResponse_elementFuture extends System.WebServiceCalloutFuture {
        public String getValue() {
            unitDetailsController.getUnitDetailValuesResponse_element response = (unitDetailsController.getUnitDetailValuesResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.return_x;
        }
    }
    public class AsyncUnitDetailsHttpSoap11Endpoint {
        public String endpoint_x = 'http://34.231.6.33:8080/CRM_SR_NEW/services/UnitDetails.UnitDetailsHttpSoap11Endpoint/';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://action.com', 'unitDetailsController'};
        public AsyncUnitDetailsController.getUnitDetailValuesResponse_elementFuture beginGetUnitDetailValues(System.Continuation continuation,String RegistrationId) {
            unitDetailsController.getUnitDetailValues_element request_x = new unitDetailsController.getUnitDetailValues_element();
            request_x.RegistrationId = RegistrationId;
            return (AsyncUnitDetailsController.getUnitDetailValuesResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncUnitDetailsController.getUnitDetailValuesResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'urn:getUnitDetailValues',
              'http://action.com',
              'getUnitDetailValues',
              'http://action.com',
              'getUnitDetailValuesResponse',
              'unitDetailsController.getUnitDetailValuesResponse_element'}
            );
        }
    }
}
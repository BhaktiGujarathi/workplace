//Generated by wsdl2apex

public class AOPTMQClass {
    public class RegistrationDetails_element {
        public String P_REGISTRATION_ID;
        public String P_SR_NUMBER;
        private String[] P_REGISTRATION_ID_type_info = new String[]{'P_REGISTRATION_ID','http://action.com',null,'0','1','true'};
        private String[] P_SR_NUMBER_type_info = new String[]{'P_SR_NUMBER','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'P_REGISTRATION_ID','P_SR_NUMBER'};
    }
    public class RegistrationDetailsResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class DocumentAttachment_element {
        public String P_REQUEST_NUMBER;
        public String P_REQUEST_NAME;
        public String P_SOURCE_SYSTEM;
        public String SourceId;
        public String RegistrationId;
        public String EntityName;
        public String Category;
        public String FileId;
        public String FileName;
        public String FileDescription;
        public String SourceFileName;
        public soapencodingTypesDatabindingAxis2Apa.Base64Binary b;
        private String[] P_REQUEST_NUMBER_type_info = new String[]{'P_REQUEST_NUMBER','http://action.com',null,'0','1','true'};
        private String[] P_REQUEST_NAME_type_info = new String[]{'P_REQUEST_NAME','http://action.com',null,'0','1','true'};
        private String[] P_SOURCE_SYSTEM_type_info = new String[]{'P_SOURCE_SYSTEM','http://action.com',null,'0','1','true'};
        private String[] SourceId_type_info = new String[]{'SourceId','http://action.com',null,'0','1','true'};
        private String[] RegistrationId_type_info = new String[]{'RegistrationId','http://action.com',null,'0','1','true'};
        private String[] EntityName_type_info = new String[]{'EntityName','http://action.com',null,'0','1','true'};
        private String[] Category_type_info = new String[]{'Category','http://action.com',null,'0','1','true'};
        private String[] FileId_type_info = new String[]{'FileId','http://action.com',null,'0','1','true'};
        private String[] FileName_type_info = new String[]{'FileName','http://action.com',null,'0','1','true'};
        private String[] FileDescription_type_info = new String[]{'FileDescription','http://action.com',null,'0','1','true'};
        private String[] SourceFileName_type_info = new String[]{'SourceFileName','http://action.com',null,'0','1','true'};
        private String[] b_type_info = new String[]{'b','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'P_REQUEST_NUMBER','P_REQUEST_NAME','P_SOURCE_SYSTEM','SourceId','RegistrationId','EntityName','Category','FileId','FileName','FileDescription','SourceFileName','b'};
    }
    public class PaymentPlanCreationResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class getMilestonePaymentDetails_element {
        public String REGISTRATION_ID;
        private String[] REGISTRATION_ID_type_info = new String[]{'REGISTRATION_ID','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'REGISTRATION_ID'};
    }
    public class PaymentPlanCreation_element {
        public String P_REGISTRATION_ID;
        public String P_SR_NUMBER;
        public String P_SR_TYPE;
        public paymentPlanCreationXxdcAoptPkgWsP.APPSXXDC_AOPT_PKG_WSX1843128X6X5[] regTerms;
        private String[] P_REGISTRATION_ID_type_info = new String[]{'P_REGISTRATION_ID','http://action.com',null,'0','1','true'};
        private String[] P_SR_NUMBER_type_info = new String[]{'P_SR_NUMBER','http://action.com',null,'0','1','true'};
        private String[] P_SR_TYPE_type_info = new String[]{'P_SR_TYPE','http://action.com',null,'0','1','true'};
        private String[] regTerms_type_info = new String[]{'regTerms','http://action.com',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'P_REGISTRATION_ID','P_SR_NUMBER','P_SR_TYPE','regTerms'};
    }
    public class PaymentPlanHistory_element {
        public String P_REGISTRATION_ID;
        public String P_SR_NUMBER;
        private String[] P_REGISTRATION_ID_type_info = new String[]{'P_REGISTRATION_ID','http://action.com',null,'0','1','true'};
        private String[] P_SR_NUMBER_type_info = new String[]{'P_SR_NUMBER','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'P_REGISTRATION_ID','P_SR_NUMBER'};
    }
    public class PaymentPlanReversalResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class EarlyHandoverPaymentPlanCreation_element {
        public String P_REGISTRATION_ID;
        public String P_SR_NUMBER;
        public String P_SR_TYPE;
        public String REGISTRATION_ID;
        public String INSTALLMENT;
        public String DESCRIPTION;
        public String PAYMENT_DATE;
        public String EXPECTED_DATE;
        public String MILESTONE_EVENT;
        public String PERCENT_VALUE;
        public String TRANSFER_AR_INTER_FLAG;
        public String PAYMENT_AMOUNT;
        private String[] P_REGISTRATION_ID_type_info = new String[]{'P_REGISTRATION_ID','http://action.com',null,'0','1','true'};
        private String[] P_SR_NUMBER_type_info = new String[]{'P_SR_NUMBER','http://action.com',null,'0','1','true'};
        private String[] P_SR_TYPE_type_info = new String[]{'P_SR_TYPE','http://action.com',null,'0','1','true'};
        private String[] REGISTRATION_ID_type_info = new String[]{'REGISTRATION_ID','http://action.com',null,'0','1','true'};
        private String[] INSTALLMENT_type_info = new String[]{'INSTALLMENT','http://action.com',null,'0','1','true'};
        private String[] DESCRIPTION_type_info = new String[]{'DESCRIPTION','http://action.com',null,'0','1','true'};
        private String[] PAYMENT_DATE_type_info = new String[]{'PAYMENT_DATE','http://action.com',null,'0','1','true'};
        private String[] EXPECTED_DATE_type_info = new String[]{'EXPECTED_DATE','http://action.com',null,'0','1','true'};
        private String[] MILESTONE_EVENT_type_info = new String[]{'MILESTONE_EVENT','http://action.com',null,'0','1','true'};
        private String[] PERCENT_VALUE_type_info = new String[]{'PERCENT_VALUE','http://action.com',null,'0','1','true'};
        private String[] TRANSFER_AR_INTER_FLAG_type_info = new String[]{'TRANSFER_AR_INTER_FLAG','http://action.com',null,'0','1','true'};
        private String[] PAYMENT_AMOUNT_type_info = new String[]{'PAYMENT_AMOUNT','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'P_REGISTRATION_ID','P_SR_NUMBER','P_SR_TYPE','REGISTRATION_ID','INSTALLMENT','DESCRIPTION','PAYMENT_DATE','EXPECTED_DATE','MILESTONE_EVENT','PERCENT_VALUE','TRANSFER_AR_INTER_FLAG','PAYMENT_AMOUNT'};
    }
    public class DocumentAttachmentResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class PaymentPlanHistoryResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class getMasterMilestone_element {
        public String REGISTRATION_ID;
        private String[] REGISTRATION_ID_type_info = new String[]{'REGISTRATION_ID','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'REGISTRATION_ID'};
    }
    public class getMasterMilestoneResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class PaymentPlanReversalCurrent_element {
        public String P_REGISTRATION_ID;
        public String P_SR_NUMBER;
        private String[] P_REGISTRATION_ID_type_info = new String[]{'P_REGISTRATION_ID','http://action.com',null,'0','1','true'};
        private String[] P_SR_NUMBER_type_info = new String[]{'P_SR_NUMBER','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'P_REGISTRATION_ID','P_SR_NUMBER'};
    }
    public class PaymentPlanReversal_element {
        public String P_REGISTRATION_ID;
        public String P_SR_NUMBER;
        private String[] P_REGISTRATION_ID_type_info = new String[]{'P_REGISTRATION_ID','http://action.com',null,'0','1','true'};
        private String[] P_SR_NUMBER_type_info = new String[]{'P_SR_NUMBER','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'P_REGISTRATION_ID','P_SR_NUMBER'};
    }
    public class getMilestonePaymentDetailsResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class EarlyHandoverPaymentPlanCreationResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class PaymentPlanReversalCurrentResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class AOPTHttpSoap11Endpoint {
        public String endpoint_x = 'http://34.231.6.33:8080/CRM_SR_NEW/services/AOPT.AOPTHttpSoap11Endpoint/';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://action.com', 'AOPTMQClass', 'http://payment_plan_creation.xxdc_aopt_pkg_ws.plsql.soaprovider.ont.apps.xmlns.oracle.com/xsd', 'paymentPlanCreationXxdcAoptPkgWsP', 'http://soapencoding.types.databinding.axis2.apache.org/xsd', 'soapencodingTypesDatabindingAxis2Apa'};
        public String PaymentPlanCreation(String P_REGISTRATION_ID,String P_SR_NUMBER,String P_SR_TYPE,paymentPlanCreationXxdcAoptPkgWsP.APPSXXDC_AOPT_PKG_WSX1843128X6X5[] regTerms) {
            AOPTMQClass.PaymentPlanCreation_element request_x = new AOPTMQClass.PaymentPlanCreation_element();
            request_x.P_REGISTRATION_ID = P_REGISTRATION_ID;
            request_x.P_SR_NUMBER = P_SR_NUMBER;
            request_x.P_SR_TYPE = P_SR_TYPE;
            request_x.regTerms = regTerms;
            AOPTMQClass.PaymentPlanCreationResponse_element response_x;
            Map<String, AOPTMQClass.PaymentPlanCreationResponse_element> response_map_x = new Map<String, AOPTMQClass.PaymentPlanCreationResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:PaymentPlanCreation',
              'http://action.com',
              'PaymentPlanCreation',
              'http://action.com',
              'PaymentPlanCreationResponse',
              'AOPTMQClass.PaymentPlanCreationResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public String EarlyHandoverPaymentPlanCreation(String P_REGISTRATION_ID,String P_SR_NUMBER,String P_SR_TYPE,String REGISTRATION_ID,String INSTALLMENT,String DESCRIPTION,String PAYMENT_DATE,String EXPECTED_DATE,String MILESTONE_EVENT,String PERCENT_VALUE,String TRANSFER_AR_INTER_FLAG,String PAYMENT_AMOUNT) {
            AOPTMQClass.EarlyHandoverPaymentPlanCreation_element request_x = new AOPTMQClass.EarlyHandoverPaymentPlanCreation_element();
            request_x.P_REGISTRATION_ID = P_REGISTRATION_ID;
            request_x.P_SR_NUMBER = P_SR_NUMBER;
            request_x.P_SR_TYPE = P_SR_TYPE;
            request_x.REGISTRATION_ID = REGISTRATION_ID;
            request_x.INSTALLMENT = INSTALLMENT;
            request_x.DESCRIPTION = DESCRIPTION;
            request_x.PAYMENT_DATE = PAYMENT_DATE;
            request_x.EXPECTED_DATE = EXPECTED_DATE;
            request_x.MILESTONE_EVENT = MILESTONE_EVENT;
            request_x.PERCENT_VALUE = PERCENT_VALUE;
            request_x.TRANSFER_AR_INTER_FLAG = TRANSFER_AR_INTER_FLAG;
            request_x.PAYMENT_AMOUNT = PAYMENT_AMOUNT;
            AOPTMQClass.EarlyHandoverPaymentPlanCreationResponse_element response_x;
            Map<String, AOPTMQClass.EarlyHandoverPaymentPlanCreationResponse_element> response_map_x = new Map<String, AOPTMQClass.EarlyHandoverPaymentPlanCreationResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:EarlyHandoverPaymentPlanCreation',
              'http://action.com',
              'EarlyHandoverPaymentPlanCreation',
              'http://action.com',
              'EarlyHandoverPaymentPlanCreationResponse',
              'AOPTMQClass.EarlyHandoverPaymentPlanCreationResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public String PaymentPlanReversal(String P_REGISTRATION_ID,String P_SR_NUMBER) {
            AOPTMQClass.PaymentPlanReversal_element request_x = new AOPTMQClass.PaymentPlanReversal_element();
            request_x.P_REGISTRATION_ID = P_REGISTRATION_ID;
            request_x.P_SR_NUMBER = P_SR_NUMBER;
            AOPTMQClass.PaymentPlanReversalResponse_element response_x;
            Map<String, AOPTMQClass.PaymentPlanReversalResponse_element> response_map_x = new Map<String, AOPTMQClass.PaymentPlanReversalResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:PaymentPlanReversal',
              'http://action.com',
              'PaymentPlanReversal',
              'http://action.com',
              'PaymentPlanReversalResponse',
              'AOPTMQClass.PaymentPlanReversalResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public String DocumentAttachment(String P_REQUEST_NUMBER,String P_REQUEST_NAME,String P_SOURCE_SYSTEM,String SourceId,String RegistrationId,String EntityName,String Category,String FileId,String FileName,String FileDescription,String SourceFileName,soapencodingTypesDatabindingAxis2Apa.Base64Binary b) {
            AOPTMQClass.DocumentAttachment_element request_x = new AOPTMQClass.DocumentAttachment_element();
            request_x.P_REQUEST_NUMBER = P_REQUEST_NUMBER;
            request_x.P_REQUEST_NAME = P_REQUEST_NAME;
            request_x.P_SOURCE_SYSTEM = P_SOURCE_SYSTEM;
            request_x.SourceId = SourceId;
            request_x.RegistrationId = RegistrationId;
            request_x.EntityName = EntityName;
            request_x.Category = Category;
            request_x.FileId = FileId;
            request_x.FileName = FileName;
            request_x.FileDescription = FileDescription;
            request_x.SourceFileName = SourceFileName;
            request_x.b = b;
            AOPTMQClass.DocumentAttachmentResponse_element response_x;
            Map<String, AOPTMQClass.DocumentAttachmentResponse_element> response_map_x = new Map<String, AOPTMQClass.DocumentAttachmentResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:DocumentAttachment',
              'http://action.com',
              'DocumentAttachment',
              'http://action.com',
              'DocumentAttachmentResponse',
              'AOPTMQClass.DocumentAttachmentResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public String getMasterMilestone(String REGISTRATION_ID) {
            AOPTMQClass.getMasterMilestone_element request_x = new AOPTMQClass.getMasterMilestone_element();
            request_x.REGISTRATION_ID = REGISTRATION_ID;
            AOPTMQClass.getMasterMilestoneResponse_element response_x;
            Map<String, AOPTMQClass.getMasterMilestoneResponse_element> response_map_x = new Map<String, AOPTMQClass.getMasterMilestoneResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:getMasterMilestone',
              'http://action.com',
              'getMasterMilestone',
              'http://action.com',
              'getMasterMilestoneResponse',
              'AOPTMQClass.getMasterMilestoneResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public String PaymentPlanReversalCurrent(String P_REGISTRATION_ID,String P_SR_NUMBER) {
            AOPTMQClass.PaymentPlanReversalCurrent_element request_x = new AOPTMQClass.PaymentPlanReversalCurrent_element();
            request_x.P_REGISTRATION_ID = P_REGISTRATION_ID;
            request_x.P_SR_NUMBER = P_SR_NUMBER;
            AOPTMQClass.PaymentPlanReversalCurrentResponse_element response_x;
            Map<String, AOPTMQClass.PaymentPlanReversalCurrentResponse_element> response_map_x = new Map<String, AOPTMQClass.PaymentPlanReversalCurrentResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:PaymentPlanReversalCurrent',
              'http://action.com',
              'PaymentPlanReversalCurrent',
              'http://action.com',
              'PaymentPlanReversalCurrentResponse',
              'AOPTMQClass.PaymentPlanReversalCurrentResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public String getMilestonePaymentDetails(String REGISTRATION_ID) {
            AOPTMQClass.getMilestonePaymentDetails_element request_x = new AOPTMQClass.getMilestonePaymentDetails_element();
            request_x.REGISTRATION_ID = REGISTRATION_ID;
            AOPTMQClass.getMilestonePaymentDetailsResponse_element response_x;
            Map<String, AOPTMQClass.getMilestonePaymentDetailsResponse_element> response_map_x = new Map<String, AOPTMQClass.getMilestonePaymentDetailsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:getMilestonePaymentDetails',
              'http://action.com',
              'getMilestonePaymentDetails',
              'http://action.com',
              'getMilestonePaymentDetailsResponse',
              'AOPTMQClass.getMilestonePaymentDetailsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public String RegistrationDetails(String P_REGISTRATION_ID,String P_SR_NUMBER) {
            AOPTMQClass.RegistrationDetails_element request_x = new AOPTMQClass.RegistrationDetails_element();
            request_x.P_REGISTRATION_ID = P_REGISTRATION_ID;
            request_x.P_SR_NUMBER = P_SR_NUMBER;
            AOPTMQClass.RegistrationDetailsResponse_element response_x;
            Map<String, AOPTMQClass.RegistrationDetailsResponse_element> response_map_x = new Map<String, AOPTMQClass.RegistrationDetailsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:RegistrationDetails',
              'http://action.com',
              'RegistrationDetails',
              'http://action.com',
              'RegistrationDetailsResponse',
              'AOPTMQClass.RegistrationDetailsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public String PaymentPlanHistory(String P_REGISTRATION_ID,String P_SR_NUMBER) {
            AOPTMQClass.PaymentPlanHistory_element request_x = new AOPTMQClass.PaymentPlanHistory_element();
            request_x.P_REGISTRATION_ID = P_REGISTRATION_ID;
            request_x.P_SR_NUMBER = P_SR_NUMBER;
            AOPTMQClass.PaymentPlanHistoryResponse_element response_x;
            Map<String, AOPTMQClass.PaymentPlanHistoryResponse_element> response_map_x = new Map<String, AOPTMQClass.PaymentPlanHistoryResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:PaymentPlanHistory',
              'http://action.com',
              'PaymentPlanHistory',
              'http://action.com',
              'PaymentPlanHistoryResponse',
              'AOPTMQClass.PaymentPlanHistoryResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
    }
}
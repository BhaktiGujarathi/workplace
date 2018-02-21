//Generated by wsdl2apex

public class GenerateSOPService {
    public class TotalPenaltyWaiver_element {
        public String P_REQUEST_NUMBER;
        public String P_REQUEST_NAME;
        public String P_SOURCE_SYSTEM;
        public String RegistrationId;
        private String[] P_REQUEST_NUMBER_type_info = new String[]{'P_REQUEST_NUMBER','http://action.com',null,'0','1','true'};
        private String[] P_REQUEST_NAME_type_info = new String[]{'P_REQUEST_NAME','http://action.com',null,'0','1','true'};
        private String[] P_SOURCE_SYSTEM_type_info = new String[]{'P_SOURCE_SYSTEM','http://action.com',null,'0','1','true'};
        private String[] RegistrationId_type_info = new String[]{'RegistrationId','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'P_REQUEST_NUMBER','P_REQUEST_NAME','P_SOURCE_SYSTEM','RegistrationId'};
    }
    public class GeneratePenaltyStatment_element {
        public String P_REQUEST_NUMBER;
        public String P_REQUEST_NAME;
        public String P_SOURCE_SYSTEM;
        public String PARAM_ID;
        public String STAGE_ID;
        public String Batch_Name;
        private String[] P_REQUEST_NUMBER_type_info = new String[]{'P_REQUEST_NUMBER','http://action.com',null,'0','1','true'};
        private String[] P_REQUEST_NAME_type_info = new String[]{'P_REQUEST_NAME','http://action.com',null,'0','1','true'};
        private String[] P_SOURCE_SYSTEM_type_info = new String[]{'P_SOURCE_SYSTEM','http://action.com',null,'0','1','true'};
        private String[] PARAM_ID_type_info = new String[]{'PARAM_ID','http://action.com',null,'0','1','true'};
        private String[] STAGE_ID_type_info = new String[]{'STAGE_ID','http://action.com',null,'0','1','true'};
        private String[] Batch_Name_type_info = new String[]{'Batch_Name','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'P_REQUEST_NUMBER','P_REQUEST_NAME','P_SOURCE_SYSTEM','PARAM_ID','STAGE_ID','Batch_Name'};
    }
    public class TotalPenaltyWaiverResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class GeneratePenaltyStatmentResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class PenaltyWaiverDetailsResponse_element {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class PenaltyWaiverDetails_element {
        public String RegistrationId;
        public String ProcessName;
        public String SubProcessName;
        public String ProjectCity;
        public String NotApplicableCity;
        public String Project;
        public String BuildingCode;
        public String BedroomType;
        public String UnitType;
        public String PermittedUse;
        public String Units;
        public String ReadyOffPlan;
        public String ApplicableNationality;
        public String CustomerClassification;
        private String[] RegistrationId_type_info = new String[]{'RegistrationId','http://action.com',null,'0','1','true'};
        private String[] ProcessName_type_info = new String[]{'ProcessName','http://action.com',null,'0','1','true'};
        private String[] SubProcessName_type_info = new String[]{'SubProcessName','http://action.com',null,'0','1','true'};
        private String[] ProjectCity_type_info = new String[]{'ProjectCity','http://action.com',null,'0','1','true'};
        private String[] NotApplicableCity_type_info = new String[]{'NotApplicableCity','http://action.com',null,'0','1','true'};
        private String[] Project_type_info = new String[]{'Project','http://action.com',null,'0','1','true'};
        private String[] BuildingCode_type_info = new String[]{'BuildingCode','http://action.com',null,'0','1','true'};
        private String[] BedroomType_type_info = new String[]{'BedroomType','http://action.com',null,'0','1','true'};
        private String[] UnitType_type_info = new String[]{'UnitType','http://action.com',null,'0','1','true'};
        private String[] PermittedUse_type_info = new String[]{'PermittedUse','http://action.com',null,'0','1','true'};
        private String[] Units_type_info = new String[]{'Units','http://action.com',null,'0','1','true'};
        private String[] ReadyOffPlan_type_info = new String[]{'ReadyOffPlan','http://action.com',null,'0','1','true'};
        private String[] ApplicableNationality_type_info = new String[]{'ApplicableNationality','http://action.com',null,'0','1','true'};
        private String[] CustomerClassification_type_info = new String[]{'CustomerClassification','http://action.com',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://action.com','true','true'};
        private String[] field_order_type_info = new String[]{'RegistrationId','ProcessName','SubProcessName','ProjectCity','NotApplicableCity','Project','BuildingCode','BedroomType','UnitType','PermittedUse','Units','ReadyOffPlan','ApplicableNationality','CustomerClassification'};
    }
    public class PenaltyWaiverHttpSoap11Endpoint {
        public String endpoint_x = 'http://34.231.6.33:8080/CRM_SR_NEW/services/PenaltyWaiver.PenaltyWaiverHttpSoap11Endpoint/';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://action.com', 'GenerateSOPService'};
        public String TotalPenaltyWaiver(String P_REQUEST_NUMBER,String P_REQUEST_NAME,String P_SOURCE_SYSTEM,String RegistrationId) {
            GenerateSOPService.TotalPenaltyWaiver_element request_x = new GenerateSOPService.TotalPenaltyWaiver_element();
            request_x.P_REQUEST_NUMBER = P_REQUEST_NUMBER;
            request_x.P_REQUEST_NAME = P_REQUEST_NAME;
            request_x.P_SOURCE_SYSTEM = P_SOURCE_SYSTEM;
            request_x.RegistrationId = RegistrationId;
            GenerateSOPService.TotalPenaltyWaiverResponse_element response_x;
            Map<String, GenerateSOPService.TotalPenaltyWaiverResponse_element> response_map_x = new Map<String, GenerateSOPService.TotalPenaltyWaiverResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:TotalPenaltyWaiver',
              'http://action.com',
              'TotalPenaltyWaiver',
              'http://action.com',
              'TotalPenaltyWaiverResponse',
              'GenerateSOPService.TotalPenaltyWaiverResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public String PenaltyWaiverDetails(String RegistrationId,String ProcessName,String SubProcessName,String ProjectCity,String NotApplicableCity,String Project,String BuildingCode,String BedroomType,String UnitType,String PermittedUse,String Units,String ReadyOffPlan,String ApplicableNationality,String CustomerClassification) {
            GenerateSOPService.PenaltyWaiverDetails_element request_x = new GenerateSOPService.PenaltyWaiverDetails_element();
            request_x.RegistrationId = RegistrationId;
            request_x.ProcessName = ProcessName;
            request_x.SubProcessName = SubProcessName;
            request_x.ProjectCity = ProjectCity;
            request_x.NotApplicableCity = NotApplicableCity;
            request_x.Project = Project;
            request_x.BuildingCode = BuildingCode;
            request_x.BedroomType = BedroomType;
            request_x.UnitType = UnitType;
            request_x.PermittedUse = PermittedUse;
            request_x.Units = Units;
            request_x.ReadyOffPlan = ReadyOffPlan;
            request_x.ApplicableNationality = ApplicableNationality;
            request_x.CustomerClassification = CustomerClassification;
            GenerateSOPService.PenaltyWaiverDetailsResponse_element response_x;
            Map<String, GenerateSOPService.PenaltyWaiverDetailsResponse_element> response_map_x = new Map<String, GenerateSOPService.PenaltyWaiverDetailsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:PenaltyWaiverDetails',
              'http://action.com',
              'PenaltyWaiverDetails',
              'http://action.com',
              'PenaltyWaiverDetailsResponse',
              'GenerateSOPService.PenaltyWaiverDetailsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public String GeneratePenaltyStatment(String P_REQUEST_NUMBER,String P_REQUEST_NAME,String P_SOURCE_SYSTEM,String PARAM_ID,String STAGE_ID,String Batch_Name) {
            GenerateSOPService.GeneratePenaltyStatment_element request_x = new GenerateSOPService.GeneratePenaltyStatment_element();
            request_x.P_REQUEST_NUMBER = P_REQUEST_NUMBER;
            request_x.P_REQUEST_NAME = P_REQUEST_NAME;
            request_x.P_SOURCE_SYSTEM = P_SOURCE_SYSTEM;
            request_x.PARAM_ID = PARAM_ID;
            request_x.STAGE_ID = STAGE_ID;
            request_x.Batch_Name = Batch_Name;
            GenerateSOPService.GeneratePenaltyStatmentResponse_element response_x;
            Map<String, GenerateSOPService.GeneratePenaltyStatmentResponse_element> response_map_x = new Map<String, GenerateSOPService.GeneratePenaltyStatmentResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:GeneratePenaltyStatment',
              'http://action.com',
              'GeneratePenaltyStatment',
              'http://action.com',
              'GeneratePenaltyStatmentResponse',
              'GenerateSOPService.GeneratePenaltyStatmentResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
    }
}
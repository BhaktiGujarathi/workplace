public with sharing class PaymentsProcessUtils {

    public final static String SEPARATOR = ',';
    public final static String OBJECT_NAME = 'Payment__c';
    public static String error;
    public static String warning;    
    public static String errorMessage;    

    
    public static Payment__c[] getPayments(String pid, Blob csvFileBody) {
        error = null;
        warning = null;
        errorMessage = null;

        try {                

            String fileBody = blobToString(csvFileBody);             

            Processor_Field_Mapping__c[] mappings = queryMappings(pid);

            if (mappings != null && mappings.size() > 0) {
                
                String[] fileLines = (fileBody.contains('\n') ? fileBody.split('\n') : (fileBody.contains('\\') ? fileBody.split('\\') : fileBody.split('\n')));

                Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(OBJECT_NAME).getDescribe().fields.getMap();
                
                Boolean skipHeader = true;
                
                Payment__c[] payments = new Payment__c[]{};

                for (String line : fileLines) {
                    line = line.replaceAll(',(?!(([^"]*"){2})*[^"]*$)', '').remove('"');
            
                    if (skipHeader) {
                        skipHeader = false; 
                        String [] fileData = line.split(SEPARATOR);
                        if (line != null && line != '' && fileData.size() > 1) {
                            for (Processor_Field_Mapping__c mapping : mappings) {
                                mapping.Index_Field_Label__c = fileData[Integer.valueOf(mapping.Index__c - 1)];
                                
                            }
                            upsert mappings;
                        }
                        
                    }
                    else {
                        Payment__c payment = new Payment__c() ;
                        String [] fileData = line.split(SEPARATOR);
                        
                        if (line != null && line != '' && fileData.size() > 1) {
                            for (Processor_Field_Mapping__c mapping : mappings) {
                                
                                if (mapping.Field_Name__c != null) {
                                    Schema.SObjectField sfield = fieldMap.get(mapping.Field_Name__c);
                                    
                                    String value = fileData[Integer.valueOf(mapping.Index__c - 1)];
                                    value = value.remove('$').remove('%').trim();

                                    if (sfield.getDescribe().getType() == Schema.DisplayType.DateTime || 
                                        sfield.getDescribe().getType() == Schema.DisplayType.Date) {
                                        
                                        try {
                                            payment.put(mapping.Field_Name__c, DateTime.parse(value).format('MM/dd/yyyy'));
                                        }
                                        catch (Exception e) {
                                            payment.put(mapping.Field_Name__c, date.parse(value));
                                        }
                                    } 
                                    else if (sfield.getDescribe().getType() == Schema.DisplayType.Currency || 
                                             sfield.getDescribe().getType() == Schema.DisplayType.Percent  ||
                                             sfield.getDescribe().getType() == Schema.DisplayType.Integer) {
                                        payment.put(mapping.Field_Name__c, Double.valueOf(value));
                                    } 
                                    else {
                                        payment.put(mapping.Field_Name__c, value);
                                    }
                                }
                            }

                            payments.add(payment);
                        }
                    }
                }

                Map<String, Repayment__c> paymentSettingMap = new Map<String, Repayment__c>();                    
                for (Payment__c p : payments) {
                    paymentSettingMap.put(p.Merchant_Id__c, null);
                }

                for (Repayment__c ps : [select Name, Merchant_Id__c 
                                                from Repayment__c 
                                               where Merchant_Id__c = :paymentSettingMap.keySet()
                                                 and RecordType.Name = 'Splits']) {
                    paymentSettingMap.put(ps.Merchant_Id__c, ps);
                }

                for (Payment__c p : payments) {
                    if (paymentSettingMap.get(p.Merchant_Id__c) != null) {
                        p.Repayment__c = paymentSettingMap.get(p.Merchant_Id__c).Id;
                        p.Repayment__r = paymentSettingMap.get(p.Merchant_Id__c);
                    }
                }                  

                return payments;
            }
            else {
                warning = 'No Payment Integration Mapping was configured for this Processor';
            }
        } 
        catch (Exception e) {
            error = 'There was an error while trying to processing your CSV file';
            errorMessage = e.getMessage() + ' ' + e.getStackTraceString();

            //error += ' ' + errorMessage;
        } 
        
        return null;
    }


    private static String blobToString(Blob inputFile){
        try {
            return inputFile.toString();
        }
        catch (Exception e ) {
            return getUTF8(inputFile);
        }
        
        return null;
    }     


    public static String getUTF8(Blob inputFile) {
        String hex = EncodingUtil.convertToHex(inputFile);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        
        for(Integer i = 0; i < bytesCount; ++i) {
            bytes[i] =  hex.mid(i << 1, 2);
        }

        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), 'UTF-16');//ISO-8859-1');
    }
    

    public static Processor_Field_Mapping__c[] queryMappings(String pid) {
        Processor_Field_Mapping__c[] mappings = new Processor_Field_Mapping__c[]{};
        for (Processor_Field_Mapping__c e : [SELECT Id
                                                  , Index__c
                                                  , Field_Name__c
                                                  , Processor_Name__c 
                                                  , Index_Field_Label__c
                                             FROM Processor_Field_Mapping__c
                                             WHERE Processor_Name__c = :pid])  {
            mappings.add(e);
        }
        return mappings;
    }

    
    public static String insertPayments(Payment__c[] payments, String pid, Blob csvFileBody, String importType, String emailAddress) {
        Split_Batch__c bil = new Split_Batch__c();
        bil.Date_Time__c = System.now();
        bil.Processor_Integration__c = pid;
        bil.Import_Type__c = importType;
        bil.Email__c = emailAddress;
        insert bil;

        Attachment a = new Attachment();
        a.ParentId = bil.Id;
        a.Name = 'Imported File ' + System.now().format('MM-dd-YYYY') + '.csv';
        a.Body = csvFileBody;
        insert a;        

        try {
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType='Payment__c' AND isActive = true AND Name = 'Credit' LIMIT 1 ];
            
            for (Payment__c p : payments) {
                p.Split_Batch__c = bil.Id;
                p.RecordTypeId = rt.Id;
                p.Status__c = 'Settled';
                p.Transaction_Type__c = 'Payment';
            }            
            insert payments;
            
            bil.Rows_Imported__c = payments.size();
            bil.Success_Messages__c = 'Payments were processed correctly';
            
        } 
        catch (Exception e) {
            error = e.getMessage();
        }
        
        bil.Error_Messages__c = (error != null ? error : (warning != null ? warning : ''));
        update bil;

        return bil.Id;
        return null;
    }    
}
public class DealTriggerUtility{

    public static Map<String,List<VerificationMaster__c>> getTypeVerification(String type, Set<string> setStage) {


        if (type != null && type.length() > 0) {

            Map<String,List<VerificationMaster__c>> mapTypeVerification = new Map<String,List<VerificationMaster__c>>();
            String stage = '';


            //ADD OPP STAGES TO MapTypeVerification keyset
            for (String strStage : setStage ) {

                stage += '\'' + strStage + '\',' ;

                for ( String str : type.split(',') ) {

                    mapTypeVerification.put(str + strStage,new List<VerificationMaster__c>());
                    
                }
            }

            stage = stage.removeEnd(',');


            //Format types like ACH,MCA,Hybrid
            type = '\'' + type;
            type = type.replace(',', '\',\'');
            type += '\'';

            String query = 'SELECT Id, Name, Notes__c,Type__c, Stage__c, Sort_Order__c, Action_Link__c, RecordType.Name, Renewal__c ' +
                           'FROM VerificationMaster__c WHERE type__c INCLUDES (' + type + ')';

            if (stage != null && stage != '') {
                
                query += ' AND Stage__c INCLUDES (' + stage + ')';
            }

            query += ' LIMIT 1000';

            //Get all verifications with stage and type from the opportunity
            List<VerificationMaster__c> lstVer = Database.query(query);

            for (VerificationMaster__c objVer : lstVer) {

                for ( String strtype : objVer.type__c.split(';') ) {

                    //For each type
                    for (String strStage : stage.split(',')) {

                        strStage = strStage.remove('\'');
                        
                        if ( mapTypeVerification.Keyset().contains(strtype + strStage)) {

                            //system.assert(false, 'strtype ' + strtype + ' strStage ' + strStage  );
                            mapTypeVerification.get(strtype + strStage).add(objVer);
                        }

                        //system.assert(false, mapTypeVerification.size());                        
                    }

                }
            }

            return mapTypeVerification ;
        }
        else {

            Map<String,List<VerificationMaster__c>> mapTypeVerification = new Map<String,List<VerificationMaster__c>>();
            String stage ='';

            for ( String strStage : setStage ) {

                stage += '\'' + strStage + '\',' ;

                mapTypeVerification.put(strStage, new List<VerificationMaster__c>());

            }

            stage = stage.removeEnd(',');
            
            system.debug('123456789000000000' + stage);

            String query = 'SELECT Id, Name, Notes__c,Type__c, Stage__c, Sort_Order__c, Action_Link__c, RecordType.Name, Renewal__c ' +
                           'FROM VerificationMaster__c WHERE type__c = null';

            if (stage != null && stage != '') {

                query += ' AND Stage__c INCLUDES (' + stage + ')';
            }

            query += ' LIMIT 1000';

            system.debug('1234567890' + query);

            List<VerificationMaster__c> lstVer = Database.query(query);

            for (VerificationMaster__c objVer : lstVer) {

                //if ( mapTypeVerification.Keyset().contains('Underwriting') && objVer.stage__c.contains('Underwriting') ) {

                //    mapTypeVerification.get('Underwriting').add(objVer);
                //}

                //if ( mapTypeVerification.Keyset().contains('PreQualification') && objVer.stage__c.contains('PreQualification') ) {

                //    mapTypeVerification.get('PreQualification').add(objVer);
                //}

                for (String strStage : stage.split(',')) {

                    strStage = strStage.remove('\'');
                    
                    if ( mapTypeVerification.Keyset().contains(strStage)) {

                        //system.assert(false, 'strtype ' + strtype + ' strStage ' + strStage  );
                        mapTypeVerification.get(strStage).add(objVer);
                    }
                }

            }

            return mapTypeVerification ;
        }
    }


    //Construct map type stip master records
    public static Map<String, List<StipMaster__c>> getTypeStip(String type, Set<string> setStage) {

        if (type != null && type.length() > 0) {

            Map<String, List<StipMaster__c>> mapTypeStip = new Map<String, List<StipMaster__c>>();
            String stage = '';

            for ( String strStage : setStage ) {

                stage += '\'' + strStage + '\',';

                for ( String str : type.split(',') ) {

                    mapTypeStip.put( str + strStage, new List<StipMaster__c>() );
                }
            }

            mapTypeStip.put('any', new List<StipMaster__c>());
            system.debug('$$$$$$$$$$$$$$$' + mapTypeStip + stage + type);
            stage = stage.removeEnd(',');

            type = '\'' + type;
            type = type.replace(',', '\',\'');
            type += '\'';

            String query ='SELECT Id, Name, Notes__c, Type__c, stage__c, Renewal__c, Add_to_all_Deals__c FROM StipMaster__c WHERE Add_to_all_Deals__c=true';

            if (stage != null && stage != '') {
                
                query += ' OR (type__c INCLUDES (' + type + ') AND Stage__c INCLUDES (' + stage + '))';
            }
            else {
                
                query += ' OR type__c INCLUDES (' + type + ')';
            }

            query += ' LIMIT 1000';
            
            system.debug('33333333' + query);
            
            List<StipMaster__c> lstStips = Database.query(query);
            
            system.debug('44444444' + lstStips.size() + lstStips);

            for (StipMaster__c objStip : lstStips) {

                if (objStip.type__c != NULL) {

                    //for each type
                    for (String strtype : objStip.type__c.split(';')) {

                         if (objStip.stage__c != NULL && !mapTypeStip.isEmpty() && !objStip.Add_to_all_Deals__c) {

                            //For each type
                            for (String strStage : stage.split(',')) {

                                strStage = strStage.remove('\'');
                                
                                if ( mapTypeStip.Keyset().contains(strtype + strStage)) {

                                    //system.assert(false, 'strtype ' + strtype + ' strStage ' + strStage  );
                                    mapTypeStip.get(strtype + strStage).add(objStip);
                                }
                            }

                            //if ( objStip.stage__c.contains('Underwriting') && mapTypeStip.Keyset().contains(strtype + '' + 'Underwriting') ) {

                            //    mapTypeStip.get(strtype + '' + 'Underwriting').add(objStip);
                            //}

                            //if ( objStip.stage__c.contains('PreQualification') && mapTypeStip.Keyset().contains(strtype + '' + 'PreQualification') ) {

                            //    mapTypeStip.get(strtype + '' + 'PreQualification').add(objStip);
                            //}
                        }

                        else {

                            if ( objStip.Add_to_all_Deals__c && mapTypeStip.Keyset().contains('any')) {

                                mapTypeStip.get('any').add(objStip);
                            }
                        }

                        system.debug('11111112222222' + mapTypeStip);
                    }
                }
                else {

                    if ( objStip.Add_to_all_Deals__c && !mapTypeStip.isEmpty() && mapTypeStip.containsKey('any')) {

                        mapTypeStip.get('any').add(objStip);
                    }
                }
            }
            
            system.debug('888888888888888888' + mapTypeStip);
            return mapTypeStip ;

        }
        else {

            Map<String, List<StipMaster__c>> mapTypeStip = new Map<String, List<StipMaster__c>>();
            String stage = '';

            for ( String strStage : setStage ) {

                stage += '\'' + strStage + '\',';

                mapTypeStip.put(strStage, new List<StipMaster__c>() );

            }

            mapTypeStip.put('any', new List<StipMaster__c>());
            stage = stage.removeEnd(',');

            String query ='SELECT Id, Name, Notes__c, Type__c, stage__c, Renewal__c, Add_to_all_Deals__c FROM StipMaster__c WHERE Add_to_all_Deals__c=true';

            if (stage != null && stage != '') {

                query += ' OR (type__c = null AND Stage__c INCLUDES (' + stage + '))';
            }
            else {

                query += ' OR type__c = null';
            }

            query += ' LIMIT 1000';
            
            system.debug('66666666666666' + query);
            
            List<StipMaster__c> lstStips = Database.query(query);

            system.debug('777777777777777' + lstStips.size() + lstStips);

            for (StipMaster__c objStip : lstStips) {

                if (objStip.stage__c != NULL && !mapTypeStip.isEmpty() && !objStip.Add_to_all_Deals__c) {
                    
                    for (String strStage : stage.split(',')) {

                        strStage = strStage.remove('\'');
                        
                        if ( mapTypeStip.Keyset().contains(strStage)) {

                            //system.assert(false, 'strtype ' + strtype + ' strStage ' + strStage  );
                            mapTypeStip.get(strStage).add(objStip);
                        }                     
                    }

                    //if ( mapTypeStip.Keyset().contains('Underwriting') && objStip.stage__c.contains('Underwriting') ) {

                    //    mapTypeStip.get('Underwriting').add(objStip);
                    //}

                    //if ( mapTypeStip.Keyset().contains('PreQualification') && objStip.stage__c.contains('PreQualification') ) {

                    //    mapTypeStip.get('PreQualification').add(objStip);
                    //}

                }
                else {

                    if ( objStip.Add_to_all_Deals__c && !mapTypeStip.isEmpty() && mapTypeStip.containsKey('any')) {
                        mapTypeStip.get('any').add(objStip);
                    }
                }

                system.debug('9999999999999' + mapTypeStip);
            }

            system.debug('888888888888888888' + mapTypeStip);
            return mapTypeStip ;
        }
    }


    //Construct map type question master records
    public static Map<String,List<MerchantInterviewQMaster__c>> getTypeQuestion(String type, Set<string> setStage) {

        if (type != null && type.length() > 0) {

            Map<String, List<MerchantInterviewQMaster__c>> mapTypeQues = new Map<String, List<MerchantInterviewQMaster__c>>();
            String stage = '';

            //for ( String str:type.split(',') ) {

            //    mapTypeQues.put(str, new List<MerchantInterviewQMaster__c>());
            //}

            for ( String strStage : setStage ) {

                stage += '\'' + strStage + '\',';

                for ( String str : type.split(',') ) {

                    mapTypeQues.put( str + strStage, new List<MerchantInterviewQMaster__c>() );
                }
            }

            stage = stage.removeEnd(',');

            type = '\'' + type;
            type = type.replace(',', '\',\'');
            type += '\'';

            String query = 'SELECT Id, Name, Category__c, Stage__c, Question__c, Type__c, Sort_Order__c FROM MerchantInterviewQMaster__c WHERE type__c INCLUDES (' + type + ')';

            if (stage != null && stage != '') {
            
                query += ' AND Stage__c IN (' + stage + ')';
            }

            query += ' LIMIT 1000';

            List<MerchantInterviewQMaster__c> lstMastQues = Database.query(query);

            for ( MerchantInterviewQMaster__c objQues : lstMastQues ) {

                //for each type
                for (String strtype : objQues.type__c.split(';')) {

                    if (objQues.stage__c != null) {

                        for (String strStage : stage.split(',')) {

                            strStage = strStage.remove('\'');
                            
                            if ( mapTypeQues.Keyset().contains(strtype + strStage)) {

                                //system.assert(false, 'strtype ' + strtype + ' strStage ' + strStage  );
                                mapTypeQues.get(strtype + strStage).add(objQues);
                            }
                        }
                        //if ( mapTypeQues.Keyset().contains(strtype + '' + 'Underwriting') && objQues.stage__c.contains('Underwriting') ) {

                        //    mapTypeQues.get(strtype + '' + 'Underwriting').add(objQues);
                        //}

                        //if ( mapTypeQues.Keyset().contains(strtype + '' + 'PreQualification') && objQues.stage__c.contains('PreQualification') ) {


                        //    mapTypeQues.get(strtype + '' + 'PreQualification').add(objQues);
                        //}
                    }
                }
            }

            return mapTypeQues;
        }
        else {

            Map<String, List<MerchantInterviewQMaster__c>> mapTypeQues = new Map<String, List<MerchantInterviewQMaster__c>>();

            String stage = '';

            for ( String strStage : setStage ) {

                stage += '\'' + strStage + '\',';

                mapTypeQues.put(strStage, new List<MerchantInterviewQMaster__c>() );

            }

            stage = stage.removeEnd(',');



            String query = 'SELECT Id, Name, Category__c, Stage__c, Question__c, Type__c, Sort_Order__c FROM MerchantInterviewQMaster__c WHERE type__c = null LIMIT 1000';
            List<MerchantInterviewQMaster__c> lstMastQues = Database.query(query);

            for ( MerchantInterviewQMaster__c objQues : lstMastQues ) {

                if (objQues.stage__c != null) {

                    for (String strStage : stage.split(',')) {
                        
                        strStage = strStage.remove('\'');
                        
                        if ( mapTypeQues.Keyset().contains(strStage)) {

                            //system.assert(false, 'strtype ' + strtype + ' strStage ' + strStage  );
                            mapTypeQues.get(strStage).add(objQues);
                        }
                    }

                    //if ( mapTypeQues.Keyset().contains('Underwriting') && objQues.stage__c.contains('Underwriting') ) {

                    //    mapTypeQues.get('Underwriting').add(objQues);
                    //}

                    //if ( mapTypeQues.Keyset().contains('PreQualification') && objQues.stage__c.contains('PreQualification') ) {

                    //    mapTypeQues.get('PreQualification').add(objQues);
                    //}
                }
            }



            return mapTypeQues;
        }
    }

}
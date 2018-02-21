trigger trg_BookingUnit on Booking_Unit__c (after Update, after insert,before insert,before update) {
    
    //Logic for setting the currency conversion rate
    if(trigger.isbefore){
        if(trigger.isinsert){
            Map<String,Double> ratemap = new Map<String,Double>();
            Date D=system.today();
            for(Currency_Rate__c cr : [select id,conversion_rate__c,Conversion_Date__c,From_Currency__c,To_Currency__c from Currency_Rate__c where To_Currency__c='AED' and Conversion_Date__c= :D] ){
                ratemap.put(cr.From_Currency__c,cr.conversion_rate__c);
            }
            for(Booking_Unit__c bu : trigger.new){
                if(bu.CurrencyISOCode!=null){
                    if(ratemap.get(bu.CurrencyISOCode)!=null)
                        bu.Conversion_Rate__c=ratemap.get(bu.CurrencyISOCode);
                }
                if(bu.Conversion_Rate__c ==null)
                    bu.Conversion_Rate__c=1;
            }
            /* Calling method to update the booking unit details based on the PC details. */
            BookingUnitTriggerHandler.updateBookingUnits(trigger.new);
        }
        if(trigger.isupdate || trigger.isinsert){
            for(Booking_Unit__c bu : trigger.new){
                system.debug('CConv=='+ bu.Conversion_Rate__c);
                system.debug('Req Price=='+ bu.Requested_Price__c);
                system.debug('BUID=='+ bu.id);
                if(bu.Requested_Price__c != null){
                    bu.Requested_Price_AED__c = bu.Requested_Price__c * bu.Conversion_Rate__c;  
                }
                if(bu.Unit_Selling_Price__c != null){
                    bu.Unit_Selling_Price_AED__c= bu.Unit_Selling_Price__c * bu.Conversion_Rate__c;
                }
            }
        }
    }
    
    if(trigger.isafter && (trigger.isupdate || trigger.isinsert)){
        List<Id> lstbuIds = new List<Id>();
        set<Id> tBitsIds = new set<Id>();
        set<Id> ReceiptIds = new set<Id>();
        set<Id> DSRFlg = new set<Id>();
        for(Booking_Unit__c bu : trigger.new){
            if(trigger.isafter && trigger.isinsert){
                if(bu.DP_OK__c || 
                   bu.Token_Paid__c ||
                   bu.Registration_Status_Code__c != null && (bu.Status__c !='Removed')){
                    lstbuIds.add(bu.id);
                }
                if(bu.Booking__c != NULL && bu.Status__c !='Removed'){
                    if(bu.tBits_Ready__c){
                        tBitsIds.add(bu.id);//tBitsIds.add(bu.Booking__c);
                    } 
                    if(bu.Receipt_ID__c != null){
                        ReceiptIds.add(bu.id);//ReceiptIds.add(bu.Booking__c);
                    }
                    if(bu.DSR_Flag__c){
                        DSRFlg.add(bu.id);//DSRFlg.add(bu.Booking__c);
                    }
                }
            }
            if(trigger.isafter && trigger.isupdate){
                if(bu.DP_OK__c != trigger.oldmap.get(bu.id).DP_OK__c || 
                   bu.Token_Paid__c != trigger.oldmap.get(bu.id).Token_Paid__c ||
                   (bu.Registration_Status_Code__c != null && bu.Registration_Status_Code__c != trigger.oldmap.get(bu.id).Registration_Status_Code__c) && (bu.Status__c !='Removed')){
                       lstbuIds.add(bu.id);
                   }
                if(bu.Booking__c != NULL && bu.Status__c !='Removed'){
                    if(bu.tBits_Ready__c == true && trigger.oldmap.get(bu.id).tBits_Ready__c == false){
                        tBitsIds.add(bu.id);//tBitsIds.add(bu.Booking__c);
                    }
                    if(bu.Receipt_ID__c != null && trigger.oldmap.get(bu.id).Receipt_ID__c == null && bu.Status__c !='Removed'){
                        ReceiptIds.add(bu.id);//ReceiptIds.add(bu.Booking__c);
                    }
                    if(bu.DSR_Flag__c == true && trigger.oldmap.get(bu.id).DSR_Flag__c == false && bu.Status__c !='Removed'){
                        DSRFlg.add(bu.id);//DSRFlg.add(bu.Booking__c);
                    }
                }
            }
        } 
        //Update SR DP_OK and Token Paid Date/time based on Booking Unit Values
        if(lstbuIds != null && !lstbuIds.isEmpty()){
            BookingUnitTriggerHandler.UpdateSR(lstbuIds);    
        }
        
        List<Id> lstBookingIds = new List<Id>();
        //Call TbitsFiles Job
        if(tBitsIds != null && !tBitsIds.isEmpty()){
            lstBookingIds.addAll(tBitsIds);
            system.enqueueJob(new AsyncReceiptWebservice (lstBookingIds,'Tbitsfiles'));
        }
        //Call ReceiptDoc Job
        if(ReceiptIds != null && !ReceiptIds.isEmpty()){
            lstBookingIds = new List<Id>();
            lstBookingIds.addAll(ReceiptIds);
            system.enqueueJob(new AsyncReceiptWebservice (lstBookingIds,'ReceiptDoc'));
        }
        //Call DSR Job
        if(DSRFlg != null && !DSRFlg.isEmpty()){
            lstBookingIds = new List<Id>();
            lstBookingIds.addAll(DSRFlg);
            system.enqueueJob(new AsyncReceiptWebservice (lstBookingIds,'DSR'));
        }
        
    }
    
    if(trigger.isafter && (trigger.isinsert || trigger.isupdate)){
        BookingUnitTriggerHandler.updateCampaignTotal(trigger.newmap); 
    }
    
    if(trigger.isbefore && (trigger.isinsert || trigger.isupdate)){
        
        BookingUnitTriggerHandler.updateBookingUnitType(trigger.newmap, trigger.oldmap);
    }
}
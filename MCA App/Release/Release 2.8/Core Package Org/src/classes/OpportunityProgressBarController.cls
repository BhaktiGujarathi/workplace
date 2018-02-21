public with sharing class OpportunityProgressBarController {
    public Id oppId                                 {get; set;}
    public Long tillDate;
    public list<OpportunityHistory> lstOppHistory;
    public list<ProgressBarWrapper> lstWrapper      {get;set;}
    public map<String,ProgressBarWrapper> mapWrapper{get;set;}
    public list<String> lstcolor                    {get;set;}
    public Date modifiedDt;
    public Date createdDt;
    public String timeDifference;
    public Decimal pixelbar = 0;
    private BusinessHours bh; 
    set<string> setOppStages;

    public OpportunityProgressBarController(ApexPages.StandardController controller){
        oppId = ApexPages.currentPage().getParameters().get('Id');
        Opportunity objOpp = [select Name, CreatedDate, StageName from Opportunity where id=:oppId];
        mapWrapper = new map<string,ProgressBarWrapper>();
        lstOppHistory = new list<OpportunityHistory>();
        lstWrapper = new list<ProgressBarWrapper>();
        lstcolor = new list<String>();
        list<OpportunityStage> lstOppStages = [select id, MasterLabel from OpportunityStage where isClosed=true];
        setOppStages = new set<string>();
        for(OpportunityStage stage : lstOppStages)
            setOppStages.add(stage.MasterLabel );
        
        lstOppHistory = [Select o.SystemModstamp, o.StageName, o.OpportunityId, o.CreatedDate
                          From OpportunityHistory o 
                          where o.OpportunityId =: oppId 
                          order by o.CreatedDate];
        
        bh =[Select id
                 From BusinessHours 
                 Where IsDefault=true];
        
        createdDt =  date.newinstance(objOpp.CreatedDate.year(), objOpp.CreatedDate.month(), objOpp.CreatedDate.day());
        modifiedDt = date.newinstance(lstOppHistory[lstOppHistory.size()-1].SystemModstamp.year(), 
                            lstOppHistory[lstOppHistory.size()-1].SystemModstamp.month(), 
                            lstOppHistory[lstOppHistory.size()-1].SystemModstamp.day());
        tillDate = calculateMilisecondDifference(objOpp.CreatedDate, system.now());
        reduceLostAndWonStages();
        system.debug('tillDate --------->'+tillDate);
        pixelbar = 0;

       init(); 
    }
    
    // It is used to reduce the closed won and colsed lost stages time
    public void reduceLostAndWonStages() {
        Integer i,j, counter = 1;
        // Calculate time difference as per the stages.
        for(i=0;i<=lstOppHistory.size()-2;++i){
        
            for(j=i+1;j<=lstOppHistory.size()-1;++j){
                if(lstOppHistory[i].StageName != lstOppHistory[j].StageName && setOppStages.contains(lstOppHistory[i].StageName) ){
                    tillDate = tillDate - calculateMilisecondDifference(lstOppHistory[i].CreatedDate, lstOppHistory[j].CreatedDate);
                }
                i = j-1;
                ++counter;
                break;
            }
        }
        
        // Iterate for last stage difference
        if(lstOppHistory.size()>0 && setOppStages.contains(lstOppHistory[i].StageName)){
            tillDate = tillDate - calculateMilisecondDifference(lstOppHistory[lstOppHistory.size()-1].SystemModstamp, system.now());
        }
    }
    
    public void init(){
        Integer i,j, counter = 1;
        Long miliSecDiff;
        Map<String, OpportunityStageBar__c> mapColorCodes = OpportunityStageBar__c.getAll();
        if(mapColorCodes.isEmpty())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.label.OpportunityStageBarError));
        } else{
            // Calculate time difference as per the stages.
            for(i=0;i<=lstOppHistory.size()-2;++i){
                for(j=i+1;j<=lstOppHistory.size()-1;++j){
                    if(lstOppHistory[i].StageName != lstOppHistory[j].StageName && !setOppStages.contains(lstOppHistory[i].StageName) ){
                        miliSecDiff = calculateMilisecondDifference(lstOppHistory[i].CreatedDate, lstOppHistory[j].CreatedDate);
                        timeDifference = calculateTimeDifference(miliSecDiff);
                        system.debug('miliSecDiff --------->'+Decimal.valueof(miliSecDiff));
                        system.debug('tillDate --------->'+tillDate);
                        system.debug('cal --------->'+(Decimal.valueof(miliSecDiff)/tillDate*100).round());
                        if(miliSecDiff > 0){
                            //change the ms value
                            if(pixelbar > 0 && (Decimal.valueof(miliSecDiff)/tillDate*100).round() > pixelbar){
                                lstWrapper.add(new ProgressBarWrapper(lstOppHistory[i].StageName,((Decimal.valueof(miliSecDiff)/tillDate)*100).round()-pixelbar+'%',
                                                mapColorCodes.containsKey(lstOppHistory[i].StageName) ? mapColorCodes.get(lstOppHistory[i].StageName).ColorCode__c : mapColorCodes.get('else').ColorCode__c,
                                                                        timeDifference));
                                pixelbar = 0;
                                system.debug('lstWrapper -------->'+lstWrapper);
                            }
                            else
                                lstWrapper.add(new ProgressBarWrapper(lstOppHistory[i].StageName,((Decimal.valueof(miliSecDiff)/tillDate)*100).round()+'%',
                                                mapColorCodes.containsKey(lstOppHistory[i].StageName)?mapColorCodes.get(lstOppHistory[i].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
                                                                        timeDifference));
                                 system.debug(' ELSE lstWrapper -------->'+lstWrapper);
                        }
                        else{
                            lstWrapper.add(new ProgressBarWrapper(lstOppHistory[i].StageName,5+'px',
                                    mapColorCodes.containsKey(lstOppHistory[i].StageName)?mapColorCodes.get(lstOppHistory[i].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
                                    timeDifference));
                            ++pixelbar;
                            system.debug(' ELSE b4 break pixel lstWrapper -------->'+lstWrapper);
                        }
                        i = j-1;
                        ++counter;
                        break;
                        system.debug(' ELSE pixel lstWrapper -------->'+lstWrapper);
                    }
                }//end of FOR-j
            }//end of FOR-i
            
            // Iterate for last stage difference
            if(lstOppHistory.size()>0 && !setOppStages.contains(lstOppHistory[i].StageName)){
                miliSecDiff = calculateMilisecondDifference(lstOppHistory[lstOppHistory.size()-1].SystemModstamp,system.now());
                timeDifference = calculateTimeDifference(miliSecDiff);
                system.debug('miliSecDiff --------->'+Decimal.valueof(miliSecDiff));
                system.debug('tillDate --------->'+tillDate);
                system.debug('cal --------->'+((Decimal.valueof(miliSecDiff)/tillDate)*100).round());
                if(tillDate > 0 && ((Decimal.valueof(miliSecDiff)/tillDate)*100).round() > pixelbar){
                    if(pixelbar > 0){
                        
                        lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((Decimal.valueof(miliSecDiff)/tillDate)*100).round()-pixelbar+'%', 
                                    mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
                                                        timeDifference));
                        pixelbar = 0;
                    } else{
                        system.debug('miliSecDiff --------->'+(Decimal.valueof(miliSecDiff)/tillDate)*100);
                        lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((Decimal.valueof(miliSecDiff)/tillDate)*100).round()+'%', 
                                    mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
                                                        timeDifference));
                        }
                } else{
                    
                    lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,'5px', 
                                    mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
                                                        timeDifference));
                    ++pixelbar;
                }
            }//end If
            
            // Bucketing for same color of stages. (mapWrapper<string,PBW> - <Stage Name,object>)
            for(ProgressBarWrapper objwrapper:lstWrapper){
                if(mapWrapper!=null && mapWrapper.containsKey(objwrapper.stageColor)){
                    //add the time difference
                    mapWrapper.get(objwrapper.stageColor).timediff = addTimeDifference(mapWrapper.get(objwrapper.stageColor).timediff,objwrapper.timediff);
                } else{
                    if(mapColorCodes.get(objwrapper.stageName)!=null && mapColorCodes.get(objwrapper.stageName).Parent_Stage__c != null)
                        objwrapper.stageName = mapColorCodes.get(objwrapper.stageName).Parent_Stage__c;
                    
                    mapWrapper.put(objwrapper.stageColor,objwrapper);
                    lstcolor.add(objwrapper.stageColor);
                }
                if(pixelbar > 0){
                    if(objwrapper.stagePercentage.contains('%') && integer.valueof(objwrapper.stagePercentage.split('%',2)[0]) > pixelbar+30){
                        objwrapper.stagePercentage = integer.valueof(objwrapper.stagePercentage.split('%',2)[0]) - pixelbar + '%';
                        pixelbar = 0;
                    }
                }
                
                if(lstWrapper.size() == 1){
                    if(objwrapper.stagePercentage == '5px' || objwrapper.stagePercentage == '0%'|| objwrapper.stagePercentage < '90%')
                        objwrapper.stagePercentage = '99.99%';
                }
            }//end For
            system.debug('lstWrapper ---------->'+lstWrapper);
            system.debug('mapWrapper ---------->'+mapWrapper);
            // Display the day and hours into page.
            for(ProgressBarWrapper wrapper:mapWrapper.values())
            {
                Decimal hours = decimal.valueof((wrapper.timediff.split('D ')[1]).split('H')[0])
                        + (decimal.valueof((wrapper.timediff.split('H ')[1]).split('M')[0])/60).setScale(2, RoundingMode.HALF_UP);
                if(integer.valueOf(wrapper.timediff.split('D ')[0]) <= 0 && hours <= 0)
                    wrapper.timediff = wrapper.timediff.split('M ')[1];
                else
                    wrapper.timediff = wrapper.timediff.split('D ')[0] + 'd ' + hours + 'h';
            }//End For 
        }//end else
    }
    
    public string addTimeDifference(string pTime1, string pTime2){
        Integer dayCount = integer.valueof(pTime1.split('D',2)[0]);
        Integer hourCount = integer.valueof((pTime1.split('H',2)[0]).split('D ')[1]);
        Integer minCount = integer.valueof((pTime1.split('M',2)[0]).split('H ')[1]);
        Integer secCount = integer.valueof((pTime1.split('s',2)[0]).split('M ')[1]);
        
        secCount += integer.valueof((pTime2.split('s',2)[0]).split('M ')[1]);

        minCount += integer.valueof((pTime2.split('M',2)[0]).split('H ')[1]);
        
        minCount += integer.valueof((Decimal.valueof(secCount)/60).round(System.RoundingMode.FLOOR));
        
        secCount -= 60 * integer.valueof((Decimal.valueof(secCount)/60).round(System.RoundingMode.FLOOR));
        
        
        hourCount += integer.valueof((pTime2.split('H',2)[0]).split('D ')[1])+integer.valueof((Decimal.valueof(minCount)/60).round(System.RoundingMode.FLOOR));
        minCount -= 60 * integer.valueof((Decimal.valueof(minCount)/60).round(System.RoundingMode.FLOOR));
        
        dayCount += integer.valueof(pTime2.split('D',2)[0])+integer.valueof((Decimal.valueof(hourCount)/24).round(System.RoundingMode.FLOOR));
        hourCount -= 24 * integer.valueof((Decimal.valueof(hourCount)/60).round(System.RoundingMode.FLOOR));
        
        //String return_string = dayCount+'d '+hourCount+ minCount +'h ';
        String return_string = dayCount+'D '+hourCount+'H '+ minCount +'M '+secCount +'s';
        
        return return_string; //pass back the final string
    }
    
    public Long calculateMilisecondDifference(DateTime lastDt, DateTime newDt){
        Long milisecdiff = BusinessHours.diff(bh.id, lastDt, newDt);
        
        return milisecdiff;
    }
    
    
    public string calculateTimeDifference(Long pMilisecdiff){
        Integer secdiff = integer.valueof(pMilisecdiff / 1000);
        Integer daydiff = secdiff / 86400;
        secdiff =  math.mod(secdiff , 86400);
        
        Integer hourdiff = secdiff / 3600;
        secdiff =  math.mod(secdiff , 3600);
        
        Integer minutesdiff = secdiff / 60 ;
        secdiff =  math.mod(secdiff , 60);
        
        //String return_string = secdiff +'S'+ minutesdiff +'M'+hourdiff+'h'+daydiff+'D';
        String return_string = daydiff+'D '+hourdiff+'H '+ minutesdiff +'M '+secdiff +'s';
        system.debug('return_string---'+return_string);
        return return_string; //pass back the final string
    }

    public class ProgressBarWrapper {
        public String stageName        {get;set;}
        public String stagePercentage  {get;set;}
        public String stageColor       {get;set;}
        public Decimal daysDiff        {get;set;}
        public String timediff         {get;set;}
        public ProgressBarWrapper(String pstageName, String pstagePercentage, String pstageColor,String ptimediff){
            stageName = pstageName;
            stagePercentage = pstagePercentage;
            stageColor = pstageColor;
            //daysDiff = pdaysDiff;
            timediff = ptimediff;
        }
    }
}
public with sharing class OpportunitTimeline {
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

public OpportunitTimeline(ApexPages.StandardController controller){
        oppId = ApexPages.currentPage().getParameters().get('Id');
        Opportunity objOpp = [select Name, CreatedDate, StageName from Opportunity where id=:oppId];
        mapWrapper = new map<string,ProgressBarWrapper>();
        lstOppHistory = new list<OpportunityHistory>();
        lstWrapper = new list<ProgressBarWrapper>();
        lstcolor = new list<String>();
        list<Opportunity> lstOppStages = [Select id,stageName From Opportunity where isClosed=true];
        setOppStages = new set<string>();
        for(Opportunity stage : lstOppStages)
            setOppStages.add(stage.stageName);
        system.debug('##setOppStages'+setOppStages);
        lstOppHistory = [Select o.SystemModstamp, o.StageName, o.OpportunityId, o.CreatedDate 
                          From OpportunityHistory o 
                          where o.OpportunityId =: oppId 
                          order by o.CreatedDate];
        system.debug('@@lstOppHistory'+lstOppHistory);
        bh =[Select id
                 From BusinessHours 
                 Where IsDefault=true];
        system.debug('##BusinessHours##'+bh);
        createdDt =  date.newinstance(objOpp.CreatedDate.year(), objOpp.CreatedDate.month(), objOpp.CreatedDate.day());
        modifiedDt = date.newinstance(lstOppHistory[lstOppHistory.size()-1].SystemModstamp.year(), 
                            lstOppHistory[lstOppHistory.size()-1].SystemModstamp.month(), 
                            lstOppHistory[lstOppHistory.size()-1].SystemModstamp.day());
        tillDate = calculateMilisecondDifference(objOpp.CreatedDate,system.now());
        system.debug('%%%createdDt'+objOpp.CreatedDate+'%%%today'+system.now());
        pixelbar = 1;

       init(); 
 }
 public void init(){
        Integer i,j, counter = 1;
        Long miliSecDiff;
        Map<String, OpportunityStageBar__c> mapColorCodes = OpportunityStageBar__c.getAll();
        if(mapColorCodes.isEmpty())
        {
        	System.debug('%%%%%%mapColorCodes Under If' + mapColorCodes); 
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.label.OpportunityStageBarError));
        }
        else{
            for(i=0;i<=lstOppHistory.size()-2;++i){
                for(j=i+1;j<=lstOppHistory.size()-1;++j){
                    SyStem.debug('iiii'+lstOppHistory[i].StageName+'jjjj'+lstOppHistory[j].StageName);
                    SyStem.debug('iiii'+i+'jjjj'+j);
                    if(lstOppHistory[i].StageName != lstOppHistory[j].StageName && !setOppStages.contains(lstOppHistory[i].StageName)){
                        miliSecDiff = calculateMilisecondDifference(lstOppHistory[i].CreatedDate,lstOppHistory[j].CreatedDate);
                        timeDifference = calculateTimeDifference(miliSecDiff);
                        
                        System.debug('##timeDifference##'+timeDifference+'###'+miliSecDiff+'tillDate##'+tillDate);
                        System.debug('##111111pixelbar'+pixelbar);
                        System.debug('##22222###'+Decimal.valueof(miliSecDiff)/tillDate*100);
                        if(miliSecDiff > 0){//chnage the ms value
                            if(pixelbar > 0 && (Decimal.valueof(miliSecDiff)/tillDate*100).round(System.RoundingMode.FLOOR) > pixelbar){
                                lstWrapper.add(new ProgressBarWrapper(lstOppHistory[i].StageName,((Decimal.valueof(miliSecDiff)/tillDate)*100).round(System.RoundingMode.FLOOR)-pixelbar+'%',
                                                mapColorCodes.containsKey(lstOppHistory[i].StageName)?mapColorCodes.get(lstOppHistory[i].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
                                                                        timeDifference));
                                pixelbar = 0;}
                            else
                                lstWrapper.add(new ProgressBarWrapper(lstOppHistory[i].StageName,((Decimal.valueof(miliSecDiff)/tillDate)*100).round(System.RoundingMode.FLOOR)+'%',
                                                mapColorCodes.containsKey(lstOppHistory[i].StageName)?mapColorCodes.get(lstOppHistory[i].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
                                                                        timeDifference));
                        }
                        else{
                            lstWrapper.add(new ProgressBarWrapper(lstOppHistory[i].StageName,5+'px',
                                    mapColorCodes.containsKey(lstOppHistory[i].StageName)?mapColorCodes.get(lstOppHistory[i].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
                                    timeDifference));
                            ++pixelbar;
                        }
                        System.debug('%%%lstWrapper'+counter+lstWrapper);
                        i = j-1;
                        ++counter;
                        break;
                    }
            }//end of FOR-j
        }//end of FOR-i
        if(lstOppHistory.size()>0 && !setOppStages.contains(lstOppHistory[i].StageName)){
            miliSecDiff = calculateMilisecondDifference(lstOppHistory[lstOppHistory.size()-1].CreatedDate,system.now());
            timeDifference = calculateTimeDifference(miliSecDiff);
            
            system.debug('###tillDate'+tillDate +'11'+ pixelbar);
            system.debug('###Decimal'+(Decimal.valueof(miliSecDiff)/tillDate));
            system.debug('###Decimal'+((Decimal.valueof(miliSecDiff)/tillDate)*100).round(System.RoundingMode.FLOOR));
            if(tillDate > 0 && ((Decimal.valueof(miliSecDiff)/tillDate)*100).round(System.RoundingMode.FLOOR) > pixelbar){
                if(pixelbar > 0){
                    lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((Decimal.valueof(miliSecDiff)/tillDate)*100).round(System.RoundingMode.FLOOR)-pixelbar+'%', 
                                mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
                                                    timeDifference));
                    system.debug('###lstWrapper'+lstOppHistory[lstOppHistory.size()-1].StageName);
                    pixelbar = 0;}
                else
                    lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((Decimal.valueof(miliSecDiff)/tillDate)*100).round(System.RoundingMode.FLOOR)+'%', 
                                mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
                                                    timeDifference));
                 system.debug('###lstWrapper'+lstWrapper);
            }
            else{
                system.debug('111111111111111');
                lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,'5px', 
                                mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
                                                    timeDifference));
                ++pixelbar;
            }
        }
        System.debug('###lstWrapper'+counter+lstWrapper);
        system.debug('###mapColorCodes#'+mapColorCodes);
        //mapWrapper<string,PBW> - <Stage Name,object>
        for(ProgressBarWrapper objwrapper:lstWrapper){
            if(mapWrapper!=null && mapWrapper.containsKey(objwrapper.stageColor)){
                //add the time difference
                system.debug('$$$111'+objwrapper.stageName);
                system.debug('$$$'+mapWrapper.get(objwrapper.stageColor).timediff);
                mapWrapper.get(objwrapper.stageColor).timediff = addTimeDifference(mapWrapper.get(objwrapper.stageColor).timediff,objwrapper.timediff);
                system.debug('%%%%%%%%%%mapWrapper'+mapWrapper);
               //mapWrapper.get(objwrapper.stageName).
            }
            else{
                system.debug('$$22222'+objwrapper.stageName);
                if(mapColorCodes.get(objwrapper.stageName)!=null && mapColorCodes.get(objwrapper.stageName).Parent_Stage__c != null)
                    
                        objwrapper.stageName = mapColorCodes.get(objwrapper.stageName).Parent_Stage__c;
                        mapWrapper.put(objwrapper.stageColor,objwrapper);
                        System.debug('#######Into Wraper.put'+mapWrapper);
                    
                lstcolor.add(objwrapper.stageColor);
                System.debug('#######lstcolor'+lstcolor);
            }
            system.debug('33$$$'+mapWrapper);
            if(pixelbar > 0){
                if(objwrapper.stagePercentage.contains('%') && integer.valueof(objwrapper.stagePercentage.split('%',2)[0]) > pixelbar+30){
                    objwrapper.stagePercentage = integer.valueof(objwrapper.stagePercentage.split('%',2)[0]) - pixelbar + '%';
                    pixelbar = 0;
                }}
            if(lstWrapper.size() == 1){
                if(objwrapper.stagePercentage == '5px' || objwrapper.stagePercentage == '0%'|| objwrapper.stagePercentage != '90%')
                    objwrapper.stagePercentage = '90%';}
            system.debug('44$$$'+lstWrapper);
        }
        for(ProgressBarWrapper wrapper:mapWrapper.values())
        {
        	system.debug('#####wrapper.timediff'+wrapper.timediff);
        	system.debug('#####wrapper.timediff'+wrapper.timediff.split('H')[0]);
        	system.debug('#####wrapper.timediff'+integer.valueof((wrapper.timediff.split('H ')[1]).split('M')[0]));
        	system.debug('#####wrapper.timediff'+decimal.valueof((wrapper.timediff.split('H ')[1]).split('M')[0])/60);
        	system.debug('#####wrapper.timediff'+(decimal.valueof((wrapper.timediff.split('H ')[1]).split('M')[0])/60).setScale(2, RoundingMode.HALF_UP));
        	system.debug('#####wrapper.timediff'+ ((wrapper.timediff.split('D ')[1]).split('H')[0]));
        	Decimal hours = decimal.valueof((wrapper.timediff.split('D ')[1]).split('H')[0])
                    + (decimal.valueof((wrapper.timediff.split('H ')[1]).split('M')[0])/60).setScale(2, RoundingMode.HALF_UP);
            system.debug('@@@@hours'+hours);
            system.debug('@@@111111'+wrapper.timediff.split('D ')[0]+'@@@'+hours);
            system.debug('@@@111111'+wrapper.timediff.split('D ')[0] >0 +'@@@'+hours);
            if(integer.valueOf(wrapper.timediff.split('D ')[0]) <= 0 && hours <= 0)
                wrapper.timediff = wrapper.timediff.split('M ')[1];
            else
                wrapper.timediff = wrapper.timediff.split('D ')[0] + 'd ' + hours + 'h';
            system.debug('@@@@'+wrapper.timediff);
        }
    }//end else
 }
    
    public string addTimeDifference(string pTime1, string pTime2){
        System.debug('#########pTime1 '+pTime1+' ********pTime2'+pTime2);
        Integer dayCount = integer.valueof(pTime1.split('D',2)[0]);
        system.debug('###dayCount'+dayCount);
        Integer hourCount = integer.valueof((pTime1.split('H',2)[0]).split('D ')[1]);
        system.debug('###hourCount'+hourCount);
        Integer minCount = integer.valueof((pTime1.split('M',2)[0]).split('H ')[1]);
        system.debug('###minCount'+minCount);
        Integer secCount = integer.valueof((pTime1.split('s',2)[0]).split('M ')[1]);
        system.debug('###secCount'+secCount);

        secCount += integer.valueof((pTime2.split('s',2)[0]).split('M ')[1]);

        minCount += integer.valueof((pTime2.split('M',2)[0]).split('H ')[1]);
        system.debug('###minCount1111#'+integer.valueof((pTime2.split('M',2)[0]).split('H ')[1]));
        system.debug('###minCount1111#'+minCount);
        minCount += integer.valueof((Decimal.valueof(secCount)/60).round(System.RoundingMode.FLOOR));
        system.debug('###minCount2222##'+minCount);
        secCount -= 60 * integer.valueof((Decimal.valueof(secCount)/60).round(System.RoundingMode.FLOOR));
        system.debug('###11##secCount'+secCount+'###11##'+minCount);
        
        hourCount += integer.valueof((pTime2.split('H',2)[0]).split('D ')[1])+integer.valueof((Decimal.valueof(minCount)/60).round(System.RoundingMode.FLOOR));
        minCount -= 60 * integer.valueof((Decimal.valueof(minCount)/60).round(System.RoundingMode.FLOOR));
        system.debug('###11##minCount'+minCount+'###11##'+hourCount);

        dayCount += integer.valueof(pTime2.split('D',2)[0])+integer.valueof((Decimal.valueof(hourCount)/24).round(System.RoundingMode.FLOOR));
        hourCount -= 24 * integer.valueof((Decimal.valueof(hourCount)/60).round(System.RoundingMode.FLOOR));
        system.debug('###11##dayCount'+dayCount+'###11##'+hourCount);

        //String return_string = dayCount+'d '+hourCount+ minCount +'h ';
        String return_string = dayCount+'D '+hourCount+'H '+ minCount +'M '+secCount +'s';
        system.debug('$$$return_string'+return_string);
        return return_string; //pass back the final string
    }
    
    public Long calculateMilisecondDifference(DateTime lastDt, DateTime newDt){
        Long milisecdiff = BusinessHours.diff(bh.id, lastDt, newDt);
        system.debug('##BusinessHours##'+milisecdiff);
        return milisecdiff;
    }

    public string calculateTimeDifference(Long pMilisecdiff){
        Integer secdiff = integer.valueof(pMilisecdiff / 1000);
        Integer daydiff = secdiff / 86400;
        secdiff =  math.mod(secdiff , 86400);
        system.debug('##daydiff##'+daydiff+'##secdiff##'+secdiff);
        Integer hourdiff = secdiff / 3600;
        secdiff =  math.mod(secdiff , 3600);
        system.debug('##hourdiff##'+hourdiff+'##secdiff##'+secdiff);
        Integer minutesdiff = secdiff / 60 ;
        secdiff =  math.mod(secdiff , 60);
        system.debug('##minutesdiff##'+minutesdiff+'##secdiff##'+secdiff);
        //String return_string = secdiff +'S'+ minutesdiff +'M'+hourdiff+'h'+daydiff+'D';
        String return_string = daydiff+'D '+hourdiff+'H '+ minutesdiff +'M '+secdiff +'s';
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
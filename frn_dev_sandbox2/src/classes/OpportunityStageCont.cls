public with sharing   class OpportunityStageCont {

    public static final String STAGE_ADMITTED        =  'Admitted';
    public static final String STAGE_ADMITTED_CLOSED =  'Admitted/Closed';

	public transient Map<String,String> probabilityStageNameMap;
    public List<TWrapper> labels{get;set;}
    public List<TWrapper> tooltips {get; set;}
    public List<Integer> doneStageNumbers {get; set;}
    public List<Integer> todoStageNumbers {get; set;}
    public Integer labelCount {get; set;}
    public Boolean loadOnce {get; set;}
    public Boolean flagRTC {get; set;}
    public Boolean flagIOP {get; set;}
    public String valsText {get; set;}
    public Opportunity opp{get;set;}
    public Id opptID{get;set;}
	public String chartYear{get;set;}
	
    public OpportunityStageCont() {
		flagRTC = false;
        flagIOP = false;
        opptID = ApexPages.currentPage().getParameters().get('Id'); 
        opp = [
            Select id 
                 , StageName
                 , Recordtype.Name
                 , IsClosed
              from Opportunity 
             where ID =: opptID 
        ];

        loadOnce = true;
		if(opp != null){
			if(opp.Recordtype.Name == 'Residential Treatment'){
				flagRTC = true;
                flagIOP = false;
			}
            if(opp.Recordtype.Name == 'Outpatient Treatment') {
                flagIOP = true;
                flagRTC = false;                
            }
		}     
    }
    
    public PageReference reload(){
        init();
        loadOnce = false;
        return null;
    }
    public void init(){
        labels = new List <TWrapper>();
        tooltips = new List<TWrapper>();
        doneStageNumbers = new List<Integer>();
        todoStageNumbers = new List<Integer>();
        labelCount = 0;
        Boolean done = false;
        labels.add(new TWrapper(labelCount++,'.'));
        for(String val : valsText.split(':')){
            
            if(!done){
                doneStageNumbers.add(labelCount);
            }else{
                todoStageNumbers.add(labelCount);
            }

            if(val == opp.StageName){
                done = true;
                todoStageNumbers.add(labelCount);
            } else if ( STAGE_ADMITTED.equalsIgnoreCase(val) == true && opp.isClosed == true ){
                done = true;
                todoStageNumbers.add(labelCount);
            }

            if( STAGE_ADMITTED.equalsIgnoreCase(val) == true){
                val = STAGE_ADMITTED_CLOSED;
            }

            labels.add(new TWrapper(labelCount, val));
            toolTips.add(new TWrapper(labelCount, 'Help for ' + val + ' stage'));
            labelCount++;
        }
        labels.add(new TWrapper(labelCount, '.'));
        System.debug(labels);
    }
    
    public class TWrapper{ 
        public Integer idx {get;set;}
        public String text{get;set;}
        public TWrapper(Integer inIdx, String inText){
            idx=inIdx;
            text=inText;
        }
    }
    
    public List<SelectOption> getStages(){
        List<SelectOption> listStage = new List<SelectOption>();
        List<OpportunityStage> oppStagenameList = new List<OpportunityStage>();
         Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        //for( Schema.PicklistEntry f : fieldResult.getPicklistValues()){
        //    listStage.add(f.getValue());
        //}
        if(flagIOP) {
            oppStagenameList = [Select ApiName,
                                          Description,
                                          ForecastCategory,
                                          IsActive,
                                          IsClosed,
                                          IsWon,
                                          MasterLabel,
                                          ForecastCategoryName,
                                          DefaultProbability
                                     From OpportunityStage 
                                    where (isclosed != true 
                                       OR IsWon = true)  
                                      AND IsActive = true
                                      AND ApiName NOT IN ('Denied by VOB', 'Prospecting', 'Intervention Requested', 'Pending Medical / Clinical Review', 'Pending IOP Assessment', 'Pending Admission')
                                 ORDER BY Description 
                                ASC NULLS LAST];
        }
        else {
            oppStagenameList = [Select ApiName,
                                          Description,
                                          ForecastCategory,
                                          IsActive,
                                          IsClosed,
                                          IsWon,
                                          MasterLabel,
                                          ForecastCategoryName,
                                          DefaultProbability
                                     From OpportunityStage 
                                    where (isclosed != true 
                                       OR IsWon = true)  
                                      AND IsActive = true
                                      AND ApiName <> 'Pending Appointment'
                                 ORDER BY Description 
                                ASC NULLS LAST];
        }
        Map<String, String> stageMap = new Map<String, String>();
            //listStage.add(new SelectOption('','--None--'));
        for(OpportunityStage os : oppStagenameList){

             listStage.add(new SelectOption(os.MasterLabel, os.MasterLabel));
             system.debug('>>> os : '+os);
             //stageMap.put(os.MasterLabel, os.MasterLabel);
			 
        }
		system.debug('listStage'+listStage);
        /*for( Schema.PicklistEntry f : fieldResult.getPicklistValues()){
            if(stageMap.containsKey(f.getValue()))
            listStage.add(new SelectOption(f.getValue(), f.getValue()));
        }*/
        return listStage;
		
    } 
	/* @RemoteAction
	
	 //public static List<TWrapper> getRemoteStage(Integer inIdx, String inText) {
		 return null;

		 
	 
	
	} */
    public String getStagename(){
        return [Select StageName from  Opportunity where id =: opptID].StageName;
    }
}
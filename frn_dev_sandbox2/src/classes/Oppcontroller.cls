public class Oppcontroller
{
    public List<TWrapper> labels{get;set;}
    public List<TWrapper> tooltips {get; set;}
	public List<Integer> doneStageNumbers {get; set;}
	public List<Integer> todoStageNumbers {get; set;}
	public Integer labelCount {get; set;}
	public Boolean loadOnce {get; set;}
	public String valsText {get; set;}
	private Opportunity opp;
    public Oppcontroller(ApexPages.StandardController controller) {
        opp = (Opportunity)controller.getRecord();
        loadOnce = true;
     
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
            }
			labels.add(new TWrapper(labelCount, val));
			toolTips.add(new TWrapper(labelCount, 'Help for ' + val + ' stage'));
			labelCount++;
        }
		labels.add(new TWrapper(labelCount, '.'));
    }
	
	
	
	
	
    public class TWrapper{
        public Integer idx {get;set;}
        public String text{get;set;}
		public TWrapper(Integer inIdx, String inText)
		{
			idx=inIdx;
			text=inText;
		}
    }
}
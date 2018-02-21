public with sharing class VolumeBonusRollupController {
	
	
	public VolumeBonusRollupController() {
		
	}


	public PageReference calculateRollups() {

		String accountId = ApexPages.currentPage().getParameters().get('id');
		VolumeBonusRollUpHandler handler = new VolumeBonusRollUpHandler(accountId);
		handler.rollup();		

		return new PageReference('/' + accountId);
	}
}
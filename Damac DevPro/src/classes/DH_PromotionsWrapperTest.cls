/*********************************************************************************
* Name               : DH_PromotionsWrapperTest
* Description        :Test class for wrpper class DH_PromotionsWrapper.
*----------------------------------------------------------------------------------
* VERSION     AUTHOR            DATE          COMMENTS 
  1.0         Pratiksha(Accely) 
  **********************************************************************************/
  @isTest
private class DH_PromotionsWrapperTest {
static testMethod void  DH_PromotionsWrapperTestMethod(){
DH_PromotionsWrapper cls= new DH_PromotionsWrapper();
        cls.id ='test';
        cls.templateIdSN ='test';
        cls.templateIdCN ='test';
        cls.templateIdPN ='test';
        cls.templateIdOP ='test';
        cls.templateIdOP1 ='test';
        cls.templateIdOP2 ='test';
        cls.templateIdOP3 ='test';
        cls.templateIdOP4 ='test';
        cls.templateIdOP5 ='test';
        cls.TokenAmountApprovalStatus ='test';
        cls.NetPrice = 10.00;
        cls.productType = 'test';
        List<SelectOption> promotionOptions = cls.promotionOptions;
        List<SelectOption> campaignOptions = cls.campaignOptions;
        List<SelectOption> schemeOptions = cls.schemeOptions;       
        DH_PromotionsWrapper.optionWrapper obj = new DH_PromotionsWrapper.optionWrapper();
        obj.Name = 'test';
        obj.Id = 'test';
        obj.Price = 'test';
        List<DH_PromotionsWrapper.optionWrapper> objoptionWrapper = new List<DH_PromotionsWrapper.optionWrapper>();
        objoptionWrapper.add(obj);
        List<DH_PromotionsWrapper.optionWrapper> optionOptions = objoptionWrapper;
}
}
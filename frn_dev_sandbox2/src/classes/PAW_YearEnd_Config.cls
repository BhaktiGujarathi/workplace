public with sharing class PAW_YearEnd_Config {

    public static Year_End_PAW_Settings__c setting;

    public static Year_End_PAW_Settings__c fetch(){
        if( setting == null )
            setting =  Year_End_PAW_Settings__c.getInstance();

        system.debug('>>> setting : '+setting);
        return setting;
    }
}
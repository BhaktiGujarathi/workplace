public class ApproveReadytoHandoverUnits {
    
    private ApexPages.StandardSetController standardController;
    
    public ApproveReadytoHandoverUnits (ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }
    
    public PageReference init()
    {
        List<Booking_Unit__c> selectedBookingUnits = (List<Booking_Unit__c>) standardController.getSelected();
        
        List<Booking_Unit__c> lstBookingUnits = new List<Booking_Unit__c>();
        for(Booking_Unit__c selectedBU : selectedBookingUnits )
        {
            selectedBU.Approved_By_HOD__c = true;
            lstBookingUnits.add(selectedBU);
        }
        
        update lstBookingUnits;
        
        pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/a0x');
        newpg.setRedirect(true);
        return newpg;
    }

}
public class HotelSubmission {


    Public Hotel__c objHotel {get; set;}
    Public HotelSubmission(){
        objHotel = new Hotel__c ();
    }
    Public PageReference save(){
        insert objHotel;
       
        return new PageReference('/thankshotel');
    }
}
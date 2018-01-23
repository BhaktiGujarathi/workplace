Public class SpeakerUpload{


    Public Speaker__c objSpeaker{get; set;}
    Public SpeakerUpload(SubmitSpeakerController stdCon){
        objSpeaker = new Speaker__c();
    }
    Public PageReference saveSpeaker(){
        insert objSpeaker;
       
        return new PageReference('/thanks');
    }
}
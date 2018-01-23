public class SubmitSpeakerController {

public Speaker__c s { get; set; }
	
	public SubmitSpeakerController () {
		s = new Speaker__C();
    }

	public PageReference submitSpeaker() {
				INSERT s;
                return new PageReference('/thanks');
		}
	}
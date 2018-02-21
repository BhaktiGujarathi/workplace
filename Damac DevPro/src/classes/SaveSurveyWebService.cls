/**
 * Save Survey web-service will save the surveys entered by the calling users.
 */
@RestResource(urlMapping='/saveSurvey/*')
global class SaveSurveyWebService {

    /**
     * Method to process post request
     */
    @HttpPost
    global static void doPost() {
        SaveSurveyLogic.processSaveSurveyRequest();
    }
}
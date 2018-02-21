/**
 * Helper class for redirection
 *   
 * Revision History: 
 * Version           Author                 Date                 Description 
 * 1.0               Yogesh Mahajan         7-Jul-2016           Initial Draft 
*/

public class RedirectionHelper {

    private static final String CONSOLE_URL_PARAM = '?isdtp=vw';

    /**
     * Returns opportunity detail page url
     */
    public static PageReference getOpportunityDetailUrl(String oppId, Boolean isConsole) {
        String opportunityUrl = '/' + oppId + (isConsole ? CONSOLE_URL_PARAM : '');
        return new PageReference(opportunityUrl);
    }

}
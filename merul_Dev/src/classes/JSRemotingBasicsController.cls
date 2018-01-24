global with sharing class JSRemotingBasicsController {
    public JSRemotingBasicsController() {
    }
     
    @RemoteAction
    public static String doGetText(String txt) {
        return txt;
    }
}
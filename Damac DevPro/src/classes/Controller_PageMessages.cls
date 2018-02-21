/*
Created By : Swapnil Gholap
Use : Custom style of Page messages
Source : https://gist.github.com/Oblongmana/5943010#file-pagemessages-cls
*/

public with sharing class Controller_PageMessages {

    public String CustomPageMessages_ClosableErrorsRenderPlaceHolder {
        get { 
            if(CustomPageMessages_ClosableErrorsRenderPlaceHolder == null) CustomPageMessages_ClosableErrorsRenderPlaceHolder = ''; 
            return CustomPageMessages_ClosableErrorsRenderPlaceHolder; 
        }
        private set;
    } 

    public List<PageMessages.PageMessage> getPageMessages() {
        return PageMessages.getMessages();
    }
    
}
public class DemoAttDownloadController {
    public DemoAttDownloadController (){
        
    }
    public void downloadFiles() {
        Attachment attachment = [select id, body from Attachment where id =: '00P9000000fb87w'];
    }
}
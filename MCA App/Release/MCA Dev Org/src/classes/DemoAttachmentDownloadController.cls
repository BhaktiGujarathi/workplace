public class DemoAttachmentDownloadController {

    @RemoteAction
    public static string getAttachments() {
        Attachment acc = [Select id, Name, body From Attachment where id =:'00P9000000i3iXhEAI'];
        return EncodingUtil.base64Encode(acc.body);
    }
}
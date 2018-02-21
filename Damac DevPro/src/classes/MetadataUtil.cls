public class MetadataUtil {
    static MetadataService.MetadataPort port;
    
    public static MetadataService.MetadataPort getPort() {
        if (port == null) {
            port = new MetadataService.MetadataPort();
            port.sessionHeader = new MetadataService.SessionHeader_element();
            port.sessionHeader.sessionId = UserInfo.getSessionId();
        }
        return port;
    }
}
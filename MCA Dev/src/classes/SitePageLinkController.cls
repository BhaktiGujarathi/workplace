public class SitePageLinkController
{
    
    public String submissionId                                 {get; set;}
    public String encryptedId;
   
    public SitePageLinkController()
    {
        
    }
    
    public String getEncryptedId()
    {
        if(submissionId != null)
        {
            Blob cryptoKey = Blob.valueOf('1234567890123456');            
            Blob data = Blob.valueOf(submissionId);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data);
            encryptedId = encodingUtil.URLEncode(EncodingUtil.base64Encode(encryptedData),'UTF-8');  
            
            return encryptedId;
        }
        else
            return null;
    }
    
}
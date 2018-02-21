/*
*Change History:
* CH01 # 337 # 14-03-2017 # Sivasankar # Encrypting the Mobile number
*/
Global without Sharing Class PasswordCryptoGraphy{

    public string strActualPassword{get;set;}
    public string strResult{get;set;}
    public string strKey;//CH01 changed to public from private

    public PasswordCryptoGraphy() {
        strActualPassword = '';
        strResult = '';
        strKey = 'U8907654HG0765835671KLM67BTSRA12';
    }
   
    // Method to EncryptPassword
    public void EncryptPassword(){
        if(strActualPassword!=null && strActualPassword!=''){
            Blob keyblobval = Blob.valueOf(strKey);
            Blob EncryptedPasswordBlob = Crypto.encryptWithManagedIV('AES256', keyblobval, Blob.valueOf(strActualPassword));
            String strEncryptedPasswordText = EncodingUtil.base64Encode(EncryptedPasswordBlob); 
            System.debug('strEncryptedPasswordText==>'+strEncryptedPasswordText);
            strResult = strEncryptedPasswordText;
         }
    }
    
    // Method to DecryptPassword
    
    Global static string DecryptPassword(string encryptedString){
        
        string strKey = 'U8907654HG0765835671KLM67BTSRA12';
        string decryptedTxt;
        Blob keyblobval = Blob.valueOf(strKey);
       // System.debug('strActualPassword==>'+strActualPassword);
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(encryptedString);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', keyblobval, encodedEncryptedBlob);
        String decryptedPasswordText = decryptedBlob.toString();
        System.debug('decryptedPasswordText==>'+decryptedPasswordText);
        decryptedTxt = decryptedPasswordText;
        system.debug('PWD******'+decryptedTxt); 
        return decryptedTxt;
        
    }
    //CH01.Start
    /*********************************************************************************************
	* @Description : Method to encrypt the mobile number number 				                 *
	* @Params      : void			                                                             *
	* @Return      : void                                                                        *
	*********************************************************************************************/
    global void encryptMobilePhone(){
    	if(String.isNotBlank(strActualPassword)){
			Blob keyblobval = Blob.valueOf(strKey);
	        //Blob keyblobval = Crypto.generateAesKey(256);
	        System.debug('keyblobval = '+String.valueOf(keyblobval));
	        Blob EncryptedPasswordBlob = Crypto.encryptWithManagedIV('AES256', keyblobval, Blob.valueOf(strActualPassword));
	        String strEncryptedPasswordText = EncodingUtil.base64Encode(EncryptedPasswordBlob); 
	        System.debug('strEncryptedPasswordText==>'+strEncryptedPasswordText);
	        strResult = strEncryptedPasswordText;
    	}
    }
    
    /*********************************************************************************************
	* @Description : Method to decrypt the mobile number number                					 *
	* @Params      : List<Inquiry__c>                                                            *
	* @Return      : void                                                                        *
	*********************************************************************************************/
    global String decryptMobilePhone(String encryptValue){
        System.debug('encryptValue = '+encryptValue);
		String decryptedPasswordText = '';
		if(String.isNotBlank(encryptValue)){
			Blob keyblobval = Blob.valueOf(strKey);
	        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(encryptValue);
	        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', keyblobval, encodedEncryptedBlob);
	        strResult = decryptedBlob.toString();
	        system.debug('strResult==>'+strResult);
		}
        return strResult;
    }
    //CH01.End
}
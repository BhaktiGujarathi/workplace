/*****************************************************************************
* Class: ConstantUtility
* Purpose/Methods: this is where we store all the constant
------------------------------------------------------------------------------
* Utility Test Data:
------------------------------------------------------------------------------

*******************************************************************************/
public with sharing class ConstantUtility {

    public static final String GETMETHOD = 'GET';
    public static final String POSTMETHOD = 'POST';
    public static final String OBJECT_ID_PARAM = 'Id';
    public static final String CARD_PRICE_PARAM = 'cardPrice';
    public static final String RESPONSEOK = 'OK';
    public static final String RESPONSECREATED = 'Created';
    public static final Integer RESPONSE200 = 200;
    public static final Integer RESPONSE201 = 201;
    public static final Integer RESPONSE500 = 500;
    public static final String AUTHORIZATION = 'Authorization';
    public static final String POSTMANTOKEN = 'Postman-Token';
    public static final String CONTENTTYPE= 'content-type';
    public static final String TOKEN = 'Token';
    public static final String BEARER = 'Bearer';
    public static final String APPLICATIONJSON ='application/json';
    public static final String APPLICATIONTYPE = 'application/x-www-form-urlencoded';
    
    public static final String ACCEPT = 'Accept';
    public static final String SENDCARD= 'send';
    //public static final String CHECKOUT = 'checkout';
    public static final String EMPTYSTRING = '';
    public static final String STRINGWITHSPACE = ' ';
    public static final String ACTIVATION = 'Activation';
    public static final String REMINDER = 'Reminder';
    public static final String DEACTIVATION = 'Deactivation';
    public static final String CONFIRMCODE = 'confirmCode';
   // public static final String SERVICESITE = System.label.Site17Grapes +'/subscriptionDetails';
    //public static final String SERVICESITEFEEDBACK = System.label.Site17Grapes +'/FeedbackDetails';
    //RestUtility constants
    public static final Integer SET_TIMEOUT = 120000;
    public static final String MESSAGE_CALLOUT_LIMIT = 'Performing this operation would reach the Salesforce Governer Limits. Aborting operation';

    //Page messages
    public static final String ERROR_AUTHENTICATION = 'Please verify your account details';
    public static final String SET_CART_ERROR = 'There\'s some problem with selection of card please try again';
    public static final String ERROR_UNABLE_TO_ADD_CARD = 'Unable to add the card to the cart please select the contact again.';
    public static final String PAGEID_PARAM = 'id';
    public static final String IMPID_PARAM = 'impId';
    public static final String CARDNAME_PARAM = 'cardName';
    
    public static final String OBJ_LEAD = 'Lead';
    public static final String OBJ_CONTACT = 'Contact';
}
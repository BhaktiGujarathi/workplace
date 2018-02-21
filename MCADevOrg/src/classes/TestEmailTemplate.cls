public with sharing class TestEmailTemplate {
    @future
    public static void testTemplate() {
        List<EmailTemplate> emailTemp = createEmailTemplate(1);
        insert emailTemp;
    }
    public static List<EmailTemplate> createEmailTemplate(Integer recordCount){
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>(); 
        for(Integer index=0; index<=recordCount; index++) 
        {
	        EmailTemplate validEmailTemplate = new EmailTemplate();
	        validEmailTemplate.isActive = true;
	        validEmailTemplate.Name = 'SWEmailTemplate';
	        validEmailTemplate.DeveloperName = 'EmailTemplateSW'+index;
	        validEmailTemplate.TemplateType = 'text';
	        validEmailTemplate.Body = 'Hi';
	        validEmailTemplate.FolderId = UserInfo.getUserId();
	        emailTemplateList.add(validEmailTemplate);
        }//End for.
        system.debug(emailTemplateList);
        return emailTemplateList;
    }
}
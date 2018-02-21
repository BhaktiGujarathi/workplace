public class fetchLabelController{
    public fetchLabelController(){
        //system.debug('11111111'+label.EmailStips_MailIdNotPresent.getDescribe());
        system.debug('getLabelString'+getLabelString('EmailStips_MailIdNotPresent') );

    }
     public String getLabelString(String labelName ){
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        output.expressions.value= '{!$Label.' + labelName  + '}';
     


        return String.valueOf(output.id);
    }
}
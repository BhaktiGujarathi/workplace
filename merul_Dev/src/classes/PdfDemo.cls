public class PdfDemo {


public String i;


    public String getI() {
        return i;
    }



public void PdfDemo1()
{


    system.debug('######## '+ApexPages.currentPage().getParameters().get('id'));
     
     i=ApexPages.currentPage().getParameters().get('id');


}


}
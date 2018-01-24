public class TestDynamicComponentExample{
  
  
  public Contact  testContact{get;set;}
    public TestDynamicComponentExample(ApexPages.StandardController con) 
    {
      testContact=(Contact)con.getRecord();   
    }
    
    
    
    public Component.Apex.SectionHeader getHeaderWithDueDateCheck() {
        date dueDate = date.newInstance(2013, 7, 4);
        boolean overdue = date.today().daysBetween(dueDate) < 0;

        Component.Apex.SectionHeader sectionHeader = new Component.Apex.SectionHeader();
        if (overdue) {
            sectionHeader.title = 'This Form Was Due On ' + dueDate.format() + '!';
            return sectionHeader;
        } else {
            sectionHeader.title = 'Form Submission';
            return sectionHeader;
        }
    }
}
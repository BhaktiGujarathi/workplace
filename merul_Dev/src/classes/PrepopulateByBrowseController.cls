public class PrepopulateByBrowseController {
    public BirthdayTraker__c bir { get; set; }

    public Blob b { get; set; }
    public String Age { get; set; }
    public String Company { get; set; }
    public String Name { get; set; }
     public String Address { get; set; }
     public String Street { get; set; }
    public static Map <String,List <string >> mapOfHeaderAndValues;  
    Public Map<String,String> mapApiLabel{get;set;}  
    Public List<string> leftselected{get;set;}
Public List<string> rightselected{get;set;}
Public Set<string> leftvalues = new Set<string>();
Public List<string> rightvalues = new List<string>();


    public PrepopulateByBrowseController()       
    {     
           }        
    
  public void onLoad()
  { 
         
          
            mapApiLabel=new Map<String,String>();
            leftselected = new List<String>();
            rightselected = new List<String>();
            Set <String> fieldSet = new Set<String>();
            
        
            mapApiLabel.put('cricket','cricket');
            leftvalues.add('cricket');
            mapApiLabel.put('music','music');
            leftvalues.add('music');
            mapApiLabel.put('ps2','ps2');
            leftvalues.add('ps2');
            mapApiLabel.put('dance','dance');
            leftvalues.add('dance');             
            
                    
            leftvalues.removeAll(rightvalues);

                            

     }
   
 



public List<SelectOption> getunSelectedValues()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,mapApiLabel.get(s)));
        return options;
    }

 
public List<SelectOption> getSelectedValues()
    {
           
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        
        tempList.addAll(rightvalues);
       /* if(shouldSort)
        {
            //tempList.sort();
            shouldSort=false;
        }  */  
        for(String s : tempList)
            options1.add(new SelectOption(s,mapApiLabel.get(s)));
           
        return options1;
    }


   

   
    public PageReference selectclick(){
      //  shouldSort=true;
        rightselected.clear();
        for(String s : leftselected)
        {
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
    
    
    public PageReference unselectclick()
    {
            leftselected.clear();
            for(String s : rightselected){
               
                for(Integer i=0;i<rightvalues.size();i++)
                {
                    if(rightvalues[i].equals(s))
                    {
                    
                         rightvalues.remove(i);
                                       
                    }
                           
                }
                
                leftvalues.add(s);
            }
            return null;
    }
    
    public PageReference upclick()
    {
               Map<Integer,String> indexOfValue=new Map<Integer,String>();
               List<string> tempList = new List<String>();
               tempList.addall(rightvalues);
                
                system.debug('$$$$$$$  '+leftvalues);
               for(String s : rightselected)
               {
                    for(Integer i=0; i<tempList.size();i++)
                    {
                        if(s.equals(tempList[i]))
                        {
                            indexOfValue.put(i,s);
                        }
                               
                    }
                            
               }
               
               for(Integer i:indexOfValue.keyset())
               {
                 if(i!=0)
                 {
                     String var1=tempList.get(i-1);
                     String var2=tempList.get(i);
                         
                     tempList.set(i,var1);
                     tempList.set(i-1,var2);
                            
                 }
               }
             
               rightvalues=tempList;
               system.debug('$$$$$$$  '+leftvalues);
               return null;
    } 
     
     
     
    public PageReference downclick()
    {
                 Map<Integer,String> indexOfValue=new Map<Integer,String>();
                 List<string> tempList = new List<String>();
                 List<integer> tempIndex=new List<integer>();
        
                 tempList.addall(rightvalues);
                
                
                   for(String s : rightselected)
                   {
                        for(Integer i=0; i<tempList.size();i++)
                        {
                            if(s.equals(tempList[i]))
                            {
                                indexOfValue.put(i,s);
                            }
                                   
                        }
                                
                   }
                   
                  tempIndex.addall(indexOfValue.keyset());
               
                   for(Integer i=tempIndex.size()-1;i>=0;i--)
                   {
                     if(tempIndex[i]!=tempList.size()-1)
                     {
                         String var1=tempList.get(tempIndex[i]+1);
                         String var2=tempList.get(tempIndex[i]);
                        
                         tempList.set(tempIndex[i],var1);
                         tempList.set(tempIndex[i]+1,var2);
                      
                       
                     }
                   }
                
               rightvalues=tempList;
               return null;
    }
     
    
 

 
 
       

   
   
   public PageReference onSave()
   {
       system.debug('@@@@@@@@   '+parseCSV(b.toString(),false));
        mapOfHeaderAndValues=listToMap(parseCSV(b.toString(),false));
        system.debug('$$$$$$$$  '+mapOfHeaderAndValues);
        
        
        
        Name=mapOfHeaderAndValues.get('Name')[0]; 
        Age=mapOfHeaderAndValues.get('Age')[0];   
        Company =mapOfHeaderAndValues.get('Company')[0];  
        Address =mapOfHeaderAndValues.get('Address')[0];  
        
        
        Street=mapOfHeaderAndValues.get('Street')[0];   
        
        rightvalues.add(mapOfHeaderAndValues.get('Hobbies')[0]);           
        
        
        bir=new BirthdayTraker__c();
       bir.TestMultiselect__c='ABC';  

      
        PageReference secondPage = Page.PrepopulateForm;
        secondPage.setRedirect(false);
        return secondPage; 
          
   }
   
   
   public static Map <String,List <string >> listToMap(List<List<String>> lls) 
   {
   
        Map < String, List < string >> mapKeyValue = new Map < String, List < string >> ();
        for (integer i = 0; i < lls[0].size(); i++)
        {
            list < String > s = new list < String > ();
            for (integer j = 1; j < lls.size(); j++) {
                s.add(lls[j][i]);
            }
            mapKeyValue.put(lls[0][i], s);
        }
        
        return mapKeyValue;
     
   }
   
   
   
   
  
   
   
   public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) 
   {

    List<List<String>> allFields = new List<List<String>>();

 

    // replace instances where a double quote begins a field containing a comma

    // in this case you get a double quote followed by a doubled double quote

    // do this for beginning and end of a field

    contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');

    // now replace all remaining double quotes - we do this so that we can reconstruct

    // fields with commas inside assuming they begin and end with a double quote

    contents = contents.replaceAll('""','DBLQT');

    // we are not attempting to handle fields with a newline inside of them

    // so, split on newline to get the spreadsheet rows

    List<String> lines = new List<String>();

    try {
       
        lines = contents.split('\n');

    } catch (System.ListException e) {

        System.debug('Limits exceeded?' + e.getMessage());

    }
   
   
  

    Integer num = 0;

    for(String line : lines) {

        // check for blank CSV lines (only commas)
       
        if (line.replaceAll(',','').trim().length() == 0) break;

         

        List<String> fields = line.split(',');   

        List<String> cleanFields = new List<String>();

        String compositeField;

        Boolean makeCompositeField = false;

        for(String field : fields) {
           field=field.trim();

            if (field.startsWith('"') && field.endsWith('"')) {

                cleanFields.add(field.replaceAll('DBLQT','"'));

            } else if (field.startsWith('"')) {

                makeCompositeField = true;

                compositeField = field;

            } else if (field.endsWith('"')) {

                compositeField += ',' + field;

                cleanFields.add(compositeField.replaceAll('DBLQT','"'));

                makeCompositeField = false;

            } else if (makeCompositeField) {

                compositeField +=  ',' + field;

            } else {

                cleanFields.add(field.replaceAll('DBLQT','"'));

            }

        }

        allFields.add(cleanFields);

    }

    if (skipHeaders) allFields.remove(0);

    return allFields;      

}

   


}
public class multiselect {
 
    Public Set<String> originalvalues = new Set<String>{'A','B','C','D','E','F','G'};
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    Public Set<string> leftvalues = new Set<string>();
    Public List<string> rightvalues = new List<string>();
    Public boolean shouldSort=false;
    public multiselect(){
        
        leftselected = new List<String>();
        rightselected = new List<String>();
        leftvalues.addAll(originalValues);
    }
     
    public PageReference selectclick(){
        shouldSort=true;
        rightselected.clear();
       for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
    
    
    public PageReference upclick(){
    
        Map<Integer,String> indexOfValue=new Map<Integer,String>();
        List<string> tempList = new List<String>();
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
           
        return null;
    } 
     
     
     
    public PageReference downclick(){
       Map<Integer,String> indexOfValue=new Map<Integer,String>();
        List<string> tempList = new List<String>();
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
       
       List<integer> tempIndex=new List<integer>();
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
     
    public PageReference unselectclick(){
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
 
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
       // tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getSelectedValues(){
    
         
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        
        tempList.addAll(rightvalues);
        if(shouldSort)
        {
            //tempList.sort();
            shouldSort=false;
        }    
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
            
          
            
        return options1;
    }
}
global Class TabsObjectLabel implements Comparable {
    
    public String label {get; set;}
    public String keyPrefix {get; set;}
    public String apiName {get; set;}
    
    public TabsObjectLabel(String labelName, String Api, String Key){
        label = labelName;
        apiName = Api;
        keyPrefix = Key;
    }
    
    
    // Implement the compareTo() method
    global Integer compareTo(Object compareTo) {
       TabsObjectLabel compareToObj = (TabsObjectLabel)compareTo;
        if (label <  compareToObj.label) return -1;
        if (label > compareToObj.label ) return 1;
        return 0;        
    }

}
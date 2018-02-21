public Class checkRecursive{
    private static boolean runBefore = true;
    private static boolean runAfter = true;
    public static boolean runOnceForBefore(){
        if(runBefore){
         runBefore = false;
         return true;
        }else{
            return runBefore ;
        }
    }
    public static boolean runOnceForAfter(){
        if(runAfter){
         runAfter = false;
         return true;
        }else{
            return runAfter ;
        }
    }
}
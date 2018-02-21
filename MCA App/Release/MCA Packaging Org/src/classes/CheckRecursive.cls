/*
* Version       Date             Author         Description
*   1.0         23/10/2015       Ashwini S      For early exit and recursive checks
*/
public with sharing class CheckRecursive {
 public static boolean runBefore = true;
    public static boolean runAfter = true;
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
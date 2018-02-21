public with sharing class CheckRecursive {

    public static Boolean runBefore = true;
    public static Boolean runAfter = true;

    public static Boolean runOnceForBefore() {

        if ( runBefore ) {

            runBefore = false;
            return true;
        }
        else {

            return runBefore ;
        }
    }


    public static Boolean runOnceForAfter() {

        if ( runAfter ) {

            runAfter = false;
            return true;
        }
        else {

            return runAfter ;
        }
    }
}
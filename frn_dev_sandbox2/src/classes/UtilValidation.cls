global class UtilValidation{
    webservice static boolean isEstimateBalance(decimal unitePrice,decimal balance,decimal pymtAMt){
        if((pymtAMt + balance)!= unitePrice){
            return false;
        }
        return true;
    }
}
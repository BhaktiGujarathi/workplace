public class XIRR_3{
    /*
    public static decimal calculate(Map<Integer, Integer> dateMap, Map<Integer,Double> costMap){
        System.debug(dateMap);
        System.debug(costMap);
        
        double LOW_RATE = 0.00000000001;
//        double HIGH_RATE = 0.9;
        double HIGH_RATE = 100000;
//        double MAX_ITERATION = 900;
//        double MAX_ITERATION = 600;
                double MAX_ITERATION = 850;
                
        double PRECISION_REQ =  0.000000000000000000000000001;      
        integer numOfFlows = costMap.size();
        

        integer i = 0,j = 0;
        double m = 0.0;
        double old = 0.00;
        double new1 = 0.00;
        double oldguessRate = LOW_RATE;
        double newguessRate = LOW_RATE;
        double guessRate = LOW_RATE;
        double lowGuessRate = LOW_RATE;
        double highGuessRate = HIGH_RATE;
        double npv = 0.0;
        double denom = 0.0;
        
        for(i=0; i<MAX_ITERATION; i++){
            npv = 0.00;
            double k=0;
            for(j=0; j<numOfFlows; j++){
                if(j>0){
                    k = dateMap.get(j);
                }
                k=k/365;
                denom = Math.pow((1 + guessRate),k);


                if(costMap.get(j) <> null){
                    npv = npv + (costMap.get(j)/denom);
                }

            } // j for loop end here

            // Stop checking once the required precision is achieved 
            if((npv > 0) && (npv < PRECISION_REQ))
                break;
            if(old == 0)
                old = npv;
            else
                old = new1;
                
            new1 = npv;
            if(i > 0){
                if(old < new1){
                    if(old < 0 && new1 < 0)
                        highGuessRate = newguessRate;
                    else
                        lowGuessRate = newguessRate;
                }
                else{
                    if(old > 0 && new1 > 0)
                        lowGuessRate = newguessRate;
                    else
                        highGuessRate = newguessRate;
                }
            } //(i>0) close here
            oldguessRate = guessRate;
            guessRate = (lowGuessRate + highGuessRate) / 2;
            newguessRate = guessRate;
        }
        
            decimal toRound = guessRate*100;
            decimal result =  toRound.setScale(0, RoundingMode.HALF_UP);            
            return result;
    }

*/

    public static decimal cal(Map<Integer, Integer> dateMap, Map<Integer,Double> costMap){
        //System.debug(dateMap);
        //System.debug(costMap);
        
        double LOW_RATE = 0.00000000001;
//        double HIGH_RATE = 0.9;
        double HIGH_RATE = 100000;
//        double MAX_ITERATION = 900;
//        double MAX_ITERATION = 600;
                double MAX_ITERATION = 250;
                
        double PRECISION_REQ =  0.000000000000000000000000001;      
        integer numOfFlows = costMap.size();
        

        integer i = 0,j = 0;
        double m = 0.0;
        double old = 0.00;
        double new1 = 0.00;
        double oldguessRate = LOW_RATE;
        double newguessRate = LOW_RATE;
        double guessRate = LOW_RATE;
        double lowGuessRate = LOW_RATE;
        double highGuessRate = HIGH_RATE;
        double npv = 0.0;
        double denom = 0.0;
        
        for(i=0; i<MAX_ITERATION; i++){
            npv = 0.00;
            double k=0;
            for(j=0; j<numOfFlows; j++){
                if(j>0){
                    k = dateMap.get(j);
                }
                k=k/365;
                denom = Math.pow((1 + guessRate),k);

                if(costMap.get(j) <> null){
                    npv = npv + (costMap.get(j)/denom);
                }

            } // j for loop end here

            /* Stop checking once the required precision is achieved */
            if((npv > 0) && (npv < PRECISION_REQ))
                break;
            if(old == 0)
                old = npv;
            else
                old = new1;
                
            new1 = npv;
            if(i > 0){
                if(old < new1){
                    if(old < 0 && new1 < 0)
                        highGuessRate = newguessRate;
                    else
                        lowGuessRate = newguessRate;
                }
                else{
                    if(old > 0 && new1 > 0)
                        lowGuessRate = newguessRate;
                    else
                        highGuessRate = newguessRate;
                }
            } //(i>0) close here
            oldguessRate = guessRate;
            guessRate = (lowGuessRate + highGuessRate) / 2;
            newguessRate = guessRate;
        }
        
            decimal toRound = guessRate*100;
            decimal result =  toRound.setScale(0, RoundingMode.HALF_UP);            
            return result;
    }


}
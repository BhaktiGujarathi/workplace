global class CCTripIteratable implements iterable<Trip__c>
{
   
     private Map<String,Trip__c> mapIdConcurNewTrip;
     public CCTripIteratable(Map<String,Trip__c> mapIdConcurTrip)
     {
          mapIdConcurNewTrip = mapIdConcurTrip;
     
     }
   
     global Iterator<Trip__c> Iterator()
     {
          return mapIdConcurNewTrip.values().iterator();
     }
}
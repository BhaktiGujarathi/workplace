public with sharing class MileStoneEventsWrapper {

  public class MileStoneEvents 
  {
    public List<MILESTONE_TAB_TYPE> MILESTONE_TAB_TYPE;
    public String message;
    public String status;
  }

  public class MILESTONE_TAB_TYPE 
  {
    public String MILESTONE_EVENT;
    public String ARABIC_MILESTONE_EVENT;
  }

  
  public static MileStoneEvents parse(String json) 
  {
    return (MileStoneEvents) System.JSON.deserialize(json, MileStoneEvents.class);
  }
}
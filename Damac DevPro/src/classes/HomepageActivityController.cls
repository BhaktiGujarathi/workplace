public class HomepageActivityController {
    public list<RecentlyViewed> listActivity{get;set;}
    public list<wrapparActivity> listwrapparActivity{get;set;}
    public List<wrapparActivity> getlitsAct(){
        listwrapparActivity = new list<wrapparActivity>();
        listActivity = [SELECT Id, 
                               Name , 
                               Alias,
                               Type
                        FROM RecentlyViewed 
                        WHERE Type IN ('Account', 'Contact','Lead','Opportunity','Task')
                        ORDER BY LastViewedDate DESC ];
        System.debug('..listActivity...'+listActivity);                  
        if(!listActivity.isEmpty()){                 
        for(RecentlyViewed objActivities :listActivity ){
            wrapparActivity objwrapparActivity = new wrapparActivity(); 
            
            objwrapparActivity.Name = objActivities.Type == 'Account' ? 'You recently viewed account '+objActivities.Name : 
                                      objActivities.Type == 'Contact' ?  'You recently viewed Contact '+objActivities.Name :
                                      objActivities.Type == 'Lead' ?  'You recently viewed Lead '+objActivities.Name :
                                      objActivities.Type == 'Opportunity' ?  'You recently viewed Opportunity '+objActivities.Name :
                                      objActivities.Type == 'Task' ?  'You recently viewed Task '+objActivities.Name :
                                      '';
            
            listwrapparActivity.add(objwrapparActivity);
        }  
       System.debug('..listwrapparActivity..'+listwrapparActivity);
       }            
        return listwrapparActivity; 
    }
    public class wrapparActivity{
        public string Name{get;set;}
    }
}
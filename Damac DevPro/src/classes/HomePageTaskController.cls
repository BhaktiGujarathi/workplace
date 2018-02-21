public class HomePageTaskController {
    public list<Task> listTask{get;set;}
    public list<wrapparActivity> listwrapparActivity{get;set;}
    public List<wrapparActivity> getlitsAct(){
        listwrapparActivity = new list<wrapparActivity>();
        listTask = [SELECT Id, 
                           Subject , 
                           Priority,
                           Status
                    FROM Task 
                    WHERE what.type = 'Case'];
        System.debug('..listTask...'+listTask);                  
        if(!listTask.isEmpty()){                 
        for(Task objTasks :listTask ){
            wrapparActivity objwrapparActivity = new wrapparActivity(); 
            objwrapparActivity.Name = 'You have new task '+objTasks.Subject+
                                      ' Priority is '+objTasks.Priority+
                                      ' status is '+objTasks.Status;
            objwrapparActivity.ID = 'https://pratikshanarvekar-dev-ed--c.ap2.visual.force.com/'+objTasks.ID;                          
            listwrapparActivity.add(objwrapparActivity);
        }  
       System.debug('..listwrapparActivity..'+listwrapparActivity);
       }            
        return listwrapparActivity; 
    }
    public class wrapparActivity{
        public string Name{get;set;}
        public string ID{get;set;}
    }
}
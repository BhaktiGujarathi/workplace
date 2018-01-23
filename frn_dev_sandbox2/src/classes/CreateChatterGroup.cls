global class CreateChatterGroup {
    webservice static string chatter(String coName){
        list<CollaborationGroup> collist = [select name from CollaborationGroup where Name=:coName]; 
        if(collist.size()<1){
        CollaborationGroup grp= new CollaborationGroup();
         grp.Name =coName; 
         grp.CollaborationType = 'Public';
         insert grp;
         System.debug('grp...>>'+grp);
         return 'yes';
        }else{
            return 'No';
        }    
        return null; 
    } 
    webservice static string chatter1(String oppName){
        list<CollaborationGroup> collist = [select name from CollaborationGroup where Name=:oppName]; 
        if(collist.size()<1){
        CollaborationGroup grp= new CollaborationGroup();
         grp.Name =oppName; 
         grp.CollaborationType = 'Public';
         insert grp;
         System.debug('grp...>>'+grp);
         return 'yes';
        }else{
            return 'No';
        }    
        return null; 
    } 
}
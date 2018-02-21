/*
* Name : Pavithra Gajendra
* Date : 02/12/2017
* Purpose : Class to do DML on User object 
* Company : NSI Gulf
* 
*/
public class UpdateIsActiveOnUser implements Queueable{

        private List<User> userListToActivate ;
        private List<User> userListToDeActivate ;

        public UpdateIsActiveOnUser(List<User> userListToActivate, List<User> userListToDeActivate){
                this.userListToActivate = new List<User>(userListToActivate);
                this.userListToDeActivate = new List<User>(userListToDeActivate);
            }
        //------ Implementing Execute method of Queueable Interface
        public void execute(QueueableContext qc) {

            if(!userListToActivate.isEmpty()){
                System.debug('userListToActivate '+userListToActivate);
                try{
                    update userListToActivate ;
                }catch(Exception e){
                    System.debug('Exception '+e.getMessage());
                }
            }

            if(!userListToDeActivate.isEmpty()){
                 System.debug('userListToDeActivate '+userListToDeActivate);
                try{
                    update userListToDeActivate ;
                }catch(Exception e){
                    System.debug('Exception '+e.getMessage());
                }
            }            
        }

}
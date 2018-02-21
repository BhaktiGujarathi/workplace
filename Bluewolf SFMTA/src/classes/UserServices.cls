public with sharing class UserServices {
    public static User GetUserById(Id userId){
        User results = new User();
        for(User usr :[SELECT Id, Name, Contact.Name, ProfileId, Profile.Name  
            FROM User 
            WHERE Id = :userId 
            limit 1]){
            
            results = usr;
        }
        return results;
    }
}
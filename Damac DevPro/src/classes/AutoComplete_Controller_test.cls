@isTest
public class AutoComplete_Controller_test {

    static testmethod void m1(){
        
        AutoComplete_Controller ac = new AutoComplete_Controller();
        object obj = 'Name';
        ac.setTargetField(obj);
        integer size = ac.getRandomNumber(10);
        
        Account acc = InitialiseTestData.getCorporateAccount('test');
        insert acc;
        
        AutoComplete_Controller.getData('Account', 'name', 'name', 'test','');
        ac.setTargetField('Name');
    }

}
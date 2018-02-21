@isTest(seeAllData=false)

private class FormAssemblyControllerTest {

    static testMethod void testGetUserId() {
        String userid = FormAssemblyController.userid();
        System.assertEquals(UserInfo.getUserId(), userid, 'GetUserId is not returning the correct user id');
    }
}
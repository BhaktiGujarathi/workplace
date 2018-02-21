@isTest
private class TaskListControllerTest {

    @testSetup
    static void setupTestData() {
        insert createTasks(200);
    }

    static List<Task> createTasks(Integer count) {
        List<Task> lstTask = new List<Task>();
        for (Integer i = 0; i < count; i++) {
            lstTask.add(new Task(
                Priority = 'Normal',
                Status = 'Not Started',
                ActivityDate = Date.today(),
                Subject = 'New Test Task',
                Type = 'Call'
            ));
        }
        return lstTask;
    }

    @isTest
    private static void testControllerPositive() {
        Test.startTest();
        TaskListController controller = new TaskListController();
        Test.stopTest();

        System.assert(!controller.lstTask.isEmpty());
    }

    @isTest
    private static void testControllerNegative() {
        delete [SELECT Id FROM Task WHERE OwnerId = :UserInfo.getUserId()];

        Test.startTest();
        TaskListController controller = new TaskListController();
        Test.stopTest();

        System.assert(controller.lstTask.isEmpty());
    }
}
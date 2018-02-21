public with sharing class TaskListController {

    public Contact customerContact  {get; set;}
    public Account customerAccount  {get; set;}

    public List<Task> lstTask       {get; set;}
    public Map<Id, Case> mapSr      {get; set;}
    public List<SRTask> lstSRTask   {get; set;}

    public String pageUrl           {get; set;}


    public TaskListController() {
        initializeVariables();
        List<User> lstUser =  [ SELECT  ContactId,
                                        Contact.AccountId
                                FROM    User
                                WHERE   Id = :UserInfo.getUserId()];
        lstTask = getUsersPendingAndTodaysTasks(UserInfo.getUserId());
        if (!lstUser.isEmpty()) {
            Id customerAccountId = lstUser[0].ContactId == NULL || lstUser[0].Contact.AccountId == NULL
                                    ? '0017E00000aqcZm' : lstUser[0].ContactId;
            mapSr = new Map<Id, Case>([
                SELECT  Id,
                        CaseNumber,
                        Booking_Unit__c,
                        Booking_Unit__r.Unit_Details__c
                FROM    Case
                WHERE   AccountId = :customerAccountId
            ]);
            for (Task task : getUsersSRTasks(UserInfo.getUserId(), mapSr.keySet())) {
                lstSRTask.add(new SRTask(task, mapSr.get(task.WhatId)));
            }
        }

    }

    private void initializeVariables() {
        lstTask = new List<Task>();
        lstSRTask = new List<SRTask>();
        pageUrl = EncodingUtil.urlEncode(ApexPages.currentPage().getUrl(), 'UTF-8');
    }

    private static List<Task> getUsersPendingAndTodaysTasks(Id userId) {
        return [SELECT      Id,
                            Subject,
                            Type,
                            ActivityDate,
                            Priority,
                            IsClosed,
                            WhatId,
                            What.Name
                FROM        Task
                WHERE       OwnerId = :userId
                            AND IsClosed = FALSE
                            AND ActivityDate <= TODAY
                ORDER BY    IsClosed ASC, Priority DESC, ActivityDate ASC
                LIMIT       1000];
    }

    public static List<Task> getUsersSRTasks(Id userId, Set<Id> setSrId) {
        return [SELECT      Id,
                            Subject,
                            Type,
                            ActivityDate,
                            Priority,
                            IsClosed,
                            WhatId,
                            What.Name
                FROM        Task
                WHERE       OwnerId = :userId
                            AND IsClosed = FALSE
                            AND ActivityDate <= TODAY
                            AND WhatId IN :setSrId
                ORDER BY    IsClosed ASC, Priority DESC, ActivityDate ASC
                LIMIT       1000];
    }

    public class SRTask {
        public Task task {get; set;}
        public String bookingUnit {get; set;}

        public SRTask(Task task, Case sr) {
            this.task = task;
            this.bookingUnit = sr.Booking_Unit__r.Unit_Details__c;
        }
    }

}
public with sharing class FullCalendarController {

    private static final String DATE_FORMAT = 'EEE, d MMM yyyy HH:mm:ss z';
    private static final String FORMAT = 'YYYY-MM-dd';

    private static Integer QUERY_ROW_LIMIT {
        get {return Limits.getLimitQueries() - Limits.getQueries();}
    }

    public FullCalendarController() {}

    @RemoteAction
    public static List<CalendarEvent> getCalendarEvents(Id userId) {
        List<CalendarEvent> lstCalendarEvent = new List<CalendarEvent>();
        for (Task task : [  SELECT      Id,
                                        Subject,
                                        Type,
                                        ActivityDate,
                                        Priority,
                                        IsClosed
                            FROM        Task
                            WHERE       OwnerId = :userId
                                    AND ActivityDate != NULL
                            LIMIT       50000]
        ) {
            lstCalendarEvent.add(new CalendarEvent(task));
        }

        for (Event event : [SELECT      Id,
                                        Subject,
                                        Type,
                                        IsAllDayEvent,
                                        StartDateTime,
                                        EndDateTime
                            FROM        Event
                            WHERE       OwnerId = :userId
                            LIMIT       :QUERY_ROW_LIMIT]
        ) {
            lstCalendarEvent.add(new CalendarEvent(event));
        }

        return lstCalendarEvent;
    }

    public class CalendarEvent {
        public String title {get;set;}
        public Boolean allDay {get;set;}
        public String startString {get;set;}
        public String endString {get;set;}
        public String url {get;set;}
        public String className {get;set;}
        public String eventType {get;set;}

        public CalendarEvent() {}

        public CalendarEvent(Task task) {
            this.title = task.Subject;
            this.allDay = false;
            this.startString = task.ActivityDate == NULL ? NULL : Datetime.newInstance(
                task.ActivityDate.year(), task.ActivityDate.month(), task.ActivityDate.day()
            ).format(FORMAT);
            this.endString = task.ActivityDate == NULL ? NULL : Datetime.newInstance(
                task.ActivityDate.year(), task.ActivityDate.month(), task.ActivityDate.day()
            ).format(FORMAT);
            this.url = '/' + task.Id;
            this.eventType = 'task';
        }

        public CalendarEvent(Event event) {
            this.title = event.Subject;
            this.allDay = event.IsAllDayEvent;
            this.startString = event.StartDateTime == NULL ? NULL : event.StartDateTime.format(FORMAT);
            this.endString = event.EndDateTime == NULL ? NULL : event.EndDateTime.format(FORMAT);
            this.url = '/' + event.Id;
            this.eventType = 'event';
        }
    }
}
public class CCUtility {

    public Static List<Sobject> cleanNullFrmLst(List<SObject> inputSobjectList) {
        Integer listSize = inputSobjectList.size();
        for(Integer index=0;index < listSize; index++)
        {
            
            if( inputSobjectList[index] == null ){
                inputSobjectList.remove(index);
                listSize--;
                index--;
            }
        }
        return inputSobjectList;
    }

    public static  Datetime getCurrentLoggedInUserDateTime(Datetime dateToConvert) {
        String localtimeinString = dateToConvert.format('MM/dd/yyyy hh:mm a', UserInfo.getTimeZone().getID());
        String[] dtTime = localtimeinString.split(' ');
        Date crntdate = Date.parse(dtTime[0]);
        System.debug('parse ::>'+crntdate);

        String timeInString = dtTime[1]+' '+dtTime[2];
        return getDateTimeFromIntervals(crntdate,timeInString);
    }

    public static DateTime getDateTimeFromIntervals(date dateFromDayOption, string timeInternal) {
        system.debug('==Date==: ' + dateFromDayOption + '==Time Interval==: ' + timeInternal);
        integer hours,minutes;

        List<string> intervals = timeInternal.split(' ');
        if(intervals[1] == 'AM'){
            List<string> lstTimings = intervals[0].split(':');
            if(lstTimings[0] == '12')
                hours = 0;
            else
                hours = integer.valueOf(lstTimings[0]);

            minutes = integer.valueOf(lstTimings[1]);
        }else if(intervals[1] == 'PM'){
            List<string> lstTimings = intervals[0].split(':');
            if(lstTimings[0] == '12')
                hours = integer.valueOf(lstTimings[0]);
            else
                hours = integer.valueOf(lstTimings[0]) + 12;

            minutes = integer.valueOf(lstTimings[1]);
        }

        Time tm = Time.newInstance(hours, minutes, 0, 0);
        system.debug('==Hours==: ' + hours + ' ==Minutes==: ' + minutes + ' ==Time==: ' + tm);

        DateTime dateTimeToReturn = dateFromDayOption;
        dateTimeToReturn = dateTimeToReturn.addHours(hours);
        dateTimeToReturn = dateTimeToReturn.addMinutes(minutes);
        dateTimeToReturn = dateTimeToReturn.addSeconds(0);
        return dateTimeToReturn;
    }

}
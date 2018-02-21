/*
	Author : RB Nagaboina
	Create On: 25th Jun 2013
	Class Name: SupportUtil
	Description : Used for various calculation on triggers, other classes etc.
	Modified By : 
*/
public with sharing class SupportUtil {
	
	public string PreviousMonths(string Month){
		if(Month != null){
			if(Month=='January')
				return 'December,November';
			else if(Month=='February')
				return 'January,December';
			else if(Month=='March')
				return 'February,January';
			else if(Month=='April')
				return 'March,February';
			else if(Month=='May')
				return 'April,March';
			else if(Month=='June')
				return 'May,April';
			else if(Month=='July')
				return 'June,May';
			else if(Month=='August')
				return 'July,June';
			else if(Month=='September')
				return 'August,July';
			else if(Month=='October')
				return 'September,August';
			else if(Month=='November')
				return 'October,September';
			else if(Month=='December')
				return 'November,October';
			else
				return '';
		}
		return '';
	}
}
/**
* @author Scott Covert
* @date 7/28/2016
* @description This class provides generic Date services such as converting date literal values to date[time] maps
*/
public with sharing class DateService 
{	
	/** Start key for date[time] map */
	public static final String START_KEY = 'Start';
	/** End key for date[time] map */
	public static final String END_KEY = 'End';
	/** Identifier for date literal containing _N_ */
	@TestVisible private static final String N_ID = '_N_';
	/** Identifier for date literal containing _AGO */
	@TestVisible private static final String AGO_ID = '_AGO';
	/** Identifier for date literal containing _FROM_NOW */
	@TestVisible private static final String FROM_NOW_ID = '_FROM_NOW';
	/** Identifier for date literal containing _FISCAL_ */
	private static final String FISCAL_ID = '_FISCAL';
	/** Identifier for date literal containing _90_ */
	private static final String NINETY_ID = '_90_';
	/** Message to relay unspecified n error */
	@TestVisible private static final String UNSPECIFIED_N_ERROR_MESSAGE = 'DateService Error: You must specify an \'N\' value for this date literal!';
	/** List of date literal identifier values */
	private static final List<String> DL_IDS = new List<String>{ N_ID, AGO_ID, FROM_NOW_ID, FISCAL_ID, '_' };	
	/** Mapping of offset names by corresponding integer values for date literals */
	private static final Map<String,Integer> NAME_BY_OFFSET = new Map<String,Integer>{ 'LAST' => -1, 'THIS' => 0, 'NEXT' => 1};
	/** List of special single day date literals */
	private static final List<String> DAY_PERIODS = new List<String>{ 'YESTERDAY', 'TODAY', 'TOMORROW'};
	/** Stores a test time to use for Apex unit tests */
	@TestVisible private static final Time TEST_TIME = Time.newInstance(System.now().hour(),System.now().minute(),System.now().second(),System.now().millisecond());
	/** Stores time value for midnight */
	private static final Time MIDNIGHT = Time.newInstance(0, 0, 0, 0);
	/** Stores datetime representation of midnight on the epoch during tests and midnight on the current day in the running user's locale otherwise */
	private static final DateTime TODAY_DT_START = ( Test.isRunningTest() ) ? DateTime.newInstance(1970,1,1) : DateTime.newInstance(System.today(), MIDNIGHT);
	/** Mapping of date literal period by their corresponding datetime start boundary for the current period */
	private static final Map<String,DateTime> PERIOD_BY_DT_START;
	/** Mapping of date literal periods by their corresponding datetime end boundary for the current period */
	private static final Map<String,DateTime> PERIOD_BY_DT_END;
	/** Static code block for initializing PERIOD_BY maps */
	static
	{
		Map<Integer,Integer> MONTH_BY_QUARTER = new Map<Integer,Integer>{1 => 1, 2 => 1, 3 => 1, 4 => 2, 5 => 2, 6 => 2, 7 => 3, 8 => 3, 9 => 3, 10 => 4, 11 => 4, 12 => 4};
		Map<Integer,Integer> MONTH_BY_HALF_YEAR = new Map<Integer,Integer>{1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1, 6 => 1, 7 => 2, 8 => 2, 9 => 2, 10 => 2, 11 => 2, 12 => 2};
		Map<Integer,Integer> QUARTER_BY_HALF_YEAR_START_OFFSET = new Map<Integer,Integer>{1 => 0, 2 => -3, 3 => 0, 4 => -3};
		PERIOD_BY_DT_START = new Map<String,DateTime>{ 
			'YESTERDAY' => TODAY_DT_START.addDays(-1),
			'TODAY' => TODAY_DT_START,
			'TOMORROW' => TODAY_DT_START.addDays(1),
			'DAY' => TODAY_DT_START,
			'WEEK' => DateTime.newInstance(TODAY_DT_START.date().toStartOfWeek(), MIDNIGHT),
			'MONTH' =>  DateTime.newInstance(TODAY_DT_START.date().toStartOfMonth(), MIDNIGHT),
			'QUARTER' => DateTime.newInstance(TODAY_DT_START.year(), 1 + (3*(MONTH_BY_QUARTER.get(TODAY_DT_START.month()) - 1)), 1),
			'HALF_YEAR' => DateTime.newInstance(TODAY_DT_START.year(), 1 + (6*(MONTH_BY_HALF_YEAR.get(TODAY_DT_START.month()) - 1)), 1),
			'YEAR' => DateTime.newInstance(TODAY_DT_START.year(), 1, 1)
		};
		// During tests simulate a fiscal year that starts in September
		if (Test.isRunningTest())
		{
			PERIOD_BY_DT_START.putALL(new Map<String,DateTime>{ 'FISCAL_QUARTER' => DateTime.newInstance(Date.newInstance(1969, 12, 1), MIDNIGHT), 'FISCAL_HALF_YEAR' => DateTime.newInstance(Date.newInstance(1969, 9, 1), MIDNIGHT), 'FISCAL_YEAR' => DateTime.newInstance(Date.newInstance(1969, 9, 1), MIDNIGHT) });
		}
		else
		{
			for (Period p : [SELECT Type, Number, StartDate FROM Period WHERE StartDate <= TODAY AND EndDate >= TODAY AND (Type = 'Year' OR Type = 'Quarter')])
			{
				PERIOD_BY_DT_START.put('FISCAL_'+p.Type.toUpperCase(), DateTime.newInstance(p.StartDate, MIDNIGHT));
				if (p.Type.toUpperCase() == 'QUARTER')
					PERIOD_BY_DT_START.put('FISCAL_HALF_YEAR', DateTime.newInstance(p.StartDate.addMonths(QUARTER_BY_HALF_YEAR_START_OFFSET.get(p.Number)), MIDNIGHT));
			}
		}		
		PERIOD_BY_DT_END = new Map<String,DateTime>{
			'YESTERDAY' => PERIOD_BY_DT_START.get('YESTERDAY').addDays(1),
			'TODAY' => PERIOD_BY_DT_START.get('TODAY').addDays(1),
			'TOMORROW' => PERIOD_BY_DT_START.get('TOMORROW').addDays(1),
			'DAY' => PERIOD_BY_DT_START.get('DAY').addDays(1),
			'WEEK' => PERIOD_BY_DT_START.get('WEEK').addDays(7),
			'MONTH' => PERIOD_BY_DT_START.get('MONTH').addMonths(1),
			'QUARTER' => PERIOD_BY_DT_START.get('QUARTER').addMonths(3),
			'HALF_YEAR' => PERIOD_BY_DT_START.get('HALF_YEAR').addMonths(6),
			'YEAR' => PERIOD_BY_DT_START.get('YEAR').addYears(1),
			'FISCAL_QUARTER' => PERIOD_BY_DT_START.get('FISCAL_QUARTER').addMonths(3),
			'FISCAL_HALF_YEAR' => PERIOD_BY_DT_START.get('FISCAL_HALF_YEAR').addMonths(6),
			'FISCAL_YEAR' => PERIOD_BY_DT_START.get('FISCAL_YEAR').addYears(1)
		};
	}	

	/**
    * @author Scott Covert
    * @date 7/28/2016
    * @description Converts a given date literal to a datetime map
    * @param DateLiteral DateLiteral enum value
    * @return Map Datetime map representing the given date literal
    */
	public static Map<String,DateTime> dateLiteralToDateTimeMap(DateLiteral dl)
	{
		if ( dl.name().contains(N_ID) || dl.name().contains(AGO_ID) || dl.name().contains(DateService.FROM_NOW_ID))
			return dateLiteralToDateTimeMap(dl, 0);		
		return buildDateTimeMap(dl.name(),1);
	}

	/**
    * @author Scott Covert
    * @date 7/28/2016
    * @description Converts a given date literal to a datetime map
    * @param DateLiteral DateLiteral enum value
    * @param Integer Number of periods to apply when finding the range for the given date literal
    * @return Map Datetime map representing the given date literal
    */
	public static Map<String,DateTime> dateLiteralToDateTimeMap(DateLiteral dl, Integer numPeriods)
	{
		if ( !dl.name().contains(N_ID) && !dl.name().contains(AGO_ID) && !dl.name().contains(FROM_NOW_ID) )
			return dateLiteralToDateTimeMap(dl);
		if (numPeriods == null || numPeriods == 0)			
			throw new CustomException(UNSPECIFIED_N_ERROR_MESSAGE);
		return buildDateTimeMap(dl.name(), numPeriods);
	}

	/**
    * @author Scott Covert
    * @date 7/28/2016
    * @description Converts a given date literal to a date map
    * @param DateLiteral DateLiteral enum value
    * @return Map Datet map representing the given date literal
    */
	public static Map<String,Date> dateLiteralToDateMap(DateLiteral dl)
	{
		return dateTimeMapToDateMap( dateLiteralToDateTimeMap(dl) );
	}

	/**
    * @author Scott Covert
    * @date 7/28/2016
    * @description Converts a given date literal to a date map
    * @param DateLiteral DateLiteral enum value
    * @param Integer Number of periods to apply when finding the range for the given date literal
    * @return Map Date map representing the given date literal and period number
    */
	public static Map<String,Date> dateLiteralToDateMap(DateLiteral dl, Integer numPeriods)
	{
		return dateTimeMapToDateMap( dateLiteralToDateTimeMap(dl, numPeriods) );
	}

	/**
    * @author Scott Covert
    * @date 7/29/2016
    * @description Retrieves the start boundary for a given date literal
    * @param DateLiteral DateLiteral enum value
    * @return DateTime Start boundary for the given date literal
    */
	public static DateTime dateLiteralToStartDateTime(DateLiteral dl)
	{
		return dateLiteralToDateTimeMap(dl).get(START_KEY);
	}

	/**
    * @author Scott Covert
    * @date 7/29/2016
    * @description Retrieves the start boundary for the given date literal and number of periods
    * @param DateLiteral DateLiteral enum value
    * @param Integer Number of periods to apply when finding the range for the given date literal
    * @return DateTime Start boundary for the given date literal
    */
	public static DateTime dateLiteralToStartDateTime(DateLiteral dl, Integer numPeriods)
	{
		return dateLiteralToDateTimeMap(dl,numPeriods).get(START_KEY);
	}

	/**
    * @author Scott Covert
    * @date 7/29/2016
    * @description Retrieves the end boundary for a given date literal
    * @param DateLiteral DateLiteral enum value
    * @return DateTime End boundary for the given date literal
    */
	public static DateTime dateLiteralToEndDateTime(DateLiteral dl)
	{
		return dateLiteralToDateTimeMap(dl).get(END_KEY);
	}

	/**
    * @author Scott Covert
    * @date 7/29/2016
    * @description Retrieves the end boundary for the given date literal and number of periods
    * @param DateLiteral DateLiteral enum value
    * @param Integer Number of periods to apply when finding the range for the given date literal
    * @return DateTime End boundary for the given date literal
    */
	public static DateTime dateLiteralToEndDateTime(DateLiteral dl, Integer numPeriods)
	{
		return dateLiteralToDateTimeMap(dl,numPeriods).get(END_KEY);
	}

	/**
    * @author Scott Covert
    * @date 7/29/2016
    * @description Retrieves the start boundary for a given date literal
    * @param DateLiteral DateLiteral enum value
    * @return Date Start boundary for the given date literal
    */
	public static Date dateLiteralToStartDate(DateLiteral dl)
	{
		return dateLiteralToDateMap(dl).get(START_KEY);
	}

	/**
    * @author Scott Covert
    * @date 7/29/2016
    * @description Retrieves the start boundary for the given date literal and number of periods
    * @param DateLiteral DateLiteral enum value
    * @param Integer Number of periods to apply when finding the range for the given date literal
    * @return Date Start boundary for the given date literal
    */
	public static Date dateLiteralToStartDate(DateLiteral dl, Integer numPeriods)
	{
		return dateLiteralToDateMap(dl,numPeriods).get(START_KEY);
	}

	/**
    * @author Scott Covert
    * @date 7/29/2016
    * @description Retrieves the end boundary for a given date literal
    * @param DateLiteral DateLiteral enum value
    * @return Date End boundary for the given date literal
    */
	public static Date dateLiteralToEndDate(DateLiteral dl)
	{
		return dateLiteralToDateMap(dl).get(END_KEY);
	}

	/**
    * @author Scott Covert
    * @date 7/29/2016
    * @description Retrieves the end boundary for the given date literal and number of periods
    * @param DateLiteral DateLiteral enum value
    * @param Integer Number of periods to apply when finding the range for the given date literal
    * @return Date End boundary for the given date literal
    */
	public static Date dateLiteralToEndDate(DateLiteral dl, Integer numPeriods)
	{		
		return dateLiteralToDateMap(dl,numPeriods).get(END_KEY);
	}

	/**
    * @author Scott Covert
    * @date 7/28/2016
    * @description Returns a datetime map for a given date literal name and period number
    * @param String Date literal name
    * @param Integer Number of periods to apply when finding the range for the given date literal
    * @return Map Date map representing the given date literal and period number
    */
	private static Map<String,DateTime> buildDateTimeMap(String dlName, Integer numPeriods)
	{
		// LAST/NEXT_90_DAYS date literals are really just instances of the LAST/NEXT_N_DAYS date literals
		if ( dlName.contains(NINETY_ID) && dlName.contains(new List<String>(NAME_BY_OFFSET.keySet())[0]) )		
			return buildDateTimeMap(DateLiteral.LAST_N_DAYS.name(), 90);		
		else if ( dlName.contains(NINETY_ID) )					
			return buildDateTimeMap(DateLiteral.NEXT_N_DAYS.name(), 90);		
		// Special single day date literals
		for (String dayKey : DAY_PERIODS)
		{
			if ( dlName == dayKey )
			{
				return new Map<String,DateTime>{ START_KEY => convertDateTimeForDST( PERIOD_BY_DT_START.get(dayKey), START_KEY ), END_KEY => convertDateTimeForDST( DateTime.newInstance(PERIOD_BY_DT_END.get(dayKey).getTime()-1), END_KEY ) };
			}
		}
		// Iterating through the date literal identifier list allows for breaking down date literals into their component parts
		for (String dlId : DL_IDS)
		{
			Integer idIndex = dlName.indexOf(dlId);
			if ( idIndex != -1 )
			{
				Integer offset;
				String period;
				if ( dlId != AGO_ID && dlId != FROM_NOW_ID)
				{
					offset = NAME_BY_OFFSET.get(dlName.substring(0,idIndex));
					period = ( dlId == FISCAL_ID ) ? FISCAL_ID.substring(1,FISCAL_ID.length()) + dlName.substring(idIndex + dlId.length(), dlName.length()) : dlName.substring(idIndex + dlId.length(), dlName.length());					
				}
				else
				{
					period = dlName.substring(2, idIndex);
					// Offset is either one period back for AGO_ID or one period ahead for FROM_NOW_ID
					offset = (dlId == AGO_ID) ? -1 : 1;
				}
				if ( period.endsWith('S') )
					period = period.substring(0, period.length()-1);				
				return buildDateTimeMap(dlName,period,offset,numPeriods);	
			}
		}
		throw new CustomException('DateService Error: Unhandled date literal value!');		
		return null;
	}

	/**
    * @author Scott Covert
    * @date 7/28/2016
    * @description Returns a datetime map for a given date literal name, period type, offset, and period number
    * @param String Date literal name
    * @param String Period type
    * @param Integer Period offset
    * @param Integer Number of periods to apply when finding the range for the given date literal
    * @return Map Datetime map representing the given date literal name, period type, offset, and period number
    */
	private static Map<String,DateTime> buildDateTimeMap(String dlName, String periodType, Integer offset, Integer numPeriods)
	{
		DateTime startDT = PERIOD_BY_DT_START.get(periodType);
		// Backward-looking date literals will have end boundaries taken from the current period, except for 'AGO' date literals
		DateTime endDT = ( offset < 0 && !dlName.contains(AGO_ID) ) ? startDT : PERIOD_BY_DT_END.get(periodType);
		if (periodType == 'DAY')
		{
			if ( offset < 0 )
			{
				startDT = startDT.addDays(offset * numPeriods);
				// LAST_N_DAYS date literals are unique in that their end boundaries actually continue up to the current second
				endDT = ( dlName.contains(AGO_ID) ) ? endDT.addDays(offset * numPeriods) : ( Test.isRunningTest() ) ? Datetime.newInstance(TODAY_DT_START.date(),Time.newInstance(TEST_TIME.hour(), TEST_TIME.minute(), TEST_TIME.second(), TEST_TIME.millisecond())) : Datetime.newInstance(TODAY_DT_START.date(),Time.newInstance(System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond()));
			}				
			else if ( offset > 0 ){
				startDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addDays(numPeriods) : startDT.addDays(1);
				endDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addDays(1) : startDT.addDays(offset * numPeriods);				
			}
		}
		else if (periodType == 'WEEK')
		{
			if ( offset < 0 )
			{
				startDT = startDT.addDays(7 * offset * numPeriods);
				endDT = ( dlName.contains(AGO_ID) ) ? endDT.addDays(7 * offset * numPeriods) : endDT;
			}				
			else if ( offset > 0 ){
				startDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addDays(7 * numPeriods) : startDT.addDays(7);
				endDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addDays(7) : startDT.addDays(7 * offset * numPeriods);
			}
		}
		else if (periodType == 'MONTH')
		{
			if ( offset < 0 )
			{							
				startDT = startDT.addMonths(offset * numPeriods);
				endDT = ( dlName.contains(AGO_ID) ) ? endDT.addMonths(offset * numPeriods) : endDT;
			}
			else if ( offset > 0 ){
				startDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addMonths(numPeriods) : startDT.addMonths(1);
				endDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addMonths(1) : startDT.addMonths(offset * numPeriods);
			}
		}
		else if (periodType.contains('QUARTER'))
		{
			if ( offset < 0 ){
				startDT = startDT.addMonths(3 * offset * numPeriods);
				endDT = ( dlName.contains(AGO_ID) ) ? endDT.addMonths(3 * offset * numPeriods) : endDT;
			}
			else if ( offset > 0 ){
				startDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addMonths(3 * numPeriods) : startDT.addMonths(3);
				endDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addMonths(3) : startDT.addMonths(3 * offset * numPeriods);
			}
		}
		else if (periodType.contains('HALF_YEAR'))
		{
			if ( offset < 0 )
			{
				startDT = startDT.addMonths(6 * offset * numPeriods);
				endDT = ( dlName.contains(AGO_ID) ) ? endDT.addMonths(6 * offset * numPeriods) : endDT;
			}
			else if ( offset > 0 ){
				startDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addMonths(6 * numPeriods) : startDT.addMonths(6);
				endDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addMonths(6) : startDT.addMonths(6 * offset * numPeriods);
			}
		}
		else if (periodType.contains('YEAR'))
		{
			if ( offset < 0 )
			{
				startDT = startDT.addYears(offset * numPeriods);
				endDT = ( dlName.contains(AGO_ID) ) ? endDT.addYears(offset * numPeriods) : endDT;
			}
			else if ( offset > 0 ){
				startDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addYears(numPeriods) : startDT.addYears(1);
				endDT = ( dlName.contains(FROM_NOW_ID) ) ? startDT.addYears(1) : startDT.addYears(offset * numPeriods);
			}
		}		
		// LAST_N_DAYS date literals should not have their end boundaries tampered with, again because they actually continue up to the current second
		return new Map<String,DateTime>{ START_KEY => convertDateTimeForDST( startDT, START_KEY ), END_KEY => (periodType == 'DAY' && offset < 0 && !dlName.contains(AGO_ID) ) ? endDT : convertDateTimeForDST( DateTime.newInstance(endDT.getTime()-1), END_KEY ) };
	}

	/**
    * @author Scott Covert
    * @date 7/28/2016
    * @description Returns a datetime representation of a given datetime value, adusted for possible DST issues
    * @param DateTime Datetime value that may need adjusting due to possible DST issues
    * @param String Determines if the given datetime value is to represent a start or end boundary for the eventual datetime map
    * @return DateTime Datetime value adjusted for possible DST issues
    */
	@TestVisible private static DateTime convertDateTimeForDST(DateTime originalDT, String type)
	{		
		// Start boundaries should always be 12:00
		if (originalDT.hour()==1 && type == START_KEY)
			return originalDT.addHours(-1);
		else if (originalDT.hour()==23 && type == START_KEY)
			return originalDT.addHours(1);
		// End boundaries should always be 11:59
		if (originalDT.hour()==0 && type == END_KEY)
			return originalDT.addHours(-1);
		else if (originalDT.hour()==22 && type == END_KEY)
			return originalDT.addHours(1);
		return originalDT;
	}

	/**
    * @author Scott Covert
    * @date 7/28/2016
    * @description Converts a given datetime map into a datemap
    * @param Map Datetime map to be converted to a date map
    * @return Map Date map representing the given datetime map
    */
	private static Map<String,Date> dateTimeMapToDateMap(Map<String,DateTime> dateTimeMap)
	{
		return new Map<String,Date>{ START_KEY => dateTimeMap.get(START_KEY).date(), END_KEY => dateTimeMap.get(END_KEY).date() };
	}

}
/**
* @author Scott Covert
* @date 7/29/2016
* @description This class provides unit tests for DateService
*/
@isTest (seealldata=false)
public with sharing class DateServiceTest
{
	/** Reference date to be used during testing */
	private static final Date EPOCH_DATE = Date.newInstance(1970, 1, 1);
	/** 'N' value to be applied during tests */
	private static final Integer NUM_PERIODS = 3;
	/** Map of fiscal period by start date, which simulates a fiscal year that starts in September */
	private static final Map<String,Date> FISCAL_PERIOD_TYPE_BY_START_DATE = new Map<String,Date>{ 'FISCAL_QUARTER' => Date.newInstance(1969, 12, 1), 'FISCAL_HALF_YEAR' => Date.newInstance(1969, 9, 1), 'FISCAL_YEAR' => Date.newInstance(1969, 9, 1) };
	/** Fixed datetime boundary map to compare against DateService methods' results */
	private static Map<DateLiteral,Map<String,DateTime>> fixedDateTimeBoundaryMap;
	/** Static code block for initializing fixedDateTimeBoundaryMap */
	static {		
		fixedDateTimeBoundaryMap = new Map<DateLiteral,Map<String,DateTime>>
		{
			DateLiteral.YESTERDAY => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addDays(-1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.TODAY => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addDays(1), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.TOMORROW => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addDays(1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addDays(2), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_WEEK => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.toStartOfWeek().addDays(-7), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.toStartOfWeek(), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.THIS_WEEK => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.toStartOfWeek(), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.toStartOfWeek().addDays(7), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_WEEK => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.toStartOfWeek().addDays(7), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.toStartOfWeek().addDays(14), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_N_WEEKS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.toStartOfWeek().addDays(-7 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.toStartOfWeek(), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_N_WEEKS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.toStartOfWeek().addDays(7), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.toStartOfWeek().addDays(7*(1+NUM_PERIODS)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_WEEKS_AGO => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.toStartOfWeek().addDays(-7 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.toStartOfWeek().addDays(-7 * (NUM_PERIODS-1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_WEEKS_FROM_NOW => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.toStartOfWeek().addDays(7 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.toStartOfWeek().addDays(7 * (NUM_PERIODS+1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_MONTH => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(-1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.THIS_MONTH => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(1), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_N_MONTHS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(1+NUM_PERIODS), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_N_MONTHS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(-1 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_MONTHS_AGO => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(-1 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(-1 * (NUM_PERIODS-1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_MONTHS_FROM_NOW => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths((NUM_PERIODS+1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_MONTH => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(2), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_90_DAYS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addDays(-90), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => Datetime.newInstance(EPOCH_DATE, DateService.TEST_TIME)
			},
			DateLiteral.NEXT_90_DAYS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addDays(1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addDays(91), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_N_DAYS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addDays(-1 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => Datetime.newInstance(EPOCH_DATE, DateService.TEST_TIME)
			},
			DateLiteral.NEXT_N_DAYS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addDays(1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addDays(1+NUM_PERIODS), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_DAYS_AGO => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addDays(-1 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addDays(-1 * (NUM_PERIODS-1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_DAYS_FROM_NOW => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addDays(NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addDays((NUM_PERIODS+1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_QUARTER => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(-3), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.THIS_QUARTER => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(3), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_QUARTER => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(3), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(6), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_N_QUARTERS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(-3 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_N_QUARTERS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(3), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(3+(3*NUM_PERIODS)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_QUARTERS_AGO => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(-3 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(-3 * (NUM_PERIODS-1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_QUARTERS_FROM_NOW => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(3 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(3 * (NUM_PERIODS+1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_HALF_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(-6), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.THIS_HALF_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(6), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_HALF_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(6), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(12), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_HALF_YEARS_AGO => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(-6 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(-6 * (NUM_PERIODS-1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_HALF_YEARS_FROM_NOW => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(6 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(6 * (NUM_PERIODS+1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_N_HALF_YEARS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(-6 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_N_HALF_YEARS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addMonths(6), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addMonths(6+(6*NUM_PERIODS)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addYears(-1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.THIS_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addYears(1), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},	
			DateLiteral.NEXT_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addYears(1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addYears(2), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_YEARS_AGO => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addYears(-1 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addYears(-1 * (NUM_PERIODS-1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_YEARS_FROM_NOW => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addYears(NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addYears((NUM_PERIODS+1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_N_YEARS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addYears(-1 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE, Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_N_YEARS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(EPOCH_DATE.addYears(1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(EPOCH_DATE.addYears(1 + NUM_PERIODS), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},	
			DateLiteral.LAST_FISCAL_QUARTER => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER').addMonths(-3), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER'), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.THIS_FISCAL_QUARTER => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER'), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER').addMonths(3), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},	
			DateLiteral.NEXT_FISCAL_QUARTER => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER').addMonths(3), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER').addMonths(6), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_N_FISCAL_QUARTERS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER').addMonths(-3 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER'), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_N_FISCAL_QUARTERS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER').addMonths(3), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER').addMonths(3 + (3 * NUM_PERIODS)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_FISCAL_QUARTERS_AGO => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER').addMonths(-3 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER').addMonths(-3 * (NUM_PERIODS-1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_FISCAL_QUARTERS_FROM_NOW => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER').addMonths(3 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_QUARTER').addMonths(3 * (NUM_PERIODS+1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},	
			DateLiteral.LAST_FISCAL_HALF_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR').addMonths(-6), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR'), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.THIS_FISCAL_HALF_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR'), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR').addMonths(6), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_FISCAL_HALF_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR').addMonths(6), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR').addMonths(12), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_N_FISCAL_HALF_YEARS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR').addMonths(-6 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR'), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_N_FISCAL_HALF_YEARS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR').addMonths(6), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR').addMonths(6 + (6 * NUM_PERIODS)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_FISCAL_HALF_YEARS_AGO => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR').addMonths(-6 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR').addMonths(-6 * (NUM_PERIODS-1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_FISCAL_HALF_YEARS_FROM_NOW => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR').addMonths(6 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_HALF_YEAR').addMonths(6 * (NUM_PERIODS+1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},	
			DateLiteral.LAST_FISCAL_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR').addYears(-1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR'), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.THIS_FISCAL_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR'), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR').addYears(1), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},	
			DateLiteral.NEXT_FISCAL_YEAR => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR').addYears(1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR').addYears(2), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.LAST_N_FISCAL_YEARS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR').addYears(-1 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR'), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.NEXT_N_FISCAL_YEARS => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR').addYears(1), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR').addYears(1 + NUM_PERIODS), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_FISCAL_YEARS_AGO => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR').addYears(-1 * NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR').addYears(-1 * (NUM_PERIODS-1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			},
			DateLiteral.N_FISCAL_YEARS_FROM_NOW => new Map<String,DateTime>
			{
				DateService.START_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR').addYears(NUM_PERIODS), Time.newInstance(0,0,0,0)), DateService.START_KEY),
				DateService.END_KEY => DateService.convertDateTimeForDST( Datetime.newInstance(Datetime.newInstance(FISCAL_PERIOD_TYPE_BY_START_DATE.get('FISCAL_YEAR').addYears((NUM_PERIODS+1)), Time.newInstance(0,0,0,0)).getTime()-1), DateService.END_KEY)
			}
		};
	}

	/** 
	* @author Scott Covert
	* @date 7/29/2016
	* @description This method tests the DateService methods
	*/
	@isTest (seealldata=false)
	public static void testDateService() {

		if (!TestVerificationService.ShouldExecute('DateServiceTest.testDateService')) return;						

		Map<String,DateTime> dateTimeBoundaryMap;
		Boolean errorThrown = false;
		String errorMessage;

		// Test all date literals are handled properly
		for (DateLiteral dl : DateLiteral.values())
		{
			Map<String,Date> dateBoundaryMap;
			DateTime startBoundaryDateTime;
			DateTime endBoundaryDateTime;
			Date startBoundaryDate;
			Date endBoundaryDate;
		    if ( dl.name().contains(DateService.N_ID) || dl.name().contains(DateService.AGO_ID) || dl.name().contains(DateService.FROM_NOW_ID))
		    {
		        dateTimeBoundaryMap = DateService.dateLiteralToDateTimeMap(dl, NUM_PERIODS);
		        startBoundaryDateTime = DateService.dateLiteralToStartDateTime(dl, NUM_PERIODS);
				endBoundaryDateTime = DateService.dateLiteralToEndDateTime(dl, NUM_PERIODS);
		        dateBoundaryMap = DateService.dateLiteralToDateMap(dl, NUM_PERIODS);
		        startBoundaryDate = DateService.dateLiteralToStartDate(dl, NUM_PERIODS);
				endBoundaryDate = DateService.dateLiteralToEndDate(dl, NUM_PERIODS);
		    }
		    else
		    {
		    	dateTimeBoundaryMap = DateService.dateLiteralToDateTimeMap(dl);
		    	startBoundaryDateTime = DateService.dateLiteralToStartDateTime(dl);
				endBoundaryDateTime = DateService.dateLiteralToEndDateTime(dl);
		    	dateBoundaryMap = DateService.dateLiteralToDateMap(dl);
		    	startBoundaryDate = DateService.dateLiteralToStartDate(dl);
				endBoundaryDate = DateService.dateLiteralToEndDate(dl);
		    }		    		        
		    System.assertEquals(fixedDateTimeBoundaryMap.get(dl), dateTimeBoundaryMap, 'DateService Error: Returned boundary datetime map does not equal expected value for ' + dl.name());
		    System.assertEquals(fixedDateTimeBoundaryMap.get(dl).get(DateService.START_KEY), startBoundaryDateTime, 'DateService Error: Returned start boundary datetime does not equal expected value for ' + dl.name());
		    System.assertEquals(fixedDateTimeBoundaryMap.get(dl).get(DateService.END_KEY), endBoundaryDateTime, 'DateService Error: Returned end boundary datetime does not equal expected value for ' + dl.name());
		    System.assertEquals(new Map<String,Date>{ DateService.START_KEY => fixedDateTimeBoundaryMap.get(dl).get(DateService.START_KEY).date() , DateService.END_KEY => fixedDateTimeBoundaryMap.get(dl).get(DateService.END_KEY).date() }, dateBoundaryMap, 'DateService Error: Returned boundary date map does not equal expected value for ' + dl.name());
		    System.assertEquals(fixedDateTimeBoundaryMap.get(dl).get(DateService.START_KEY).date(), startBoundaryDate, 'DateService Error: Returned start boundary date does not equal expected value for ' + dl.name());
		    System.assertEquals(fixedDateTimeBoundaryMap.get(dl).get(DateService.END_KEY).date(), endBoundaryDate, 'DateService Error: Returned end boundary date does not equal expected value for ' + dl.name());
		}

		// Test errors are properly thrown	
		try {
			dateTimeBoundaryMap = DateService.dateLiteralToDateTimeMap(DateLiteral.N_DAYS_AGO);
		}
		catch(Exception e) {
			errorThrown = true;
			errorMessage = e.getMessage(); 
		}
		System.assertEquals(true, errorThrown);
		System.assertEquals(DateService.UNSPECIFIED_N_ERROR_MESSAGE, errorMessage);
		
		errorThrown = false;
		try {
			dateTimeBoundaryMap = DateService.dateLiteralToDateTimeMap(DateLiteral.N_DAYS_FROM_NOW);	
		}
		catch(Exception e) {
			errorThrown = true;
			errorMessage = e.getMessage();
		}
		System.assertEquals(true, errorThrown);
		System.assertEquals(DateService.UNSPECIFIED_N_ERROR_MESSAGE, errorMessage);
		
		// Confirm superfluous 'N' values are ignored
		System.assertEquals(DateService.dateLiteralToDateTimeMap(DateLiteral.THIS_MONTH), DateService.dateLiteralToDateTimeMap(DateLiteral.THIS_MONTH, 100));
		
	}
}
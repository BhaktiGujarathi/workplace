/*
* Name : Pavithra Gajendra
* Date : 01/19/2017
* Purpose : To have all the constants of the org
* Company : NSI Gulf
* 
*/
public class DAMAC_Constants{

    public static final String PC_PROFILE = 'Property Consultant';
    public static final String RECEPTIONIST_PROFILE = 'Receptionist';
    public static final String LEAD_MANAGEMENT_TEAM_PROFILE = 'Lead Management Team';
    public static final String PC_NOTIFICATION_TEMPLATE = 'Send_Notification_to_Existing_PC';
    public static final String NURTURING_STATUS = 'Nurturing';
    public static final String WALK_IN_STATUS = 'Walk in';
    public static final String STANDS_SOURCE = 'Stands';
    public static final String EVENTS_ROADSHOW_SOURCE = 'Events / Roadshows/ Sales Trip';
    public static final String INQUIRY_ACTIVE_STATUS = 'Active';
    public static final String INQUIRY_NEW_STATUS = 'New';
    public static final String EVENT_COMPLETED_STATUS = 'Completed'; 
    public static final String EVENT_PLANNED_STATUS = 'Planned';
    public static final String LOCATION_UNIT_RT = 'Unit';
    public static final String DEFAULT_LANGUAGE = 'English';
    public static final String INQUIRY_CIL_RT = 'CIL';
    public static final String INQUIRY_RT = 'Inquiry';
    public static final String LOCATION_BUILDING_RT = 'Building';
    public static final String LOCATION_FLOOR_RT = 'Floor';
    public static final String LOCATION_TYPE_FLOOR = 'Floor';
    public static final String LOCATION_TYPE_BUILDING = 'Building';
    public static final String LOCATION_TYPE_OFFICE = 'OFFICE';
    public static final String LOCATION_TYPE_UNIT = 'Unit';
    public static final String DAMAC_QUEUE = 'DAMAC_Queue';
    public static final String USER_TYPE_OWNER = 'User';
    public static final String AGENT_REFERAL_STATUS = 'Agent Referral';
    public static final String CUSTOMER_REFERAL_STATUS = 'Customer Referral';
    public static final String BUDGET_CONSTRAINT_STATUS = 'Budget Constraint';
    public static final String PRODUCT_CONSTRAINT_STATUS = 'Product Constraint';
    public static final String NOT_LEAD_STATUS ='Not a lead';
    public static final String POTENTIAL_AGENT_STATUS ='Potential Agent';
    public static final String UNREACHABLE_NOTRESPONDING_STATUS = 'Unreachable - Not responding';
    public static final String CUSTOMER_COMMUNITY_AUTH_OFFICER = 'Customer Community - Auth Officer';
    public static final String CUSTOMER_COMMUNITY_OWNER = 'Customer Community - Owner';
    public static final String NURTURING_QUEUE = 'Nurturing_Queue';
    public static final String CIL_RT = 'CIL';
    public static final String DOS_ROLE = 'DOS';
    public static final String HOS_ROLE = 'HOS';
    public static final String LEAD_MANAGEMENT_QUEUE = 'Lead_Management_Queue';
    public static final String INVENTORY_AREA_RANGE = 'Inventory Area Range';
    public static final String INVENTORY_STEP = 'Inventory Step';
    public static final String COMMENTS_FOR_BLACKLISTING = 'Submitting agency for Blacklisting.';
    public static final String COMMENTS_FOR_UNBLACKLISTING = 'Submitting agency for Un-blacklisting.';
    public static final String COMMENTS_FOR_TERMINATION = 'Submitting agency for Termination.';
    public static final String COMMENTS_FOR_UNTERMINATION = 'Submitting agency for UnTermination.';
    public static final String PROSPECTING_BY_PC_SOURCE = 'Prospecting';
    public static final String PROMOTERS_BY_PC_SOURCE = 'Promoters';
    public static final String INQUIRY_SCORE_DEFAULT = 'Hot';
    public static final String[] TASK_STATUS = new List<String>{'Completed','Not Started','In Progress','Deferred','Waiting on someone else'};
    public static final String ACTIVE_TASK_STATUS = 'Completed,Not Started,In Progress,Deferred,Waiting on someone else';
    public static Boolean isExecutingFromReshufflingBatch = false;
    public static Boolean IS_BYPASS_TRIGGER = false;
    public static Boolean skip_InventoryTrigger = false;
    public static Boolean skip_AttacmentTrigger = false;
    public static Set<String> userExtForBreak = new Set<String>();//to Strore the User's ext numbers
    public static Set<String> inquirySourceToInclude = new Set<String>{ 'Stands', 'Conventional', 'Digital', 'Social', 'Events', 'Database', 
    																	'Direct', 'Walk in', 'Roadshow/Exhibition', 'Chat', 'Call Center', 
    																	'Promoters', 'DAMAC Website'};
}
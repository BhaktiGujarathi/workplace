<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Bizfi_Decline_Email</fullName>
        <description>Bizfi Decline Email</description>
        <protected>false</protected>
        <recipients>
            <field>McaApp__Owner_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sys_Admin_Email_Templates/Bizfi_Decline_Email</template>
    </alerts>
    <alerts>
        <fullName>Closed_Lost_Funding_Source</fullName>
        <ccEmails>mcp@bizfi.com</ccEmails>
        <description>Closed Lost Funding Source</description>
        <protected>false</protected>
        <recipients>
            <field>McaApp__Owner_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sys_Admin_Email_Templates/MCP_Email</template>
    </alerts>
    <alerts>
        <fullName>Email_Funding_Desk_for_Submission_to_be_Reviewed</fullName>
        <description>Email Funding Desk for Submission to be Reviewed</description>
        <protected>false</protected>
        <recipients>
            <recipient>Funding_Desk_Manager</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>creilly@bizfi.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ggiacopino@bizfi.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jrodriguez@bizfi.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jurquijo@bizfi.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kislar@bizfi.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>loconnor@bizfi.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sbrutus@bizfi.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Submission_Ready_for_Review</template>
    </alerts>
    <alerts>
        <fullName>Email_when_Opportunity_stage_application_missing_info</fullName>
        <description>Email when Opportunity stage application missing info</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Email_For_application_missing_info</template>
    </alerts>
    <alerts>
        <fullName>Email_when_Opportunity_stage_approved</fullName>
        <description>Email when Opportunity stage approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Email_for_application_approved</template>
    </alerts>
    <alerts>
        <fullName>Email_when_Opportunity_stage_declined</fullName>
        <description>Email when Opportunity stage declined</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Email_for_Appliction_Declined</template>
    </alerts>
    <alerts>
        <fullName>MCP_Decline_Email_with_Record_Data</fullName>
        <ccEmails>Bizfi@robot.zapier.com</ccEmails>
        <description>MCP Decline Email with Record Data</description>
        <protected>false</protected>
        <recipients>
            <recipient>klee@bizfi.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sbroman1@bizfi.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sys_Admin_Email_Templates/MCP_Decline_Email</template>
    </alerts>
    <alerts>
        <fullName>McaApp__Email_Open_Stips_to_Owner</fullName>
        <description>Email Open Stips to Owner</description>
        <protected>false</protected>
        <recipients>
            <field>McaApp__Owner_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>McaApp__MCA_Template_Folder/McaApp__Email_Stips</template>
    </alerts>
    <alerts>
        <fullName>New_Opportunity_Owner_Assignment</fullName>
        <description>New Opportunity Owner Assignment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Email_when_opportunity_owner_is_changed</template>
    </alerts>
    <alerts>
        <fullName>Winning_Lead_Duplicated_Opportunity_Closer</fullName>
        <description>Winning Lead - Duplicated Opportunity Closer</description>
        <protected>false</protected>
        <recipients>
            <recipient>Closer_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Lead_Duplicated_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Winning_Lead_Duplicated_Opportunity_Opener</fullName>
        <description>Winning Lead - Duplicated Opportunity Opener</description>
        <protected>false</protected>
        <recipients>
            <recipient>Opener_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Lead_Duplicated_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Winning_Lead_Duplicated_Opportunity_Renewal</fullName>
        <description>Winning Lead - Duplicated Opportunity Renewal</description>
        <protected>false</protected>
        <recipients>
            <recipient>Renewals_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Lead_Duplicated_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Winning_Opportunity_Duplicated_Opportunity_Closer</fullName>
        <description>Winning Opportunity - Duplicated Opportunity Closer</description>
        <protected>false</protected>
        <recipients>
            <recipient>Closer_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Opportunity_Duplicated_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Winning_Opportunity_Duplicated_Opportunity_Opener</fullName>
        <description>Winning Opportunity - Duplicated Opportunity Opener</description>
        <protected>false</protected>
        <recipients>
            <recipient>Opener_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Opportunity_Duplicated_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Winning_Opportunity_Duplicated_Opportunity_Renewal</fullName>
        <description>Winning Opportunity - Duplicated Opportunity Renewal</description>
        <protected>false</protected>
        <recipients>
            <recipient>Renewals_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Opportunity_Duplicated_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>X20_Paid_in_Renewals</fullName>
        <ccEmails>vpapa@bizfi.com</ccEmails>
        <description>20% Paid in - Renewals</description>
        <protected>false</protected>
        <recipients>
            <field>McaApp__Owner_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>renewals@bizfi.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Bizfi_Drip_Templates/X20_2</template>
    </alerts>
    <alerts>
        <fullName>X40_Paid_In_Renewal</fullName>
        <ccEmails>vpapa@bizfi.com</ccEmails>
        <description>40% Paid In - Renewal</description>
        <protected>false</protected>
        <recipients>
            <field>McaApp__Owner_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>renewals@bizfi.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Bizfi_Drip_Templates/X40_2</template>
    </alerts>
    <alerts>
        <fullName>X60_Paid_In_Renewal</fullName>
        <ccEmails>vpapa@bizfi.com</ccEmails>
        <description>60% Paid In - Renewal</description>
        <protected>false</protected>
        <recipients>
            <field>McaApp__Owner_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>renewals@bizfi.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Bizfi_Drip_Templates/Renewal_60</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approved_Date_Time</fullName>
        <field>Approved_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Approved Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Agreement_Sent</fullName>
        <field>Agreement_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Check Agreement Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Agreement_Signed</fullName>
        <field>Agreement_Signed__c</field>
        <literalValue>1</literalValue>
        <name>Check Agreement Signed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Partner_Deal</fullName>
        <field>Partner_Deal__c</field>
        <literalValue>1</literalValue>
        <name>Check Partner Deal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Underwriting</fullName>
        <field>Underwriting__c</field>
        <literalValue>1</literalValue>
        <name>Check Underwriting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Closed_Lost_Funding_Source_Date_Time</fullName>
        <field>Closed_Lost_Funding_Source_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Closed Lost - Funding Source Date /Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Closed_Lost_Merchant_DateTime_on_Opp</fullName>
        <field>Closed_Lost_Merchant_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Closed Lost - Merchant DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Estimated_Paid</fullName>
        <field>Estimate_Paid__c</field>
        <formula>Estimated_Paid__c</formula>
        <name>Estimated % Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Opportunity_Assign_Opportunity_Name</fullName>
        <description>Updates the Opportunity name in the &apos;Account Name - Created Date - count of the Opportunity for that Account&apos; format.</description>
        <field>Name</field>
        <formula>Account.Name &amp; &apos; - &apos; 
&amp; (TEXT(MONTH(DATEVALUE(CreatedDate)))+&quot;/&quot; +TEXT(DAY(DATEVALUE(CreatedDate)))+&quot;/&quot; +TEXT(YEAR(DATEVALUE(CreatedDate)))) &amp; &apos; - &apos;
&amp;  TEXT(Account.McaApp__Count_Of_Opportunities__c +1)</formula>
        <name>Opportunity&gt; Assign Opportunity Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Opportunity_set_Credit_Card_Sales</fullName>
        <field>McaApp__Credit_Card_Sales__c</field>
        <formula>Account.McaApp__Monthly_CC_Avg_All__c</formula>
        <name>Opportunity &gt; set Credit Card Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Set_Closed_Date_when_Closed</fullName>
        <field>CloseDate</field>
        <formula>IF( NOT(ISBLANK( McaApp__Date_Funded__c)), McaApp__Date_Funded__c,today())</formula>
        <name>Set Closed Date when Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Set_Funding_Amount_To_Amount</fullName>
        <field>Amount</field>
        <formula>McaApp__Funding_Amount__c</formula>
        <name>Set Funding Amount To Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Set_Opportunity_Stage</fullName>
        <field>StageName</field>
        <literalValue>Application Sent</literalValue>
        <name>Set Opportunity Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Set_Opportunity_Stage_Application_Sent</fullName>
        <field>StageName</field>
        <literalValue>Application Sent</literalValue>
        <name>Set Opportunity Stage: Application Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__UpdateClosedDateToFundedDate</fullName>
        <description>Update the Opportunity Closed Date to Funded Date when Opportunity Stage = Funded</description>
        <field>CloseDate</field>
        <formula>McaApp__Date_Funded__c</formula>
        <name>UpdateClosedDateToFundedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__UpdateContractRequestedDate</fullName>
        <field>McaApp__Contract_Requested_Date__c</field>
        <formula>today()</formula>
        <name>UpdateContractRequestedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__UpdateGrossMonthlySales</fullName>
        <description>Update the Gross Monthly Sales on creation of Opportunity</description>
        <field>McaApp__Gross_monthly_Sales__c</field>
        <formula>Account.McaApp__Gross_monthly_Sales__c</formula>
        <name>UpdateGrossMonthlySales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_App_Received</fullName>
        <field>McaApp__App_Received__c</field>
        <literalValue>1</literalValue>
        <name>Update: App Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_App_Received_Date</fullName>
        <field>McaApp__App_Received_Date__c</field>
        <formula>IF(ISBLANK( McaApp__App_Received_Date__c ), Today(),McaApp__App_Received_Date__c)</formula>
        <name>Update: App Received Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_App_Sent</fullName>
        <field>McaApp__App_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Update: App Sent = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_App_Sent_Date</fullName>
        <field>McaApp__App_Sent_Date__c</field>
        <formula>IF(ISBLANK( McaApp__App_Sent_Date__c ), Today(),McaApp__App_Sent_Date__c)</formula>
        <name>Update: App Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Approved</fullName>
        <field>McaApp__Approved__c</field>
        <literalValue>1</literalValue>
        <name>Update: Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Approved_Date</fullName>
        <field>McaApp__Approved_Date__c</field>
        <formula>IF(ISBLANK(McaApp__Approved_Date__c), Today(),McaApp__Approved_Date__c)</formula>
        <name>Update: Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Contract_Signed</fullName>
        <field>McaApp__Contract_Signed__c</field>
        <literalValue>1</literalValue>
        <name>Update: Contract Signed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Contract_Signed_Date</fullName>
        <field>McaApp__Date_Contract_Signed__c</field>
        <formula>IF(ISBLANK( McaApp__Date_Contract_Signed__c), today(),McaApp__Date_Contract_Signed__c)</formula>
        <name>Update: Contract Signed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Funded_Date_Today</fullName>
        <field>McaApp__Date_Funded__c</field>
        <formula>IF( ISBLANK(McaApp__Date_Funded__c), Today(),McaApp__Date_Funded__c)</formula>
        <name>Update: Funded Date = Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Funded_True</fullName>
        <field>McaApp__Funded__c</field>
        <literalValue>1</literalValue>
        <name>Update: Funded = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Next_Step_Due_Date</fullName>
        <field>McaApp__Next_Step_Due_Date__c</field>
        <formula>Today() + 1</formula>
        <name>Update Next Step Due Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Opp_Amount_with_Amount_Requested</fullName>
        <field>Amount</field>
        <formula>McaApp__Amount_Requested__c</formula>
        <name>Update Opp Amount with Amount Requested</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Opp_Description_with_Cont_Desc</fullName>
        <field>Description</field>
        <formula>McaApp__Owner_1__r.Description</formula>
        <name>Update Opp Description with Cont Desc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Opp_Type_to_New_Biz_Upon_Convert</fullName>
        <field>Type</field>
        <literalValue>New Customer</literalValue>
        <name>Update Opp Type to New Biz Upon Convert</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Type_New_Deal</fullName>
        <field>Type</field>
        <literalValue>New Deal</literalValue>
        <name>Update: Type = New Deal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_custom_opp_description_field</fullName>
        <field>Description</field>
        <formula>McaApp__MapFromLeadDescription__c</formula>
        <name>Update custom opp description field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__updatelaststagechangedate</fullName>
        <description>Updates the &apos;Last Stage Change Date&apos; with current date when stage changes</description>
        <field>McaApp__Last_Stage_Change_Date__c</field>
        <formula>IF( OR(ISCHANGED(  StageName  ), ISNEW() ), NOW()  ,  McaApp__Last_Stage_Change_Date__c )</formula>
        <name>updateLastStageChangeDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__updateopportunitynextstep</fullName>
        <description>Updates the Opportunity Next Step according to the Opportunity Stage value</description>
        <field>NextStep</field>
        <formula>CASE( StageName , &apos;Prospecting&apos;, &apos;Send out Application&apos;,
&apos;Application Sent&apos;,&apos;Follow up with merchant for signed App&apos;,
&apos;Application In&apos;, &apos;Submit to Banks&apos;,
&apos;Application Missing Info&apos;,&apos;Follow up on missing info&apos;,
&apos;Underwriting&apos;,&apos;Follow up with Banks to get Approval/Decline&apos;,
&apos;Approved&apos;,&apos;Present offers to Merchant&apos;,
&apos;Declined&apos;,&apos;Declined, send to different bank?&apos;,
&apos;Agreement Requested&apos;,&apos;Get Contract from Bank&apos;,
&apos;Agreement Sent&apos;,&apos;Follow up with Merchant for Signed Contract&apos;,
&apos;Agreement Signed&apos;,&apos;Fund the deal&apos;,
&apos;Funded&apos;,&apos;Monitor for renewal&apos;,
&apos;Closed Lost&apos;,&apos;&apos;,
&apos;Renewal Prospecting&apos;,&apos;Contact Merchant for Renewal&apos;,
&apos;Renewal Requested&apos;,&apos;Begin renewal review process&apos;,
&apos;&apos;)</formula>
        <name>UpdateOpportunityNextStep</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NDB_Whole_Number</fullName>
        <field>McaApp__NDBs_avg__c</field>
        <formula>CEILING( McaApp__NDBs_avg__c )</formula>
        <name>NDB Whole Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NSF_Whole_Numbers</fullName>
        <field>McaApp__NSFs_avg__c</field>
        <formula>CEILING(No_of_NSFs__c)</formula>
        <name>NSF Whole Numbers</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opener_Checkbox</fullName>
        <field>Opener_Package__c</field>
        <literalValue>1</literalValue>
        <name>Opener Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Campaign_Source</fullName>
        <field>Campaign_Source__c</field>
        <formula>Account.Campaign_Source__c</formula>
        <name>Populate Campaign Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Close_Date</fullName>
        <description>Auto Populates Close Date.  Currently defaults to Funded Date or Today plus 14 days.  Revisit for future enhancement - vary number of days added dependent on Stage selected.</description>
        <field>CloseDate</field>
        <formula>IF(ISNULL(CloseDate),IF(ISPICKVAL(StageName,&quot;Funded&quot;), McaApp__Date_Funded__c, Today()+14),(CloseDate+0))</formula>
        <name>Populate Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reason_Lost</fullName>
        <field>McaApp__Reason_Lost__c</field>
        <literalValue>Timed Out</literalValue>
        <name>Reason Lost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reason_Lost_to_Timed_Out</fullName>
        <field>McaApp__Reason_Lost__c</field>
        <literalValue>Timed Out</literalValue>
        <name>Reason Lost to Timed Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stage</fullName>
        <field>StageName</field>
        <literalValue>Declined</literalValue>
        <name>Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stage_Update_to_Declined</fullName>
        <field>StageName</field>
        <literalValue>Declined</literalValue>
        <name>Stage Update to Declined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submission_Approved_DTS</fullName>
        <field>Submission_Approved_DTS__c</field>
        <formula>NOW()</formula>
        <name>Submission Approved DTS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Opener_Package</fullName>
        <field>Opener_Package__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Opener Package</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Agreement_Request_DateTime_on_Opp</fullName>
        <field>Agreement_Requested_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Agreement Request DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Agreement_Sent_DateTime_on_Opp</fullName>
        <field>Agreement_Sent_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Agreement Sent DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Agreement_Signed_DateTime_on_Opp</fullName>
        <field>Agreement_Signed_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Agreement Signed DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Annual_Revenue</fullName>
        <field>AnnualRevenue</field>
        <formula>Gross_Annual_Sales__c</formula>
        <name>Update Annual Revenue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Application_In_DateTime_on_Opp</fullName>
        <field>Application_In_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Application In DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Application_Missing_Info_DateTime</fullName>
        <field>Application_Missing_Info_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Application Missing Info DateTime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Application_Sent_DateTime_on_Opp</fullName>
        <field>Application_Sent_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Application Sent DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closed_Lost_DateTime_on_Opp</fullName>
        <field>Closed_Lost_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Closed Lost DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closed_Lost_Duplicate_DT_on_Opp</fullName>
        <field>Closed_Lost_Duplicate_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Closed Lost Duplicate DT  on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closed_Renewed_DateTime_on_Opp</fullName>
        <field>Closed_Renewed_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Closed/Renewed DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Decline_Email_Sent_Data_Time</fullName>
        <field>Decline_Email_Sent_Date_Time__c</field>
        <formula>now()</formula>
        <name>Update Decline Email Sent Data/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Declined_DateTime_on_Opp</fullName>
        <field>Declined_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Declined DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Estimated_Paid</fullName>
        <field>Estimate_Paid__c</field>
        <formula>Estimated_Paid__c</formula>
        <name>Update Estimated % Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Funded_Account</fullName>
        <field>Under_10500__c</field>
        <literalValue>1</literalValue>
        <name>Update Funded Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Funded_DateTime_on_Opp</fullName>
        <field>Funded_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Funded DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Gross_Annual_Sales</fullName>
        <field>Gross_Annual_Sales__c</field>
        <formula>Account.AnnualRevenue</formula>
        <name>Update Gross Annual Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Record_type_to_MCAApp</fullName>
        <field>RecordTypeId</field>
        <lookupValue>McaApp__Legacy_Funding_Opportunity</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Opportunity Record type to MCAApp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Type_to_Refinance</fullName>
        <field>Type</field>
        <literalValue>Refinance</literalValue>
        <name>Update Opportunity Type to Refinance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Paid_Off_Time</fullName>
        <field>Paid_Off_Time__c</field>
        <formula>IF ( AND(X20_Term_Completed_Date__c &lt;= TODAY(), X40_Term_Completed_Date__c &gt; TODAY()), &apos;20%&apos;, 
IF ( AND(X40_Term_Completed_Date__c &lt;= TODAY(), X60_Term_Completed_Date__c &gt; TODAY()), &apos;40%&apos;, 
IF ( AND(X60_Term_Completed_Date__c &lt;= TODAY(), X80_Term_Completed_Date__c &gt; TODAY()), &apos;60%&apos;, 
IF ( AND(X80_Term_Completed_Date__c &lt;= TODAY(), X100_Term_Completed_Date__c &gt; TODAY()), &apos;80%&apos;, 
IF ( AND(X100_Term_Completed_Date__c &lt;= TODAY(), Paid_Off_60_Days_Ago__c == false), &apos;Under 60 Days&apos;,
IF ( AND(X100_Term_Completed_Date__c &lt;= TODAY(), Paid_Off_60_Days_Ago__c == true), &apos;Over 60 Days&apos;, 
IF ( X20_Term_Completed_Date__c &gt; TODAY(), &apos;0%&apos;,NULL) 
) 
) 
) 
) 
)
)</formula>
        <name>Update Paid Off Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Prospecting_Date_Time_field_Opp</fullName>
        <field>Prospecting_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Prospecting Date/Time field Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Renewal_Prospect_DateTime_on_Opp</fullName>
        <field>Renewal_Prospecting_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Renewal Prospect DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Renewal_Requested_DateTime_on_Opp</fullName>
        <field>Renewal_Requested_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Renewal Requested DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Underwriting_DateTime_on_Opp</fullName>
        <field>Underwriting_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Underwriting DateTime on Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Agreement_Sent</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/propsnt</endpointUrl>
        <fields>Id</fields>
        <fields>OwnerId</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>vpapa@bizfi.com</integrationUser>
        <name>Agreement Sent</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Agreement_Sent_KPI</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/propsnt</endpointUrl>
        <fields>Id</fields>
        <fields>OwnerId</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>vpapa@bizfi.com</integrationUser>
        <name>Agreement Sent KPI</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Agreement_Signed</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/ctrctrev</endpointUrl>
        <fields>Id</fields>
        <fields>OwnerId</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>vpapa@bizfi.com</integrationUser>
        <name>Agreement Signed</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>App_In</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/qualopp</endpointUrl>
        <fields>Id</fields>
        <fields>OwnerId</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>vpapa@bizfi.com</integrationUser>
        <name>App In</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>App_Missing_Info</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/apptsheld</endpointUrl>
        <fields>Id</fields>
        <fields>OwnerId</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>vpapa@bizfi.com</integrationUser>
        <name>App Missing Info</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>App_Sent_KPI</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/ndsanly</endpointUrl>
        <fields>Id</fields>
        <fields>OwnerId</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>vpapa@bizfi.com</integrationUser>
        <name>App Sent KPI</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Contract_Review</fullName>
        <apiVersion>34.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/ctrctrev</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>klee@bizfi.com</integrationUser>
        <name>Contract Review</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Funded_Dollars_KPI</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/annual_con_val</endpointUrl>
        <fields>Id</fields>
        <fields>McaApp__Funding_Amount__c</fields>
        <fields>OwnerId</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>vpapa@bizfi.com</integrationUser>
        <name>Funded Dollars KPI</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Funded_KPI</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/oppwon</endpointUrl>
        <fields>Id</fields>
        <fields>OwnerId</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>vpapa@bizfi.com</integrationUser>
        <name>Funded KPI</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Opener_Subs</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/apptsset</endpointUrl>
        <fields>Id</fields>
        <fields>Submitted_By__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>vpapa@bizfi.com</integrationUser>
        <name>Opener Subs</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Opportunity_Won</fullName>
        <apiVersion>34.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/oppwon</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>klee@bizfi.com</integrationUser>
        <name>Opportunity Won</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Proposal_Sent</fullName>
        <apiVersion>34.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/propsnt</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>klee@bizfi.com</integrationUser>
        <name>Proposal Sent</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>20%25 Paid In Email Drip</fullName>
        <actions>
            <name>X20_Paid_in_Renewals</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.X20_Term_Completed_Date__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>If the 20% paid in date is equal to today, then an email will go out to the contact(s) on the opportunity.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>40%25 Paid In Email Drip</fullName>
        <actions>
            <name>X40_Paid_In_Renewal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.X40_Term_Completed_Date__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>If the 40% paid in date is equal to today, then an email will go out to the contact(s) on the opportunity.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>60%25 Paid In Email Drip</fullName>
        <actions>
            <name>X60_Paid_In_Renewal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.X60_Term_Completed_Date__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>If the 60% paid in date is equal to today, then an email will go out to the contact(s) on the opportunity.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Check for Current Lead Partners</fullName>
        <actions>
            <name>Check_Partner_Deal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Current_Lead_Partner__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Checks to see if the Opportunity was generated by a current Lead Partner, and will check the Partner Deal checkbox if true.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Contract</fullName>
        <actions>
            <name>Contract_Review</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Negotiation/Review</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email - Declined</fullName>
        <actions>
            <name>Bizfi_Decline_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND ( ISPICKVAL ( StageName , &quot;Declined&quot; ) , 
 OR ( ISPICKVAL ( McaApp__Reason_Lost__c , &quot;Low sales volume&quot; ) , 
  ISPICKVAL ( McaApp__Reason_Lost__c , &quot;High Open Balance&quot; ) , 
  ISPICKVAL ( McaApp__Reason_Lost__c , &quot;Restricted Industry&quot; ) , 
  ISPICKVAL ( McaApp__Reason_Lost__c , &quot;Years in Business&quot; ) , 
  ISPICKVAL ( McaApp__Reason_Lost__c , &quot;Tax liens&quot; ) , 
  ISPICKVAL ( McaApp__Reason_Lost__c , &quot;Poor Bank Account History&quot; ) ) , 
 OR ( CONTAINS( Campaign_Source__c , &quot;LendingTree&quot; ) , 
  CONTAINS( Campaign_Source__c , &quot;5Linx&quot; ) , 
  CONTAINS( Campaign_Source__c , &quot;Credit Karma&quot; ) , 
  CONTAINS( Campaign_Source__c , &quot;Blue Global&quot; ) , 
  CONTAINS( Campaign_Source__c , &quot;Sure&quot; ) , 
  CONTAINS( Campaign_Source__c , &quot;ConEd&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;Delivery.com&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;General Failover&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;Doctors Funding Group&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;iHeart&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;Illinois&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;LendVantage&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;Lightspeed&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;Merchant Advisors&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;Nav&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;Profitstars&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;PTIN&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;Onlybusinessloans&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;TheTopTen&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;TouchSuite&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;TrafficJamming&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;Transfirst&quot; ) ,
  Campaign_Source__c = &quot;EPSG&quot; ,
  CONTAINS( Campaign_Source__c , &quot;Lendio&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;NYSRA&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;Press1&quot; ) ,
  CONTAINS( Campaign_Source__c , &quot;Rep Gen&quot; ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MCP Closed Lost Funding Source</fullName>
        <actions>
            <name>Closed_Lost_Funding_Source</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>MCP_Decline_Email_with_Record_Data</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND ( 2 OR 3 OR 4 OR 5 AND 9 ) AND ( 6 OR 7 ) AND 8</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost - Funding Source</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.LeadSource</field>
            <operation>equals</operation>
            <value>Digital,Mailer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Campaign_Source__c</field>
            <operation>contains</operation>
            <value>Growth</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Campaign_Source__c</field>
            <operation>contains</operation>
            <value>Radiance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Campaign_Source__c</field>
            <operation>contains</operation>
            <value>Belize</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>Closer</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>Opener</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.McaApp__Reason_Lost__c</field>
            <operation>notEqual</operation>
            <value>Fraudulent Deal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Campaign_Source__c</field>
            <operation>notContain</operation>
            <value>Sure</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Demo%3A Email to Team that Deal was approved</fullName>
        <actions>
            <name>McaApp__Email_Noification_to_Team_that_Deal_was_approved</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>This email tells the team that this deal was submitted to Approved.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opp%3EOpportunity Description To Map</fullName>
        <actions>
            <name>McaApp__Update_custom_opp_description_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity %3E Application In - Task to Submit to bank</fullName>
        <actions>
            <name>McaApp__Send_Deal_to_Bank1</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>McaApp__Send_Deal_to_Bank2</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Application In</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.McaApp__Number_of_Submission__c</field>
            <operation>lessThan</operation>
            <value>1</value>
        </criteriaItems>
        <description>Opportunity &gt; Application In - Task to Submit to bank</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity %3E set Closed Date Upon Close</fullName>
        <actions>
            <name>McaApp__Set_Closed_Date_when_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Closed Date upon close.</description>
        <formula>IsClosed =true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity %3E set Closed Date to Funded Date</fullName>
        <actions>
            <name>McaApp__UpdateClosedDateToFundedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Funded</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.McaApp__Date_Funded__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule updates the Closed Date of Opportunity when Opportunity Stage = Funded</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity %3E set Credit Card Sales</fullName>
        <actions>
            <name>McaApp__Opportunity_set_Credit_Card_Sales</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.McaApp__Monthly_CC_Avg_All__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.McaApp__Credit_Card_Sales__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>This workflow rule updates the Credit Card Sales on conversion of Lead from Account</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity %3E set Gross Monthly Sales</fullName>
        <actions>
            <name>McaApp__UpdateGrossMonthlySales</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.McaApp__Gross_monthly_Sales__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule updates the Gross Monthly Sales on conversion of Lead from Account</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity %3E set Last Stage Change Date</fullName>
        <actions>
            <name>McaApp__updatelaststagechangedate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule updates the &apos;Last Stage Change Date&apos; when Opportunity stage changes</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity %3E set Next Step</fullName>
        <actions>
            <name>McaApp__Update_Next_Step_Due_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>McaApp__updateopportunitynextstep</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule updates the Opportunity next step according to Opportunity Stage</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity - Populate Contract Requested Date</fullName>
        <actions>
            <name>McaApp__UpdateContractRequestedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Agreement Requested</value>
        </criteriaItems>
        <description>Will automatically populate the Contract Requested Date when stage is &apos;Agreement Requested&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity%3E Assign Opportunity Name</fullName>
        <actions>
            <name>McaApp__Opportunity_Assign_Opportunity_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Opportunity name in the &apos;Account Name - Created Date - count of the Opportunity for that Account&apos; format.</description>
        <formula>OR(AND(ISNEW(),      NOT(ISNULL(Account.Name))    ),    ISCHANGED(AccountId) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity%3E Email Stips</fullName>
        <actions>
            <name>McaApp__Email_Open_Stips_to_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.McaApp__Open_Stip_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.McaApp__Email_Open_Stips__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity%3E Set Funding Amount on Amount Field</fullName>
        <actions>
            <name>McaApp__Set_Funding_Amount_To_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When contract is get funded, the funding amount of opportunity will be set on amount field of opportunity.</description>
        <formula>IF(AND(NOT(ISPICKVAL(PRIORVALUE(StageName),&apos;Funded&apos;)),    ISPICKVAL(StageName, &apos;Funded&apos;)),     True,     false )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Opportunity%3E Set Stage To %22Application In%22</fullName>
        <actions>
            <name>McaApp__Set_Opportunity_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.McaApp__Set_Opportunity_Status__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.McaApp__Next_Step_Value__c</field>
            <operation>notEqual</operation>
            <value>Send App</value>
        </criteriaItems>
        <description>Set opportunity stage to &quot;Prospecting&quot;, When opportunity gets created through lead conversion</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Set Opportunity Stage%3A Application Sent 2</fullName>
        <actions>
            <name>McaApp__Set_Opportunity_Stage_Application_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>McaApp__Email_Funding_Application</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>McaApp__Follow_Up_with_Merchant_for_Signed_App</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Prospecting</value>
        </criteriaItems>
        <description>Default Stage upon Conversion: Set Opportunity Stage: Application Sent</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update %3E Type %3D New Deal</fullName>
        <actions>
            <name>McaApp__Update_Type_New_Deal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.McaApp__Count_Of_Opportunities__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update Opp Description with Contact Description</fullName>
        <actions>
            <name>McaApp__Update_Opp_Description_with_Cont_Desc</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK( Description ) &amp;&amp; NOT(ISBLANK( McaApp__Owner_1__r.Description ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update Opp Type to New Biz Upon Convert</fullName>
        <actions>
            <name>McaApp__Update_Opp_Type_to_New_Biz_Upon_Convert</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.McaApp__Created_Upon_Convert__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update the Opportunity Type to &quot;New Customer&quot;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update Opportunity Amount Based on Amount Requested</fullName>
        <actions>
            <name>McaApp__Update_Opp_Amount_with_Amount_Requested</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.McaApp__Amount_Requested__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Prospecting,Application Sent,Application In,Application Missing Info,Underwriting</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update%3A App Received %26 App Reveived Date</fullName>
        <actions>
            <name>McaApp__Update_App_Received</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>McaApp__Update_App_Received_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update: App Received &amp; App Received Date</description>
        <formula>If(OR(ISPICKVAL(StageName,&apos;Application In&apos;),ISPICKVAL(StageName,&apos;Application Missing Info&apos;),  McaApp__Application__c=true),true,false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update%3A App Sent %26 App Sent Date</fullName>
        <actions>
            <name>McaApp__Update_App_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>McaApp__Update_App_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Application Sent</value>
        </criteriaItems>
        <description>Update: App Sent &amp; App Sent Date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update%3A Approved %26 Approved Date</fullName>
        <actions>
            <name>McaApp__Update_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>McaApp__Update_Approved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update%3A Contract Signed %26 Contract Signed Date</fullName>
        <actions>
            <name>McaApp__Update_Contract_Signed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>McaApp__Update_Contract_Signed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Agreement Signed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update%3A Funded %26 Funded Dated</fullName>
        <actions>
            <name>McaApp__Update_Funded_Date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>McaApp__Update_Funded_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Funded</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opener Package</fullName>
        <actions>
            <name>Opener_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Submitted_By__r.UserRole.Name =&quot;Opener&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opener Package Uncheck</fullName>
        <actions>
            <name>Uncheck_Opener_Package</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Submitted_By__r.UserRole.Name =&quot;Closer&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Agreement Requested</fullName>
        <actions>
            <name>Update_Agreement_Request_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Agreement Requested</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Agreement Sent</fullName>
        <actions>
            <name>Check_Agreement_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Agreement_Sent_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Agreement Sent</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Agreement Signed</fullName>
        <actions>
            <name>Check_Agreement_Signed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Agreement_Signed_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Agreement Signed</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Application In</fullName>
        <actions>
            <name>Update_Application_In_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Application In</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Application Missing Info</fullName>
        <actions>
            <name>Update_Application_Missing_Info_DateTime</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Application Missing Info</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Application Sent</fullName>
        <actions>
            <name>Update_Application_Sent_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Application Sent</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Approved</fullName>
        <actions>
            <name>Approved_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Closed Duplicate</fullName>
        <actions>
            <name>Update_Closed_Lost_Duplicate_DT_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost - Duplicate</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Closed Lost</fullName>
        <actions>
            <name>Update_Closed_Lost_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Closed Lost - Funding Source</fullName>
        <actions>
            <name>Closed_Lost_Funding_Source_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost - Funding Source</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Closed Lost - Merchant</fullName>
        <actions>
            <name>Closed_Lost_Merchant_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost - Merchant</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Closed%2FRenewed</fullName>
        <actions>
            <name>Update_Closed_Renewed_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed/Renewed</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Declined</fullName>
        <actions>
            <name>Update_Declined_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Declined</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Funded</fullName>
        <actions>
            <name>Update_Funded_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Funded</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Prospecting</fullName>
        <actions>
            <name>Update_Prospecting_Date_Time_field_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Prospecting</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Renewal Prospecting</fullName>
        <actions>
            <name>Update_Renewal_Prospect_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Renewal Prospecting</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Renewal Requested</fullName>
        <actions>
            <name>Update_Renewal_Requested_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Renewal Requested</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Stage Underwriting</fullName>
        <actions>
            <name>Check_Underwriting</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Underwriting_DateTime_on_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Underwriting</value>
        </criteriaItems>
        <description>On Opportunity stage change, to capture the date and time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Campaign Source</fullName>
        <actions>
            <name>Populate_Campaign_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>1/1/2001</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Close Date</fullName>
        <actions>
            <name>Populate_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>1/1/2012</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Gross Annual Sales</fullName>
        <actions>
            <name>Update_Gross_Annual_Sales</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>1/1/2001</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Gross_Annual_Sales__c</field>
            <operation>lessOrEqual</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Gross_Annual_Sales__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Powerstandings Agreement Sent</fullName>
        <actions>
            <name>Agreement_Sent</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Agreement Sent</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Powerstandings Agreement Signed</fullName>
        <actions>
            <name>Agreement_Signed</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Agreement Signed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Powerstandings App In</fullName>
        <actions>
            <name>App_In</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Application In</value>
        </criteriaItems>
        <description>Talks to Powerstandings</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Powerstandings App Missing Info</fullName>
        <actions>
            <name>App_Missing_Info</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Application Missing Info</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Powerstandings App Sent</fullName>
        <actions>
            <name>App_Sent_KPI</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>App Sent KPI - talks to Opener leader board</description>
        <formula>ISPICKVAL(StageName, &apos;Application Sent&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Powerstandings Funded %23</fullName>
        <actions>
            <name>Funded_KPI</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Funded</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Funded_Date_Time__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Powerstandings Funding %24</fullName>
        <actions>
            <name>Funded_Dollars_KPI</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Funded_Date_Time__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Powerstandings Submissions</fullName>
        <actions>
            <name>Opener_Subs</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Submission_Approved_DTS__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Submission_Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proposal</fullName>
        <actions>
            <name>Proposal_Sent</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Proposal/Price Quote</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Email to Funding Desk to Review Opportunity</fullName>
        <actions>
            <name>Email_Funding_Desk_for_Submission_to_be_Reviewed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Underwriting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Scrubbed_By__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Send an email to Funding Desk when an Opportunity is ready to be reviewed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sent Email When New Opportunity Owner Assigned</fullName>
        <actions>
            <name>New_Opportunity_Owner_Assignment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>On opportunity when owner is changed by a user of role submission desk.</description>
        <formula>AND(ISCHANGED(OwnerId),OR( $UserRole.Name  =&apos;Funding Desk Manager&apos;,$UserRole.Name =&apos;Funding Desk Admin&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Sent Email When Opportunity Stage - Approved</fullName>
        <actions>
            <name>Email_when_Opportunity_stage_approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>On opportunity when owner profile is closer and stage is approved.</description>
        <formula>AND(ISPICKVAL(PRIORVALUE(StageName),&apos;Underwriting&apos;),ISPICKVAL(StageName,&apos;Approved&apos;), Owner.UserRole.Name = &apos;Closer&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Sent Email When Opportunity Stage - Declined</fullName>
        <actions>
            <name>Email_when_Opportunity_stage_declined</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>On opportunity when stage changes from Underwriting to Declined.</description>
        <formula>AND(ISPICKVAL(StageName,&apos;Declined&apos;),  OR(Owner.UserRole.Name = &quot;Closer&quot;,Owner.UserRole.Name = &quot;Renewals Agent&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sent Email When Opportunity Stage-Application Missing Info</fullName>
        <actions>
            <name>Email_when_Opportunity_stage_application_missing_info</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>On opportunity when current user is having profile opener and changes the stage to application missing info.</description>
        <formula>AND( ISPICKVAL(StageName,&apos;Application Missing Info&apos;), $User.Id  != OwnerId )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Submission Approved DTS</fullName>
        <actions>
            <name>Submission_Approved_DTS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Submission_Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Populates the field for Submission Approved DTS when the Submission Approved checkbox is marked true.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UW Stage Time Out</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Underwriting</value>
        </criteriaItems>
        <description>Anything that has been in the stage of Underwriting for longer than 5 days, will be marked as &quot;Declined&quot; with reason lost &quot;Timed Out.&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reason_Lost</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Stage</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>UW Stage Time Out2</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Underwriting</value>
        </criteriaItems>
        <description>Anything that has been in the stage of Underwriting for longer than 5 days, will be marked as &quot;Declined&quot; with reason lost &quot;Timed Out.&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reason_Lost_to_Timed_Out</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Stage_Update_to_Declined</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Annual Revenue on Account</fullName>
        <actions>
            <name>Update_Annual_Revenue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>On opportunity when Gross Annual sales is updated,Annual Revenue on account is updated</description>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Decline Email Sent Data%2FTime Field</fullName>
        <actions>
            <name>Update_Decline_Email_Sent_Data_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Decline_Email_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>On Opportunity when Decline Email Sent field is true, Update the Decline Email Sent  Call date/time field with current date/time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Funded Account</fullName>
        <actions>
            <name>Update_Funded_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(Account.Funded_Date__c &lt;= McaApp__Date_Funded__c,   McaApp__Funding_Amount__c  &lt;= 10500)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Opportunity Record Type From Read Only to MCA App Default</fullName>
        <actions>
            <name>Update_Opportunity_Record_type_to_MCAApp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Read Only</value>
        </criteriaItems>
        <description>When an Opportunity is cloned or created where the record type = Read Only, the record type will be changed to MCA App Default.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Paid Off Time</fullName>
        <actions>
            <name>Estimated_Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Paid_Off_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>Account.Funded_Date__c &lt;= McaApp__Date_Funded__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Type when Using Create Renewal</fullName>
        <actions>
            <name>Update_Opportunity_Type_to_Refinance</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Existing Customer - Renewal</value>
        </criteriaItems>
        <description>Updates the Type of Opportunity when using Create Renewal</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Winning Lead - Duplicated Opportunity Closer</fullName>
        <actions>
            <name>Winning_Lead_Duplicated_Opportunity_Closer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Owner.UserRole.Name = &apos;Closer&apos; &amp;&amp; NOT(ISBLANK(DupRefLeadId2__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Winning Lead - Duplicated Opportunity Opener</fullName>
        <actions>
            <name>Winning_Lead_Duplicated_Opportunity_Opener</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Owner.UserRole.Name = &apos;Opener&apos; &amp;&amp; NOT(ISBLANK(DupRefLeadId2__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Winning Lead - Duplicated Opportunity Renewal</fullName>
        <actions>
            <name>Winning_Lead_Duplicated_Opportunity_Renewal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Owner.UserRole.Name = &apos;Renewals Agent&apos; &amp;&amp; NOT(ISBLANK(DupRefLeadId2__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Winning Opportunity - Duplicated Opportunity Closer</fullName>
        <actions>
            <name>Winning_Opportunity_Duplicated_Opportunity_Closer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Owner.UserRole.Name = &apos;Closer&apos; &amp;&amp; NOT(ISBLANK(DupRefOppId__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Winning Opportunity - Duplicated Opportunity Opener</fullName>
        <actions>
            <name>Winning_Opportunity_Duplicated_Opportunity_Opener</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Owner.UserRole.Name = &apos;Opener&apos; &amp;&amp; NOT(ISBLANK(DupRefOppId__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Winning Opportunity - Duplicated Opportunity Renewal</fullName>
        <actions>
            <name>Winning_Opportunity_Duplicated_Opportunity_Renewal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Owner.UserRole.Name = &apos;Renewals Agent&apos; &amp;&amp; NOT(ISBLANK(DupRefOppId__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>McaApp__Email_Funding_Application</fullName>
        <assignedTo>dev@cloudmybiz.com.bizfi</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email: Funding Application</subject>
    </tasks>
    <tasks>
        <fullName>McaApp__Email_Noification_to_Team_that_Deal_was_approved</fullName>
        <assignedTo>dev@cloudmybiz.com.bizfi</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email: Noification sent to Team - Deal Approved</subject>
    </tasks>
    <tasks>
        <fullName>McaApp__Follow_Up_with_Merchant_for_Signed_App</fullName>
        <assignedTo>dev@cloudmybiz.com.bizfi</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow Up with Merchant for Signed App</subject>
    </tasks>
    <tasks>
        <fullName>McaApp__Send_Deal_to_Bank1</fullName>
        <assignedTo>dev@cloudmybiz.com.bizfi</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Please send this deal to banks</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send Deal to Bank</subject>
    </tasks>
    <tasks>
        <fullName>McaApp__Send_Deal_to_Bank2</fullName>
        <assignedTo>dev@cloudmybiz.com.bizfi</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Please send this deal to banks</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send Deal to Bank</subject>
    </tasks>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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
    <rules>
        <fullName>McaApp__Demo%3A Email to Team that Deal was approved</fullName>
        <actions>
            <name>McaApp__Email_Noification_to_Team_that_Deal_was_approved</name>
            <type>Task</type>
        </actions>
        <active>true</active>
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
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Application In</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.McaApp__No_of_Submission__c</field>
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
            <field>Opportunity.McaApp__Open_Stips__c</field>
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
        <active>true</active>
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
        <active>true</active>
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
    <tasks>
        <fullName>McaApp__Email_Funding_Application</fullName>
        <assignedTo>dev@cloudmybiz.com.mcadfa</assignedTo>
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
        <assignedTo>dev@cloudmybiz.com.mcadfa</assignedTo>
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
        <assignedTo>dev@cloudmybiz.com.mcadfa</assignedTo>
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
        <assignedTo>dev@cloudmybiz.com.mcadfa</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Please send this deal to banks</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send Deal to Bank</subject>
    </tasks>
    <tasks>
        <fullName>McaApp__Send_Deal_to_Bank2</fullName>
        <assignedTo>dev@cloudmybiz.com.mcadfa</assignedTo>
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

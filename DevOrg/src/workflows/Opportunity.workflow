<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Open_Stips_to_Owner</fullName>
        <description>Email Open Stips to Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Owner_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Email_Stips</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_Owner1</fullName>
        <description>Send Email to Owner1</description>
        <protected>false</protected>
        <recipients>
            <field>Owner_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/App_Sent_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>test11</fullName>
        <description>test11</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Email_Stips</template>
    </alerts>
    <fieldUpdates>
        <fullName>Check_Application_to_True</fullName>
        <description>The Field update will check the check box of Application to True</description>
        <field>Application__c</field>
        <literalValue>1</literalValue>
        <name>Check Application to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Assign_Opportunity_Name</fullName>
        <description>Updates the Opportunity name in the &apos;Account Name - Created Date - count of the Opportunity for that Account&apos; format.</description>
        <field>Name</field>
        <formula>Account.Name &amp; &apos; - &apos; 
&amp; (TEXT(MONTH(DATEVALUE(CreatedDate)))+&quot;/&quot; +TEXT(DAY(DATEVALUE(CreatedDate)))+&quot;/&quot; +TEXT(YEAR(DATEVALUE(CreatedDate)))) &amp; &apos; - &apos;
&amp;  TEXT(Account.Count_Of_Opportunities__c +1)</formula>
        <name>Opportunity&gt; Assign Opportunity Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OwnershipOfOwner1</fullName>
        <field>Owner_1_Ownership__c</field>
        <formula>Owner_1__r.Of_Ownership__c</formula>
        <name>%OwnershipOfOwner1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OwnershipOfOwner2Update</fullName>
        <field>Owner_2_Ownership__c</field>
        <formula>Owner_2__r.Of_Ownership__c</formula>
        <name>%OwnershipOfOwner2Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Closed_Date_when_Closed</fullName>
        <field>CloseDate</field>
        <formula>IF( NOT(ISBLANK( Date_Funded__c)), Date_Funded__c,today())</formula>
        <name>Set Closed Date when Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Funding_Amount_To_Amount</fullName>
        <field>Amount</field>
        <formula>Funding_Amount__c</formula>
        <name>Set Funding Amount To Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Opportunity_Stage</fullName>
        <field>StageName</field>
        <literalValue>Application Sent</literalValue>
        <name>Set Opportunity Stage: Application Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Opportunity_Stage_Application_Sent</fullName>
        <field>StageName</field>
        <literalValue>Application Sent</literalValue>
        <name>Set Opportunity Stage: Application Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Testing</fullName>
        <field>StageName</field>
        <literalValue>Funded</literalValue>
        <name>Testing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateClosedDateToFundedDate</fullName>
        <description>Update the Opportunity Closed Date to Funded Date when Opportunity Stage = Funded</description>
        <field>CloseDate</field>
        <formula>Date_Funded__c</formula>
        <name>UpdateClosedDateToFundedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContractRequestedDate</fullName>
        <field>Contract_Requested_Date__c</field>
        <formula>TODAY()</formula>
        <name>UpdateContractRequestedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCreditCardSales</fullName>
        <description>update the Credit Card Sales of Opportunity with Monthly CC Avg - All of Account</description>
        <field>Credit_Card_Sales__c</field>
        <formula>Account.Monthly_CC_Avg_All__c</formula>
        <name>UpdateCreditCardSales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateGrossMonthlySales</fullName>
        <description>Update the Gross Monthly Sales on creation of Opportunity</description>
        <field>Gross_monthly_Sales__c</field>
        <formula>Account.Gross_monthly_Sales__c</formula>
        <name>UpdateGrossMonthlySales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateOpportunityNextStep</fullName>
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
        <fullName>Update_App_Received</fullName>
        <field>App_Received__c</field>
        <literalValue>1</literalValue>
        <name>Update: App Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_App_Received_Date</fullName>
        <field>App_Received_Date__c</field>
        <formula>IF(ISBLANK( App_Received_Date__c ), Today(),App_Received_Date__c)</formula>
        <name>Update: App Received Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_App_Sent</fullName>
        <field>App_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Update: App Sent = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_App_Sent_Date</fullName>
        <field>App_Sent_Date__c</field>
        <formula>IF(ISBLANK( App_Sent_Date__c ), Today(),App_Sent_Date__c)</formula>
        <name>Update: App Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approved</fullName>
        <field>Approved__c</field>
        <literalValue>1</literalValue>
        <name>Update: Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approved_Date</fullName>
        <field>Approved_Date__c</field>
        <formula>IF(ISBLANK(Approved_Date__c), Today(),Approved_Date__c)</formula>
        <name>Update: Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contract_Signed</fullName>
        <field>Contract_Signed__c</field>
        <literalValue>1</literalValue>
        <name>Update: Contract Signed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contract_Signed_Date</fullName>
        <field>Date_Contract_Signed__c</field>
        <formula>IF(ISBLANK( Date_Contract_Signed__c), today(),Date_Contract_Signed__c)</formula>
        <name>Update: Contract Signed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Deal_Entry_Wizard_checkBozx_False</fullName>
        <description>The Field update will Update Deal Entry wizard check-box as False when new deal is created and If checkbox is checked previously.</description>
        <field>Deal_Entry_Wizard_Check__c</field>
        <literalValue>0</literalValue>
        <name>Update Deal Entry Wizard checkBozx False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Funded_Date_Today</fullName>
        <field>Date_Funded__c</field>
        <formula>IF( ISBLANK(Date_Funded__c), Today(),Date_Funded__c)</formula>
        <name>Update: Funded Date = Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Funded_True</fullName>
        <field>Funded__c</field>
        <literalValue>1</literalValue>
        <name>Update: Funded = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Amount_with_Amount_Requested</fullName>
        <field>Amount</field>
        <formula>Amount_Requested__c</formula>
        <name>Update Opp Amount with Amount Requested</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Description_with_Cont_Desc</fullName>
        <field>Description</field>
        <formula>Owner_1__r.Description</formula>
        <name>Update Opp Description with Cont Desc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Type_to_New_Biz_Upon_Convert</fullName>
        <field>Type</field>
        <literalValue>New Customer</literalValue>
        <name>Update Opp Type to New Biz Upon Convert</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Stage_Application_Sen</fullName>
        <description>The field update will update the stage as Application Sent  when Next step value is populate as Send App after lead is converted to opportunity</description>
        <field>StageName</field>
        <literalValue>Agreement Sent</literalValue>
        <name>Update Opportunity Stage Application Sen</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Type_New_Deal</fullName>
        <field>Type</field>
        <literalValue>New Deal</literalValue>
        <name>Update: Type = New Deal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Type_New_Deal_Opp</fullName>
        <field>Type</field>
        <literalValue>New Deal</literalValue>
        <name>Update: Type = New Deal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>test</fullName>
        <field>Amount_Requested__c</field>
        <formula>1000</formula>
        <name>test</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updateLastStageChangeDate</fullName>
        <description>Updates the &apos;Last Stage Change Date&apos; with current date when stage changes</description>
        <field>Last_Stage_Change_Date__c</field>
        <formula>IF( OR(ISCHANGED(  StageName  ), ISNEW() ), NOW()  ,  Last_Stage_Change_Date__c )</formula>
        <name>updateLastStageChangeDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Opportunity %3E Deal Entry Wizard Check Box</fullName>
        <actions>
            <name>Update_Deal_Entry_Wizard_checkBozx_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The workflow  Rue is used to update Deal Entry Wizard check-box as False when New Opportunity is Created.</description>
        <formula>AND( ISNEW(), Deal_Entry_Wizard_Check__c == True)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity %3E Set Credit Card Sales</fullName>
        <actions>
            <name>UpdateCreditCardSales</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Monthly_CC_Avg_All__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Credit_Card_Sales__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>This Workflow Rule updated the Credit Card Sales on Opportunity with associated Account Monthly CC Avg - All on creation of Opportunity</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity %3E set Closed Date Upon Close</fullName>
        <actions>
            <name>Set_Closed_Date_when_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Closed Date upon close.</description>
        <formula>IsClosed =true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity %3E set Closed Date to Funded Date</fullName>
        <actions>
            <name>UpdateClosedDateToFundedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Funded</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Date_Funded__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule updates the Closed Date of Opportunity when Opportunity Stage = Funded</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity %3E set Gross Monthly Sales</fullName>
        <actions>
            <name>UpdateGrossMonthlySales</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Gross_monthly_Sales__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule updates the Gross Monthly Sales on conversion of Lead from Account</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity %3E set Last Stage Change Date</fullName>
        <actions>
            <name>updateLastStageChangeDate</name>
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
        <fullName>Opportunity %3E set Next Step</fullName>
        <actions>
            <name>UpdateOpportunityNextStep</name>
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
        <fullName>Opportunity - Populate Contract Requested Date</fullName>
        <actions>
            <name>UpdateContractRequestedDate</name>
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
        <fullName>Opportunity%3E Assign Opportunity Name</fullName>
        <actions>
            <name>Opportunity_Assign_Opportunity_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Opportunity name in the &apos;Account Name - Created Date - count of the Opportunity for that Account&apos; format.</description>
        <formula>OR(AND(ISNEW(),      NOT(ISNULL(Account.Name))    ),    ISCHANGED(AccountId) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity%3E Email Stips</fullName>
        <actions>
            <name>Email_Open_Stips_to_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Open_Stips__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Email_Open_Stips__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity%3E Next Step is Send App</fullName>
        <actions>
            <name>Send_Email_to_Owner1</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Check_Application_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Opportunity_Stage_Application_Sen</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Next_Step_Value__c</field>
            <operation>equals</operation>
            <value>Send App</value>
        </criteriaItems>
        <description>The workflow rule will fire when Next Step value in populated as Send App after lead is converted to opportunity.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity%3E Set Funding Amount on Amount Field</fullName>
        <actions>
            <name>Set_Funding_Amount_To_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When contract is get funded, the funding amount of opportunity will be set on amount field of opportunity.</description>
        <formula>IF(AND(NOT(ISPICKVAL(PRIORVALUE(StageName),&apos;Funded&apos;)),    ISPICKVAL(StageName, &apos;Funded&apos;)),     True,     false )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity%3E Set Stage Upon Conversion</fullName>
        <actions>
            <name>Set_Opportunity_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Set_Opportunity_Status__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Next_Step_Value__c</field>
            <operation>notEqual</operation>
            <value>Send App</value>
        </criteriaItems>
        <description>Set opportunity stage to &quot;Prospecting&quot;, When opportunity gets created through lead conversion</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Opportunity Stage%3A Application Sent 2</fullName>
        <actions>
            <name>Set_Opportunity_Stage_Application_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Email_Funding_Application</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>Follow_Up_with_Merchant_for_Signed_App</name>
            <type>Task</type>
        </actions>
        <active>true</active>
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
        <fullName>Test</fullName>
        <active>false</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>test11</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.CreatedDate</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Testing</fullName>
        <actions>
            <name>Testing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update %3E Type %3D New Deal</fullName>
        <actions>
            <name>Update_Type_New_Deal_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Count_Of_Opportunities__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Contact%27s Ownership</fullName>
        <active>false</active>
        <formula>ISCHANGED( Owner_1_Ownership__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Opp Description with Contact Description</fullName>
        <actions>
            <name>Update_Opp_Description_with_Cont_Desc</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK( Description ) &amp;&amp; NOT(ISBLANK( Owner_1__r.Description ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Opp Type to New Biz Upon Convert</fullName>
        <actions>
            <name>Update_Opp_Type_to_New_Biz_Upon_Convert</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Created_Upon_Convert__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update the Opportunity Type to &quot;New Customer&quot;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Opportunity Amount Based on Amount Requested</fullName>
        <actions>
            <name>Update_Opp_Amount_with_Amount_Requested</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount_Requested__c</field>
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
        <fullName>Update%3A App Received %26 App Reveived Date</fullName>
        <actions>
            <name>Update_App_Received</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_App_Received_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update: App Received &amp; App Reveived Date</description>
        <formula>If(OR(ISPICKVAL(StageName,&apos;Application In&apos;),ISPICKVAL(StageName,&apos;Application Missing Info&apos;),  Application__c=true),true,false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update%3A App Sent %26 App Sent Date</fullName>
        <actions>
            <name>Update_App_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_App_Sent_Date</name>
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
        <fullName>Update%3A Approved %26 Approved Date</fullName>
        <actions>
            <name>Update_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Approved_Date</name>
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
        <fullName>Update%3A Contract Signed %26 Contract Signed Date</fullName>
        <actions>
            <name>Update_Contract_Signed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Contract_Signed_Date</name>
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
        <fullName>Update%3A Funded %26 Funded Dated</fullName>
        <actions>
            <name>Update_Funded_Date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Funded_True</name>
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
        <fullName>Email_Funding_Application</fullName>
        <assignedTo>dev1@mca.com.dev</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email: Funding Application</subject>
    </tasks>
    <tasks>
        <fullName>Follow_Up_with_Merchant_for_Signed_App</fullName>
        <assignedTo>dev1@mca.com.dev</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow Up with Merchant for Signed App</subject>
    </tasks>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Onboarding_Status_In_Queue</fullName>
        <ccEmails>henry@cloudmybiz.com</ccEmails>
        <description>Onboarding Status = In Queue</description>
        <protected>false</protected>
        <recipients>
            <recipient>henrietta@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SOW_Templates/Onboarding_Status_In_Queue</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Closed_Won_Email_Notification</fullName>
        <description>Opportunity=Closed Won &gt; Email Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Internal_Users_LA</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>Internal_Users_NY</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>dennis@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Opportunity_Emails/Opportunity_Closed_Won_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>SOW_Status_In_Queue_Intenral_Email_Alert</fullName>
        <ccEmails>henry@cloudmybiz.com</ccEmails>
        <description>SOW Status = In Queue - Intenral Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>ronnie@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SOW_Templates/SOW_Status_In_Queue</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Date_SOW_Sent</fullName>
        <field>Date_SOW_Sent__c</field>
        <formula>today()</formula>
        <name>Update Date SOW Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Actual_Closed_Date</fullName>
        <field>Actual_Closed_Date__c</field>
        <formula>Today()</formula>
        <name>Update Opp Actual Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Amount</fullName>
        <description>IF(Total_SOW_Hours__c&lt;=0,null,(Total_SOW_Hours__c * Hourly_Rate__c) 

+IF( MCA_App_Cost__c &lt;=0,null,MCA_App_Cost__c)

+IF(Discount_Dollar__c&lt;=0,null,-  Discount_Dollar__c))</description>
        <field>Amount</field>
        <formula>Total_SOW_Price__c</formula>
        <name>Update Opp Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_Notes_Date</fullName>
        <field>Stage_Notes_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Stage Notes Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Onboarding Status %3D In Queue</fullName>
        <actions>
            <name>Onboarding_Status_In_Queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Onboarding_Status__c</field>
            <operation>equals</operation>
            <value>In Queue</value>
        </criteriaItems>
        <description>Onboarding Status = In Queue. This will alert the onboarding team to begin the process</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity%3DClosed Won %3E Email Notification</fullName>
        <actions>
            <name>Opportunity_Closed_Won_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SOW Status %3D In Queue</fullName>
        <actions>
            <name>SOW_Status_In_Queue_Intenral_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.SOW_Status__c</field>
            <operation>equals</operation>
            <value>In Queue</value>
        </criteriaItems>
        <description>This will drive the internal workflow of preparing new SOWs</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage Notes Date</fullName>
        <actions>
            <name>Update_Stage_Notes_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( 
AND(ISNEW(), NOT(ISBLANK(Stage_Notes__c))),
ISCHANGED(Stage_Notes__c) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Date SOW Sent</fullName>
        <actions>
            <name>Update_Date_SOW_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>SOW Sent,Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Date_SOW_Sent__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Opp Actual Closed Date</fullName>
        <actions>
            <name>Update_Opp_Actual_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When the opp closes, this date will be updated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Opp Amount</fullName>
        <actions>
            <name>Update_Opp_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(
ISNEW(),
ISCHANGED( Total_SOW_Hours__c),
ISCHANGED( Hourly_Rate__c),
ISCHANGED(  MCA_App_Cost__c ),
ISCHANGED(  Discount_Dollar__c )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

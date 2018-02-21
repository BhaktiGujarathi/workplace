<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notifying_Account_Manager_to_initiate_change_order_process</fullName>
        <description>Notifying Account Manager to initiate change order process</description>
        <protected>false</protected>
        <recipients>
            <recipient>Accounting</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Initiate_change_order</template>
    </alerts>
    <alerts>
        <fullName>PM_Project_Hours_at_80_pct</fullName>
        <description>Sends an email alert to the PM when invoiced hours are at 80%.</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ClientProjectManager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>jeffrey@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Hour_Templates/PM_Project_Hours_at_80</template>
    </alerts>
    <alerts>
        <fullName>Project_Hours_Monthly_Monitoring_Email_Alert</fullName>
        <description>Project Hours Monthly Monitoring Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>abraham@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Hour_Templates/Project_Hours_Monthly_Monitoring</template>
    </alerts>
    <alerts>
        <fullName>Send_Project_Status_Changed_Email</fullName>
        <description>Send Project Status Changed Email</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ClientProjectManager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>jeffrey@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ronnie@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Project_Status_Changed</template>
    </alerts>
    <alerts>
        <fullName>Sends_an_email_alert_to_the_PM_when_invoiced_hours_are_at_100</fullName>
        <description>Sends an email alert to the PM when invoiced hours are at 100%</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ClientProjectManager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jeffrey@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ronnie@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Hour_Templates/PM_Project_Hours_at_100</template>
    </alerts>
    <alerts>
        <fullName>Sends_an_email_alert_to_the_PM_when_invoiced_hours_are_at_50</fullName>
        <description>Sends an email alert to the PM when invoiced hours are at 50%</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ClientProjectManager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>jeffrey@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Hour_Templates/PM_Project_Hours_at_50</template>
    </alerts>
    <alerts>
        <fullName>Sends_an_email_alert_to_the_PM_when_invoiced_hours_are_at_85</fullName>
        <description>Sends an email alert to the PM when invoiced hours are at 85%.</description>
        <protected>false</protected>
        <recipients>
            <field>ClientProjectManager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Hour_Templates/PM_Project_Hours_at_85</template>
    </alerts>
    <alerts>
        <fullName>Sends_an_email_alert_to_the_PM_when_invoiced_hours_are_at_90</fullName>
        <description>Sends an email alert to the PM when invoiced hours are at 90%.</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ClientProjectManager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>jeffrey@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ronnie@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Hour_Templates/PM_Project_Hours_at_90</template>
    </alerts>
    <alerts>
        <fullName>Sends_an_email_alert_to_the_PM_when_invoiced_hours_are_at_95</fullName>
        <description>Sends an email alert to the PM when invoiced hours are at 95%.</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ClientProjectManager__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jeffrey@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ronnie@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Hour_Templates/PM_Project_Hours_at_95</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Project_Date_Started</fullName>
        <description>Update: Project - Date Started</description>
        <field>DateStarted__c</field>
        <formula>today()</formula>
        <name>Update: Project - Date Started</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Change order required</fullName>
        <actions>
            <name>Notifying_Account_Manager_to_initiate_change_order_process</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>HarvestProject__c.Needs_Change_Order__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PM Implementation Project Hours at 100%25</fullName>
        <actions>
            <name>Sends_an_email_alert_to_the_PM_when_invoiced_hours_are_at_100</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sends an email alert to the PM when invoiced hours are at 100%.</description>
        <formula>AND ( 
BurnPercent__c &gt;= 1.00,  
RecordTypeId = &apos;012600000009ci6&apos; ,
 Archived__c = FALSE
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PM Implementation Project Hours at 50%25</fullName>
        <actions>
            <name>Sends_an_email_alert_to_the_PM_when_invoiced_hours_are_at_50</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sends an email alert to the PM when invoiced hours are at 50%.</description>
        <formula>AND (
 BurnPercent__c &gt;= 0.5,
 BurnPercent__c &lt; 0.80,
  RecordTypeId = &apos;012600000009ci6&apos;,
 Archived__c = FALSE
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PM Implementation Project Hours at 80%25</fullName>
        <actions>
            <name>PM_Project_Hours_at_80_pct</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sends an email alert to the PM when invoiced hours are at 80%.</description>
        <formula>AND ( 
BurnPercent__c &gt;= 0.8, 
BurnPercent__c &lt; 0.9, 
RecordTypeId = &apos;012600000009ci6&apos;,
 Archived__c = FALSE
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PM Implementation Project Hours at 90%25</fullName>
        <actions>
            <name>Sends_an_email_alert_to_the_PM_when_invoiced_hours_are_at_90</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sends an email alert to the PM when invoiced hours are at 90%.</description>
        <formula>AND ( 
BurnPercent__c &gt;= 0.9, 
BurnPercent__c &lt; 0.95, 
RecordTypeId = &apos;012600000009ci6&apos; ,
 Archived__c = FALSE
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PM Implementation Project Hours at 95%25</fullName>
        <actions>
            <name>Sends_an_email_alert_to_the_PM_when_invoiced_hours_are_at_95</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sends an email alert to the PM when invoiced hours are at 95%.</description>
        <formula>AND ( 
BurnPercent__c &gt;= 0.95, 
BurnPercent__c &lt; 1.00, 
RecordTypeId = &apos;012600000009ci6&apos; ,
 Archived__c = FALSE
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PM Project Hours at 85%25</fullName>
        <actions>
            <name>Sends_an_email_alert_to_the_PM_when_invoiced_hours_are_at_85</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sends an email alert to the PM when invoiced hours are at 85%.</description>
        <formula>InvoicedTime__c =  Estimated_Hours__c *0.85</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Project Hours Monthly Monitoring</fullName>
        <actions>
            <name>Project_Hours_Monthly_Monitoring_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This is to monitor and control monthly budget limits</description>
        <formula>Hours_this_Month_of_Budget__c &gt;0.85</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Email when Project Status Changed</fullName>
        <actions>
            <name>Send_Project_Status_Changed_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Project_Status__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update%3A Project - Date Started</fullName>
        <actions>
            <name>Update_Project_Date_Started</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>HarvestProject__c.DateStarted__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Update: Project - Date Started. This will update the Date Started field with the created date field</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

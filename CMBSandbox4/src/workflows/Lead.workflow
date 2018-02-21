<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Lead_Opt_Out_Email_Alert</fullName>
        <description>Lead Opt Out - Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Tip_of_the_Week/Lead_Opt_Out_Alert</template>
    </alerts>
    <alerts>
        <fullName>Leads_New_assignment_notification_SAMPLE</fullName>
        <description>Leads:  New assignment notification (SAMPLE)</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dennis@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LeadsNewassignmentnotificationSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>New_web_lead_added</fullName>
        <description>New web lead added</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dennis@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Leads_Email_Templates/New_Web_to_Lead</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_to_Spam_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Spam_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to Spam Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Campaign_Name</fullName>
        <field>Campaign_Name_Copy__c</field>
        <formula>Campaign.Name</formula>
        <name>Copy Campaign Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_Web_Lead_Add_to_TOTW</fullName>
        <field>Tip_of_the_Week__c</field>
        <literalValue>Added - Active</literalValue>
        <name>New Web Lead - Add to TOTW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Spam_Yes</fullName>
        <field>Spam__c</field>
        <literalValue>1</literalValue>
        <name>Spam=Yes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TOTW_Active</fullName>
        <field>Tip_of_the_Week__c</field>
        <literalValue>Added - Active</literalValue>
        <name>TOTW=Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tip_of_the_Week_Check</fullName>
        <field>Tip_of_the_Week_Opt_In__c</field>
        <literalValue>1</literalValue>
        <name>Tip of the Week Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tip_of_the_Week_Date</fullName>
        <field>Tip_of_the_Week_Opt_In_Date__c</field>
        <formula>TODAY()</formula>
        <name>Tip of the Week Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Email_Field_with_AE_Email</fullName>
        <field>Email</field>
        <formula>Account_Executive_Email__c</formula>
        <name>Update Email Field with AE Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_First_Name</fullName>
        <field>FirstName</field>
        <formula>IF( CONTAINS( LastName, &quot; &quot; ),
LEFT( LastName ,  FIND( &quot; &quot;, LastName ) ),
&quot;&quot; )</formula>
        <name>Update First Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Industry_MCA</fullName>
        <field>Industry</field>
        <literalValue>Finance - MCA</literalValue>
        <name>Update Industry MCA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Name</fullName>
        <field>LastName</field>
        <formula>IF( CONTAINS( LastName, &quot; &quot; ),
RIGHT( LastName , LEN(LastName) - FIND( &quot; &quot;, LastName ) ),
LastName )</formula>
        <name>Update Last Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_TOTW_Opt_Out</fullName>
        <description>Update the Tip of the Week picklist to &quot;Removed By Request&quot; when &quot;Email Opt Out&quot; is checked.</description>
        <field>Tip_of_the_Week__c</field>
        <literalValue>Removed by Request</literalValue>
        <name>Update TOTW Opt Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Conga_Workflow_Send_SOW</fullName>
        <apiVersion>33.0</apiVersion>
        <endpointUrl>https://workflow.appextremes.com/apps/Conga/PMWorkflow.aspx</endpointUrl>
        <fields>Conga_Workflow_Send_SOW_URL__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>cabenaim@gmail.com</integrationUser>
        <name>Conga Workflow - Send SOW</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Conga Workflow - Send SOW</fullName>
        <actions>
            <name>Update_Email_Field_with_AE_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Conga_Workflow_Send_SOW</name>
            <type>OutboundMessage</type>
        </actions>
        <actions>
            <name>Conga_Workflow_Sent_SOW</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Account_Executive_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead MCA Equals True</fullName>
        <actions>
            <name>Update_Industry_MCA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.MCA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Opt Out Alert</fullName>
        <actions>
            <name>Lead_Opt_Out_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2</booleanFilter>
        <criteriaItems>
            <field>Lead.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Tip_of_the_Week__c</field>
            <operation>equals</operation>
            <value>Removed by Request</value>
        </criteriaItems>
        <description>Internal email alert when someone unsubscribes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Lead Internal Notification</fullName>
        <actions>
            <name>Leads_New_assignment_notification_SAMPLE</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Spam__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Description</field>
            <operation>notContain</operation>
            <value>&lt;a href=,url=</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Web-to-Lead</fullName>
        <actions>
            <name>New_web_lead_added</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Web,Web - Tip of the week</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Subject__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Spam Filter</fullName>
        <actions>
            <name>Assign_to_Spam_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Spam_Yes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Description</field>
            <operation>contains</operation>
            <value>&lt;a href=,url=</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update TOTW Opt Out</fullName>
        <actions>
            <name>Update_TOTW_Opt_Out</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update the Tip of the Week picklist to &quot;Removed By Request&quot; when &quot;Email Opt Out&quot; is checked.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web Lead - Add to TOTW</fullName>
        <actions>
            <name>New_Web_Lead_Add_to_TOTW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>contains</operation>
            <value>Web,XIRR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Tip_of_the_Week__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web Leads Naming %28First %26 Last%29</fullName>
        <actions>
            <name>Update_First_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Last_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.FirstName</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LastName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>contains</operation>
            <value>Web</value>
        </criteriaItems>
        <description>Web Leads Naming (First &amp; Last)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Web Tip of the Week</fullName>
        <actions>
            <name>TOTW_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Tip_of_the_Week_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Tip_of_the_Week_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Web - Tip of the week</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>CloudMyBiz_Project_Hours_Report_Account_Name</fullName>
        <assignedTo>cabenaim@gmail.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>CloudMyBiz Project Hours Report - {!Account.Name}</subject>
    </tasks>
    <tasks>
        <fullName>Conga_Workflow_Sent_SOW</fullName>
        <assignedTo>cabenaim@gmail.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Conga Workflow - Sent SOW</subject>
    </tasks>
</Workflow>

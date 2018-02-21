<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Bank_Send_Welcome_Email</fullName>
        <description>Bank - Send Welcome Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Bank_App_Emails/Bank_Welcome_Email</template>
    </alerts>
    <alerts>
        <fullName>Each_time_a_guest_modifies_a_bank_record</fullName>
        <description>Each time a guest modifies a bank record.</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>levi@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Bank_App_Emails/Bank_Internal_Notification_when_modified_by_guest</template>
    </alerts>
    <fieldUpdates>
        <fullName>Bank_Set_Email_Timestamp</fullName>
        <field>Email_Timestamp__c</field>
        <formula>NOW()</formula>
        <name>Bank - Set Email Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Bank_Set_Internal_Status_Contacted</fullName>
        <field>Internal_Status__c</field>
        <literalValue>Contacted - Working</literalValue>
        <name>Bank - Set Internal Status - Contacted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Bank_Password</fullName>
        <field>Password__c</field>
        <formula>&quot;1&quot; &amp; Password_Generator__c&amp;  LEFT(Name, 2)</formula>
        <name>Set Bank Password</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Bank - Internal Notification when modified by guest</fullName>
        <actions>
            <name>Each_time_a_guest_modifies_a_bank_record</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bank__c.LastModifiedById</field>
            <operation>equals</operation>
            <value>Bank Directory Site Guest User</value>
        </criteriaItems>
        <description>Each time a guest modifies a bank record.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Bank - Set Internal Status</fullName>
        <actions>
            <name>Bank_Set_Internal_Status_Contacted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 or 2) and 3</booleanFilter>
        <criteriaItems>
            <field>Bank__c.Internal_Status__c</field>
            <operation>equals</operation>
            <value>Not Contacted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Bank__c.Internal_Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Bank__c.Send_Welcome_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Bank - Set Password</fullName>
        <actions>
            <name>Set_Bank_Password</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Bank__c.Password__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Bank Welcome Email Notification</fullName>
        <actions>
            <name>Bank_Send_Welcome_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Bank_Set_Email_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Email_Welcome_to_CloudMyBiz_Bank_Directory</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bank__c.Send_Welcome_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Bank__c.Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Email_Welcome_to_CloudMyBiz_Bank_Directory</fullName>
        <assignedTo>cabenaim@gmail.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email: Welcome to CloudMyBiz Bank Directory</subject>
    </tasks>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CC_on_Case_Email</fullName>
        <description>CC on Case Emails</description>
        <protected>false</protected>
        <recipients>
            <field>CC_on_Cases__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SUPPORTSelfServiceNewCommentNotificationSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>Case_Assignment_Email_to_Abraham</fullName>
        <ccEmails>henry@cloudmybiz.com,armen@cloudmybiz.com</ccEmails>
        <description>Case Assignment Email to Abraham</description>
        <protected>false</protected>
        <recipients>
            <recipient>abraham@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Internal/Case_New_Case_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>Case_Assignment_Email_to_Carrin</fullName>
        <description>Case Assignment Email to Carrin</description>
        <protected>false</protected>
        <recipients>
            <recipient>carrin@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Internal/Case_New_Case_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>Case_Assignment_Email_to_Case_Owner</fullName>
        <description>Case Assignment Email to Case Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Internal/Case_New_Case_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>Case_Assignment_Email_to_Jeffrey</fullName>
        <description>Case Assignment Email to Jeffrey</description>
        <protected>false</protected>
        <recipients>
            <recipient>jeffrey@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Internal/Case_New_Case_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>Case_Assignment_Email_to_Sochy</fullName>
        <description>Case Assignment Email to Sochy</description>
        <protected>false</protected>
        <recipients>
            <recipient>sochy@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Internal/Case_New_Case_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>Case_Comment_Email_to_CC</fullName>
        <description>Case Comment Email to CC</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>CC_on_Cases__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@cloudmybiz.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cases_Communities/Case_Comment_Email_to_CC_on_Cases</template>
    </alerts>
    <alerts>
        <fullName>New_Case_Email_Notification_To_Client</fullName>
        <description>New Case - Email Notification To Client</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>CC_on_Cases__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@cloudmybiz.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cases_Communities/New_Case_Email_Notification_To_Client</template>
    </alerts>
    <alerts>
        <fullName>New_Case_Internal_ETC</fullName>
        <description>New Case - Internal ETC</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Internal/Case_New_Case_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>New_Email_Received_on_Case_Alert_Case_Owner</fullName>
        <description>New Email Received on Case - Alert Case Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>support@cloudmybiz.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Cases_Communities/New_Email_from_Client_Internal_Notification</template>
    </alerts>
    <alerts>
        <fullName>On_Hold_Waiting_on_Client_Email_Alert_to_Client</fullName>
        <description>On Hold - Waiting on Client - Email Alert to Client</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@cloudmybiz.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/On_Hold_Waiting_on_Client_Email_Notification_To_Client</template>
    </alerts>
    <alerts>
        <fullName>Status_Change_Email</fullName>
        <description>Status Change Email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>CC_on_Cases__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Communities/Case_Status_Change_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Ben_Assignment</fullName>
        <field>OwnerId</field>
        <lookupValue>ben@cloudmybiz.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Ben Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CC_on_Cases</fullName>
        <field>CC_on_Cases__c</field>
        <formula>Account.Client_Contact_to_CC_on_Cases__r.Email</formula>
        <name>CC on Cases</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Assignment_Abraham_Vargas</fullName>
        <field>OwnerId</field>
        <lookupValue>abraham@cloudmybiz.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Case Assignment: Abraham Vargas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Assignment_Email_to_Carrin</fullName>
        <field>OwnerId</field>
        <lookupValue>carrin@cloudmybiz.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Case Assignment: Carrin</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Assignment_Henry</fullName>
        <field>OwnerId</field>
        <lookupValue>sochy@cloudmybiz.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Case Assignment: Sochy (2)</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Assignment_Jared_Baker</fullName>
        <field>OwnerId</field>
        <lookupValue>jared.thesalesforceguy@gmail.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Case Assignment: Jared Baker</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Assignment_Jeffrey</fullName>
        <field>OwnerId</field>
        <lookupValue>jeffrey@cloudmybiz.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Case Assignment: Jeffrey</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Assignment_Sochy</fullName>
        <field>OwnerId</field>
        <lookupValue>sochy@cloudmybiz.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Case Assignment: Sochy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Close_and_Mark_as_Future</fullName>
        <field>Status</field>
        <literalValue>Closed - Future</literalValue>
        <name>Case - Close and Mark as Future</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Update_Origin_with_Communities</fullName>
        <field>Origin</field>
        <literalValue>Customer Portal</literalValue>
        <name>Case - Update Origin with Communities</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Open_In_Progress</fullName>
        <field>Status</field>
        <literalValue>Open - In Progress</literalValue>
        <name>Change Status to Open In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Open_New</fullName>
        <field>Status</field>
        <literalValue>Open - New</literalValue>
        <name>Change Status to Open New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Reopened_from_case_comm1ent</fullName>
        <field>Reopened_from_case_comment__c</field>
        <literalValue>1</literalValue>
        <name>Mark &quot;Reopened from case comment&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CaseCommunityRecordType</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Date_When_Status_Changes</fullName>
        <description>Update Status Date - When Status Changes</description>
        <field>Status_Date__c</field>
        <formula>now()</formula>
        <name>Update Status Date - When Status Changes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_case_to_Open_In_Progress</fullName>
        <field>Status</field>
        <literalValue>Open - In Progress</literalValue>
        <name>Update case to Open - In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Case - Close and Mark as Future</fullName>
        <actions>
            <name>Case_Close_and_Mark_as_Future</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.Close_Case_Mark_as_Future__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case - Update Origin with Communities</fullName>
        <actions>
            <name>Case_Update_Origin_with_Communities</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>contains</operation>
            <value>Community</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Assignment%3A Abraham Vargas</fullName>
        <actions>
            <name>Case_Assignment_Email_to_Abraham</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Assignment_Abraham_Vargas</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Account_Project_Manager__c</field>
            <operation>startsWith</operation>
            <value>abraham</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notContain</operation>
            <value>Closed - Resolved,Closed - Canceled,Closed - Future,closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Close_Case_Mark_as_Future__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This will route cases to abraham</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Assignment%3A Ben</fullName>
        <actions>
            <name>Ben_Assignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Account_Project_Manager__c</field>
            <operation>startsWith</operation>
            <value>Ben Druk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notContain</operation>
            <value>Closed - Resolved,Closed - Canceled,Closed - Future,closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Close_Case_Mark_as_Future__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This will route cases to Sochy</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Assignment%3A Carrin</fullName>
        <actions>
            <name>Case_Assignment_Email_to_Carrin</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Assignment_Email_to_Carrin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Account_Project_Manager__c</field>
            <operation>startsWith</operation>
            <value>Carrin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notContain</operation>
            <value>Closed - Resolved,Closed - Canceled,Closed - Future,closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Close_Case_Mark_as_Future__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This will route cases to Carrin</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Assignment%3A Catch All</fullName>
        <actions>
            <name>Case_Assignment_Email_to_Case_Owner</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Assignment_Henry</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Account_Project_Manager__c</field>
            <operation>notContain</operation>
            <value>jared,abraham,jeffrey,carrin,sochy,armen</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notContain</operation>
            <value>Closed - Resolved,Closed - Canceled,Closed - Future,closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Close_Case_Mark_as_Future__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notContain</operation>
            <value>cloudmybiz.com</value>
        </criteriaItems>
        <description>This is for cases that do not get routed to any specific PM, this will route cases to Henry</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Assignment%3A Jared Baker</fullName>
        <actions>
            <name>Case_Assignment_Email_to_Case_Owner</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Assignment_Jared_Baker</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Account_Project_Manager__c</field>
            <operation>startsWith</operation>
            <value>Jared</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notContain</operation>
            <value>Closed - Resolved,Closed - Canceled,Closed - Future,closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Close_Case_Mark_as_Future__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This will route cases to Jared</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Assignment%3A Jeffrey</fullName>
        <actions>
            <name>Case_Assignment_Email_to_Jeffrey</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Assignment_Jeffrey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Account_Project_Manager__c</field>
            <operation>startsWith</operation>
            <value>Jeffrey</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notContain</operation>
            <value>Closed - Resolved,Closed - Canceled,Closed - Future,closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Close_Case_Mark_as_Future__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This will route cases to Jeffrey</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Assignment%3A Sochy</fullName>
        <actions>
            <name>Case_Assignment_Email_to_Sochy</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Assignment_Sochy</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Account_Project_Manager__c</field>
            <operation>startsWith</operation>
            <value>Sochy</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notContain</operation>
            <value>Closed - Resolved,Closed - Canceled,Closed - Future,closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Close_Case_Mark_as_Future__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This will route cases to Sochy</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Comment Email to CC</fullName>
        <actions>
            <name>Case_Comment_Email_to_CC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When there is a CC on a case, this wil send an email to the CC person</description>
        <formula>AND( 
NOT(ISBLANK(CC_on_Cases__c)),
ISCHANGED(Last_Case_Comment_Date_Time__c)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Email Notification - Internal ETC</fullName>
        <actions>
            <name>New_Case_Internal_ETC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Email_Origin__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Client_Email_to_Case__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Record Type Blank</fullName>
        <actions>
            <name>Update_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Last Email from Client</fullName>
        <actions>
            <name>New_Email_Received_on_Case_Alert_Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( Last_Email_By__c = &quot;Client&quot; , ISCHANGED(Last_Email_Date__c) ,
 Last_Email_Date__c &lt;&gt; CreatedDate )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Case - Email Notification To Client</fullName>
        <actions>
            <name>New_Case_Email_Notification_To_Client</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>On Hold - Waiting on Client - Email Notification To Client</fullName>
        <actions>
            <name>On_Hold_Waiting_on_Client_Email_Alert_to_Client</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold - Waiting on Client</value>
        </criteriaItems>
        <description>This workflow rule sends an email to the client when the status of a case if moved to On Hold - Waiting on Client.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate CC on Case</fullName>
        <actions>
            <name>CC_on_Cases</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reopen Case when comment received</fullName>
        <actions>
            <name>Change_Status_to_Open_New</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_Reopened_from_case_comm1ent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
CONTAINS(text(Status), &quot;Closed&quot;),
Last_Comment_By__c = &quot;Client&quot; ,
 ISCHANGED( Last_Case_Comment__c )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reopen Case when email received</fullName>
        <actions>
            <name>Change_Status_to_Open_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_Reopened_from_case_comm1ent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
CONTAINS(text(Status), &quot;Closed&quot;),
 Last_Email_By__c = &quot;Client&quot; ,
 ISCHANGED( Last_Email_Text_Body__c  )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status Change Email</fullName>
        <actions>
            <name>Status_Change_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ischanged( Status )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Take Case off hold when comment received</fullName>
        <actions>
            <name>Update_case_to_Open_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
CONTAINS(text(Status), &quot;Hold&quot;),
Last_Comment_By__c = &quot;Client&quot; ,
 ISCHANGED( Last_Case_Comment__c )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Status Date - When Status Changes</fullName>
        <actions>
            <name>Update_Status_Date_When_Status_Changes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This will fire each time the status changes</description>
        <formula>OR(
ISNEW(),
  ISCHANGED(Status) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

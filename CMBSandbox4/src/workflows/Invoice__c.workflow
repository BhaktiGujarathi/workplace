<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_to_PM_to_review_invoice</fullName>
        <description>Email Alert to PM to review invoice</description>
        <protected>false</protected>
        <recipients>
            <field>Project_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Office_Managers</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Invoice_Templates/Invoice_Open_PM_Review</template>
    </alerts>
    <alerts>
        <fullName>Invoice_Alert_Email_Ongoing</fullName>
        <description>Invoice Alert Email - Ongoing</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Invoice_Templates/Email_for_Invoice_Alert</template>
    </alerts>
    <alerts>
        <fullName>Invoice_Open_Approved_Ready_to_Send_Alert_email</fullName>
        <description>Invoice Open - Approved &amp; Ready to Send	 (Alert email)</description>
        <protected>false</protected>
        <recipients>
            <recipient>Office_Managers</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Invoice_Templates/Invoice_Open_Approved_Ready_to_Send</template>
    </alerts>
    <alerts>
        <fullName>Invoice_Open_HA_Review_Alert_email</fullName>
        <description>Invoice Open - HA Review (Alert email)</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ingrid@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Invoice_Templates/Invoice_Open_HA_Review</template>
    </alerts>
    <alerts>
        <fullName>Invoice_Open_Pending_Credit_Cancel</fullName>
        <description>Invoice Open - Pending Credit &amp; Cancel</description>
        <protected>false</protected>
        <recipients>
            <recipient>Office_Managers</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Invoice_Open_Pending_Credit_Cancel</template>
    </alerts>
    <alerts>
        <fullName>Invoice_Open_Pending_Revision</fullName>
        <description>Invoice Open - Pending Revision</description>
        <protected>false</protected>
        <recipients>
            <recipient>Office_Managers</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Invoice_Templates/Invoice_Open_Pending_Revision</template>
    </alerts>
    <alerts>
        <fullName>Invoice_Payment_Information</fullName>
        <description>Invoice Payment Information</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Invoice_Payment_Details</template>
    </alerts>
    <alerts>
        <fullName>Open_PM_Review_Way_Past_Due_Over_18_Days</fullName>
        <description>Open PM Review Way Past Due (Over 18 Days)</description>
        <protected>false</protected>
        <recipients>
            <recipient>Office_Managers</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Invoice_Templates/Invoice_In_PM_Review_for_Too_Long</template>
    </alerts>
    <alerts>
        <fullName>Reminder_2_Open_PM_Review</fullName>
        <description>Reminder #2 - Open PM Review</description>
        <protected>false</protected>
        <recipients>
            <field>Project_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Office_Managers</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Invoice_Templates/Reminder_2_Invoice_Open_PM_Review</template>
    </alerts>
    <alerts>
        <fullName>Reminder_3_Open_PM_Review</fullName>
        <description>Reminder #3 - Open PM Review</description>
        <protected>false</protected>
        <recipients>
            <field>Project_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Office_Managers</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Invoice_Templates/Reminder_3_Invoice_Open_PM_Review</template>
    </alerts>
    <alerts>
        <fullName>Reminder_Open_PM_Revieq</fullName>
        <description>Reminder #1 - Open PM Review</description>
        <protected>false</protected>
        <recipients>
            <field>Project_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Office_Managers</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Invoice_Templates/Reminder_1_Invoice_Open_PM_Review</template>
    </alerts>
    <fieldUpdates>
        <fullName>Status_Change_to_Partially_Paid</fullName>
        <field>Status__c</field>
        <literalValue>Partially Paid</literalValue>
        <name>Status Change to Partially Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_Contact_to_CC_on_Invoices</fullName>
        <field>Billing_Contact_CC_Email__c</field>
        <formula>Opportunity__r.Client_Contact_CC_On_Invoices__r.Email</formula>
        <name>Update Billing Contact to CC on Invoices</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Description_on_Invoice_with_Proje</fullName>
        <field>Description_On_Invoice__c</field>
        <formula>Project__r.Name</formula>
        <name>Update Description on Invoice with Proje</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Internal_Notes_History</fullName>
        <field>Internal_Notes_History__c</field>
        <formula>&quot; --- [&quot; &amp; TEXT(today()) &amp;&quot; &quot;&amp;  LastModifiedBy.FirstName  &amp;&quot; &quot;&amp;  LastModifiedBy.LastName  &amp;&quot;]: &quot; &amp; BR()  &amp; Internal_Notes__c &amp;&quot; -- ||  &quot; &amp; 
BR() 
&amp;
 PRIORVALUE( Internal_Notes_History__c )</formula>
        <name>Update Internal Notes History</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Amount_When_Sent</fullName>
        <field>Invoice_Amt_when_Sent__c</field>
        <formula>Price_Conga__c</formula>
        <name>Update Invoice Amount When Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Status_Date</fullName>
        <field>Status_Date__c</field>
        <formula>today()</formula>
        <name>Update Invoice Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Status_to_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Open - Approved &amp; Ready to Send</literalValue>
        <name>Update Invoice Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Terms_Due_on_Receipt</fullName>
        <field>Terms__c</field>
        <formula>&quot;Due on Receipt&quot;</formula>
        <name>Update Invoice Terms &quot;Due on Receipt&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PM_Email_Field</fullName>
        <field>Project_Manager_Email__c</field>
        <formula>Project_Harvest__r.ClientProjectManager__r.Email</formula>
        <name>Update PM Email Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Terms_on_Invoices</fullName>
        <field>Terms__c</field>
        <formula>IF(
TEXT(Invoice_Type__c  )=&quot;Deposit&quot;,&quot;Due on Receipt&quot;,

TEXT(Opportunity__r.Terms__c )
)</formula>
        <name>Update Terms on Invoices</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Invoice - Update field with Description from Project</fullName>
        <actions>
            <name>Update_Description_on_Invoice_with_Proje</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Invoice__c.Description_On_Invoice__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Amount When Sent</fullName>
        <actions>
            <name>Update_Invoice_Amount_When_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Status__c</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Status %3D Open - Approved %26 Ready to Send %28Alert%29</fullName>
        <actions>
            <name>Invoice_Open_Approved_Ready_to_Send_Alert_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Status__c</field>
            <operation>equals</operation>
            <value>Open - Approved &amp; Ready to Send</value>
        </criteriaItems>
        <description>Email HM when ready to send</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Status %3D Open - Pending Credit %26 Cancel %28Alert%29</fullName>
        <actions>
            <name>Invoice_Open_Pending_Credit_Cancel</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Status__c</field>
            <operation>equals</operation>
            <value>Open - Pending Credit &amp; Cancel</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Status %3D Open - Pending Revision %28Alert%29</fullName>
        <actions>
            <name>Invoice_Open_Pending_Revision</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Status__c</field>
            <operation>equals</operation>
            <value>Open - Pending Revision</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Status %3D Open HA Review %28Alert%29</fullName>
        <actions>
            <name>Invoice_Open_HA_Review_Alert_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Status__c</field>
            <operation>equals</operation>
            <value>Open - HA Review</value>
        </criteriaItems>
        <description>Email HA when ready for his review</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Status %3D Open PM Review %28Alert%29</fullName>
        <actions>
            <name>Email_Alert_to_PM_to_review_invoice</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Status__c</field>
            <operation>equals</operation>
            <value>Open - PM Review</value>
        </criteriaItems>
        <description>Email PM when ready for review</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_2_Open_PM_Review</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Reminder_2_Invoice_Open_PM_Review</name>
                <type>Task</type>
            </actions>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_3_Open_PM_Review</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Reminder_3_Invoice_Open_PM_Review</name>
                <type>Task</type>
            </actions>
            <timeLength>15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Open_PM_Review_Way_Past_Due_Over_18_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>18</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_Open_PM_Revieq</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Reminder_1_Invoice_Open_PM_Review</name>
                <type>Task</type>
            </actions>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Invoice Status - Change To Partially Paid</fullName>
        <actions>
            <name>Invoice_Payment_Information</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Status_Change_to_Partially_Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Change Invoice status to 
Partially Paid if (Invoice Amount Paid &lt; Invoice Amount &amp; Amount Paid &gt; 0)</description>
        <formula>AND(  Total_Amount_Due__c  &lt; Price_Conga__c,  Total_Amount_Due__c  &lt;&gt; 0.00, Price_Conga__c &lt;&gt; 0.00)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update CC Client Email Address on Incovoice</fullName>
        <actions>
            <name>Update_Billing_Contact_to_CC_on_Invoices</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Client_Contact_CC_On_Invoices__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Internal Notes History Field</fullName>
        <actions>
            <name>Update_Internal_Notes_History</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
ISCHANGED(Internal_Notes__c ), NOT(ISBLANK(Internal_Notes__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Invoice Status to Approved</fullName>
        <actions>
            <name>Update_Invoice_Status_to_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Approved_to_Send__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update PM Email Field</fullName>
        <actions>
            <name>Update_PM_Email_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(
ISNEW(),
ISCHANGED( Project_Harvest__c )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Status Date</fullName>
        <actions>
            <name>Update_Invoice_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Eeach time the status field changes, it should update the Status Date field</description>
        <formula>OR(
TEXT(Status__c) &lt;&gt; &quot;&quot;,
 ISCHANGED(Status__c)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Terms on Invoices</fullName>
        <actions>
            <name>Update_Terms_on_Invoices</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Terms__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Terms on Invoices with Type%3D%22Deposit%22</fullName>
        <actions>
            <name>Update_Invoice_Terms_Due_on_Receipt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice__c.Invoice_Type__c</field>
            <operation>equals</operation>
            <value>Deposit</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Reminder_1_Invoice_Open_PM_Review</fullName>
        <assignedTo>ronnie@cloudmybiz.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>This is just logging that an email has gone out</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Reminder #1: Invoice Open - PM Review</subject>
    </tasks>
    <tasks>
        <fullName>Reminder_2_Invoice_Open_PM_Review</fullName>
        <assignedTo>ronnie@cloudmybiz.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>This is just logging that an email has gone out</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Reminder #2: Invoice Open - PM Review</subject>
    </tasks>
    <tasks>
        <fullName>Reminder_3_Invoice_Open_PM_Review</fullName>
        <assignedTo>ronnie@cloudmybiz.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>This is just logging that an email has gone out</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Reminder #3: Invoice Open - PM Review</subject>
    </tasks>
</Workflow>

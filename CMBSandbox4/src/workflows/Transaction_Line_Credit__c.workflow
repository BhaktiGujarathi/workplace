<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Invoice_Payment_Confirmation</fullName>
        <ccEmails>henry@cloudmybiz.com,accounting@cloudmybiz.com</ccEmails>
        <description>Invoice Payment Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Billing_Contact_s_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>accounting@cloudmybiz.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Invoice_Templates/Invoice_Payment_Confirmation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Invoice_Date_Paid</fullName>
        <description>Update Invoice Paid Date by Last Transaction date against particular invoice</description>
        <field>Date_Paid__c</field>
        <formula>Date__c</formula>
        <name>Invoice Date Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Invoice__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Invoice_Status_To_Paid</fullName>
        <field>Status__c</field>
        <literalValue>Paid</literalValue>
        <name>Invoice Status To Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Invoice__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_Contact_Email_Address</fullName>
        <field>Billing_Contact_s_Email__c</field>
        <formula>Invoice__r.Billing_Contact__r.Email</formula>
        <name>Update Billing Contact Email Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Paid_Amount</fullName>
        <field>Invoice_Amount_Paid__c</field>
        <formula>Invoice__r.Invoice_Amount_Paid__c +  Amount__c</formula>
        <name>Update Invoice Paid Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Invoice__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Invoice Amount Paid - Update Status To Paid and DatePaid To Last TLI Date</fullName>
        <actions>
            <name>Invoice_Date_Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Invoice_Status_To_Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Invoice Status Paid if Invoice Status Changed to Paid
and update Invoice.DatePaid to Transction Line Item.Paid Date</description>
        <formula>AND(Invoice__r.Amount_Due__c - Amount__c = 0 ,Amount__c&gt;0,Invoice__r.Amount_Due__c &gt; 0)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Invoice Payment Confirmation - Email Client</fullName>
        <actions>
            <name>Invoice_Payment_Confirmation</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_Notificaiton_Invoice_Payment_Confirmation</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Transaction_Line_Credit__c.Amount__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Transaction_Line_Credit__c.Override_Workflow_Email_Alert__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This wil send out an email when a new transaction credit is logged</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate the Billing Contact email when TLC is created</fullName>
        <actions>
            <name>Update_Billing_Contact_Email_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Transaction__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit</value>
        </criteriaItems>
        <description>This will populate the Billing Contact Email when a transaction line item (credit) is created</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Invoice Record</fullName>
        <actions>
            <name>Update_Invoice_Paid_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Transaction_Line_Credit__c.Amount__c</field>
            <operation>greaterThan</operation>
            <value>0.00</value>
        </criteriaItems>
        <description>On Transaction Credit Line Items, 
1) update total invoice paid amount against the invoice
2) If Payment completed then update DatePaid and status to Paid else status to partially paid</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Email_Notificaiton_Invoice_Payment_Confirmation</fullName>
        <assignedTo>ronnie@cloudmybiz.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email Notificaiton: Invoice Payment Confirmation</subject>
    </tasks>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Bill_Paid_date_Today</fullName>
        <field>Date_Paid__c</field>
        <formula>Today()</formula>
        <name>Bill Paid date = Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Bill_Status_To_Paid2</fullName>
        <field>Status__c</field>
        <literalValue>Paid</literalValue>
        <name>Bill Status To Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Change_to_Partially_Paid</fullName>
        <field>Status__c</field>
        <literalValue>Paid - Partial</literalValue>
        <name>Status Change to Partially Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_AP_Group_on_Bill</fullName>
        <field>AP_Group1__c</field>
        <formula>TEXT(Vendor__r.AP_Group__c )</formula>
        <name>Update AP Group on Bill</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Bill Status - Change To Partially Paid</fullName>
        <actions>
            <name>Status_Change_to_Partially_Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( Bill_Amount_Due__c  &lt;  Amount_Due__c  , Bill_Amount_Due__c &lt;&gt; 0.00, Amount_Due__c &lt;&gt; 0.00)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Bill paid - Update Date Paid</fullName>
        <actions>
            <name>Bill_Paid_date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bill__c.Status__c</field>
            <operation>equals</operation>
            <value>Paid</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Bill%3A Update AP Group on Bill</fullName>
        <actions>
            <name>Update_AP_Group_on_Bill</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bill__c.AP_Group1__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Change the status to Paid if Balance Amount %3D 0</fullName>
        <actions>
            <name>Bill_Status_To_Paid2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bill__c.Bill_Amount_Due__c</field>
            <operation>equals</operation>
            <value>0.00</value>
        </criteriaItems>
        <description>Change the status to Paid if Balance Amount = 0 (Bill Amount Due)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

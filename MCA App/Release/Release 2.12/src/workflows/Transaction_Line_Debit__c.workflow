<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Payable Status to Paid</fullName>
        <field>Status__c</field>
        <literalValue>Paid</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Payable__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Payable Paid Date</fullName>
        <description>Updates the Date Paid of Payable</description>
        <field>Date_Paid__c</field>
        <formula>Today()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Payable__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Transaction line Debit Date</fullName>
        <description>updates the Date of Transaction Line Debit</description>
        <field>Date__c</field>
        <formula>IF( ISNULL(Date__c), TODAY(), Date__c)</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Payable Amount Paid - Update Status To Paid</fullName>
        <actions>
            <name>Payable Status to Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>On Transaction Debit Line Items, 
If Payment is done then update the status to Paid on Payable</description>
        <formula>AND( Payable__r.Bill_Amount_Due__c -  Amount__c = 0)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Payable Date Paid</fullName>
        <actions>
            <name>Update Payable Paid Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update Transaction line Debit Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Transaction_Line_Debit__c.Amount__c</field>
            <operation>greaterThan</operation>
            <value>0.00</value>
        </criteriaItems>
        <description>updates Date Paid of Payable when Transaction Line Debit created or updated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Receivable Status To Paid</fullName>
        <field>Status__c</field>
        <literalValue>Paid</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Receivable__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Receivable Paid Amount</fullName>
        <field>Receivable_Amount_Paid__c</field>
        <formula>IF( ISNULL( Receivable__r.Receivable_Amount_Paid__c ),0,Receivable__r.Receivable_Amount_Paid__c ) +  Amount__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Receivable__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Receivable Paid Date</fullName>
        <field>Date_Paid__c</field>
        <formula>TODAY()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Receivable__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Receivable Amount Paid - Update Status To Paid</fullName>
        <actions>
            <name>Receivable Status To Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>On Transaction Credit Line Items,
 If Payment  is done then update status to Paid on Receivable</description>
        <formula>AND( Receivable__r.Amount_Due__c - Amount__c =0)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Receivable Record</fullName>
        <actions>
            <name>Update Receivable Paid Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update Receivable Paid Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Transaction_Line_Credit__c.Amount__c</field>
            <operation>notEqual</operation>
            <value>0.00</value>
        </criteriaItems>
        <description>Update total Receivable paid amount</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

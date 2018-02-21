<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update Date Paid</fullName>
        <field>Date_Paid__c</field>
        <formula>TODAY()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Invoice Date</fullName>
        <field>Date_Sent__c</field>
        <formula>Opportunity__r.Date_Funded__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Receivable Date Paid</fullName>
        <field>Date_Paid__c</field>
        <formula>TODAY()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Receivable Update Date Paid</fullName>
        <actions>
            <name>Update Receivable Date Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Receivable__c.Status__c</field>
            <operation>equals</operation>
            <value>Paid</value>
        </criteriaItems>
        <description>Update the Date Paid field of Receivable when Receivable Status = Paid</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Receivable Update Date Paid when Status is Paid</fullName>
        <actions>
            <name>Update Date Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Receivable__c.Status__c</field>
            <operation>equals</operation>
            <value>Paid</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Receivable%3ESet funded date on create</fullName>
        <actions>
            <name>Update Invoice Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow will populate the Invoice Date on a Receivable with the Funded Date of the related Opportunity</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

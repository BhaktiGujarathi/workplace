<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update Transaction Status to Paid</fullName>
        <field>Status__c</field>
        <literalValue>Completed</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Transaction Status to Pending</fullName>
        <field>Status__c</field>
        <literalValue>Pending</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateTransactionDateToToday</fullName>
        <field>Date__c</field>
        <formula>today()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Transaction %3E Update Today%27s Date When No Date Is Entered</fullName>
        <actions>
            <name>UpdateTransactionDateToToday</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Transaction__c.Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Transaction Status to Paid</fullName>
        <actions>
            <name>Update Transaction Status to Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( Amount__c  =  Total_Transaction_Credits__c,Amount__c =  Total_Transaction_Debits__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Transaction Status to pending</fullName>
        <actions>
            <name>Update Transaction Status to Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(Amount__c != Total_Transaction_Credits__c, Amount__c != Total_Transaction_Debits__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update Status to Pause</fullName>
        <field>Status__c</field>
        <literalValue>Pause</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Payment_Setting__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Update%3A Payment Setting Status to Pause</fullName>
        <actions>
            <name>Update Status to Pause</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ACH_Transaction__c.Status__c</field>
            <operation>equals</operation>
            <value>Failed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>StipStatusUpdateToComplete</fullName>
        <field>Status__c</field>
        <literalValue>Completed</literalValue>
        <name>StipStatusUpdateToComplete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Stip %3EGRIDStatusUpdateToCompleted</fullName>
        <actions>
            <name>StipStatusUpdateToComplete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Changes the Status field of Stips object to &apos;Completed&apos; once attachement Ids field is not blank</description>
        <formula>NOT(ISNULL( Attachments_IDs__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

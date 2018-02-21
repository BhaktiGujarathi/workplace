<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>GRIDStatusUpdateToComplete</fullName>
        <field>Status__c</field>
        <literalValue>Completed</literalValue>
        <name>GRIDStatusUpdateToComplete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Stips__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Stip Attachment%3EGRIDStatusUpdateToCompleted</fullName>
        <actions>
            <name>GRIDStatusUpdateToComplete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Stips__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Changes the Status field of Stips object to &apos;Completed&apos; on creation of Stip Attachment record.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

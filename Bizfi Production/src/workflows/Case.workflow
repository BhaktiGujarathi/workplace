<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>New_SFDC_Case</fullName>
        <field>OwnerId</field>
        <lookupValue>System_Admin_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>New SFDC Case</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>New SFDC Case</fullName>
        <actions>
            <name>New_SFDC_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Chatter</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

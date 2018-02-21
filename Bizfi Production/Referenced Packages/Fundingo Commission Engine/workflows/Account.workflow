<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_unique_user</fullName>
        <field>UniqueUser__c</field>
        <formula>McaApp__User__c</formula>
        <name>Set unique user</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Account%3ESet unique user</fullName>
        <actions>
            <name>Set_unique_user</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISCHANGED( McaApp__User__c ) , ISNEW()  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

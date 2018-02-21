<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Public_Records_Name_Update</fullName>
        <field>Name</field>
        <formula>(  Type__c  )</formula>
        <name>Public Records Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>true</protected>
    </fieldUpdates>
    <rules>
        <fullName>Public Records Name Update</fullName>
        <actions>
            <name>Public_Records_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Public_Records__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Lead_Mapping_Created_Date_Field</fullName>
        <field>Lead_Created_Date_Copy_for_Mapping__c</field>
        <formula>datevalue(CreatedDate)</formula>
        <name>Lead - Mapping Created Date Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Lead - Populate Created Date to Mapping</fullName>
        <actions>
            <name>Lead_Mapping_Created_Date_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

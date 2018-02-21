<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Lead Created Date %28Copy for Mapping%29</fullName>
        <field>Lead_Created_Date_Copy_for_Mapping__c</field>
        <formula>CreatedDate</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Lead Created Date %28Copy for Mapping%29</fullName>
        <actions>
            <name>Lead Created Date %28Copy for Mapping%29</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

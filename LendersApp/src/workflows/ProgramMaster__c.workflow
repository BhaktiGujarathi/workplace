<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ProgramMasterNameUpdate</fullName>
        <field>Name</field>
        <formula>TEXT(Program_Type__c) +&apos;-&apos;+ TEXT(Term__c)</formula>
        <name>ProgramMasterNameUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ProgramMasterNameUpdate</fullName>
        <actions>
            <name>ProgramMasterNameUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>Id !=null</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

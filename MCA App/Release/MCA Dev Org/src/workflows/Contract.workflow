<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateContractName</fullName>
        <description>Updates the Contract Name with associated Opportunity Name</description>
        <field>Name</field>
        <formula>IF(  ISNULL(Opportunity__c) , &apos;&apos;,  Opportunity__r.Name )</formula>
        <name>UpdateContractName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contract %3E set Contract Name</fullName>
        <actions>
            <name>UpdateContractName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.Name</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>This workflow Rule updates the Contract Name with associated Opportunity Name.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Monthly Sales to Annual Revenue</fullName>
        <field>AnnualRevenue</field>
        <formula>Gross_monthly_Sales__c *12</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Record Type</fullName>
        <description>Update Account Record Type on conversion</description>
        <field>RecordTypeId</field>
        <lookupValue>Merchant</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account%3ESet Converted Account Record Type</fullName>
        <actions>
            <name>Update Record Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ConvertedAccount__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When Lead is converted, set stage of created Account to &apos;Merchant&apos;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Gross Monthly Sales To Annual Revenue</fullName>
        <actions>
            <name>Monthly Sales to Annual Revenue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>or(and( not(isnull(Gross_monthly_Sales__c )),isnull( AnnualRevenue )),and(ischanged(Gross_monthly_Sales__c),not(isnull(Gross_monthly_Sales__c))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>testwf</fullName>
        <active>false</active>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

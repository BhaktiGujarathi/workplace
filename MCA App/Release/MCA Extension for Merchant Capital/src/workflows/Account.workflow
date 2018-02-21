<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Monthly Sales to Annual Revenue</fullName>
        <field>AnnualRevenue</field>
        <formula>McaApp__Gross_monthly_Sales__c *12</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Record Type</fullName>
        <description>Update Account Record Type on conversion</description>
        <field>RecordTypeId</field>
        <lookupValue>McaApp__Merchant</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>McaApp__Account%3ESet Converted Account Record Type</fullName>
        <actions>
            <name>McaApp__Update Record Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.McaApp__ConvertedAccount__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When Lead is converted, set stage of created Account to &apos;Merchant&apos;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Gross Monthly Sales To Annual Revenue</fullName>
        <actions>
            <name>McaApp__Monthly Sales to Annual Revenue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>or(and( not(isnull(McaApp__Gross_monthly_Sales__c )),isnull( AnnualRevenue )),and(ischanged(McaApp__Gross_monthly_Sales__c),not(isnull(McaApp__Gross_monthly_Sales__c))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

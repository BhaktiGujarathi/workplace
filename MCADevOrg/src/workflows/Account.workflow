<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Monthly_Sales_to_Annual_Revenue</fullName>
        <field>AnnualRevenue</field>
        <formula>Gross_monthly_Sales__c *12</formula>
        <name>Monthly Sales to Annual Revenue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type</fullName>
        <description>Update Account Record Type on conversion</description>
        <field>RecordTypeId</field>
        <lookupValue>Merchant</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account%3ESet Converted Account Record Type</fullName>
        <actions>
            <name>Update_Record_Type</name>
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
            <name>Monthly_Sales_to_Annual_Revenue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow rule updates the Annual Revenue of Account</description>
        <formula>or(and( not(isnull(Gross_monthly_Sales__c )),isnull( AnnualRevenue )),and(ischanged(Gross_monthly_Sales__c),not(isnull(Gross_monthly_Sales__c))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>test</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Account.Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>testwf</fullName>
        <active>false</active>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

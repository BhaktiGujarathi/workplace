<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Lead_Created_Date_Copy_for_Mapping</fullName>
        <field>Lead_Created_Date_Copy_for_Mapping__c</field>
        <formula>CreatedDate</formula>
        <name>Lead Created Date (Copy for Mapping)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Annual_Revenue_by_Monthly_Gross</fullName>
        <field>AnnualRevenue</field>
        <formula>Monthly_Gross_Sales__c * 12</formula>
        <name>Update Annual Revenue by Monthly Gross</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Desired_Amount_with_Amount_R</fullName>
        <field>Desired_Amount__c</field>
        <formula>Amount_Requested__c</formula>
        <name>Update Lead Desired Amount with Amount R</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Lead Created Date %28Copy for Mapping%29</fullName>
        <actions>
            <name>Lead_Created_Date_Copy_for_Mapping</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Annual Revenue by Monthly Gross</fullName>
        <actions>
            <name>Update_Annual_Revenue_by_Monthly_Gross</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.AnnualRevenue</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Monthly_Gross_Sales__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When left blank, the Annual Rev will be updated by the Monthly gross Sales</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Lead Desired Amount with Amount Requested</fullName>
        <actions>
            <name>Update_Lead_Desired_Amount_with_Amount_R</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Amount_Requested__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Desired_Amount__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>When Desired amount is blank,  Update Lead Desired Amount with Amount Requested</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

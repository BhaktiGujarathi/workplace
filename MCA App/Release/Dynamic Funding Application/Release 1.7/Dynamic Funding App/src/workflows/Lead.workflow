<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Lead Created Date %28Copy for Mapping%29</fullName>
        <field>McaApp__Lead_Created_Date_Copy_for_Mapping__c</field>
        <formula>CreatedDate</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Annual Revenue by Monthly Gross</fullName>
        <field>AnnualRevenue</field>
        <formula>McaApp__Monthly_Gross_Sales__c * 12</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Lead Desired Amount with Amount R</fullName>
        <field>McaApp__Desired_Amount__c</field>
        <formula>McaApp__Amount_Requested__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update custom lead description field</fullName>
        <field>McaApp__LeadDescriptionToMap__c</field>
        <formula>Description</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>McaApp__Lead Created Date %28Copy for Mapping%29</fullName>
        <actions>
            <name>McaApp__Lead Created Date %28Copy for Mapping%29</name>
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
        <fullName>McaApp__Lead%3ELead Description To Map</fullName>
        <actions>
            <name>McaApp__Update custom lead description field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Description</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update Annual Revenue by Monthly Gross</fullName>
        <actions>
            <name>McaApp__Update Annual Revenue by Monthly Gross</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.AnnualRevenue</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.McaApp__Monthly_Gross_Sales__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When left blank, the Annual Rev will be updated by the Monthly gross Sales</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update Lead Desired Amount with Amount Requested</fullName>
        <actions>
            <name>McaApp__Update Lead Desired Amount with Amount R</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.McaApp__Amount_Requested__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.McaApp__Desired_Amount__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>When Desired amount is blank,  Update Lead Desired Amount with Amount Requested</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

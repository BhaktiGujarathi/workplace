<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateOpportunityAmount</fullName>
        <field>Amount</field>
        <formula>IF( Opportunity__r.Amount  &gt;  Amount__c , Opportunity__r.Amount, Amount__c)</formula>
        <name>UpdateOpportunityAmount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateOpportunityFundingAmount</fullName>
        <field>Funding_Amount__c</field>
        <formula>IF( Opportunity__r.Funding_Amount__c &gt;  Amount__c  , Opportunity__r.Funding_Amount__c, Amount__c)</formula>
        <name>UpdateOpportunityFundingAmount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Offer_On_Opportuntiy</fullName>
        <field>Offer__c</field>
        <formula>Name+Details__c+Funder__r.Name+TEXT( Amount__c)</formula>
        <name>Update Offer On Opportuntiy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Offer %3E Set Funder</fullName>
        <active>false</active>
        <formula>NOT(ISNULL(Submission__r.Funder__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Offer %3E Set Opportunity Funding Amount</fullName>
        <actions>
            <name>UpdateOpportunityAmount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Offer__c.Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update the Opportunity Funding Amount</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Offer On Opportuntiy</fullName>
        <actions>
            <name>Update_Offer_On_Opportuntiy</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Offer__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

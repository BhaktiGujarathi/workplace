<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Opportunity_Stage_Approved</fullName>
        <field>StageName</field>
        <literalValue>Approved</literalValue>
        <name>Opportunity - Stage Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submission_Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Submission Status - Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Submission__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submission_Status_Date</fullName>
        <field>Status_Date__c</field>
        <formula>today()</formula>
        <name>Submission Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Submission__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateOpportunityAmount</fullName>
        <field>Amount</field>
        <formula>IF(Opportunity__r.Amount  &gt;  Amount__c, Opportunity__r.Amount, Amount__c)</formula>
        <name>UpdateOpportunityAmount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
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
        <description>Update the Opportunity Amount with highest Offer Funding Amount</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Offer - Submission Approved</fullName>
        <actions>
            <name>Opportunity_Stage_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Submission_Status_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Submission_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Submission__c.Status__c</field>
            <operation>equals</operation>
            <value>UW</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Underwriting</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

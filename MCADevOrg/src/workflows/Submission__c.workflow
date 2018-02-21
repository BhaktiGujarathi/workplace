<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_stage_to_approved</fullName>
        <field>StageName</field>
        <literalValue>Approved</literalValue>
        <name>Set stage to approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateSubmissionStatusDate</fullName>
        <description>Updates the Submission status Date when Submission created or Submission Status is changed</description>
        <field>Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>UpdateSubmissionStatusDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Submission %3E Set Opportunity Stage to Approved</fullName>
        <actions>
            <name>Set_stage_to_approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Submission__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Submission %3E set Status Date</fullName>
        <actions>
            <name>UpdateSubmissionStatusDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow rule updates the Submission Status Date to Today when created or changed the Status value</description>
        <formula>OR( ISNEW() , ISCHANGED( Status__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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

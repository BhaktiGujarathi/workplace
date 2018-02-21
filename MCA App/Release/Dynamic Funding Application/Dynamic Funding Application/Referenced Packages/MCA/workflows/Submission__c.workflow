<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Opportunity_Stage_to_Approved</fullName>
        <description>The field update will set Opportunity Stage to &quot;Approved&quot;.</description>
        <field>StageName</field>
        <literalValue>Approved</literalValue>
        <name>Set Opportunity Stage to Approved</name>
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
    <fieldUpdates>
        <fullName>Update_Opportunity_stage_to_Underwriting</fullName>
        <field>StageName</field>
        <literalValue>Underwriting</literalValue>
        <name>Update Opportunity stage to Underwriting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Submission %3E Set Opportunity Stage to Approved</fullName>
        <actions>
            <name>Set_Opportunity_Stage_to_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Submission__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>The workflow will set Opportunity stage to &quot;Approved&quot; whenever a Submission record is created or updated and its status is &quot;Approved&quot;.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Submission %3E set Status Date</fullName>
        <actions>
            <name>UpdateSubmissionStatusDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow rule updates the Submission Status Date to Today when created or changed the Status value</description>
        <formula>OR( ISNEW() , ISCHANGED( Status__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Opportunity to Underwriting</fullName>
        <actions>
            <name>Update_Opportunity_stage_to_Underwriting</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.No_of_Submission__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Prospecting,Application Sent,Application In,Application Missing Info,Declined,Closed Lost,Renewal Prospecting,Renewal Requested</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

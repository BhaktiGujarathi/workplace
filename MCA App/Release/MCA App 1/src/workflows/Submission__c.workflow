<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

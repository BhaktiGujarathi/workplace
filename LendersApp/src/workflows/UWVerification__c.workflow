<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Picklist_Status</fullName>
        <description>Update status picklist to Completed</description>
        <field>Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Picklist Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Workflow_Update_Flag</fullName>
        <field>Is_WF_Firing_Trigger__c</field>
        <literalValue>1</literalValue>
        <name>Set Workflow Update Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status</fullName>
        <description>Completed checkbox to true when status = completed</description>
        <field>Completed__c</field>
        <literalValue>1</literalValue>
        <name>Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateVerificationStatus</fullName>
        <field>Status__c</field>
        <literalValue>Pending</literalValue>
        <name>UpdateVerificationStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Completed_on_UW_Vericiation</fullName>
        <description>Update: Date Completed on UW Vericiation</description>
        <field>Date_Completed__c</field>
        <formula>now()</formula>
        <name>Update: Date Completed on UW Vericiation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Verification_Auto_Assigned_To</fullName>
        <field>Assigned_To__c</field>
        <lookupValue>lendersdev@cloudmybiz.com.dev</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Verification: Auto Assigned To</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Verification Status</fullName>
        <actions>
            <name>UpdateVerificationStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update verification status to pending if completed checkbox uncheked form checked.</description>
        <formula>IF(AND( Completed__c  = false,  ISPICKVAL(Status__c, &apos;Completed&apos;)),true,false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Verification Status Checkbox</fullName>
        <actions>
            <name>Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UWVerification__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Verification Status Picklist</fullName>
        <actions>
            <name>Picklist_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UWVerification__c.Completed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update%3A Date Completed on UW Vericiations</fullName>
        <actions>
            <name>Set_Workflow_Update_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Date_Completed_on_UW_Vericiation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 3) AND 2</booleanFilter>
        <criteriaItems>
            <field>UWVerification__c.Completed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>UWVerification__c.Date_Completed__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>UWVerification__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Verification</fullName>
        <actions>
            <name>Verification_Auto_Assigned_To</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>UWVerification__c.Assigned_To__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

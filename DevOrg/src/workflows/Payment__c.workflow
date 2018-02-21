<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Payment_Running_Balance</fullName>
        <field>Running_Balance__c</field>
        <formula>IF(Is_Running_Balance_Applicable__c ||   Repayment__r.RecordType.Name = &apos;SPLITS&apos;, IF(Is_Payment__c || Repayment__r.RecordType.Name = &apos;SPLITS&apos;, Balance__c - Transaction_Amount__c, Balance__c + Transaction_Amount__c),0)</formula>
        <name>Payment Running Balance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Payment_Setting_Set_Settlement_Date</fullName>
        <field>Last_Settlement_Date__c</field>
        <formula>Settlement_Date__c</formula>
        <name>Payment Setting &gt; Set Settlement Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Repayment__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_ACH_Transaction_Check</fullName>
        <field>Check__c</field>
        <formula>$Setup.ACH_Public_Settings__c.Transaction_Check__c + &apos;#&apos; + TEXT(Repayment__r.Count_of_Transactions__c + 1)</formula>
        <name>Set ACH Transaction Check #</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Pause</fullName>
        <field>Status__c</field>
        <literalValue>Pause</literalValue>
        <name>Update Status to Pause</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Repayment__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Payment Running Balance</fullName>
        <actions>
            <name>Payment_Running_Balance</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Email when R02 Area Code</fullName>
        <actions>
            <name>CAll_Client_for_missed_payment</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Payment__c.Error_Code__c</field>
            <operation>notEqual</operation>
            <value>r02</value>
        </criteriaItems>
        <description>Send email to rep when there is a....</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set ACH Transaction Check %23</fullName>
        <actions>
            <name>Set_ACH_Transaction_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Last Settlement Date</fullName>
        <actions>
            <name>Payment_Setting_Set_Settlement_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Payment__c.Status__c</field>
            <operation>equals</operation>
            <value>Settled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update%3A Payment Setting Status to Pause</fullName>
        <actions>
            <name>Update_Status_to_Pause</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Payment__c.Status__c</field>
            <operation>equals</operation>
            <value>Failed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>CAll_Client_for_missed_payment</fullName>
        <assignedTo>dev1@mca.com.dev</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>CAll Client for missed payment</subject>
    </tasks>
</Workflow>

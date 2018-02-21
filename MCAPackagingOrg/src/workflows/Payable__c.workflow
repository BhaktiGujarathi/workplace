<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Payable_Update_Payee_Type_External</fullName>
        <field>Payee_Type__c</field>
        <literalValue>External</literalValue>
        <name>Payable&gt;Update Payee Type External</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Payable_Update_Payee_Type_Internal</fullName>
        <field>Payee_Type__c</field>
        <literalValue>Internal</literalValue>
        <name>Payable&gt;Update Payee Type Internal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Partial_Paid</fullName>
        <description>Payable Status to Partial Paid</description>
        <field>Status__c</field>
        <literalValue>Paid - Partial</literalValue>
        <name>Status to Partial Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Paid</fullName>
        <field>Date_Paid__c</field>
        <formula>TODAY()</formula>
        <name>Update Date Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Payable_Date</fullName>
        <field>Payable_Date__c</field>
        <formula>Opportunity__r.Date_Funded__c</formula>
        <name>Update Payable Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Partially Paid Payables</fullName>
        <actions>
            <name>Status_to_Partial_Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
   Bill_Amount_Due__c != 0,
   Bill_Amount_Paid__c != 0
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Payable Update Date Paid when Status is Paid</fullName>
        <actions>
            <name>Update_Date_Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Payable__c.Status__c</field>
            <operation>equals</operation>
            <value>Paid</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Payable%3ESet Payee Type to External</fullName>
        <actions>
            <name>Payable_Update_Payee_Type_External</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow will update Payee Type field on payable, set value from Account type.</description>
        <formula>Account__c != null &amp;&amp; ISPICKVAL(Account__r.Type, &apos;External&apos;) &amp;&amp;   Account__r.RecordType.DeveloperName == &apos;ISO&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Payable%3ESet Payee Type to Internal</fullName>
        <actions>
            <name>Payable_Update_Payee_Type_Internal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow will update Payee Type field on payable, set value Internal</description>
        <formula>Account__c != null &amp;&amp; ISPICKVAL(Account__r.Type, &apos;Internal&apos;) &amp;&amp; Account__r.RecordType.DeveloperName == &apos;ISO&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Payable%3ESet funded date on create</fullName>
        <actions>
            <name>Update_Payable_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow will populate the Payable Date on a Payable, if null, with the Funded Date of the related Opportunity</description>
        <formula>NOT(ISBLANK(Opportunity__r.Date_Funded__c) ) &amp;&amp;  ISBLANK( Payable_Date__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

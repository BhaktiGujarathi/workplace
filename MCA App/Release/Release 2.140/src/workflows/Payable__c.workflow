<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Payable%3EUpdate Payee Type External</fullName>
        <field>Payee_Type__c</field>
        <literalValue>External</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Payable%3EUpdate Payee Type Internal</fullName>
        <field>Payee_Type__c</field>
        <literalValue>Internal</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status to Partial Paid</fullName>
        <description>Payable Status to Partial Paid</description>
        <field>Status__c</field>
        <literalValue>Paid - Partial</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Date Paid</fullName>
        <field>Date_Paid__c</field>
        <formula>TODAY()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Payable Date</fullName>
        <field>Payable_Date__c</field>
        <formula>Opportunity__r.Date_Funded__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Partially Paid Payables</fullName>
        <actions>
            <name>Status to Partial Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(Bill_Amount_Due__c &lt;&gt; Amount_Due__c) 
&amp;&amp;
Bill_Amount_Due__c&lt;&gt;0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Payable Update Date Paid when Status is Paid</fullName>
        <actions>
            <name>Update Date Paid</name>
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
            <name>Payable%3EUpdate Payee Type External</name>
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
            <name>Payable%3EUpdate Payee Type Internal</name>
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
            <name>Update Payable Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow will populate the Payable Date on a Payable with the Funded Date of the related Opportunity</description>
        <formula>NOT(ISBLANK(Opportunity__r.Date_Funded__c) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

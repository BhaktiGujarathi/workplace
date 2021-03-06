<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set Payback Amount On Current Balance</fullName>
        <field>McaApp__Current_Balance_Amt__c</field>
        <formula>McaApp__Opportunity__r.McaApp__Payback_Amount__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set current date on Current Balance Date</fullName>
        <field>McaApp__Current_Balance_Date__c</field>
        <formula>TODAY()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stage to %27Eligible for Renewal%27</fullName>
        <description>This Field update sets the Contract Stage to &apos;Eligible for Renewal&apos;</description>
        <field>McaApp__Stage__c</field>
        <literalValue>Eligible for Renewal</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Unique flag</fullName>
        <field>McaApp__Unique_Flag__c</field>
        <formula>McaApp__Opportunity__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContractName</fullName>
        <description>Updates the Contract Name with associated Opportunity Name</description>
        <field>Name</field>
        <formula>IF( ISNULL(McaApp__Opportunity__c) , &apos;&apos;, McaApp__Opportunity__r.Name )</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>McaApp__Contract %3E Set Current Balance and Current Balance Date</fullName>
        <actions>
            <name>McaApp__Set Payback Amount On Current Balance</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>McaApp__Set current date on Current Balance Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>when contract is &quot;Funded&quot;, the Payback Amount will be set to Current Balance field and current date will be timestamped on current balance date field.</description>
        <formula>IF(AND(NOT(ISPICKVAL(PRIORVALUE(McaApp__Stage__c),&apos;Funded&apos;)),    ISPICKVAL(McaApp__Stage__c, &apos;Funded&apos;)),      True,      false )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Contract %3E Set Stage to %27Eligible for Renewal%27</fullName>
        <actions>
            <name>McaApp__Stage to %27Eligible for Renewal%27</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The workflow sets the Contract Stage to &apos;Eligible for Renewal&apos; when the criteria is met</description>
        <formula>McaApp__Current_Balance_Amt__c &lt;=  McaApp__Potential_Renewal_Amt__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Contract %3E Update Unique field</fullName>
        <actions>
            <name>McaApp__Update Unique flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Unique field on Contract with Opportunity Id</description>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Contract %3E set Contract Name</fullName>
        <actions>
            <name>McaApp__UpdateContractName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.Name</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>This workflow Rule updates the Contract Name with associated Opportunity Name.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

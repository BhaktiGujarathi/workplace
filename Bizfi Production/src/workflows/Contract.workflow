<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>McaApp__Set_Payback_Amount_On_Current_Balance</fullName>
        <description>@Deprecated</description>
        <field>McaApp__Current_Balance_Amt__c</field>
        <formula>McaApp__Opportunity__r.McaApp__Payback_Amount__c</formula>
        <name>Set Payback Amount On Current Balance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Set_current_date_on_Current_Balance_Date</fullName>
        <description>@Deprecated</description>
        <field>McaApp__Current_Balance_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set current date on Current Balance Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Stage_to_Eligible_for_Renewal</fullName>
        <description>@Deprecated - This Field update sets the Contract Stage to &apos;Eligible for Renewal&apos;</description>
        <field>McaApp__Stage__c</field>
        <literalValue>Eligible for Renewal</literalValue>
        <name>Stage to &apos;Eligible for Renewal&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__UpdateContractName</fullName>
        <description>@Deprecated - Updates the Contract Name with associated Opportunity Name</description>
        <field>Name</field>
        <formula>IF( ISNULL(McaApp__Opportunity__c) , &apos;&apos;, McaApp__Opportunity__r.Name )</formula>
        <name>UpdateContractName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Unique_flag</fullName>
        <description>@Deprecated</description>
        <field>McaApp__Unique_Flag__c</field>
        <formula>McaApp__Opportunity__c</formula>
        <name>Update Unique flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>McaApp__Contract %3E Set Current Balance and Current Balance Date</fullName>
        <actions>
            <name>McaApp__Set_Payback_Amount_On_Current_Balance</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>McaApp__Set_current_date_on_Current_Balance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>@Deprecated when contract is &quot;Funded&quot;, the Payback Amount will be set to Current Balance field and current date will be timestamped on current balance date field.</description>
        <formula>IF(AND(NOT(ISPICKVAL(PRIORVALUE(McaApp__Stage__c),&apos;Funded&apos;)),    ISPICKVAL(McaApp__Stage__c, &apos;Funded&apos;)),      True,      false )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Contract %3E Set Stage to %27Eligible for Renewal%27</fullName>
        <actions>
            <name>McaApp__Stage_to_Eligible_for_Renewal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>@Deprecated The workflow sets the Contract Stage to &apos;Eligible for Renewal&apos; when the criteria is met</description>
        <formula>McaApp__Current_Balance_Amt__c &lt;=  McaApp__Potential_Renewal_Amt__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Contract %3E Update Unique field</fullName>
        <actions>
            <name>McaApp__Update_Unique_flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>@Deprecated Update the Unique field on Contract with Opportunity Id</description>
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
        <description>@Deprecated This workflow Rule updates the Contract Name with associated Opportunity Name.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Payback_Amount_On_Current_Balance</fullName>
        <description>@Deprecated</description>
        <field>Current_Balance_Amt__c</field>
        <formula>Opportunity__r.Payback_Amount__c</formula>
        <name>Set Payback Amount On Current Balance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_current_date_on_Current_Balance_Date</fullName>
        <description>@Deprecated</description>
        <field>Current_Balance_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set current date on Current Balance Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stage_to_Eligible_for_Renewal</fullName>
        <description>@Deprecated - This Field update sets the Contract Stage to &apos;Eligible for Renewal&apos;</description>
        <field>Stage__c</field>
        <literalValue>Eligible for Renewal</literalValue>
        <name>Stage to &apos;Eligible for Renewal&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContractName</fullName>
        <description>@Deprecated - Updates the Contract Name with associated Opportunity Name</description>
        <field>Name</field>
        <formula>IF( ISNULL(Opportunity__c) , &apos;&apos;, Opportunity__r.Name )</formula>
        <name>UpdateContractName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unique_flag</fullName>
        <description>@Deprecated</description>
        <field>Unique_Flag__c</field>
        <formula>Opportunity__c</formula>
        <name>Update Unique flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Contract %3E Set Current Balance and Current Balance Date</fullName>
        <actions>
            <name>Set_Payback_Amount_On_Current_Balance</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_current_date_on_Current_Balance_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>@Deprecated when contract is &quot;Funded&quot;, the Payback Amount will be set to Current Balance field and current date will be timestamped on current balance date field.</description>
        <formula>IF(AND(NOT(ISPICKVAL(PRIORVALUE(Stage__c),&apos;Funded&apos;)),    ISPICKVAL(Stage__c, &apos;Funded&apos;)),      True,      false )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contract %3E Set Stage to %27Eligible for Renewal%27</fullName>
        <actions>
            <name>Stage_to_Eligible_for_Renewal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contract.CreatedById</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <description>@Deprecated The workflow sets the Contract Stage to &apos;Eligible for Renewal&apos; when the criteria is met</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Contract %3E Update Unique field</fullName>
        <actions>
            <name>Update_Unique_flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>@Deprecated Update the Unique field on Contract with Opportunity Id</description>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contract %3E set Contract Name</fullName>
        <actions>
            <name>UpdateContractName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contract.Name</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>@Deprecated This workflow Rule updates the Contract Name with associated Opportunity Name.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

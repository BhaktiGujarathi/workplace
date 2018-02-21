<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set Combination Format For Owner</fullName>
        <field>Combination_Key_For_Owner__c</field>
        <formula>IF(ISBLANK( AccountId),&apos;&apos;,AccountId +&apos;-&apos;)+ 

IF(ISBLANK(FirstName) ,&apos;&apos;,(FirstName +&apos;-&apos;)) +
IF(ISBLANK(LastName) ,&apos;&apos;,(LastName+&apos;-&apos;)) +
IF(ISBLANK(TEXT(Contact_Roles__c )),&apos;&apos;,(TEXT(Contact_Roles__c )))+ TEXT(NOW())</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Funding Application%3ESet Combination Key For owner on Contact</fullName>
        <actions>
            <name>Set Combination Format For Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.LastName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

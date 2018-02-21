<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Last_Email_Text_Body</fullName>
        <field>Last_Email_Text_Body__c</field>
        <formula>TextBody</formula>
        <name>Last Email Text Body</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Email_Origin_to_Jared</fullName>
        <field>Email_Origin__c</field>
        <formula>ToAddress</formula>
        <name>Update Email Origin to Jared</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Email_By_on_Case</fullName>
        <field>Last_Email_By__c</field>
        <formula>IF( CONTAINS(FromAddress, &quot;cloudmybiz.com&quot;), &quot;CloudMyBiz&quot;, &quot;Client&quot;)</formula>
        <name>Update Last Email By on Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Email_Date</fullName>
        <field>Last_Email_Date__c</field>
        <formula>now()</formula>
        <name>Update Last Email Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>New Email on Case</fullName>
        <actions>
            <name>Last_Email_Text_Body</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Last_Email_By_on_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Last_Email_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Email Origin on Case - jared%40cloudmybiz%2Ecom</fullName>
        <actions>
            <name>Update_Email_Origin_to_Jared</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>equals</operation>
            <value>jared@cloudmybiz.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.CcAddress</field>
            <operation>equals</operation>
            <value>jared@cloudmybiz.com</value>
        </criteriaItems>
        <description>Updates the Email Origin field for cases sent to Jared@cloudmybiz.com</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

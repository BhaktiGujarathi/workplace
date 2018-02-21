<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Application_Registration</fullName>
        <description>New Application Registration</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Application_Registration</template>
    </alerts>
    <rules>
        <fullName>New Application Registration</fullName>
        <actions>
            <name>New_Application_Registration</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.Stage__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Submitted_By_Client__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Bank_Program_Created</fullName>
        <description>New Bank Program Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>levi@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Bank_App_Emails/New_Bank_Program_Created</template>
    </alerts>
    <rules>
        <fullName>Email Alert - New Bank Program Created</fullName>
        <actions>
            <name>New_Bank_Program_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Program__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_email_alert_when_payment_setting_status_is_complete</fullName>
        <description>Send email alert when payment setting status is complete</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Paymet_complete_email_alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Status_to_Complete</fullName>
        <field>Status__c</field>
        <literalValue>Complete</literalValue>
        <name>Update Status to Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update%3A Payment Setting Status to Complete</fullName>
        <actions>
            <name>Update_Status_to_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Repayment__c.Total_Outstanding_Amount__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

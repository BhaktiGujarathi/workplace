<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Commission_Paid_Confirmation</fullName>
        <ccEmails>henry@cloudmybiz.com,accounting@cloudmybiz.com</ccEmails>
        <description>Commission Paid Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Due_to_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>accounting@cloudmybiz.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Commissions/Commission_Paid_Confirmation</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_to_Contact</fullName>
        <description>Email alert to Contact</description>
        <protected>false</protected>
        <recipients>
            <field>Due_to_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Invoice_is_Ready_to_be_Paid</template>
    </alerts>
    <alerts>
        <fullName>email_alert_new_commission_is_generated</fullName>
        <description>email alert new commission is generated</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Commissions/Commission_is_Generated</template>
    </alerts>
    <rules>
        <fullName>Commission Paid Confirmation</fullName>
        <actions>
            <name>Commission_Paid_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Commission__c.Status__c</field>
            <operation>equals</operation>
            <value>Paid</value>
        </criteriaItems>
        <description>Email when commission is paid</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email alert to contact</fullName>
        <actions>
            <name>Email_alert_to_Contact</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Commission__c.Invoice_Paid__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RecordCreationWithRequestPaymentStatus</fullName>
        <actions>
            <name>email_alert_new_commission_is_generated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>when a record is created and status = &quot;Request Payment&quot;</description>
        <formula>ISPICKVAL(Status__c,&quot;Request Payment&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contact_Opt_Out</fullName>
        <description>Contact Opt Out</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Tip_of_the_Week/Contact_Opt_Out</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Contact_to_be_removed_from_ToTW</fullName>
        <description>Updates the Tip of the Week picklist to &quot;Removed By Request&quot; when &quot;Email Opt Out&quot; is checked.</description>
        <field>Tip_of_The_Week__c</field>
        <literalValue>Removed by Request</literalValue>
        <name>Update Contact to be removed from ToTW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Contact - Update Contact to be removed from ToTW</fullName>
        <actions>
            <name>Update_Contact_to_be_removed_from_ToTW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Tip of the Week picklist to &quot;Removed By Request&quot; when &quot;Email Opt Out&quot; is checked.</description>
        <formula>HasOptedOutOfEmail = TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contact Opt Out Alert</fullName>
        <actions>
            <name>Contact_Opt_Out</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2</booleanFilter>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Tip_of_The_Week__c</field>
            <operation>equals</operation>
            <value>Removed by Request</value>
        </criteriaItems>
        <description>Internal email when an unsubscribe</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Test</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Contact.AccountName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Transaction_Alert</fullName>
        <description>Transaction Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Accounting</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>Office_Managers</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Transaction_Alert_Tempalte</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Transaction_Status_to_Paid</fullName>
        <field>Status__c</field>
        <literalValue>Paid</literalValue>
        <name>Update Transaction Status to Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Transaction_Status_to_Pending</fullName>
        <field>Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Update Transaction Status to Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Transaction Completed Alert</fullName>
        <actions>
            <name>Transaction_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Transaction__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Transaction Status to Paid</fullName>
        <actions>
            <name>Update_Transaction_Status_to_Paid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(Amt_Non_Hourly__c  =  Total_Transaction_Credits__c, Amt_Non_Hourly__c  =  Total_Transaction_Debits__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Transaction Status to pending</fullName>
        <actions>
            <name>Update_Transaction_Status_to_Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(AND(ISCHANGED( Amt_Non_Hourly__c ),Amt_Non_Hourly__c&gt; Total_Transaction_Credits__c), AND(ISCHANGED(Amt_Non_Hourly__c),Amt_Non_Hourly__c&gt; Total_Transaction_Debits__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

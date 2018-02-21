<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Test%3DProject Work Completed</fullName>
        <actions>
            <name>Reminder_Send_out_Invoice_to_Client</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Category__c</field>
            <operation>equals</operation>
            <value>Project Work</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Reminder_Send_out_Invoice_to_Client</fullName>
        <assignedTo>cabenaim@gmail.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Reminder: Project Work Completed - Send out Invoice to Client</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reminder: Project Work Completed - Send out Invoice to Client</subject>
    </tasks>
</Workflow>

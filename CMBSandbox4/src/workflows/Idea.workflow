<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Idea_Created_Internal_Alert</fullName>
        <description>New Idea Created - Internal Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Idea_Submitted_Internal_Notification</template>
    </alerts>
    <rules>
        <fullName>New Idea Submitted - Internal Notification</fullName>
        <actions>
            <name>New_Idea_Created_Internal_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Idea.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

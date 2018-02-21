<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>User_Has_Logged_in_For_First_Time</fullName>
        <description>User Has Logged in For First Time</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/User_Has_Logged_in_For_First_Time</template>
    </alerts>
    <rules>
        <fullName>USer%3A Internal Email when USer Logs in for the fist time</fullName>
        <actions>
            <name>User_Has_Logged_in_For_First_Time</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.LastLoginDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This will help notify which community users logged in.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>test u</fullName>
        <active>false</active>
        <criteriaItems>
            <field>User.AboutMe</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

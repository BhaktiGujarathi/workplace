<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DETE_Email_Alert_To_Notify_New_Community_User</fullName>
        <ccEmails>bhaktigujarathi27@gmail.com</ccEmails>
        <description>DETE_Email_Alert_To_Notify_New_Community_User</description>
        <protected>false</protected>
        <recipients>
            <recipient>DETE_Internal_Users</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/DETE_Profile_Alert</template>
    </alerts>
    <rules>
        <fullName>DETE_Community_User_Created</fullName>
        <actions>
            <name>DETE_Email_Alert_To_Notify_New_Community_User</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>DETE_CommunityUser</value>
        </criteriaItems>
        <description>Rule to check if a new Talent Exchange Profile/User is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Copy_Birthdate_from_Lead</fullName>
        <field>Birthdate</field>
        <formula>Birthdate_for_Workflow__c</formula>
        <name>Copy Birthdate from Birthdate from Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Home_Address_City_to_Other_Address</fullName>
        <field>OtherCity</field>
        <formula>Home_Address_City_for_Workflow__c</formula>
        <name>Copy Home Address City to Other Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Home_Address_State_to_Other_Address</fullName>
        <field>OtherState</field>
        <formula>Home_Address_State_for_Workflow__c</formula>
        <name>Copy Home Address State to Other Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Home_Address_Zip_to_Other_Address</fullName>
        <field>OtherPostalCode</field>
        <formula>Home_Address_Zip_for_Workflow__c</formula>
        <name>Copy Home Address Zip to Other Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Home_Address_to_Other_Address</fullName>
        <field>OtherStreet</field>
        <formula>Home_Address_for_Workflow__c</formula>
        <name>Copy Home Address to Other Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Set_Combination_Format_For_Owner</fullName>
        <field>McaApp__Combination_Key_For_Owner__c</field>
        <formula>IF(ISBLANK( AccountId),&apos;&apos;,AccountId +&apos;-&apos;)+ 

IF(ISBLANK(FirstName) ,&apos;&apos;,(FirstName +&apos;-&apos;)) +
IF(ISBLANK(LastName) ,&apos;&apos;,(LastName+&apos;-&apos;)) +
IF(ISBLANK(TEXT(McaApp__Contact_Roles__c )),&apos;&apos;,(TEXT(McaApp__Contact_Roles__c )))+ TEXT(NOW())</formula>
        <name>Set Combination Format For Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>McaApp__Funding Application%3ESet Combination Key For owner on Contact</fullName>
        <actions>
            <name>McaApp__Set_Combination_Format_For_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.LastName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>@DEPRECATED</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Birthdate with Birthdate from Lead</fullName>
        <actions>
            <name>Copy_Birthdate_from_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(  ISNEW(),  ISCHANGED(  Birthdate_for_Workflow__c   )) &amp;&amp; ISNULL( Birthdate )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Other Address with Home Address from Lead</fullName>
        <actions>
            <name>Copy_Home_Address_City_to_Other_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Home_Address_State_to_Other_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Home_Address_Zip_to_Other_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Home_Address_to_Other_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(  ISNEW(),  ISCHANGED( Home_Address_for_Workflow__c  ),  ISCHANGED( Home_Address_City_for_Workflow__c  ),  ISCHANGED(  Home_Address_State_for_Workflow__c  ),  ISCHANGED( Home_Address_Zip_for_Workflow__c  ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

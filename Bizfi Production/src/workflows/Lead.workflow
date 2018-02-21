<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Drip_Closed_FC</fullName>
        <description>Drip Closed FC</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Bizfi_Drip_Templates/Drip_Closed_FC_VF</template>
    </alerts>
    <alerts>
        <fullName>Drip_Open_AC_5_Days</fullName>
        <description>Drip Open AC &lt; 5 Days</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Bizfi_Drip_Templates/Drip_Open_AC_5_Days_VF</template>
    </alerts>
    <alerts>
        <fullName>Drip_Open_AC_Over_5_Days</fullName>
        <description>Drip Open AC &gt;= 5 Days</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Bizfi_Drip_Templates/Drip_Open_AC_over_5_Days_VF</template>
    </alerts>
    <alerts>
        <fullName>Drip_Open_AC_Over_5_Days_VF</fullName>
        <description>Drip Open AC &gt;= 5 Days VF</description>
        <protected>false</protected>
        <recipients>
            <recipient>amckenzie@bizfi.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Bizfi_Drip_Templates/Drip_Open_AC_Over_5_Days</template>
    </alerts>
    <alerts>
        <fullName>Winning_Lead_Duplicate_Lead_Closer</fullName>
        <description>Winning Lead - Duplicate Lead Closer</description>
        <protected>false</protected>
        <recipients>
            <recipient>Closer_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Lead_Duplicated_Lead</template>
    </alerts>
    <alerts>
        <fullName>Winning_Lead_Duplicate_Lead_Opener</fullName>
        <description>Winning Lead - Duplicate Lead Opener</description>
        <protected>false</protected>
        <recipients>
            <recipient>Opener_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Lead_Duplicated_Lead</template>
    </alerts>
    <alerts>
        <fullName>Winning_Lead_Duplicate_Lead_Renewal</fullName>
        <description>Winning Lead - Duplicate Lead Renewal</description>
        <protected>false</protected>
        <recipients>
            <recipient>Renewals_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Lead_Duplicated_Lead</template>
    </alerts>
    <alerts>
        <fullName>Winning_Opportunity_Duplicate_Lead_Closer</fullName>
        <description>Winning Opportunity - Duplicate Lead Closer</description>
        <protected>false</protected>
        <recipients>
            <recipient>Closer_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Opportunity_Duplicated_Lead</template>
    </alerts>
    <alerts>
        <fullName>Winning_Opportunity_Duplicate_Lead_Opener</fullName>
        <description>Winning Opportunity - Duplicate Lead Opener</description>
        <protected>false</protected>
        <recipients>
            <recipient>Opener_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Opportunity_Duplicated_Lead</template>
    </alerts>
    <alerts>
        <fullName>Winning_Opportunity_Duplicate_Lead_Renewal</fullName>
        <description>Winning Opportunity - Duplicate Lead Renewal</description>
        <protected>false</protected>
        <recipients>
            <recipient>Renewals_Manager</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Emails/Original_Opportunity_Duplicated_Lead</template>
    </alerts>
    <fieldUpdates>
        <fullName>Date_Stamp_Inside_Sales_Answered</fullName>
        <field>Inside_Sales_Answer_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Date/Stamp Inside Sales Answered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Stamp_Inside_Sales_Unanswered</fullName>
        <field>Inside_Sales_Unanswered_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Date/Stamp Inside Sales Unanswered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Stamp_Closed_Unqualified_Dup</fullName>
        <field>Closed_Unqualified_Duplicate_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Date/Time Stamp Closed - Unqualified Dup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Do_Not_Call_checkbox</fullName>
        <field>DoNotCall</field>
        <literalValue>1</literalValue>
        <name>Do Not Call checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Do_Not_email_Checkbox</fullName>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <name>Do Not email Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Lead_Created_Date_Copy_for_Mapping</fullName>
        <field>McaApp__Lead_Created_Date_Copy_for_Mapping__c</field>
        <formula>CreatedDate</formula>
        <name>Lead Created Date (Copy for Mapping)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Annual_Revenue_by_Monthly_Gross</fullName>
        <field>AnnualRevenue</field>
        <formula>McaApp__Monthly_Gross_Sales__c * 12</formula>
        <name>Update Annual Revenue by Monthly Gross</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_Lead_Desired_Amount_with_Amount_R</fullName>
        <description>@Deprecated</description>
        <field>McaApp__Desired_Amount__c</field>
        <formula>McaApp__Amount_Requested__c</formula>
        <name>Update Lead Desired Amount with Amount R</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>McaApp__Update_custom_lead_description_field</fullName>
        <field>McaApp__LeadDescriptionToMap__c</field>
        <formula>Description</formula>
        <name>Update custom lead description field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Lead_ID</fullName>
        <field>Lead_ID__c</field>
        <formula>Id</formula>
        <name>Populate Lead ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reassign_Duplicate_Leads_to_Storage_Acco</fullName>
        <field>OwnerId</field>
        <lookupValue>storage@bizfi.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Reassign Duplicate Leads to Storage Acco</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reassign_to_Storage_Account</fullName>
        <field>OwnerId</field>
        <lookupValue>storage@bizfi.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Reassign to Storage Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_12_Days_Rule</fullName>
        <field>X12_Days_Rule__c</field>
        <literalValue>0</literalValue>
        <name>Reset 12 Days Rule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_4_Days_Rule</fullName>
        <field>X4_Days_Rule__c</field>
        <literalValue>0</literalValue>
        <name>Reset 4 Days Rule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_8_Days_Rule</fullName>
        <field>X8_Days_Rule__c</field>
        <literalValue>0</literalValue>
        <name>Reset 8 Days Rule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Lead_Status</fullName>
        <field>Status</field>
        <literalValue>Open - Not Contacted</literalValue>
        <name>Reset Lead Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Sub_Status</fullName>
        <field>McaApp__Sub_Status__c</field>
        <name>Reset Sub Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_12_Days_Rule</fullName>
        <field>X12_Days_Rule__c</field>
        <literalValue>1</literalValue>
        <name>Set 12 Days Rule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_4_Days_Rule</fullName>
        <field>X4_Days_Rule__c</field>
        <literalValue>1</literalValue>
        <name>Set 4 Days Rule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_8_Days_Rule</fullName>
        <field>X8_Days_Rule__c</field>
        <literalValue>1</literalValue>
        <name>Set 8 Days Rule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Closed_Future_Client_DT</fullName>
        <field>Closed_Future_Client_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Set Closed - Future Client DT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Open_Attempting_Contact_Date_Time</fullName>
        <field>Open_Attempting_Contact_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Set Open - Attempting Contact Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Reassign_Lead</fullName>
        <field>cmblre__Reassign_Lead__c</field>
        <literalValue>1</literalValue>
        <name>Set Reassign Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Reset_and_Reassign</fullName>
        <field>Reset_and_Reassign__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Reset and Reassign</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closed_Converted_Date_Time</fullName>
        <field>Closed_Converted_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Closed - Converted Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closed_Lost_Date_Time_on_Lead</fullName>
        <field>Closed_Lost_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Closed - Lost Date/Time on Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contacted_Date_Time_on_Lead</fullName>
        <field>Working_Contacted_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Contacted Date Time on Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Open_Date_Time_on_Lead</fullName>
        <field>Open_Not_Contacted_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Open - Not Contacted Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Owner_1_Credit_Score</fullName>
        <field>Owner_1_Credit_Score__c</field>
        <formula>McaApp__Credit_Score__c</formula>
        <name>Update Owner 1 Credit Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Phone_Format</fullName>
        <field>Phone</field>
        <formula>&quot;(&quot; + LEFT(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Phone, &quot;-&quot;, &quot;&quot;), &quot; &quot;, &quot;&quot;), &quot;)&quot;, &quot;&quot;), &quot;(&quot;, &quot;&quot;), 3) + &quot;) &quot; + 
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Phone, &quot;-&quot;, &quot;&quot;), &quot; &quot;, &quot;&quot;), &quot;)&quot;, &quot;&quot;), &quot;(&quot;, &quot;&quot;), 4, 3) + &quot;-&quot; +
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Phone, &quot;-&quot;, &quot;&quot;), &quot; &quot;, &quot;&quot;), &quot;)&quot;, &quot;&quot;), &quot;(&quot;, &quot;&quot;), 7, 4) + &quot; &quot; +
MID(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(Phone, &quot;-&quot;, &quot;&quot;), &quot; &quot;, &quot;&quot;), &quot;)&quot;, &quot;&quot;), &quot;(&quot;, &quot;&quot;), 11, 245)</formula>
        <name>Update Phone Format</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Reassigned_to_Rep_48_Hr_Rule</fullName>
        <field>Reassigned_to_Rep_48_Hr_Rule_Date_Time__c</field>
        <formula>Now()</formula>
        <name>Update Reassigned to Rep - 48 Hr Rule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>PS_SMS</fullName>
        <apiVersion>35.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/sms</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>klee@bizfi.com</integrationUser>
        <name>PS&gt;SMS</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Test_ResponsePop</fullName>
        <apiVersion>34.0</apiVersion>
        <endpointUrl>https://nextlevelfundingllc.insidesales.com/do=noauth/salesforce_add_lead?do=responsepop&amp;inbound_initiative_id=7940</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>klee@bizfi.com</integrationUser>
        <name>Test ResponsePop</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>12 Days Reassignment Trigger</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Open - Attempting Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.IsConverted</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reassign_to_Storage_Account</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Set_12_Days_Rule</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead.Open_Attempting_Contact_Date_Time__c</offsetFromField>
            <timeLength>12</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>4 Days Reassignment Trigger</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Open - Attempting Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.IsConverted</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_4_Days_Rule</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead.Open_Attempting_Contact_Date_Time__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>8 Days Reassignment Trigger</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Open - Attempting Contact</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.IsConverted</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_8_Days_Rule</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead.Open_Attempting_Contact_Date_Time__c</offsetFromField>
            <timeLength>8</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Date%2FStamp Inside Sales Answered</fullName>
        <actions>
            <name>Date_Stamp_Inside_Sales_Answered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Inside_Sales_Answer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Date%2FStamp Inside Sales Unanswered</fullName>
        <actions>
            <name>Date_Stamp_Inside_Sales_Unanswered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Inside_Sales_Unanswered__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Date%2FTime Stamp Closed - Unqualified Duplicate</fullName>
        <actions>
            <name>Date_Time_Stamp_Closed_Unqualified_Dup</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Closed - Unqualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.McaApp__Sub_Status__c</field>
            <operation>equals</operation>
            <value>Duplicate</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Do Not Call%2F Email</fullName>
        <actions>
            <name>Do_Not_Call_checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Do_Not_email_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Closed - Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.McaApp__Sub_Status__c</field>
            <operation>equals</operation>
            <value>Do Not Call</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Drip Closed FC %3C 6 Months</fullName>
        <active>false</active>
        <formula>AND( HasOptedOutOfEmail = FALSE, OR(Owner:User.UserRole.Name = &apos;Opener&apos;, Owner:User.UserRole.Name = &apos;Closer&apos;, Owner:User.UserRole.Name = &apos;Opener Manager&apos;), ISPICKVAL(Status, &apos;Closed - Future Client&apos;),  IsConverted = false, NOT(OR(Campaign_Source__c = &apos;CAPITAL ADVANCE SOLUTIONS&apos;,  Campaign_Source__c = &apos;NLF Paid off 12 2015&apos;,  CONTAINS(Campaign_Source__c, &apos;Tree&apos;),  CONTAINS(Campaign_Source__c, &apos;tree&apos;),  CONTAINS(Campaign_Source__c, &apos;Karma&apos;),  CONTAINS(Campaign_Source__c, &apos;karma&apos;),  CONTAINS(Campaign_Source__c, &apos;Nav&apos;),  CONTAINS(Campaign_Source__c, &apos;NAV&apos;),  CONTAINS(Campaign_Source__c, &apos;EPSG&apos;))) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>120</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>150</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>180</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Drip Closed FC %3E 6 Months</fullName>
        <active>false</active>
        <formula>AND( HasOptedOutOfEmail = FALSE, OR(Owner:User.UserRole.Name = &apos;Opener&apos;, Owner:User.UserRole.Name = &apos;Closer&apos;, Owner:User.UserRole.Name = &apos;Opener Manager&apos;), ISPICKVAL(Status, &apos;Closed - Future Client&apos;),  IsConverted = false, NOT(OR(Campaign_Source__c = &apos;CAPITAL ADVANCE SOLUTIONS&apos;,  Campaign_Source__c = &apos;NLF Paid off 12 2015&apos;,  CONTAINS(Campaign_Source__c, &apos;Tree&apos;),  CONTAINS(Campaign_Source__c, &apos;tree&apos;),  CONTAINS(Campaign_Source__c, &apos;Karma&apos;),  CONTAINS(Campaign_Source__c, &apos;karma&apos;),  CONTAINS(Campaign_Source__c, &apos;Nav&apos;),  CONTAINS(Campaign_Source__c, &apos;NAV&apos;),  CONTAINS(Campaign_Source__c, &apos;EPSG&apos;))) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>210</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>240</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>360</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>270</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>330</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>300</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Drip Closed Lost</fullName>
        <active>false</active>
        <formula>AND( HasOptedOutOfEmail = FALSE, OR(Owner:User.UserRole.Name = &apos;Opener&apos;, Owner:User.UserRole.Name = &apos;Closer&apos;, Owner:User.UserRole.Name = &apos;Opener Manager&apos;), ISPICKVAL(Status, &apos;Closed - Lost&apos;), NOT(OR(ISPICKVAL(McaApp__Sub_Status__c, &apos;Looking for Startup Capital&apos;), ISPICKVAL(McaApp__Sub_Status__c, &apos;Low Volume&apos;), ISPICKVAL(McaApp__Sub_Status__c, &apos;Time in Business too Short&apos;))), IsConverted = false, NOT(OR(Campaign_Source__c = &apos;CAPITAL ADVANCE SOLUTIONS&apos;,  Campaign_Source__c = &apos;NLF Paid off 12 2015&apos;,  CONTAINS(Campaign_Source__c, &apos;Tree&apos;),  CONTAINS(Campaign_Source__c, &apos;tree&apos;),  CONTAINS(Campaign_Source__c, &apos;Karma&apos;),  CONTAINS(Campaign_Source__c, &apos;karma&apos;),  CONTAINS(Campaign_Source__c, &apos;Nav&apos;),  CONTAINS(Campaign_Source__c, &apos;NAV&apos;),  CONTAINS(Campaign_Source__c, &apos;EPSG&apos;))) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>330</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>270</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>300</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>210</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>360</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>240</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Drip Closed Lost %3C 6 Months</fullName>
        <active>false</active>
        <formula>AND( HasOptedOutOfEmail = FALSE, OR(Owner:User.UserRole.Name = &apos;Opener&apos;, Owner:User.UserRole.Name = &apos;Closer&apos;, Owner:User.UserRole.Name = &apos;Opener Manager&apos;), ISPICKVAL(Status, &apos;Closed - Lost&apos;), NOT(OR(ISPICKVAL(McaApp__Sub_Status__c, &apos;Looking for Startup Capital&apos;), ISPICKVAL(McaApp__Sub_Status__c, &apos;Low Volume&apos;), ISPICKVAL(McaApp__Sub_Status__c, &apos;Time in Business too Short&apos;))), IsConverted = false, NOT(OR(Campaign_Source__c = &apos;CAPITAL ADVANCE SOLUTIONS&apos;,  Campaign_Source__c = &apos;NLF Paid off 12 2015&apos;,  CONTAINS(Campaign_Source__c, &apos;Tree&apos;),  CONTAINS(Campaign_Source__c, &apos;tree&apos;),  CONTAINS(Campaign_Source__c, &apos;Karma&apos;),  CONTAINS(Campaign_Source__c, &apos;karma&apos;),  CONTAINS(Campaign_Source__c, &apos;Nav&apos;),  CONTAINS(Campaign_Source__c, &apos;NAV&apos;),  CONTAINS(Campaign_Source__c, &apos;EPSG&apos;))) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>180</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Closed_FC</name>
                <type>Alert</type>
            </actions>
            <timeLength>120</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Drip Open AC %3C 20 Weeks</fullName>
        <active>false</active>
        <formula>AND( HasOptedOutOfEmail = FALSE, OR(Owner:User.UserRole.Name = &apos;Opener&apos;, Owner:User.UserRole.Name = &apos;Closer&apos;, Owner:User.UserRole.Name = &apos;Opener Manager&apos;), ISPICKVAL(Status, &apos;Open - Attempting Contact&apos;), NOT(OR(ISPICKVAL(McaApp__Sub_Status__c, &apos;Duplicate&apos;), ISPICKVAL(McaApp__Sub_Status__c, &apos;Fraudulent Deal&apos;))),  IsConverted = false, NOT(OR(Campaign_Source__c = &apos;CAPITAL ADVANCE SOLUTIONS&apos;,  Campaign_Source__c = &apos;NLF Paid off 12 2015&apos;,  CONTAINS(Campaign_Source__c, &apos;Tree&apos;),  CONTAINS(Campaign_Source__c, &apos;tree&apos;),  CONTAINS(Campaign_Source__c, &apos;Karma&apos;),  CONTAINS(Campaign_Source__c, &apos;karma&apos;),  CONTAINS(Campaign_Source__c, &apos;Nav&apos;),  CONTAINS(Campaign_Source__c, &apos;NAV&apos;),  CONTAINS(Campaign_Source__c, &apos;EPSG&apos;))) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>28</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>56</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>84</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>112</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>140</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Drip Open AC %3C 5 Days</fullName>
        <actions>
            <name>Drip_Open_AC_5_Days</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND( HasOptedOutOfEmail = FALSE, OR(Owner:User.UserRole.Name = &apos;Opener&apos;, Owner:User.UserRole.Name = &apos;Closer&apos;, Owner:User.UserRole.Name = &apos;Opener Manager&apos;), ISPICKVAL(Status, &apos;Open - Attempting Contact&apos;), NOT(OR(ISPICKVAL(McaApp__Sub_Status__c, &apos;Duplicate&apos;), ISPICKVAL(McaApp__Sub_Status__c, &apos;Fraudulent Deal&apos;))), IsConverted = false, NOT(OR(Campaign_Source__c = &apos;CAPITAL ADVANCE SOLUTIONS&apos;,  Campaign_Source__c = &apos;NLF Paid off 12 2015&apos;,  CONTAINS(Campaign_Source__c, &apos;Tree&apos;),  CONTAINS(Campaign_Source__c, &apos;tree&apos;),  CONTAINS(Campaign_Source__c, &apos;Karma&apos;),  CONTAINS(Campaign_Source__c, &apos;karma&apos;),  CONTAINS(Campaign_Source__c, &apos;Nav&apos;),  CONTAINS(Campaign_Source__c, &apos;NAV&apos;),  CONTAINS(Campaign_Source__c, &apos;EPSG&apos;))) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Drip Open AC %3E%3D 20 Weeks</fullName>
        <active>false</active>
        <formula>AND( HasOptedOutOfEmail = FALSE, OR(Owner:User.UserRole.Name = &apos;Opener&apos;, Owner:User.UserRole.Name = &apos;Closer&apos;, Owner:User.UserRole.Name = &apos;Opener Manager&apos;), ISPICKVAL(Status, &apos;Open - Attempting Contact&apos;), NOT(OR(ISPICKVAL(McaApp__Sub_Status__c, &apos;Duplicate&apos;), ISPICKVAL(McaApp__Sub_Status__c, &apos;Fraudulent Deal&apos;))), IsConverted = false, NOT(OR(Campaign_Source__c = &apos;CAPITAL ADVANCE SOLUTIONS&apos;,  Campaign_Source__c = &apos;NLF Paid off 12 2015&apos;,  CONTAINS(Campaign_Source__c, &apos;Tree&apos;),  CONTAINS(Campaign_Source__c, &apos;tree&apos;),  CONTAINS(Campaign_Source__c, &apos;Karma&apos;),  CONTAINS(Campaign_Source__c, &apos;karma&apos;),  CONTAINS(Campaign_Source__c, &apos;Nav&apos;),  CONTAINS(Campaign_Source__c, &apos;NAV&apos;),  CONTAINS(Campaign_Source__c, &apos;EPSG&apos;))) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>252</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>280</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>168</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>196</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>224</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>308</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>336</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Drip_Open_AC_Over_5_Days</name>
                <type>Alert</type>
            </actions>
            <timeLength>364</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Format API Lead Phone</fullName>
        <actions>
            <name>Update_Phone_Format</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Is_API_Lead__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Lead Created Date %28Copy for Mapping%29</fullName>
        <actions>
            <name>McaApp__Lead_Created_Date_Copy_for_Mapping</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Lead%3ELead Description To Map</fullName>
        <actions>
            <name>McaApp__Update_custom_lead_description_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Description</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update Annual Revenue by Monthly Gross</fullName>
        <actions>
            <name>McaApp__Update_Annual_Revenue_by_Monthly_Gross</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.AnnualRevenue</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.McaApp__Monthly_Gross_Sales__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When left blank, the Annual Rev will be updated by the Monthly gross Sales</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>McaApp__Update Lead Desired Amount with Amount Requested</fullName>
        <actions>
            <name>McaApp__Update_Lead_Desired_Amount_with_Amount_R</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.McaApp__Amount_Requested__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.McaApp__Desired_Amount__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>@Deprecated When Desired amount is blank,  Update Lead Desired Amount with Amount Requested</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Closed - Converted Date%2FTime on Lead</fullName>
        <actions>
            <name>Update_Closed_Converted_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Closed - Converted</value>
        </criteriaItems>
        <description>On Lead creation or update, captures time on Lead when the status changes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Closed - Future Client Date%2FTime</fullName>
        <actions>
            <name>Set_Closed_Future_Client_DT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Closed - Future Client</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Closed - Lost Date%2FTime on Lead</fullName>
        <actions>
            <name>Update_Closed_Lost_Date_Time_on_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Closed - Lost</value>
        </criteriaItems>
        <description>On Lead creation or update, captures time on Lead when the status changes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Lead ID On Lead Insert</fullName>
        <actions>
            <name>Populate_Lead_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Open - Attempting Contact Date%2FTime on Lead</fullName>
        <actions>
            <name>Set_Open_Attempting_Contact_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Open - Attempting Contact</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Open - Not Contacted Date%2FTime on Lead</fullName>
        <actions>
            <name>Update_Open_Date_Time_on_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Reassigned_to_Rep_48_Hr_Rule</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Open - Not Contacted</value>
        </criteriaItems>
        <description>On Lead creation or update, captures time on Lead when the status changes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Owner 1 Credit Score with Credit Score</fullName>
        <actions>
            <name>Update_Owner_1_Credit_Score</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Working - Contacted Date%2FTime on Lead</fullName>
        <actions>
            <name>Update_Contacted_Date_Time_on_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Working - Contacted</value>
        </criteriaItems>
        <description>On Lead creation or update, captures time on Lead when the status changes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Powerstandings %3E SMS %28Test%29</fullName>
        <actions>
            <name>PS_SMS</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.FirstName</field>
            <operation>equals</operation>
            <value>Kevin</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.LastName</field>
            <operation>equals</operation>
            <value>Lee</value>
        </criteriaItems>
        <description>Test workflow to better understand how they effect powerstandings</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reassign Duplicate Leads to Storage Account</fullName>
        <actions>
            <name>Reassign_Duplicate_Leads_to_Storage_Acco</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR (  NOT(ISBLANK(DupRefLeadID__c )),  NOT(ISBLANK(DupRefOppID__c ))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reassign Lead Due to Attempting Contact</fullName>
        <actions>
            <name>Reset_4_Days_Rule</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_8_Days_Rule</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Reassign_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(     ISPICKVAL(Status, &quot;Open - Attempting Contact&quot;),     OR(         AND(X4_Days_Rule__c,  Days_in_Attempting_to_Contact__c = 4),         AND(X8_Days_Rule__c,  Days_in_Attempting_to_Contact__c = 8)     ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reset 12 Day Rule Checkbox</fullName>
        <actions>
            <name>Reset_12_Days_Rule</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  ISPICKVAL(Status, &quot;Open - Attempting Contact&quot;),  AND(X12_Days_Rule__c, Days_in_Attempting_to_Contact__c = 12)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reset and Reassign</fullName>
        <actions>
            <name>Reset_Lead_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Sub_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Reset_and_Reassign__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Uncheck_Reset_and_Reassign</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Winning Lead - Duplicate Lead Closer</fullName>
        <actions>
            <name>Winning_Lead_Duplicate_Lead_Closer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>If after a deduplication process we found that this Lead is a duplicate of another Lead send an email.</description>
        <formula>Owner:User.UserRole.Name = &apos;Closer&apos; &amp;&amp; NOT(ISBLANK(DupRefLeadID__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Winning Lead - Duplicate Lead Opener</fullName>
        <actions>
            <name>Winning_Lead_Duplicate_Lead_Opener</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>If after a deduplication process we found that this Lead is a duplicate of another Lead send an email.</description>
        <formula>Owner:User.UserRole.Name = &apos;Opener&apos; &amp;&amp; NOT(ISBLANK(DupRefLeadID__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Winning Lead - Duplicate Lead Renewal</fullName>
        <actions>
            <name>Winning_Lead_Duplicate_Lead_Renewal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>If after a deduplication process we found that this Lead is a duplicate of another Lead send an email.</description>
        <formula>Owner:User.UserRole.Name = &apos;Renewals Agent&apos; &amp;&amp; NOT(ISBLANK(DupRefLeadID__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Winning Opportunity - Duplicate Lead Closer</fullName>
        <actions>
            <name>Winning_Opportunity_Duplicate_Lead_Closer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>If after a deduplication process we found that this Lead is a duplicate of an an Account send an email.</description>
        <formula>Owner:User.UserRole.Name = &apos;Closer&apos; &amp;&amp;  NOT(ISBLANK(DupRefOppID__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Winning Opportunity - Duplicate Lead Opener</fullName>
        <actions>
            <name>Winning_Opportunity_Duplicate_Lead_Opener</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>If after a deduplication process we found that this Lead is a duplicate of an an Account send an email.</description>
        <formula>Owner:User.UserRole.Name = &apos;Opener&apos; &amp;&amp;  NOT(ISBLANK(DupRefOppID__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Winning Opportunity - Duplicate Lead Renewal</fullName>
        <actions>
            <name>Winning_Opportunity_Duplicate_Lead_Renewal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>If after a deduplication process we found that this Lead is a duplicate of an an Account send an email.</description>
        <formula>Owner:User.UserRole.Name = &apos;Renewals_Agent&apos; &amp;&amp; NOT(ISBLANK(DupRefOppID__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

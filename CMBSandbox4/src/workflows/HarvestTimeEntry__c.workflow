<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Project_Budget_Monitoring_Alert_PM</fullName>
        <description>Project Budget Monitoring - Alert PM</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Hour_Templates/Project_Budget_Monitoring_Alert_PM</template>
    </alerts>
    <alerts>
        <fullName>Project_Monthly_Budget_Monitoring_Email_Alert</fullName>
        <description>Project Monthly Budget Monitoring Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Hour_Templates/Project_Budget_Monthly_Monitoring_on_TI</template>
    </alerts>
    <alerts>
        <fullName>Project_has_Crossed_20_Threshold</fullName>
        <description>Project has Crossed 20% Threshold</description>
        <protected>false</protected>
        <recipients>
            <recipient>abraham@cloudmybiz.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cabenaim@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Hour_Templates/Percentage_Below_20</template>
    </alerts>
    <fieldUpdates>
        <fullName>Credit_non_billable_hours</fullName>
        <field>Credit_Hrs__c</field>
        <formula>Duration__c</formula>
        <name>Credit non-billable hours</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Parsing_1</fullName>
        <field>Parsing_1__c</field>
        <formula>LEFT(Notes__c,40)</formula>
        <name>Parsing 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contractor_Cost_for_Roll_Up</fullName>
        <field>Contractor_Cost_Roll_Up__c</field>
        <formula>Contractor_Cost__c</formula>
        <name>Update Contractor Cost for Roll Up</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contractor_Rate_from_Account</fullName>
        <field>Contractor_Hourly_Rate__c</field>
        <formula>Contractor_Rate__c</formula>
        <name>Update: Contractor Rate from Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Field_70_Alert_PM</fullName>
        <field>X70_Alert__c</field>
        <literalValue>1</literalValue>
        <name>Update Field - 70% Alert PM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>HarvestProject__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Field_Hours_with_hours_for_clien</fullName>
        <field>Hours__c</field>
        <formula>Hours_For_Client__c</formula>
        <name>Update Field: Hours with hours for clien</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Sent_To_Client_Date</fullName>
        <field>Invoice_Sent_To_Client_Date__c</field>
        <formula>Today()</formula>
        <name>Update: Invoice Sent To Client Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoiced_By_CMB_Date</fullName>
        <field>Invoiced_by_CMB_Date__c</field>
        <formula>today()</formula>
        <name>Update: Invoiced By CMB Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Non_Billable_State_to_True</fullName>
        <field>Non_Billable_State_When_Logged__c</field>
        <literalValue>1</literalValue>
        <name>Update Non Billable State to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Burn Rate over 70%25 - Alert PM</fullName>
        <actions>
            <name>Project_Budget_Monitoring_Alert_PM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Field_70_Alert_PM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( HarvestProject__r.X70_Alert__c =false,
HarvestProject__r.BurnPercent__c &gt; 0.70)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Monthly Project Budget Alert</fullName>
        <actions>
            <name>Project_Monthly_Budget_Monitoring_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>HarvestProject__r.Hours_this_Month_of_Budget__c &gt; 0.85</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PM Project Hours at 80%25</fullName>
        <active>false</active>
        <description>Sends an email alert to the PM when total client hours are at 80%.</description>
        <formula>AND (Hours_For_Client__c  &gt;=    HarvestProject__r.Estimated_Hours__c  *0.80,
Hours_For_Client__c  &lt;=    HarvestProject__r.Estimated_Hours__c  *0.84)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Project Percentage Below 10%25</fullName>
        <actions>
            <name>Project_has_Crossed_20_Threshold</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>and(  Hours_For_Client__c  &gt;0,HarvestProject__r.Actual_vs_Estimate_Percent__c &lt;0.10)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Time Entry Parsing 1</fullName>
        <actions>
            <name>Parsing_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Contractor Cost for Roll Up</fullName>
        <actions>
            <name>Update_Contractor_Cost_for_Roll_Up</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Filed%3A TimeEntry Hours for Roll Up</fullName>
        <actions>
            <name>Update_Field_Hours_with_hours_for_clien</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This will update the Hours field on Time Entries</description>
        <formula>OR(
 ISNEW(),
ISCHANGED( Update_Workflow__c ),

ISCHANGED( LastModifiedDate )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Non BIllable State on Time Entry</fullName>
        <actions>
            <name>Update_Non_Billable_State_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>HarvestProject__c.Non_Billable_State__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update%3A Contractor Rate from Account</fullName>
        <actions>
            <name>Update_Contractor_Rate_from_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>HarvestTimeEntry__c.Contractor_Hourly_Rate__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>HarvestTimeEntry__c.Contractor_Hourly_Rate__c</field>
            <operation>lessOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <description>This should update the contractor hourly rate on time entry from the account page.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update%3A Invoice Sent To Client Date</fullName>
        <actions>
            <name>Update_Invoice_Sent_To_Client_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>HarvestTimeEntry__c.Invoice_Sent_to_Client__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update%3A Invoiced By CMB Date</fullName>
        <actions>
            <name>Update_Invoiced_By_CMB_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>HarvestTimeEntry__c.Invoiced_by_CMB__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Percentage_Below_20</fullName>
        <assignedTo>abraham@cloudmybiz.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Percentage Below 20%</subject>
    </tasks>
</Workflow>

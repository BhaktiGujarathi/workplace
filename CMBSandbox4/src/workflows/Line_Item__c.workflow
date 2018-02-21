<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CloudMyBiz_Line_Items_Credit_Hours</fullName>
        <field>Credit_Hrs__c</field>
        <formula>Hours_Num__c</formula>
        <name>CloudMyBiz Line Items Credit Hours</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contractor_Rate_Account_Cnt_rate</fullName>
        <field>Contractor_Rate__c</field>
        <formula>Contractor__r.Contractor_Rate__c</formula>
        <name>Contractor Rate = Account Cnt rate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Client_Contractor_Hour_Ratio_on_L</fullName>
        <description>Update Client Contractor Hour Ratio on Line Item</description>
        <field>Client_Contractor_Hour_Ratio_Copy__c</field>
        <formula>Client_Contractor_Hour_Ratio__c</formula>
        <name>Update Client Contractor Hour Ratio on L</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Credit_Hours_based_on_Ratio</fullName>
        <description>IF( Client_Contractor_Hour_Ratio__c &lt;&gt;null,
Hours_Num__c-(Client_Contractor_Hour_Ratio__c *Hours_Num__c),
IF(Contractor_Hour_Ratio__c&lt;&gt;null,
Hours_Num__c -(Hours_Num__c *  Contractor_Hour_Ratio__c),
Hours_Num__c  - (Hours_Num__c *  0.5)
))</description>
        <field>Credit_Hrs__c</field>
        <formula>IF(  CONTAINS(Task_Harvest__c , &quot;Shared Client&quot;),Hours_Num__c ,
IF( Credit_Hrs__c&gt;=0.01,Credit_Hrs__c,

IF( CONTAINS(Task_Harvest__c, &quot;Non-Billable&quot;),  Hours_Num__c , 

IF(Hours_Num__c - (Hours_Num__c * Contractor_Hour_Ratio_To_Use__c )=0,null,Hours_Num__c - (Hours_Num__c * Contractor_Hour_Ratio_To_Use__c )))))</formula>
        <name>Update Credit Hours based on Ratio</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Field_Date_Conga_Text</fullName>
        <field>Date_Conga_Text__c</field>
        <formula>TEXT(MONTH(Date_Conga__c)) &amp; &quot;/&quot; &amp; TEXT(DAY(Date_Conga__c)) &amp; &quot;/&quot; &amp; TEXT(YEAR(Date_Conga__c))</formula>
        <name>Update Field - Date (Conga - Text)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Field_isCredit</fullName>
        <field>isCredit_Checkbox__c</field>
        <literalValue>1</literalValue>
        <name>Update Field: isCredit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Field_isDeposit</fullName>
        <field>isDeposit__c</field>
        <literalValue>1</literalValue>
        <name>Update Field - isDeposit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Line_Item_Project_Hours</fullName>
        <field>Project_Harvest_Text__c</field>
        <formula>HarvestProject__r.Name</formula>
        <name>Update: Invoice Line Item Project Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Remove_from_Client_Inv</fullName>
        <field>Remove_from_Client_Inv__c</field>
        <literalValue>1</literalValue>
        <name>Update: Remove from Client Inv</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Task_Notes_field</fullName>
        <field>Task_Notes__c</field>
        <formula>IF(
NOT(ISBLANK(Task_Harvest__c)), 
   &quot;[&quot; &amp; Task_Harvest__c &amp; &quot;] &quot; &amp; BR() &amp; Description__c,
        Description__c)</formula>
        <name>Update Task &amp; Notes field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Time_Entry_Id</fullName>
        <field>Time_Entry_Id__c</field>
        <formula>Time_Entry__r.Id</formula>
        <name>Update Time Entry Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_isCredit_to_False</fullName>
        <field>isCredit_Checkbox__c</field>
        <literalValue>0</literalValue>
        <name>Update &quot;isCredit&quot; to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CloudMyBiz Line Items Credit Hours</fullName>
        <actions>
            <name>CloudMyBiz_Line_Items_Credit_Hours</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(
CONTAINS( Invoice__r.Account__r.Name , &quot;CloudMyBiz&quot;),
CONTAINS( Invoice__r.Account__r.Name , &quot;Fundingo&quot;)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Line Item Remove from Client Inv</fullName>
        <actions>
            <name>Update_Remove_from_Client_Inv</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Line_Item__c.Description__c</field>
            <operation>equals</operation>
            <value>time moved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Line_Item__c.Hours_Num__c</field>
            <operation>lessOrEqual</operation>
            <value>0</value>
        </criteriaItems>
        <description>This will check the checkbox to remove from client invoice</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Time Entry Id</fullName>
        <actions>
            <name>Update_Time_Entry_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Client Contractor Hour Ratio on Line Item</fullName>
        <actions>
            <name>Update_Client_Contractor_Hour_Ratio_on_L</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(
ISCHANGED( Contractor__c ) ,
isnew())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Credit Hours based on Ratio</fullName>
        <actions>
            <name>Update_Credit_Hours_based_on_Ratio</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
isnew(),
 NOT(CONTAINS( Invoice__r.Account__r.Name , &quot;CloudMyBiz&quot;) )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Field - Date %28Conga - Text%29</fullName>
        <actions>
            <name>Update_Field_Date_Conga_Text</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Line_Item__c.Date_Conga__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Field - isCredit %3D False</fullName>
        <actions>
            <name>Update_isCredit_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Line_Item__c.isCredit__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Field - isCredit %3D True</fullName>
        <actions>
            <name>Update_Field_isCredit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Line_Item__c.isCredit__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Field - isDeposit</fullName>
        <actions>
            <name>Update_Field_isDeposit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Line_Item__c.Deposit_Invoice_Formula__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Task %26 Notes field</fullName>
        <actions>
            <name>Update_Task_Notes_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This field will be updated every time a record is edited and this field will go on the invoice</description>
        <formula>OR(
isnew(),
ISCHANGED( NotToExceed__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update%3A Contractor Rate on Inv Line Items</fullName>
        <actions>
            <name>Contractor_Rate_Account_Cnt_rate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Line_Item__c.Contractor_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Line_Item__c.Contractor_Rate__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update%3A Invoice Line Item Project %28Hours%29 Text</fullName>
        <actions>
            <name>Update_Invoice_Line_Item_Project_Hours</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

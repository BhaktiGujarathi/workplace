<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>BankStatementName</fullName>
        <field>Name</field>
        <formula>&quot;BNK-&quot; &amp; TEXT(Year__c) &amp; &quot;-&quot; &amp; CASE(Month__c, 
                                    &quot;01 - January&quot;, &quot;01&quot;, 
                                    &quot;02 - February&quot;, &quot;02&quot;, 
                                    &quot;03 - March&quot;, &quot;03&quot;, 
                                    &quot;04 - April&quot;, &quot;04&quot;, 
                                    &quot;05 - May&quot;, &quot;05&quot;, 
                                    &quot;06 - June&quot;, &quot;06&quot;, 
                                    &quot;07 - July&quot;, &quot;07&quot;, 
                                    &quot;08 - August&quot;, &quot;08&quot;, 
                                    &quot;09 - September&quot;, &quot;09&quot;, 
                                    &quot;10 - October&quot;, &quot;10&quot;, 
                                    &quot;11 - November&quot;, &quot;11&quot;,  
                                    &quot;12 - December&quot;, &quot;12&quot;, 
                                    &quot; &quot;)</formula>
        <name>BankStatementName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BankStatement%3ENaming Convention %27BNK-yyyy-mm%27</fullName>
        <actions>
            <name>BankStatementName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bank_Account__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>This will set the name of bank statement name in a format &apos;BNK-yyyy-mm&apos;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

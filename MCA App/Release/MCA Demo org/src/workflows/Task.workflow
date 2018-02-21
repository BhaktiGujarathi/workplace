<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Opportunity%3E Stage to Application Sent</fullName>
        <active>false</active>
        <description>When sending Application via conga, the stage should be updated to Application Sent</description>
        <formula>AND(  ISPICKVAL(Status, &apos;Completed&apos;),  Subject  = &apos;Funding Application&apos;, CONTAINS( Description , &apos;PFA the Funding Application&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

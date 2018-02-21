@isTest
private class HarvestServiceTest {

    static testMethod void testgetEntriesForProject() {
        Account account = new Account(Name='bla');
        insert account;
        HarvestProject__c project = new HarvestProject__c(Name='bla', Account__c=account.Id);
        insert project;
        HarvestServiceStub svc = new HarvestServiceStub();
        List<Dom.Document> stubDocuments = new List<Dom.Document>();
		String docXml = null;
		Dom.Document doc = null;        

        doc = new Dom.Document();
        docXml = '<?xml version="1.0" encoding="UTF-8"?><tasks type="array">  <task>    <billable-by-default type="boolean">false</billable-by-default>    <cache-version type="integer">1273953107</cache-version>    <created-at type="datetime">2009-12-16T00:30:15Z</created-at>    <deactivated type="boolean">false</deactivated>    <default-hourly-rate type="decimal" nil="true"></default-hourly-rate>    <id type="integer">1</id>    <is-default type="boolean">false</is-default>    <name>Admin</name>    <updated-at type="datetime">2009-12-16T18:10:17Z</updated-at>  </task></tasks>';
        doc.load(docXml);
        stubDocuments.add(doc);

		doc = new Dom.Document();
		docXml = '<?xml version="1.0" encoding="UTF-8"?><users type="array">  <user>    <cache-version type="integer">1754599018</cache-version>    <created-at type="datetime">2010-05-25T14:18:44Z</created-at>    <default-expense-category-id type="integer" nil="true"></default-expense-category-id>    <default-expense-project-id type="integer" nil="true"></default-expense-project-id>    <default-hourly-rate type="decimal" nil="true"></default-hourly-rate>    <default-task-id type="integer" nil="true"></default-task-id>    <default-time-project-id type="integer" nil="true"></default-time-project-id>    <department nil="true"></department>    <duplicate-timesheet-wants-notes type="boolean">true</duplicate-timesheet-wants-notes>    <email>brian@akacrm.com</email>    <email-after-submit type="boolean">true</email-after-submit>    <first-name>Brian</first-name>    <first-timer type="boolean">false</first-timer>    <has-access-to-accounting type="boolean">false</has-access-to-accounting>    <has-access-to-all-future-projects type="boolean">false</has-access-to-all-future-projects>    <id type="integer">1</id>    <identity-url>http://akacrm.com/openid?id=116928819743714147216</identity-url>    <is-active type="boolean">true</is-active>    <is-admin type="boolean">true</is-admin>    <is-contractor type="boolean">false</is-contractor>    <last-name>Connell</last-name>    <opensocial-identifier>116928819743714147216</opensocial-identifier>    <opensocial-identifier-hash type="integer">168499430</opensocial-identifier-hash>    <preferred-approval-screen>timeframe</preferred-approval-screen>    <preferred-entry-method>daily</preferred-entry-method>    <preferred-n8-account-id type="integer" nil="true"></preferred-n8-account-id>    <preferred-project-status-reports-screen>active</preferred-project-status-reports-screen>    <telephone></telephone>    <timezone>Mountain Time (US &amp; Canada)</timezone>    <twitter-username nil="true"></twitter-username>    <updated-at type="datetime">2010-10-26T01:36:36Z</updated-at>    <wants-newsletter type="boolean">true</wants-newsletter>    <wants-timesheet-duplication type="boolean">false</wants-timesheet-duplication>  </user></users>';
        doc.load(docXml);
        stubDocuments.add(doc);
        
        doc = new Dom.Document();
        docXml = '<?xml version="1.0" encoding="UTF-8"?><projects type="array">  <project>    <active type="boolean">false</active>    <active-task-assignments-count type="integer">1</active-task-assignments-count>    <active-user-assignments-count type="integer">1</active-user-assignments-count>    <basecamp-id type="integer" nil="true"></basecamp-id>    <bill-by>Project</bill-by>    <billable type="boolean">true</billable>    <budget type="decimal" nil="true"></budget>    <budget-by>project</budget-by>    <cache-version type="integer">964485068</cache-version>    <client-id type="integer">296483</client-id>    <code>1</code>    <cost-budget type="decimal" nil="true"></cost-budget>    <cost-budget-include-expenses type="boolean">false</cost-budget-include-expenses>    <created-at type="datetime">2010-05-26T22:22:16Z</created-at>    <fees type="decimal" nil="true"></fees>    <highrise-deal-id type="integer" nil="true"></highrise-deal-id>    <hourly-rate type="decimal" nil="true"></hourly-rate>    <id type="integer">1</id>    <name>ABC Company-Test Project</name>    <notify-when-over-budget type="boolean">false</notify-when-over-budget>    <over-budget-notification-percentage type="decimal">80.0</over-budget-notification-percentage>    <over-budget-notified-at type="date" nil="true"></over-budget-notified-at>    <show-budget-to-all type="boolean">false</show-budget-to-all>    <updated-at type="datetime">2010-07-15T09:30:31Z</updated-at>    <estimate nil="true"></estimate>    <estimate-by>project</estimate-by>    <notes></notes>  </project></projects>';
        doc.load(docXml);
        stubDocuments.add(doc);
        
        doc = new Dom.Document();
        docXml = '<?xml version="1.0" encoding="UTF-8"?><day-entries type="array">  <day-entry>    <adjustment-record type="boolean">false</adjustment-record>    <created-at type="datetime">2010-09-23T01:55:05Z</created-at>    <hours type="decimal">0.45</hours>    <id type="integer">1</id>    <is-closed type="boolean">false</is-closed>    <notes>Call with Dean to review priorities, discuss Proposal model, new areas (calendaring) and next steps.</notes>    <project-id type="integer">1</project-id>    <spent-at type="date">2010-09-22</spent-at>    <task-id type="integer">1</task-id>    <timer-started-at type="datetime" nil="true"></timer-started-at>    <updated-at type="datetime">2010-09-23T01:55:05Z</updated-at>    <user-id type="integer">1</user-id>    <is-billed type="integer">0</is-billed>  </day-entry>  </day-entries>';
        doc.load(docXml);
        stubDocuments.add(doc);
        
        HarvestServiceStub.stubDocuments = stubDocuments; 
		svc.populateTasks();			
		svc.populatePeople();		
		svc.populateProjectIdMap();		
        List<HarvestEntry> entries = svc.getEntriesForProject('1');
    }
    
    @isTest
    static void getHarvestProjectId() {
        HarvestServiceStub svc = new HarvestServiceStub();
        List<Dom.Document> stubDocuments = new List<Dom.Document>();
        Dom.Document doc = new Dom.Document();
        String docXml = '<?xml version="1.0" encoding="UTF-8"?><projects type="array">  <project>    <active type="boolean">false</active>    <active-task-assignments-count type="integer">1</active-task-assignments-count>    <active-user-assignments-count type="integer">1</active-user-assignments-count>    <basecamp-id type="integer" nil="true"></basecamp-id>    <bill-by>Project</bill-by>    <billable type="boolean">true</billable>    <budget type="decimal" nil="true"></budget>    <budget-by>project</budget-by>    <cache-version type="integer">964485068</cache-version>    <client-id type="integer">296483</client-id>    <code>1</code>    <cost-budget type="decimal" nil="true"></cost-budget>    <cost-budget-include-expenses type="boolean">false</cost-budget-include-expenses>    <created-at type="datetime">2010-05-26T22:22:16Z</created-at>    <fees type="decimal" nil="true"></fees>    <highrise-deal-id type="integer" nil="true"></highrise-deal-id>    <hourly-rate type="decimal" nil="true"></hourly-rate>    <id type="integer">1</id>    <name>ABC Company-Test Project</name>    <notify-when-over-budget type="boolean">false</notify-when-over-budget>    <over-budget-notification-percentage type="decimal">80.0</over-budget-notification-percentage>    <over-budget-notified-at type="date" nil="true"></over-budget-notified-at>    <show-budget-to-all type="boolean">false</show-budget-to-all>    <updated-at type="datetime">2010-07-15T09:30:31Z</updated-at>    <estimate nil="true"></estimate>    <estimate-by>project</estimate-by>    <notes></notes>  </project></projects>';
        doc.load(docXml);
        stubDocuments.add(doc);
        HarvestServiceStub.stubDocuments = stubDocuments; 

        String id = svc.getHarvestProjectId('1');

        System.assertEquals('1', id);
    }

    @isTest
    static void activateProject() {
        HarvestServiceStub svc = new HarvestServiceStub();
        List<Dom.Document> stubDocuments = new List<Dom.Document>();
        Dom.Document doc = new Dom.Document();
        String docXml = '<?xml version="1.0" encoding="UTF-8"?><project>  <active type="boolean">false</active>    <active-task-assignments-count type="integer">1</active-task-assignments-count>    <active-user-assignments-count type="integer">1</active-user-assignments-count>    <basecamp-id type="integer" nil="true"></basecamp-id>    <bill-by>Project</bill-by>    <billable type="boolean">true</billable>    <budget type="decimal" nil="true"></budget>    <budget-by>project</budget-by>    <cache-version type="integer">964485068</cache-version>    <client-id type="integer">296483</client-id>    <code>1</code>    <cost-budget type="decimal" nil="true"></cost-budget>    <cost-budget-include-expenses type="boolean">false</cost-budget-include-expenses>    <created-at type="datetime">2010-05-26T22:22:16Z</created-at>    <fees type="decimal" nil="true"></fees>    <highrise-deal-id type="integer" nil="true"></highrise-deal-id>    <hourly-rate type="decimal" nil="true"></hourly-rate>    <id type="integer">1</id>    <name>ABC Company-Test Project</name>    <notify-when-over-budget type="boolean">false</notify-when-over-budget>    <over-budget-notification-percentage type="decimal">80.0</over-budget-notification-percentage>    <over-budget-notified-at type="date" nil="true"></over-budget-notified-at>    <show-budget-to-all type="boolean">false</show-budget-to-all>    <updated-at type="datetime">2010-07-15T09:30:31Z</updated-at>    <estimate nil="true"></estimate>    <estimate-by>project</estimate-by>    <notes></notes>  </project>';
        doc.load(docXml);
        stubDocuments.add(doc);
        stubDocuments.add(doc);
        HarvestServiceStub.stubDocuments = stubDocuments; 

        svc.activateProject('1');
    }

    @isTest
    static void deactivateProject() {
        HarvestServiceStub svc = new HarvestServiceStub();
        List<Dom.Document> stubDocuments = new List<Dom.Document>();
        Dom.Document doc = new Dom.Document();
        String docXml = '<?xml version="1.0" encoding="UTF-8"?><project>  <active type="boolean">false</active>    <active-task-assignments-count type="integer">1</active-task-assignments-count>    <active-user-assignments-count type="integer">1</active-user-assignments-count>    <basecamp-id type="integer" nil="true"></basecamp-id>    <bill-by>Project</bill-by>    <billable type="boolean">true</billable>    <budget type="decimal" nil="true"></budget>    <budget-by>project</budget-by>    <cache-version type="integer">964485068</cache-version>    <client-id type="integer">296483</client-id>    <code>1</code>    <cost-budget type="decimal" nil="true"></cost-budget>    <cost-budget-include-expenses type="boolean">false</cost-budget-include-expenses>    <created-at type="datetime">2010-05-26T22:22:16Z</created-at>    <fees type="decimal" nil="true"></fees>    <highrise-deal-id type="integer" nil="true"></highrise-deal-id>    <hourly-rate type="decimal" nil="true"></hourly-rate>    <id type="integer">1</id>    <name>ABC Company-Test Project</name>    <notify-when-over-budget type="boolean">false</notify-when-over-budget>    <over-budget-notification-percentage type="decimal">80.0</over-budget-notification-percentage>    <over-budget-notified-at type="date" nil="true"></over-budget-notified-at>    <show-budget-to-all type="boolean">false</show-budget-to-all>    <updated-at type="datetime">2010-07-15T09:30:31Z</updated-at>    <estimate nil="true"></estimate>    <estimate-by>project</estimate-by>    <notes></notes>  </project>';
        doc.load(docXml);
        stubDocuments.add(doc);
        stubDocuments.add(doc);
        HarvestServiceStub.stubDocuments = stubDocuments; 

        svc.deactivateProject('1');
    }
}
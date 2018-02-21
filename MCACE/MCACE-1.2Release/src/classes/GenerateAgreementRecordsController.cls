/*
    Created by :Srikanth Pinnamaneni
    
*/
public class GenerateAgreementRecordsController {

    private ApexPages.StandardController std;

    private Commission_Rule__c[] newRules;

    private Commission_Structure__c newStructure;

    private Commission_Rule_Entry__c[] newEntries;

    private Integer validSortNumber;

    private Set < Id > ruleIds;


    public GenerateAgreementRecordsController(ApexPages.StandardController std) {

        this.std = std;

        newRules = new Commission_Rule__c[] {};

        newEntries = new Commission_Rule_Entry__c[] {};

        ruleIds = new Set < Id > ();


    }


    public PageReference init() {

        CloneCommissionStructure();

        cloneCommissionRule();

        return new Pagereference('/' + newStructure.Id);

    }


    private void cloneCommissionStructure() {


        Commission_Structure__c structure = [SELECT Id, Name, Description__c, Type__c FROM Commission_Structure__c WHERE Id = : std.getId()];

        newStructure = structure.clone(false, true, false, false);

        insert newStructure;

    }

    private void cloneCommissionRule() {

        Commission_Rule__c newRule = new Commission_Rule__c();
        Map < Id, Commission_Rule__c > ruleMap = new Map < Id, Commission_Rule__c > ();

        List < Commission_Rule__c > rules = [SELECT Id, Name, Commission_Percentage__c, Commission_Structure__c, Commission_Type__c, Description__c, Fixed_Amount__c,

            Payable_Type__c, Percentage_Of__c FROM Commission_Rule__c WHERE Commission_Structure__c = : std.getId()
        ];


        for (Commission_Rule__c rule: rules) {

            newRule = rule.clone(false, true, false, false);

            newRule.Commission_Structure__c = newStructure.id;

            newRules.add(newRule);
            ruleMap.put(rule.id, newRule);

        }

        if (!newRules.isEmpty()) {
            insert newRules;
            CloneRuleEntries(ruleMap);

        }

    }

    private void cloneRuleEntries(Map < Id, Commission_Rule__c > ruleMap) {

        Commission_Rule_Entry__c[] entries = [SELECT Id, name, Commission_Rule__c, Description__c, Field_API__c, Object_API__c, Operator__c,
            text__c FROM Commission_Rule_Entry__c WHERE Commission_Rule__c IN: rulemap.keyset()
        ];

        for (Commission_Rule_Entry__c entry: entries) {
            if (rulemap.containsKey(entry.Commission_rule__c)) {

                Commission_Rule_Entry__c newEntry = entry.clone(false, true, false, false);
                newentry.Commission_Rule__c = ruleMap.get(entry.commission_rule__c).id;
                newEntries.add(newEntry);
            }
        }

        if (!newEntries.isEmpty()) {
            insert newEntries;

        }
    }

}
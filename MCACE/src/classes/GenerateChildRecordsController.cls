/*
     Created by:Srikanth Pinnamaneni
*/
public class GenerateChildRecordsController {


    private ApexPages.StandardController std;

    private Commission_Rule__c newRule;


    private Commission_Rule_Entry__c[] newEntries;

    private Integer validSortNumber;


    public generateChildRecordsController(ApexPages.StandardController std) {

        this.std = std;

        newEntries = new Commission_Rule_Entry__c[] {};

    }

    public PageReference init() {

        cloneCommissionRule();

        cloneRuleEntries();

        return new Pagereference('/' + newRule.Id);

    }

    private void cloneCommissionRule() {

        Commission_Rule__c rule = [SELECT Id, Name, Commission_Percentage__c, Commission_Structure__c, Commission_Type__c, Description__c, Fixed_Amount__c,
            Payable_Type__c, Percentage_Of__c FROM Commission_Rule__c WHERE Id = : std.getId()
        ];


        newRule = rule.clone(false, true, false, false);

        insert newRule;

    }

    private void cloneRuleEntries() {

        Commission_Rule_Entry__c[] entries = [SELECT Id, name, Commission_Rule__c, Description__c, Field_API__c, Object_API__c, Operator__c, text__c FROM Commission_Rule_Entry__c WHERE Commission_Rule__c = : std.getId()];

        for (Commission_Rule_Entry__c entry: entries) {

            Commission_Rule_Entry__c newEntry = entry.clone(false, true, false, false);

            newEntry.Commission_Rule__c = newRule.Id;

            newEntries.add(newEntry);

        }

        if (!newEntries.isEmpty()) {

            insert newEntries;

        }

    }

}
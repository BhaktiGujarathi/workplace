/*
    Revision History:
 *
 * Version         Author              Date(DD-MM-YYYY)      Description
 * 1.0             Shraddha P.           16-03-2016          Initial Draft
 * 2.0             Ajinkya H.            10-01-2017          Fix for rollup for Offer on Submission events
 */
trigger SubmissionTrigger on Submission__c (after insert, before delete, after delete, after undelete) {

    List<MCATriggerExecuter__mdt> triggerExecutors
        = [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'SubmissionRollUpTrigger'];
    if(triggerExecutors.isEmpty() || !triggerExecutors[0].IsActivate__c) {
        return;
    }

    if(trigger.isBefore && trigger.isDelete) {
        // Fetch child Offers related to deleted Submissions
        // and assign to static variable to be used in after delete event handler
        OfferHandler.offersToDelete = [SELECT
                                            Id
                                            , Opportunity__c
                                        FROM
                                            Offer__c
                                        WHERE
                                            Submission__c IN: trigger.old
                                        ];
    }

    if(trigger.isAfter) {

        //if record is Inserted,Updated or Undeleted fire the following trigger condition
        if(trigger.isInsert) {
            List<RollupService.FieldDefinition> fieldDefinitions =
            new List<RollupService.FieldDefinition> {
                new RollupService.FieldDefinition('COUNT', 'Id', 'Number_of_Submission__c')
            };
            RollupService.rollUpTrigger(fieldDefinitions,trigger.new, 'Submission__c', 'Opportunity__c', 'Opportunity', '');
        }

        //if record is Deleted fire the following trigger condition
        if(trigger.isDelete){
            List<RollupService.FieldDefinition> fieldDefinitions =
            new List<RollupService.FieldDefinition> {
                new RollupService.FieldDefinition('COUNT', 'Id', 'Number_of_Submission__c')
            };
            RollupService.rollUpTrigger(fieldDefinitions,trigger.old, 'Submission__c', 'Opportunity__c', 'Opportunity', '');

            // Call after delete event handler for child Offers for deleted submissions
            if(OfferHandler.offersToDelete != null && !OfferHandler.offersToDelete.isEmpty()) {
                new OfferHandler().onAfterDelete(OfferHandler.offersToDelete);
            }
        }

        if(trigger.isUndelete) {
            List<RollupService.FieldDefinition> fieldDefinitions =
            new List<RollupService.FieldDefinition> {
                new RollupService.FieldDefinition('COUNT', 'Id', 'Number_of_Submission__c')
            };
            RollupService.rollUpTrigger(fieldDefinitions,trigger.new, 'Submission__c', 'Opportunity__c', 'Opportunity', '');

            // Fetch undeleted child Offer records and call after undelete event handler for Offer
            List<Offer__c> undeletedOffers = [SELECT
                                                    Id
                                                    , Opportunity__c
                                                    , IsDeleted
                                                FROM
                                                    Offer__c
                                                WHERE
                                                    Submission__c IN: trigger.new
                                            ];
            if(!undeletedOffers.isEmpty()) {
                new OfferHandler().onAfterUndelete(undeletedOffers);
            }
        }
    }
}
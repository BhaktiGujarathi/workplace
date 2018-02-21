public with sharing class UnderwriterAssignmentRule {
    
    public Integer sortOrder { get; set; }
    public Boolean useQuotas { get; set; }
    public Boolean useLoadBalancing { get; set; }
    public UnderwriterAssignmentRuleEntry[] assignmentRuleEntries { get; set; }
    public UnderwriterAssignmentRuleMember[] assignmentRuleMembers { get; set; }


    public UnderwriterAssignmentRule(Underwriter_Assignment_Rule__c assignmentRule) {
        
        assignmentRuleEntries = new UnderwriterAssignmentRuleEntry[]{};
        assignmentRuleMembers = new UnderwriterAssignmentRuleMember[]{};


        useQuotas = assignmentRule.Quotas__c;
        useLoadBalancing = assignmentRule.Load_Balancing__c;
        sortOrder = Integer.valueOf(assignmentRule.Sort_Order__c);
        

        for (Underwriter_Assignment_Rule_Entry__c assignmentRuleEntry : assignmentRule.Underwriter_Assignment_Rule_Entries__r) {

            assignmentRuleEntries.add(new UnderwriterAssignmentRuleEntry(assignmentRuleEntry));
        }


        for (Underwriter_Assignment_Rule_Member__c assignmentRuleMember : assignmentRule.Underwriter_Assignment_Rule_Members__r) {

            assignmentRuleMembers.add(new UnderwriterAssignmentRuleMember(assignmentRuleMember));
        }        
    }


    public Set<String> getObjectFields() {

        Set<String> objectFields = new Set<String>();

        for (UnderwriterAssignmentRuleEntry assignmentRuleEntry : assignmentRuleEntries) {

            objectFields.add(assignmentRuleEntry.fieldAPI);
        }

        return objectFields;
    }    


    public Boolean evaluateRule(Opportunity opportunity) {

        Boolean assignmentRuleMatched = null;

        if (!assignmentRuleEntries.isEmpty()) {
            
            for (UnderwriterAssignmentRuleEntry assignmentRuleEntry : assignmentRuleEntries) {

                assignmentRuleMatched = evaluateRuleEntry(assignmentRuleMatched, assignmentRuleEntry.evaluateRuleEntry(opportunity));
            }
        }

        return (assignmentRuleMatched == true);
    }


    private Boolean evaluateRuleEntry(Boolean assignmentRuleMatched, Boolean evaluationResult) {

        if (assignmentRuleMatched == null) {

            assignmentRuleMatched = true;
        }

        return assignmentRuleMatched && evaluationResult;
    }


    public UnderwriterAssignmentRuleMember getAssignmentRuleMember() {

        if (!assignmentRuleMembers.isEmpty()) {

            Map<String, Opportunity[]> opportunitiesMap = getOpportunitiesMap();

            List<Integer> pipelines = new List<Integer>();
            Map<Integer, Set<Id>> usersPipelines = getUserPipeline();

            for (Integer i : usersPipelines.keySet()) {

                pipelines.add(i);
            }

            pipelines.sort();


            for (Integer i : pipelines) {

                for (UnderwriterAssignmentRuleMember assignmentRuleMember : getMembersByAssignmentDate(usersPipelines.get(i))) {

                    Integer assignedOpportunities = 0;

                    if (opportunitiesMap.containsKey(assignmentRuleMember.id + '-' + assignmentRuleMember.underwriter)) {
                        
                        assignedOpportunities = opportunitiesMap.get(assignmentRuleMember.id + '-' + assignmentRuleMember.underwriter).size();
                    }   


                    if (useQuotas) {

                        if (assignedOpportunities < assignmentRuleMember.quota) {

                            assignmentRuleMember.lastAssignmentDatetime = Datetime.now();

                            return assignmentRuleMember;
                        }
                        else if (assignmentRuleMember.quota == 0) {
                        
                            assignmentRuleMember.lastAssignmentDatetime = Datetime.now();

                            return assignmentRuleMember;
                        }
                    }
                    else {

                        assignmentRuleMember.lastAssignmentDatetime = Datetime.now();

                        return assignmentRuleMember;
                    }
                }
            }
        }

        return null;
    }


    private Map<String, Opportunity[]> getOpportunitiesMap() {

        Set<Id> assignmentRuleMemberIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Map<String, Opportunity[]> opportunitiesMap = new Map<String, Opportunity[]>();
        

        for (UnderwriterAssignmentRuleMember assignmentRuleMember : assignmentRuleMembers) {

            assignmentRuleMemberIds.add(assignmentRuleMember.id);
            userIds.add(assignmentRuleMember.underwriter);
        }


        Opportunity[] opportunities = (Opportunity[]) Database.query(
            'SELECT Underwriter__c, ' +
            '       Underwriter_Assignment_Rule_Member__c ' +
            '  FROM Opportunity ' +
            ' WHERE Underwriter__c in :userIds ' +
            '   AND Underwriter_Assignment_Rule_Member__c in :assignmentRuleMemberIds ' +
            '   AND Underwriter_Assignment_Rule_Member__c <> null' +
            '   AND Count_Against_Pipeline__c = true'
        );


        for (Opportunity o : opportunities) {

            if (!opportunitiesMap.containsKey(o.Underwriter_Assignment_Rule_Member__c + '-' + o.Underwriter__c)) {

                opportunitiesMap.put(o.Underwriter_Assignment_Rule_Member__c + '-' + o.Underwriter__c, new Opportunity[]{});
            }

            opportunitiesMap.get(o.Underwriter_Assignment_Rule_Member__c + '-' + o.Underwriter__c).add(o);
        }

        return opportunitiesMap;
    }


    private Map<Integer, Set<Id>> getUserPipeline() {

        Set<Id> userIds = new Set<Id>();
        Map<Id,Integer> usersOpportunities = new Map<Id,Integer>();
        Map<Integer, Set<Id>> usersPipelines = new Map<Integer, Set<Id>>();


        for (UnderwriterAssignmentRuleMember assignmentRuleMember : assignmentRuleMembers) {

            userIds.add(assignmentRuleMember.underwriter);
        }

        
        Opportunity[] opportunities = (Opportunity[]) Database.query(
            'SELECT Underwriter__c ' +
            '  FROM Opportunity ' + 
            ' WHERE Underwriter__c in :userIds' +
            '   AND Count_Against_Pipeline__c = true'
        );


        for (Opportunity o : opportunities) {

            if (usersOpportunities.get(o.Underwriter__c) == null) {

                usersOpportunities.put(o.Underwriter__c, 0);
            }

            if (useLoadBalancing) {
                
                usersOpportunities.put(o.Underwriter__c, usersOpportunities.get(o.Underwriter__c) + 1);
            }
            else {

                usersOpportunities.put(o.Underwriter__c, 0);                
            }
        }


        for (Id userId : usersOpportunities.keySet()) {

            if (!usersPipelines.containsKey(usersOpportunities.get(userId))) {

                usersPipelines.put(usersOpportunities.get(userId), new Set<Id>());                
            }

            usersPipelines.get(usersOpportunities.get(userId)).add(userId);                
        }

        if (usersPipelines.isEmpty()) {

            usersPipelines.put(0, userIds);
        }
        else {

            for (Integer pipeline : usersPipelines.keySet()) {

                for (Id userId : usersPipelines.get(pipeline)) {

                    userIds.remove(userId);
                }
            }

            if (!userIds.isEmpty()) {

                if (usersPipelines.get(0) == null) {
                    
                    usersPipelines.put(0, new Set<Id>());
                }

                usersPipelines.get(0).addAll(userIds);
            }
        }

        return usersPipelines;
    }


    private UnderwriterAssignmentRuleMember[] getMembersByAssignmentDate(Set<Id> userIds) {

        UnderwriterAssignmentRuleMember[] membersByAssignmentDate = new UnderwriterAssignmentRuleMember[]{};

        for (UnderwriterAssignmentRuleMember assignmentRuleMember : assignmentRuleMembers) {

            if (userIds.contains(assignmentRuleMember.underwriter)) {
                
                membersByAssignmentDate.add(assignmentRuleMember);                
            }
        }

        return membersByAssignmentDate;
    }    
}
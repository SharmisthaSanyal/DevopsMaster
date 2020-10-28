// Without sharing to avoid errors when running user changes status to Act Now and is not a member of the queue that is assigned the record
public without sharing class H_Lead {
    public static void handleBeforeUpdate(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        List<Lead> leadsToProcessAssignmentRulesOn = new List<Lead>();
        for(Lead ltp : newMap.values()) {
            if(ltp.Status == 'Act Now' && oldMap.get(ltp.Id).Status != 'Act Now') {
                leadsToProcessAssignmentRulesOn.add(ltp);
            }
        }
        if(!leadsToProcessAssignmentRulesOn.isEmpty()) {
            H_Lead.triggerLeadAssignmentRules(leadsToProcessAssignmentRulesOn);
        }
    }

    // For any of the leads passed into this. We will aim to update the leads to use the assignment rules.
    public static void triggerLeadAssignmentRules(List<Lead> leadsToProcess) {
        List<Lead> leadsToUpdate = new List<Lead>();
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.assignmentRuleHeader.useDefaultRule = true;
        dmlOptions.emailHeader.triggerUserEmail = true;
        for(Lead ltp : leadsToProcess) {
            Lead ltu = new Lead();
            ltu.Id = ltp.Id;
            ltu.setOptions(dmlOptions);
            leadsToUpdate.add(ltu);
        }

        if(!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }
}
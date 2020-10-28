public without sharing class MeetingOutcome {
    /* creating variables */
    public Lead l {get;set;}
    public Meeting__c m {get;set;}
    public String recId {get; set;}
    public String errMsg {get;set;}
    
    /* getting the Lead record */
    public Lead getLead() {
        return l;
    }
    /* getting the Meeting__c record */
    public Meeting__c getMeeting() {
        return m;
    }
    
 	/* pulls the record Id from the visualforce page and queries for the Meeting__c record 
	and associated Lead record */
    public MeetingOutcome(ApexPages.StandardController controller) {
    	recId = controller.getId();
        
        m = [SELECT Id, Name, Lead__r.VSE_SDR_Review__c, Meeting_Category__c, 
             Meeting_Location__c, Event_DateTime__c, Outcome__c, 
             Short_Term_Opportunity__c, Opportunity_Number__c, Meeting_Notes__c,
             Lead_Name__c, SDR__c, Company__c,
             Lead__r.OwnerId, Lead__r.Company, Lead__r.Name
             FROM Meeting__c 
             WHERE Id =:recId];
        
        l =[SELECT Id, Company, Name, VSE_Opportunity_Number__c, VSE_SDR_Review__c 
            FROM Lead
           	WHERE Id =:m.Lead__c];
    }
    
	/* validates the data sent from the visualforce form and saves to the record */
    public PageReference save() {
        /* if there is an error, it will be added to the errMsg variable */
        errMsg = null;
        
		/* validate Outcome__c field: outcome is not --None-- */
        if(m.Outcome__c != '--None--') {
            /* outcome is Thumbs Up: change Lead VSE_SDR_Review__c field to Meeting Positive 
			and Meeting__c Meeting_Status__c to Meeting Completed - Opportunity Viable */
            if(m.Outcome__c == 'Thumbs Up') {
                l.VSE_SDR_Review__c  = 'Meeting Positive';
                m.Meeting_Status__c = 'Meeting Completed - Opportunity Viable';
            }        
			/* outcome is Thumbs Down: change Lead VSE_SDR_Review__c field to Initiate Rejection
			and Meeting__c Meeting_Status__c to Meeting Completed */
            if(m.Outcome__c == 'Thumbs Down') {
                l.VSE_SDR_Review__c = 'Initiate Rejection';
                m.Meeting_Status__c = 'Meeting Completed';
            }
            /* outcome is Meeting Reschedule Request: change Meeting__c Meeting_Status__c to Meeting Rescheduled */
            if(m.Outcome__c == 'Meeting Reschedule Request') {
                m.Meeting_Status__c = 'Meeting Rescheduled';
            }
        /* outcome is --None--: add error to errMsg. */
        } else {
            errMsg = '  ERROR: Please select a meeting outcome.';
        }
        /* validate Short_Term_Opportunity__c field */
        if(m.Short_Term_Opportunity__c == null || m.Short_Term_Opportunity__c == '--None--') {
            errMsg += '  ERROR: Short Term Opportunity must be either Yes or No.';
        } else if(m.Short_Term_Opportunity__c == 'Yes') {
            /* validate Opportunity_Number__c: not blank, set Lead VSE_Opportunity_Number__c 
			to Meeting__c Opportunity_Number__c value */
            if(String.isNotBlank(m.Opportunity_Number__c)) {
                l.VSE_Opportunity_Number__c = m.Opportunity_Number__c;
            }
            else {
                errMsg += '  ERROR: Opportunity number cannot be null.';
            }
        }
		/* if there are Meeting_Notes__c, save to the Meeting__c record */
        if(m.Meeting_Notes__c != '' || m.Meeting_Notes__c != null) {
            m.Meeting_Notes__c = m.Meeting_Notes__c;
        }
        /* if the errMsg is no longer null, show the error in the <apex:pageMessages ></apex:pageMessages> tags */
        if(errMsg != null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, errMsg);
            ApexPages.addMessage(msg);
            
            system.debug('ERROR: ' + errMsg);
            return null;
        }
        /* errMsg is still null: try to update Meeting__c and Lead records. show success message. */
        else {
            try {
                update m;
                update l;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'  Feedback successfully saved. Thank you.'));  
            }
            /* error saving the Meeting__c and Lead records. display the error and show in a debug. */
            catch(Exception e) {
                ApexPages.addMessages(e);
                system.debug('ERROR: ' + e.getMessage());
            }
            return null;
        }
    }
}
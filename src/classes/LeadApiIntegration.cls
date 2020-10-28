/* US-279560
 * 1 to 1 Integration with Ascend
 * Created On : 03-03-2020 v1.0
 * Created By : Rahul Kotamgari
 * called from LeadTriggerHandler.cls
*/
public class LeadApiIntegration {
    
    //QualificationLevel code Map
    public static Map<String, String> qCodeMap = new Map<String, String>{
        'Z1' => 'Suspect', 'Z2' => 'Inquiry', 'Z3' => 'MQL', 'Z4' => 'SAL' , 'Z5' => 'SQL', 'Z6' => 'SQO'
    };
        
    /* 1. Insert Lead in SFDC  --> Create Lead in Ascend */
    /* 2. Update Lead in SFDC  --> Create Lead in Ascend */    
    @future(callout = true)
    public static void createLeadsInAscend(Set<Id> leadsIdSet) {
        // CALL 1 - GET call to get CSRF token and session Id
        HTTPResponse response = LeadApiService.getTokensFromAscend(leadsIdSet);
        
        if(response != null && response.getstatusCode() == 200){ 
            String csrfToken = String.valueOf(response.getHeader('x-csrf-token'));
            String cookie = response.getHeader(System.Label.Set_Cookie_Lower_Case);
            String sessionId ;
            if(String.isBlank(cookie)){
                cookie = response.getHeader(System.Label.Set_Cookie_Upper_Case); 
            } 
            if(!String.isBlank(cookie)){
            	sessionId = cookie.substringBefore(';');  
            }
            
            //Create lead api call
            System.debug('--csrfToken--'+csrfToken);
            System.debug('--sessionId--'+sessionId);
            System.debug('---cookie--'+cookie);
            
            //if crsftoken and sessionId is not blank then make api call
            if(!String.isBlank(csrfToken) && !String.isBlank(sessionId)){
                // CALL 2 - POST call to Create Lead
            	LeadApiService.createLeadApiCall(leadsIdSet, csrfToken, sessionId);
            }
        }
    }
    
    /*  3. Update Lead in SFDC --> Update Lead in Ascend */
    @future(callout = true)
    public static void updateLeadsInAscend(String stageCode, String statusCode, Set<Id> leadIdUpdateSet, String codeDeveloperName) {
        String qualificationLevelCode;
        // CALL 1 - GET call to get CSRF token and session Id
        HTTPResponse response = LeadApiService.getTokensFromAscend(leadIdUpdateSet);
        
        if(response != null && response.getstatusCode() == 200){ 
            String csrfToken = String.valueOf(response.getHeader('x-csrf-token'));
            String cookie = response.getHeader(System.Label.Set_Cookie_Lower_Case);
            String sessionId ;
            if(String.isBlank(cookie)){
                cookie = response.getHeader(System.Label.Set_Cookie_Upper_Case); 
            } 
            if(!String.isBlank(cookie)){
            	sessionId = cookie.substringBefore(';');  
            } 
            //Create lead api call
            System.debug('--csrfToken--'+csrfToken);
            System.debug('--sessionId--'+sessionId);
            
            String ascendStageCode ;
            Boolean makeUpdateCall = false;
            //if crsftoken and sessionId is not blank then make api call
            if(!String.isBlank(csrfToken) && !String.isBlank(sessionId)){
                for(Id leadId : leadIdUpdateSet){
					qualificationLevelCode = LeadApiService.getLeadDataFromAscend(csrfToken, sessionId, leadId );   
                    ascendStageCode = qCodeMap.containsKey(qualificationLevelCode) ? qCodeMap.get(qualificationLevelCode) : '';
                    
                    //Validates the stage and makes the update call
                    if(!String.isBlank(ascendStageCode)) {
                        if((codeDeveloperName == 'PlaybookPopulatedAndMeetingSetIsBlank' || codeDeveloperName == 'Rejected') && (ascendStageCode == 'MQL' || ascendStageCode == 'SAL')) {
                            makeUpdateCall = true;
                        } else if((codeDeveloperName == 'Qualified' || codeDeveloperName == 'RejectedAndMeetingDatePopulated') && (ascendStageCode == 'MQL' || ascendStageCode == 'SAL' || ascendStageCode == 'SQL')) {
                            makeUpdateCall = true;
                        } else if(codeDeveloperName == 'Qualified_With_Meeting_Positive' && (ascendStageCode == 'MQL' || ascendStageCode == 'SAL' || ascendStageCode == 'SQO' || ascendStageCode == 'SQL')) {
                            makeUpdateCall = true;
                        } else {
                            
                            Lead leadData = new Lead();
                            leadData.id = leadId;
                            leadData.Ascend_Response_Code__c = '';
                            leadData.Ascend_Lead_Update_failed__c = false;
                            leadData.Send_to_Ascend__c = false;
                            leadData.Ascend_Response_Description__c	 = '[' + System.now() + '] ' + System.Label.Lead_has_been_progressed;
                            System.debug('----leadData'+leadData);
                            Update leadData;
                        }
                    }
                    
                    System.debug('---codeDeveloperName-'+codeDeveloperName);
                    System.debug('--ascendStageCode--'+ascendStageCode);
                    System.debug('---makeUpdateCall--'+makeUpdateCall);
                    
                    // CALL 2 - POST call to Update Lead details
                    if(makeUpdateCall) {
                    	LeadApiService.updateLeadInAscend(csrfToken, sessionId, stageCode, statusCode, leadIdUpdateSet);
                    }
                }
            }
        }
    }
}
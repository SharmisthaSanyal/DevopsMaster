/* US-279560 Test Deploy
 * 1 to 1 Integration with Ascend,so that sales reps can Convert Leads into Opportunities from Ascend 
 * Created On : 03-03-2020 v1.0
 * Created By : Rahul Kotamgari
 * Handler for LeadsIntegration.trigger
*/
public class LeadTriggerHandler {
    
    public static String stageCode;
    public static String statusCode;
    public static String codeDeveloperName;
    
    /* 1. Insert Lead in SFDC & No 'AscendLeadId' --> Create Lead in Ascend */
    /* if Status = Qualified and Meeting Start Date has value */   
    public void OnAfterInsertCreateLeadInAscend(List<Lead> LeadwithNoAscendList) {
    	
        Set<Id> leadIdSet = new Set<Id>(); 
   		for(Lead leadRecord : LeadwithNoAscendList){
        	if(leadRecord.Status == System.Label.Qualified_Status 
               && leadRecord.VSE_Meeting_Start_Date__c != null) {
             
                   leadIdSet.add(leadRecord.Id);
             }
         }//for
        system.debug('@@@@@ OnAfterInsert - leads to be created in Ascend='+leadIdSet);
         if ( !leadIdSet.isEmpty() ){
          	if( AscendStatic.runOnce() ){ 
            	LeadApiIntegration.createLeadsInAscend(leadIdSet);
            }
         }//if not empty 
        
    }//fn
     
    
    /* 2. Update Lead in SFDC & No 'AscendLeadId' --> Create Lead in Ascend  
       if (Status = Qualified & changed)   (Meeting Start Date hasValue & changed)*/	
    public void OnAfterUpdateCreateLeadInAscend(List<Lead> LeadsWithAscendIdList, Map<Id, Lead> leadOldMap) {
        // check if Status= Qualified , Meeting Start Date has value or ischanged
        Set<Id> leadIdCreateSet = new Set<Id>();
        for(Lead leadRecord : LeadsWithAscendIdList){
                    if((leadRecord.Status == System.Label.Qualified_Status 
                       && String.isBlank(leadRecord.VSE_Ascend_Lead_Id__c)
                       && leadRecord.VSE_Meeting_Start_Date__c != null 
                       && (leadRecord.Status != leadOldMap.get(leadRecord.Id).Status || leadOldMap.get(leadRecord.Id).VSE_Meeting_Start_Date__c == null))
                       || (String.isBlank(leadRecord.VSE_Ascend_Lead_Id__c) && leadRecord.Send_to_Ascend__c == true && leadOldMap.get(leadRecord.Id).Send_to_Ascend__c != true)) {
                                    
                    	leadIdCreateSet.add(leadRecord.Id);
         		  	}
         }//for
        
         system.debug('@@@@@ OnAfterUpdate - leads to be created in Ascend='+leadIdCreateSet);
         if ( !leadIdCreateSet.isEmpty() ){
          	if( AscendStatic.runOnce() ){ 
            	LeadApiIntegration.createLeadsInAscend(leadIdCreateSet);
            }
         }//if not empty 
    }
    
    
   /*  3. Update Lead in SFDC & 'AscendLeadId' is present --> Update Lead in Ascend
    */    
	public void OnAfterUpdateUpdateLeadInAscend(List<Lead> LeadsWithAscendIdList, Map<Id, Lead> leadOldMap) {
        Set<Id> leadIdUpdateSet = new Set<Id>();
        for(Lead leadRecord : LeadsWithAscendIdList){
            leadIdUpdateSet.add(leadRecord.Id);
            Boolean ascendCheck = leadRecord.Send_to_Ascend__c && leadOldMap.get(leadRecord.Id).Send_to_Ascend__c != true;
            
            Boolean playbookPopulateMeetingSetDateBlank = (!String.isBlank(leadRecord.Playbooks_Play_Name__c) && leadRecord.VSE_Meeting_Set_Date__c == null);
            //3.1 playbook name populated and Meeting setdate is blank and ascend id is present
            if(playbookPopulateMeetingSetDateBlank && String.isBlank(leadOldMap.get(leadRecord.Id).Playbooks_Play_Name__c) || playbookPopulateMeetingSetDateBlank && ascendCheck ) {
                codeDeveloperName = 'PlaybookPopulatedAndMeetingSetIsBlank';
            }
            
            Boolean rejected = leadRecord.Status == 'Rejected';
            Boolean qualified = leadRecord.Status == System.Label.Qualified_Status;
            Boolean qualifiedAndSDRPositive = (leadRecord.Status == System.Label.Qualified_Status && leadRecord.VSE_SDR_Review__c == System.Label.Ascend_Meeting_Positive);
                
            // 3.2.'Status' = "Rejected" && 'Ascend Lead ID' is present && 'Meeting Set Date' is Blank
        	if(rejected && leadRecord.Status != leadOldMap.get(leadRecord.Id).Status || rejected && ascendCheck) {
                if(leadRecord.VSE_Meeting_Set_Date__c == null) { //'MeetingSetDate' is blank                   
                    codeDeveloperName = 'Rejected';//Set developer name of  CustomMetadata
                } // 3.4 Status = "Rejected" && Ascend Lead ID is present && Meeting Set Date is NOT Blank           
                else if(leadRecord.VSE_Meeting_Set_Date__c != null) { //'MeetingSetDate' is NOT blank
                    codeDeveloperName = 'RejectedAndMeetingDatePopulated';//Set developer name of  CustomMetadata
                }
            }
            
            // 3.3 Status is Qualified 
            else if(qualified && leadRecord.Status != leadOldMap.get(leadRecord.Id).Status || qualified && ascendCheck ) {
                    codeDeveloperName = 'Qualified';
            } 
            
            //3.5 Status is Qualified and SDR meeting review is positive
            else if(qualifiedAndSDRPositive && leadRecord.VSE_SDR_Review__c != leadOldMap.get(leadRecord.Id).VSE_SDR_Review__c || qualifiedAndSDRPositive && ascendCheck ){
           		codeDeveloperName = 'Qualified_With_Meeting_Positive';     
            }
            
            System.debug('--codeDeveloperName--'+codeDeveloperName);
            if(!String.isBlank(codeDeveloperName)){
                //Fetch the stage code and status code from custom metadat
                List<Ascend_Integ_QualifiedRej_StatusStage__mdt> codeList = [SELECT DeveloperName, AscendLeadStage__c, AscendLeadStatus__c 
                                                                             FROM Ascend_Integ_QualifiedRej_StatusStage__mdt 
                                                                             WHERE DeveloperName = :codeDeveloperName];
                if(!codeList.isEmpty()){
                    stageCode = codeList.get(0).AscendLeadStage__c;
                    statusCode = codeList.get(0).AscendLeadStatus__c;
                    if( AscendStatic.runOnce() ){ 
                    	LeadApiIntegration.updateLeadsInAscend(stageCode, statusCode, leadIdUpdateSet, codeDeveloperName);
                    }
                }
            }
        }
    }    
}
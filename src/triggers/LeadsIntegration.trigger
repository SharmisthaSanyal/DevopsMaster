/* US-279560
 * 1 to 1 Integration with Ascend,so that sales reps can Convert Leads into Opportunities from Ascend 
 * Created On : 03-03-2020 v1.0
 * Created By : Rahul Kotamgari
*/

trigger LeadsIntegration on Lead (after insert, after update) {
    
    LeadTriggerHandler handler = new LeadTriggerHandler();
    Map<Id, lead> leadOldMap = Trigger.oldMap;        
   
    /* 1. Insert Lead in SFDC & No 'AscendLeadId' --> Create Lead in Ascend */
    if(Trigger.isAfter && Trigger.isInsert){
        
        Set<Id> LeadIdSet = new Set<Id>();
        List<Lead> LeadwithNoAscendList = new List<Lead>();
       
        for(Lead leadRecord : Trigger.New){
            if( String.isBlank(leadRecord.VSE_Ascend_Lead_Id__c) ) {           
                       LeadwithNoAscendList.add(leadRecord);
                       handler.OnAfterInsertCreateLeadInAscend(LeadwithNoAscendList);                  
            }   
        } 
    }// 'AfterInsert'
    
    /* 2. Update Lead in SFDC & No 'AscendLeadId' --> Create Lead in Ascend 
       3. Update Lead in SFDC & 'AscendLeadId' is present --> Update Lead in Ascend */
    if(Trigger.isAfter && Trigger.isUpdate) {
            
        List<Lead> LeadwithNoAscendList = new List<Lead>();
        List<Lead> LeadsWithAscendIdList = new List<Lead>();
     
        for(Lead leadRecord : Trigger.New){
        	if(String.isBlank(leadRecord.VSE_Ascend_Lead_Id__c)){ // No 'AscendLeadId'
                //Update Lead in SFDC & No 'AscendLeadId' --> Create Lead in Ascend 
                LeadwithNoAscendList.add(leadRecord);
                handler.OnAfterUpdateCreateLeadInAscend(LeadwithNoAscendList,leadOldMap);
            }else{
                 //'AscendLeadId' Present
                //Update Lead in SFDC & 'AscendLeadId' is present --> Update Lead in Ascend
                 LeadsWithAscendIdList.add(leadRecord);
                 handler.OnAfterUpdateUpdateLeadInAscend(LeadsWithAscendIdList, leadOldMap);
            }                
        }//for    
        
    }// 'AfterUpdate'
    
}
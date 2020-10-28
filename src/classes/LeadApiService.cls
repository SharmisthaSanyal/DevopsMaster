/* US-279560
 * 1 to 1 Integration with Ascend
 * Created On : 03-03-2020 v1.0
 * Created By : Rahul Kotamgari
 * called from LeadApiIntegration.cls
*/
public class LeadApiService {
    
    public static String ascendStatusCode;
    public static Map<String, String> codesMap = new Map<String,String>();
    public static Lead leadDetails = new Lead();
    // CALL 1 - GET call to get CSRF token and session Id
    public static HTTPResponse getTokensFromAscend(Set<Id> LeadIdSet){
         for(Ascend_Lead_Integration_Picklist_Codes__mdt codes : [SELECT AscendCode__c, SFDCPicklistValue__c FROM
                                                                Ascend_Lead_Integration_Picklist_Codes__mdt  ]){
       		codesMap.put(codes.SFDCPicklistValue__c, codes.AscendCode__c);                                        
        }
	
        HTTPRequest request = new HTTPRequest();
        request.setEndpoint('callout:Ascend_Lead_Integration');
        request.setHeader('x-csrf-token', 'fetch');
        request.setHeader('Set-Cookie', 'fetch');
        request.setMethod('GET');
        HTTPResponse response;
        String csrfToken;
        String sessionId;
        try{
        	response = new Http().send(request);
            System.debug('## Http GET response=='+response);
            csrfToken = String.valueOf(response.getHeader('x-csrf-token'));
            String cookie = response.getHeader(System.Label.Set_Cookie_Lower_Case);
            if(String.isBlank(cookie)){
                cookie = response.getHeader(System.Label.Set_Cookie_Upper_Case); 
            } 
            if(!String.isBlank(cookie)){
            	sessionId = cookie.substringBefore(';');  
            }
            
            
            System.debug('---headers--'+response.getHeaderKeys());
            System.debug('---cookie--'+cookie);
        } catch(calloutException ex) {
            System.debug('##calloutException'+ex);
        }
        
        //csrf or sessionId or status != 200 - update error details to lead
        if(String.isBlank(csrfToken) || String.isBlank(sessionId)){
            leadDetails.Ascend_Response_Description__c = ' [ '+system.now() +' :GET Token BLANK => '+ System.Label.AscendGetCallCSRFSessionIDIssue + ' ] ';
            Id leadId = (new list<Id>(LeadIdSet))[0];
            leadDetails.Id = leadId ;
        }
        if(response.getStatusCode() != 200){ //error (200=success)
            leadDetails.Ascend_Response_Code__c  = ' [ ' +system.now()+' :GET Token:FAIL => '+String.valueOf(response.getStatusCode()) + ' ] ';
            leadDetails.Ascend_Response_Description__c = ' [ ' + system.now()+' :GET Token:FAIL: '+leadDetails.Ascend_Response_Description__c
                + response.getBody() + ' ] ';
        }
        if(String.isBlank(csrfToken) || String.isBlank(sessionId) || response.getStatusCode() != 200){
           Update leadDetails;  
        }
        
        return response;
    }
    
    /* 1. Insert Lead in SFDC  --> Create Lead in Ascend */
    /* 2. Update Lead in SFDC  --> Create Lead in Ascend */
    public static void createLeadApiCall(Set<Id> newLeadSet, String csrfToken, String sessionId){
        List<Ascend_Lead_Integration_Mapping__mdt> fieldMappingList = [SELECT Id, label, DeveloperName, Source_Field__c,
                            Target_Field__c FROM Ascend_Lead_Integration_Mapping__mdt WHERE Is_Insert__c = true];
        
        String queryStr = 'SELECT ';
        for(Ascend_Lead_Integration_Mapping__mdt mdt : fieldMappingList) {
            if(mdt.Source_Field__c == 'Status' && queryStr.contains(mdt.Source_Field__c)){
                continue;
            } else {
                queryStr = queryStr == 'SELECT ' ? queryStr + mdt.Source_Field__c  : queryStr + ',' + mdt.Source_Field__c ;
            }
        }
        queryStr = queryStr + ' FROM Lead WHERE Id IN :newLeadSet' ; 
        
        //Query the lead record
        List<Lead> leadList = Database.query(queryStr);
        
		List<Lead> updatedList = new List<Lead>(); 
        
        for(Lead leadRec: leadList) {
            String requestJsonBody = createRequestBody(leadRec, fieldMappingList);
        	String ascendLeadId;
                                     
            System.debug('-requestJsonBody---'+requestJsonBody);
                                     
            HTTPRequest req = new HTTPRequest();
            req.setMethod('POST');
            req.setEndpoint('callout:Ascend_Lead_Integration/LeadCollection');
            req.setHeader('Content-Type','application/json');
            req.setHeader('Accept','application/json');
            req.setHeader('x-csrf-token', csrfToken);
            req.setHeader('cookie', sessionId);
            req.setBody(requestJsonBody);
            req.setTimeout(120000);
            HTTPResponse response;
           	
            try{
            	response = new http().send(req);
            } catch(calloutException ex){
                System.debug('---InsertFailed--'+ex);
            }
            
            if(response.getStatusCode() != 201){//error
				leadDetails.Ascend_Lead_Update_failed__c = true;
				leadDetails.Ascend_Response_Code__c  = ' [ '+system.now()+' :Create:POST:FAIL=> '+String.valueOf(response.getStatusCode())+' ] ';  
                leadDetails.Ascend_Response_Description__c = ' [ '+system.now() +' :Create:POST:FAIL: '+response.getBody()+' ] ';
            }else{// call2 success 201 = success  
                leadDetails.Ascend_Lead_Update_failed__c = false;
				//leadDetails.Ascend_Lead_Update_Success__c = true;
				leadDetails.Ascend_Response_Code__c  = ' [ '+system.now()+' :Create:POST:SUCCESS=> '+String.valueOf(response.getStatusCode())+' ] ';  
                leadDetails.Ascend_Response_Description__c = ' [ '+system.now() +' :Create:POST:SUCCESS]';
            
			}
                                     
            //Fetch Ascend Lead Id from response                  
            if( response.getstatusCode() == 201 ) {  //201 = success      
            	Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeuntyped(response.getBody());
                Map<String,Object> dataMap = (Map<String,Object>)responseMap.get('d');
                Map<String,Object> newMap = (Map<String,Object>)dataMap.get('results');
                ascendLeadId = String.valueOf(newMap.get('ID'));
                System.debug('Result--' + ascendLeadId);
                //CALL 3 - POST with PATCH call to update Status on created Lead in Ascend
                //Update Lead Status in Ascend
                if(!String.isBlank(ascendLeadId)){
                	updateLeadStatus(ascendLeadId, ascendStatusCode, csrfToken, sessionId, fieldMappingList);
                }
            }
			
            leadDetails.Id = leadRec.Id;
            leadDetails.VSE_Ascend_Lead_Id__c = ascendLeadId;
            leadDetails.Send_to_Ascend__c = false;
            updatedList.add(leadDetails);
    	}
        
        if(!updatedList.isEmpty()){
           UPDATE updatedList; 
        }
    }
   
    private static String createRequestBody(Lead leadData, List<Ascend_Lead_Integration_Mapping__mdt> fieldMappingList) {
        JSONGenerator jsonBody = JSON.createGenerator(true);  
        jsonBody.writeStartObject();      

        for(Ascend_Lead_Integration_Mapping__mdt mdt : fieldMappingList){ 
            if(!String.isBlank(String.ValueOf(leadData.get(mdt.Source_Field__c)))){
                if(mdt.DeveloperName == 'Lead_Category_Group_Code' && codesMap.containsKey(String.ValueOf(leadData.get(mdt.Source_Field__c)))) {
                    jsonBody.writeStringField(mdt.Target_Field__c, codesMap.get(String.ValueOf(leadData.get(mdt.Source_Field__c))));
                } else if(mdt.DeveloperName == 'Meeting_Start_Date_Meeting_Start_Date') {
                    DateTime formattedDt = (DateTime) leadData.get(mdt.Source_Field__c);
                    String newformattedDt = formattedDt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                    jsonBody.writeStringField(mdt.Target_Field__c, newformattedDt);
                } else if(mdt.DeveloperName == 'Company_Company'){
                    if(String.isBlank(String.valueOf(leadData.get('VSE_Ascend_Site_Id__c')))){
                        jsonBody.writeStringField(mdt.Target_Field__c, String.valueOf(leadData.get(mdt.Source_Field__c)));
                    }
                } else if(mdt.DeveloperName == 'Stage_QualificationLevelCode'){
                   List<Ascend_Integ_QualifiedRej_StatusStage__mdt> qualifiedCodeList = [SELECT DeveloperName, MasterLabel, AscendLeadStage__c, AscendLeadStatus__c 
                                                                                            FROM Ascend_Integ_QualifiedRej_StatusStage__mdt 
                                                                                            WHERE DeveloperName = 'Qualified'];
                    if(!qualifiedCodeList.isEmpty()){
                        jsonBody.writeStringField(mdt.Target_Field__c, qualifiedCodeList.get(0).AscendLeadStage__c);
                        ascendStatusCode = qualifiedCodeList.get(0).AscendLeadStatus__c;
                    }
                } else if(mdt.DeveloperName == 'Status_UserStatusCode' || mdt.DeveloperName == 'Status_Ascend_Status'){
                    continue;
                } else {
                    jsonBody.writeStringField(mdt.Target_Field__c, String.valueOf(leadData.get(mdt.Source_Field__c)));
                }
            }
        }
        jsonBody.writeEndObject();
        
        return jsonBody.getAsString();
    }
    
    // CALL 3 - POST with PATCH - Create Lead
    public static void updateLeadStatus(String ascendLeadId, String ascendStatusCode, String csrfToken, String sessionId,
                                       List<Ascend_Lead_Integration_Mapping__mdt> fieldMappingList) {
        JSONGenerator jsonBody = JSON.createGenerator(true);  
        jsonBody.writeStartObject();      
        
        for(Ascend_Lead_Integration_Mapping__mdt mdt : fieldMappingList) {
        	
            if(mdt.DeveloperName == 'Status_UserStatusCode') {
            	jsonBody.writeStringField('UserStatusCode', ascendStatusCode);
            } else if(mdt.DeveloperName == 'Status_Ascend_Status') {
                jsonBody.writeStringField('ZLeadStatus_KUT', ascendStatusCode);
            }
        }
        jsonBody.writeEndObject();
        String reqBody = jsonBody.getAsString();
        
        HTTPRequest request = new HTTPRequest();
        request.setEndpoint('callout:Ascend_Update_Integration/LeadCollection(\''+ascendLeadId +'\')');
        request.setHeader('Content-Type','application/json');
        request.setHeader('x-csrf-token', csrfToken);
        request.setHeader('cookie', sessionId);
        request.setHeader('X-HTTP-Method-Override','PATCH');
        request.setMethod('POST');
        request.setBody(reqBody);
        request.setTimeout(120000);
        HttpResponse response;
        
        try{
            response = new http().send(request);
        } catch(calloutException ex){
            System.debug('---InsertFailed--'+ex);
        }
        
        if(response.getStatusCode() == 204){//success
            //leadDetails.Ascend_Lead_Update_Success__c = true;
            leadDetails.Ascend_Lead_Update_failed__c = false;
			leadDetails.Ascend_Response_Code__c  = leadDetails.Ascend_Response_Code__c + ' [ '+ system.now() + ' :Create:PATCH:SUCCESS=> ' + String.valueOf(response.getStatusCode()) + ' ] ';
			leadDetails.Ascend_Response_Description__c  = leadDetails.Ascend_Response_Description__c + ' [ '+ system.now() + ' :Create:PATCH:SUCCESS ] ';
        } else {//error
		    leadDetails.Ascend_Lead_Update_failed__c = true;
            leadDetails.Ascend_Response_Code__c  = leadDetails.Ascend_Response_Code__c + ' [ '+ system.now() + ' :Create:PATCH:FAIL=> ' + String.valueOf(response.getStatusCode()) + ' ] ';
            leadDetails.Ascend_Response_Description__c = leadDetails.Ascend_Response_Description__c + ' [ '+system.now() + ':Create:PATCH:FAIL: '+response.getBody() + ' ] ';
        }
    }
    
    
    /*  3. Update Lead in SFDC --> Update Lead in Ascend */
    public static void updateLeadInAscend(String csrfToken, String sessionId, String stageCode, String statusCode, Set<Id> leadIdUpdateSet) {
        List<Ascend_Lead_Integration_Mapping__mdt> fieldMappingList = [SELECT Source_Field__c, Target_Field__c, DeveloperName
        								FROM Ascend_Lead_Integration_Mapping__mdt WHERE Is_Update__c = true ];
        
        String queryStr = 'SELECT ';
        for(Ascend_Lead_Integration_Mapping__mdt mdt : fieldMappingList) {
            if(mdt.Source_Field__c == 'Status' && queryStr.contains(mdt.Source_Field__c)){
                continue;
            } else {
                queryStr = queryStr == 'SELECT ' ? queryStr + mdt.Source_Field__c  : queryStr + ',' + mdt.Source_Field__c ;
            }
        }
        queryStr = queryStr + ' , VSE_Ascend_Lead_Id__c FROM Lead WHERE Id IN :leadIdUpdateSet' ; 
        
        List<Lead> leadList = Database.query(queryStr);
        List<Lead> updatedList = new List<Lead>();
        
        for(Lead leadRec: leadList) {
                             
        	String updateReqBody = buildUpdateRequestBody(leadRec, fieldMappingList, stageCode, statusCode);
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:Ascend_Update_Integration/LeadCollection(\''+leadRec.VSE_Ascend_Lead_Id__c +'\')');
            request.setHeader('Content-Type','application/json');
            request.setHeader('x-csrf-token', csrfToken);
            request.setHeader('cookie', sessionId);
            request.setHeader('X-HTTP-Method-Override','PATCH');
            request.setMethod('POST');
            request.setBody(updateReqBody);
            request.setTimeout(120000);
            HttpResponse response;
            system.debug('@@@updateReqBody=='+updateReqBody);                   
            try{
            	response = new http().send(request);
                System.debug('---responsebody--'+response.getbody());
            } catch(calloutException ex){
            	System.debug('---Update Failed--'+ex.getMessage());
            }
                               
            if(response.getStatusCode() != 204){//(204=success)
			    leadDetails.Ascend_Lead_Update_failed__c = true;
            	leadDetails.Ascend_Response_Code__c  = ' [ '+system.now()+' :Update:POSTPATCH:FAIL => '+String.valueOf(response.getStatusCode())+' ] ';
                leadDetails.Ascend_Response_Description__c = ' [ '+system.now()+' :Update:POSTPATCH:FAIL: '+response.getBody()+' ] ';
            }else{
				leadDetails.Ascend_Lead_Update_failed__c = false;
				leadDetails.Ascend_Response_Code__c  = ' [ '+system.now()+' :Update:POSTPATCH:SUCCESS => '+String.valueOf(response.getStatusCode())+' ] ';
				leadDetails.Ascend_Response_Description__c = ' [ '+system.now()+' :Update:POSTPATCH:SUCCESS ] ';
			}
            
            leadDetails.Id = leadRec.Id;
            leadDetails.Send_to_Ascend__c = false;
            updatedList.add(leadDetails);
        }
        system.debug('@@@ Update ascend call- updatedList='+updatedList);
        if(!updatedList.isEmpty()){
            
           UPDATE updatedList; 
        }
    }
    
    private static String buildUpdateRequestBody(Lead leadData, List<Ascend_Lead_Integration_Mapping__mdt> fieldMappingList,
                                                String stageCode, String statusCode) {
        JSONGenerator jsonBody = JSON.createGenerator(true);  
        jsonBody.writeStartObject();
        
        for(Ascend_Lead_Integration_Mapping__mdt mdt : fieldMappingList){ 
            system.debug('@@@@Reject Reason Codemap leadData.get(mdt.Source_Field__c)='+leadData.get(mdt.Source_Field__c)); 
            if(!String.isBlank(String.ValueOf(leadData.get(mdt.Source_Field__c)))) {             
                if(mdt.DeveloperName == 'Rejection_Reason_Result_Reason') {
                    system.debug('@@@@Reject Reason Codemap='+codesMap);                    	
                    if(codesMap.containsKey(String.ValueOf(leadData.get(mdt.Source_Field__c)))) {
                        String picklistVal = String.ValueOf(leadData.get(mdt.Source_Field__c));
                        if(picklistVal == 'Partner'){
                            picklistVal = picklistVal + ' (Rejected)';
                        }
                        jsonBody.writeStringField(mdt.Target_Field__c, codesMap.get(picklistVal));
                    }
                } else if(mdt.DeveloperName == 'Stage_QualificationLevelCode') {
                    jsonBody.writeStringField(mdt.Target_Field__c, stageCode);
                } else if(mdt.DeveloperName == 'Status_Ascend_Status') {
                	jsonBody.writeStringField(mdt.Target_Field__c, statusCode);
                } else if(mdt.DeveloperName == 'Status_UserStatusCode') {
                    jsonBody.writeStringField(mdt.Target_Field__c, statusCode);
                }else if(mdt.DeveloperName == 'Lead_Category_Group_Code' && codesMap.containsKey(String.ValueOf(leadData.get(mdt.Source_Field__c)))) {
                    jsonBody.writeStringField(mdt.Target_Field__c, codesMap.get(String.ValueOf(leadData.get(mdt.Source_Field__c))));
                } else if(mdt.DeveloperName == 'Meeting_Start_Date_Meeting_Start_Date') {
                    DateTime formattedDt = (DateTime) leadData.get(mdt.Source_Field__c);
                    String newformattedDt = formattedDt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                    jsonBody.writeStringField(mdt.Target_Field__c, newformattedDt);
                } else if(mdt.DeveloperName == 'Company_Company'){
                    if(String.isBlank(String.valueOf(leadData.get('VSE_Ascend_Site_Id__c')))){
                        jsonBody.writeStringField(mdt.Target_Field__c, String.valueOf(leadData.get(mdt.Source_Field__c)));
                    }
                }else {
                	jsonBody.writeStringField(mdt.Target_Field__c, String.valueOf(leadData.get(mdt.Source_Field__c)));
                }
            }
        }
        
        jsonBody.writeEndObject();
        
        return jsonBody.getAsString();
    }
    
    public static String getLeadDataFromAscend(String csrfToken, String sessionId, Id leadId) {
        HTTPRequest request = new HTTPRequest();
        Lead leadRec;
        
        if(leadId != null ) {
            leadRec = [SELECT VSE_Ascend_Lead_Id__c FROM Lead WHERE Id = :leadId];
        }
        request.setMethod('GET');
        request.setEndpoint('callout:Ascend_Lead_Integration/LeadCollection?ID='+leadRec.VSE_Ascend_Lead_Id__c);
        request.setHeader('Content-Type','application/json');
        request.setHeader('Accept','application/json');
        request.setHeader('x-csrf-token', csrfToken);
        request.setHeader('cookie', sessionId);
        request.setTimeout(120000);
        HTTPResponse response;
        
        try{
            response = new http().send(request);
        } catch(calloutException ex) {
            System.debug('---Get Lead--'+ex.getMessage());
        }
        
        String qualificationLevelCode;
        if(response.getStatusCode() == 200){
        	Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeuntyped(response.getBody());
			Map<String,Object> dataMap = (Map<String,Object>)responseMap.get('d');
			List<Object> newMap = (List<Object>)dataMap.get('results');
			Map<String, Object> codeMap = (Map<String,Object>) newMap.get(0);
			System.debug('---QualificationLevelCode--'+ codeMap.get('QualificationLevelCode'));
            qualificationLevelCode = String.valueOf(codeMap.get('QualificationLevelCode'));
        } else {
            leadDetails.Ascend_Lead_Update_failed__c = true;
            leadDetails.Ascend_Response_Code__c  = ' [ '+system.now()+' :GetLead:FAIL => '+String.valueOf(response.getStatusCode())+' ] ';
            leadDetails.Ascend_Response_Description__c = ' [ '+system.now()+' :GetLead:FAIL: '+response.getBody()+' ] ';
            leadDetails.Id = leadId;
            Update leadDetails; 
        }
        

        return qualificationLevelCode;
    }
}
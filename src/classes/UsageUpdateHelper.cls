/*
//////////////////////////////////
UsageUpdateHelper oBatch = new UsageUpdateHelper();
Database.executeBatch(oBatch);
//////////////////////////////////
*/
global class UsageUpdateHelper implements Database.Batchable<Sobject>{
    
    global UsageUpdateHelper(){
        System.debug('@Developer --> UsageUpdateHelper -->');
    }
    
    global Database.queryLocator start(Database.BatchableContext bc){
        System.debug('@Developer --> UsageUpdateHelper --> start --> timestamp:' + system.now());
        
        String sSOQL = 'Select ID, Reported_Date__c, Billable__c ';	  
        sSOQL += ' From Usage__c ';
        sSOQL += ' Where Billable__c = \'Yes\' ';
        sSOQL += ' And Reported_Date__c <> yesterday ';
        
        if(test.isRunningTest()){
            sSOQL += ' limit 5 ';
        }
        
        System.debug('@Developer --> sSOQL:' + sSOQL);   
        return Database.getQueryLocator(sSOQL);
    }
    
    global void execute(Database.BatchableContext bc, List<Usage__c> scope){
        System.debug('@Developer --> UsageUpdateHelper --> execute --> timestamp:' + system.now());
        
        List<Error_Logger__c> lstErrLog = new List<Error_Logger__c>();
        List<Usage__c> lstUsagesToUpdate = new List<Usage__c>();
        
        for(Usage__c u : scope) {     
            u.Billable__c = 'No';
            lstUsagesToUpdate.add(u);
        }
        
        try{
            if(lstUsagesToUpdate.size() > 0){
                
                list<Database.SaveResult> lstSaveResult = Database.update(lstUsagesToUpdate,false); 
                for (Database.SaveResult sr : lstSaveResult){
                    if(sr.isSuccess()){
                        System.debug('@Developer --> UsageUpdateHelper --> Usage-Success Processed:' + sr.getId());
                    }
                    else{
                        String sErr = '';
                        for(Database.Error err : sr.getErrors()) {  
                            sErr = err.getStatusCode() + ' - ' + err.getMessage();
                            System.debug('@Developer --> UsageUpdateHelper --> Usage-Fail Error :' + sErr);
                            lstErrLog.add(ErrorLogUtility.createErrorLog('UsageUpdateHelper','Usage__c','Database.Error-' + sErr,String.join(err.getFields(),','),false));
                        }
                    }
                }
            }
            
            if(lstErrLog.size() > 0){
                insert lstErrLog;
            }
            
        }
        catch (DMLException ex){
            System.debug('@Developer --> UsageUpdateHelper --> Usage-DMLException :' + ex.getdmlMessage(0));
            ErrorLogUtility.createErrorLog('UsageUpdateHelper','Usage__c','DMLException-' + ex.getdmlMessage(0),ex.getStackTraceString(),true);
        }
        catch(Exception ex){
            System.debug('@Developer --> UsageUpdateHelper --> Usage-Exception :' + ex.getMessage());
            ErrorLogUtility.createErrorLog('UsageUpdateHelper','Usage__c','Exception-' + ex.getMessage(),ex.getStackTraceString(),true);
        }
    } 	   
    
    global void finish(Database.BatchableContext bc){
        System.debug('@Developer --> UsageUpdateHelper --> finish --> timestamp:' + system.now()); 	         
    }
}
global class SubscriptionProcessHelperExtension implements Database.Batchable<String> {
    
    global list<String> lstData;
    
    global SubscriptionProcessHelperExtension(list<String> data){
        System.debug('@Developer --> SubscriptionProcessHelperExtension -->');
        lstData = data;
        System.debug('@Developer --> Total number of Records :' + lstData.size());
    }
    
    global Iterable<String> start(Database.BatchableContext bc) {
        System.debug('@Developer --> SubscriptionProcessHelperExtension --> start --> timestamp:' + system.now());
        return lstData;
    }
    
    global void execute(Database.BatchableContext bc, List<String> lstRecord) {
        System.debug('@Developer --> SubscriptionProcessHelperExtension --> execute --> timestamp:' + system.now());
        
        list<String> lstFields = new list<String>();
        map<string,Account> mapAccount = new map<string,Account>();
        map<String,Subscriber__c> mapUniqueIdWiseSubscriber = new map<String,Subscriber__c>();
        
        map<String,Usage__c> mapUniqueIdWiseUsage; 
        map<string,map<String,Usage__c>> mapReportedDateWiseUniqueIdWiseUsage = new map<string,map<String,Usage__c>>();
        
        list<Usage_Trend__c> lstUsageTrend = new list<Usage_Trend__c>();
        map<string,list<Usage_Trend__c>> mapReportedDateWiseUsageTrends = new map<string,list<Usage_Trend__c>> ();
                
        List<Error_Logger__c> lstErrLog = new List<Error_Logger__c>();
        map<String,Boolean>mapCmatIdWiseAccount = new map<String,Boolean>();
        for(string record : lstRecord){
            list<String> lstFld = record.split(',');
            mapCmatIdWiseAccount.put(lstFld[26],false);
        }
        System.debug('@Developer --> mapCmatIdWiseAccount :' + mapCmatIdWiseAccount);
        
        for(Account acc: [Select Id,CMAT_ID__c From Account Where CMAT_ID__c In :mapCmatIdWiseAccount.keyset()]){
            if(mapCmatIdWiseAccount.containsKey(acc.CMAT_ID__c)){
                mapCmatIdWiseAccount.put(acc.CMAT_ID__c,true);
            }
        }
        System.debug('@Developer --> mapCmatIdWiseAccount :' + mapCmatIdWiseAccount);
        
        for(string record : lstRecord){
            System.debug('@Developer --> SubscriptionProcessHelperExtension --> record :' + record);
            
            lstFields = new list<String>();
            
            lstFields = record.split(',');
            system.debug('@Developer --> lstFields:' + lstFields);
            
            Subscriber__c sub = new Subscriber__c();
            sub.Azure_GEO__c = lstFields[6];
            sub.Billable__c = lstFields[1];
            sub.Name = lstFields[11];
            sub.Unique_Id__c = lstFields[12];
            sub.Cloud_Customer_Name__c = lstFields[3];
            sub.ANF_GEO__c = lstFields[0];
            sub.Hyperscaler_Indicator__c = lstFields[28];
            
            System.debug('@Developer --> lstFields[15] :' + lstFields[15]);
            //sub.Sales_Rep__r.External_ID__c = lstFields[15];
            if(lstFields[15] != ''){
                sub.Sales_Rep__r = new User(External_ID__c = lstFields[15]);
            }
            
            System.debug('@Developer --> lstFields[26] :' + lstFields[26]);
            //sub.Customer_Name__r.CMAT_ID__c
            if(lstFields[26] != ''){
                sub.Customer_Name__r = new Account(CMAT_ID__c = lstFields[26]);
                
                //Account acc = new Account(Name='Account-' +lstFields[26],CMAT_ID__c = lstFields[26]);
                Account acc = new Account(CMAT_ID__c = lstFields[26]);
                if(mapCmatIdWiseAccount.containsKey(lstFields[26])){
                    if(mapCmatIdWiseAccount.get(lstFields[26]) == false){
                        acc.Name = 'Account-' + lstFields[26];
                    }
                }
                mapAccount.put(lstFields[26],acc);
            }
            
            mapUniqueIdWiseSubscriber.put(lstFields[12],sub);
            
            Usage__c usg = new Usage__c();
            usg.Region__c = lstFields[8];
            usg.True_Allocated_Avg_TB__c = decimal.valueOf(lstFields[22]);
            usg.Reported_Date__c = Date.parse(lstFields[9]);
            usg.Allocated_TB__c = decimal.valueOf(lstFields[21]);
            usg.Used_Avg_GiB_Logic_Snapshot__c = decimal.valueOf(lstFields[24]);
            usg.Usage_Percent__c = decimal.valueOf(lstFields[2]);
            usg.Volumes__c = decimal.valueOf(lstFields[7]);
            usg.Performance_Tier__c = lstFields[10];
            usg.Billable__c = lstFields[1];
            usg.Snapshot_MRR__c = decimal.valueOf(lstFields[19]);
            usg.Total_Pool_Snapshot_Used_Avg_Gib__c = decimal.valueOf(lstFields[18]);
            usg.Total_Pool_Allocated_Avg_Gib__c = decimal.valueOf(lstFields[16]);
            usg.Used_with_Snapshot_TB__c = decimal.valueOf(lstFields[23]);
            usg.Total_NetApp_revenue__c = decimal.valueOf(lstFields[20]);
            usg.Total_Pool_Logical_Used_Avg_TB__c = decimal.valueOf(lstFields[17]);
            usg.Unique_Id__c = lstFields[13];
            
            if(lstFields[12] != ''){
                usg.Subscriber_ID__r = new Subscriber__c(Unique_Id__c = lstFields[12]);
            }
            
            if(lstFields[26] != ''){
                usg.NAGP_Account__r = new Account(CMAT_ID__c = lstFields[26]);
            }
            
            if(mapReportedDateWiseUniqueIdWiseUsage.containsKey(lstFields[9])){
                mapUniqueIdWiseUsage = mapReportedDateWiseUniqueIdWiseUsage.get(lstFields[9]);
            }
            else{
                mapUniqueIdWiseUsage = new map<String,Usage__c>();
            }
            mapUniqueIdWiseUsage.put(lstFields[13],usg);
            mapReportedDateWiseUniqueIdWiseUsage.put(lstFields[9],mapUniqueIdWiseUsage);
            
            if(mapReportedDateWiseUsageTrends.containsKey(lstFields[9])){
                lstUsageTrend = mapReportedDateWiseUsageTrends.get(lstFields[9]);
            }
            else{
                lstUsageTrend = new list<Usage_Trend__c>();
            }
            
            Usage_Trend__c ut = new Usage_Trend__c();
            if(lstFields[12] != ''){
                ut.Subscription_ID__r = new Subscriber__c(Unique_Id__c = lstFields[12]);
            }
            ut.Allocated_TB__c = usg.Allocated_TB__c;
            ut.Billable__c = usg.Billable__c;
            ut.NAGP_Account__c = usg.NAGP_Account__c;
            ut.Performance_Tier__c = usg.Performance_Tier__c;
            ut.Region__c = usg.Region__c;
            ut.Reported_Date__c = usg.Reported_Date__c;
            ut.Snapshot_MRR__c = usg.Snapshot_MRR__c;
            ut.Total_Pool_Allocated_Avg_Gib__c = usg.Total_Pool_Allocated_Avg_Gib__c;
            ut.Total_Pool_Logical_Used_Avg_TB__c = usg.Total_Pool_Logical_Used_Avg_TB__c;
            ut.Total_Pool_Snapshot_Used_Avg_Gib__c = usg.Total_Pool_Snapshot_Used_Avg_Gib__c;
            ut.True_Allocated_Avg_TB__c = usg.True_Allocated_Avg_TB__c;
            ut.Used_Avg_GiB_Logic_Snapshot__c = usg.Used_Avg_GiB_Logic_Snapshot__c;
            ut.Used_with_Snapshot_TB__c = usg.Used_with_Snapshot_TB__c;
            
            if(usg.Reported_Date__c != null){
                //[Usage__c].Unique_Id__c & "<=>" & TEXT(YEAR([Usage__c].Reported_Date__c )) & TEXT(MONTH([Usage__c].Reported_Date__c )) & TEXT(DAY([Usage__c].Reported_Date__c ))
                ut.Unique_Id__c = usg.Unique_Id__c + '<=>' + usg.Reported_Date__c + usg.Reported_Date__c.year() + usg.Reported_Date__c.month()+usg.Reported_Date__c.day();   
            }
            
            ut.Usage_ID__r = new Usage__c(Unique_Id__c = lstFields[13]);
            lstUsageTrend.add(ut);
            
            mapReportedDateWiseUsageTrends.put(lstFields[9],lstUsageTrend);
        }

        if(mapAccount.size() > 0){
            try{
                System.debug('@Developer --> mapAccount.values().size() :' + mapAccount.values().size());
                Schema.SObjectField accExternalField = Account.Fields.CMAT_ID__c;
                list<Database.UpsertResult> lstResult = Database.upsert(mapAccount.values(),accExternalField,false);  
                for (Database.UpsertResult ur : lstResult){
                    
                    if(ur.isSuccess()){
                        System.debug('@Developer --> Account-Success Processed:' + ur.getId());
                    }
                    else{
                        String sErr = '';
                        for(Database.Error err : ur.getErrors()) {  
                            sErr = err.getStatusCode() + ' - ' + err.getMessage();
                            System.debug('@Developer --> Account-Fail Error :' + sErr);
                            lstErrLog.add(ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Account','Database.Error-' + sErr,String.join(err.getFields(),','),false));
                        }
                    }
                }
            }
            catch (DMLException ex){
                System.debug('@Developer --> Account-DMLException :' + ex.getdmlMessage(0));
                ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Account','DMLException-' + ex.getdmlMessage(0),ex.getStackTraceString(),true);
                
            }
            catch(Exception ex){
                System.debug('@Developer --> Account-Exception :' + ex.getMessage());
                ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Account','Exception-' + ex.getMessage(),ex.getStackTraceString(),true);
            }
        }
        
        if(mapUniqueIdWiseSubscriber.size() > 0){
            try{
                System.debug('@Developer --> mapUniqueIdWiseSubscriber.values().size() :' + mapUniqueIdWiseSubscriber.values().size());
                Schema.SObjectField externalField = Subscriber__c.Fields.Unique_Id__c;
                list<Database.UpsertResult> lstResult = Database.upsert(mapUniqueIdWiseSubscriber.values(),externalField,false);  
                
                for (Database.UpsertResult ur : lstResult){
                    if(ur.isSuccess()){
                        System.debug('@Developer --> Subscriber-Success Processed:' + ur.getId());
                    }
                    else{
                        String sErr = '';
                        for(Database.Error err : ur.getErrors()) {                                             
                            sErr = err.getStatusCode() + ' - ' + err.getMessage();
                            System.debug('@Developer --> Subscriber-Fail Error :' + sErr);
                            lstErrLog.add(ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Subscriber__c','Database.Error-' + sErr,String.join(err.getFields(),','),false));
                        }
                    }
                }
            }
            catch (DMLException ex){
                System.debug('@Developer --> Subscriber-DMLException :' + ex.getdmlMessage(0));
                ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Subscriber__c','DMLException-' + ex.getdmlMessage(0),ex.getStackTraceString(),true);
            }
            catch(Exception ex){
                System.debug('@Developer --> Subscriber-Exception :' + ex.getMessage());
                ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Subscriber__c','Exception-' + ex.getMessage(),ex.getStackTraceString(),true);
            }
        }
        
        if(mapReportedDateWiseUniqueIdWiseUsage.size() > 0){
            
            for(String sReportedDate : mapReportedDateWiseUniqueIdWiseUsage.keySet()){
                
                mapUniqueIdWiseUsage = mapReportedDateWiseUniqueIdWiseUsage.get(sReportedDate);
                if(mapUniqueIdWiseUsage.size() > 0){
                    try{
                        System.debug('@Developer --> mapUniqueIdWiseUsage.values().size() :' + mapUniqueIdWiseUsage.values().size());
                        Schema.SObjectField externalField = Usage__c.Fields.Unique_Id__c;
                        list<Database.UpsertResult> lstResult = Database.upsert(mapUniqueIdWiseUsage.values(),externalField,false);  
                        
                        for (Database.UpsertResult ur : lstResult){
                            if(ur.isSuccess()){
                                System.debug('@Developer --> Usage-Success Processed:' + ur.getId());
                            }
                            else{
                                String sErr = '';
                                for(Database.Error err : ur.getErrors()) {                                             
                                    sErr = err.getStatusCode() + ' - ' + err.getMessage();
                                    System.debug('@Developer --> Usage-Fail Error :' + sErr);
                                    lstErrLog.add(ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Usage__c','Database.Error-' + sErr,String.join(err.getFields(),','),false));
                                }
                            }
                        }
                    }
                    catch (DMLException ex){
                        System.debug('@Developer --> Usage-DMLException :' + ex.getdmlMessage(0));
                        ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Usage__c','DMLException-' + ex.getdmlMessage(0),ex.getStackTraceString(),true);
                    }
                    catch(Exception ex){
                        System.debug('@Developer --> Usage-Exception :' + ex.getMessage());
                        ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Usage__c','Exception-' + ex.getMessage(),ex.getStackTraceString(),true);
                    }
                }
                
                if(mapReportedDateWiseUsageTrends.containsKey(sReportedDate)){
                    list<Usage_Trend__c> lstUT = mapReportedDateWiseUsageTrends.get(sReportedDate);
                    if(lstUT.size() > 0){
                        try{
                            System.debug('@Developer --> lstUT.size() :' + lstUT.size());
                            list<Database.SaveResult> lstResult = Database.insert(lstUT,false);  
                            
                            for (Database.SaveResult sr : lstResult){
                                if(sr.isSuccess()){
                                    System.debug('@Developer --> UsageTrend-Success Processed:' + sr.getId());
                                }
                                else{
                                    String sErr = '';
                                    for(Database.Error err : sr.getErrors()) {                                             
                                        sErr = err.getStatusCode() + ' - ' + err.getMessage();
                                        System.debug('@Developer --> UsageTrend-Fail Error :' + sErr);
                                        lstErrLog.add(ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Usage_Trend__c','Database.Error-' + sErr,String.join(err.getFields(),','),false));
                                    }
                                }
                            }
                        }
                        catch (DMLException ex){
                            System.debug('@Developer --> UsageTrend-DMLException :' + ex.getdmlMessage(0));
                            ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Usage_Trend__c','DMLException-' + ex.getdmlMessage(0),ex.getStackTraceString(),true);
                        }
                        catch(Exception ex){
                            System.debug('@Developer --> UsageTrend-Exception :' + ex.getMessage());
                            ErrorLogUtility.createErrorLog('SubscriptionProcessHelperExtension','Usage_Trend__c','Exception-' + ex.getMessage(),ex.getStackTraceString(),true);
                        }
                    }
                }
            }
        }
        
        if(lstErrLog.size() > 0){
            insert lstErrLog;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('@Developer --> SubscriptionProcessHelperExtension --> finish --> timestamp:' + system.now());
        
        UsageUpdateHelper oBatch = new UsageUpdateHelper();
        Database.executeBatch(oBatch);
    }
}
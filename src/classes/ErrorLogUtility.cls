public class ErrorLogUtility {
    public static Error_Logger__c createErrorLog(String resource,String objectName,String description,String stacktrace, Boolean doInsert){
        Error_Logger__c errLog = new Error_Logger__c();
        errLog.Resource__c = resource;
        errLog.Object__c = objectName;
        errLog.Description__c = description;
        errLog.StackTrace__c = stacktrace;
        if(doInsert){
            insert errLog;
        }
        return errLog;
    } 
}
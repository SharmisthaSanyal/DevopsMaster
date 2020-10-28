@isTest
private class UsageUpdateHelperTest {
    @isTest
    private static void UnitTest() {
        Subscriber__c oSubscriber = new Subscriber__c();
        oSubscriber.Name = 'Sub001';
        insert oSubscriber;
        
        Usage__c oUsage = new Usage__c();
        oUsage.Subscriber_ID__c = oSubscriber.Id;
        oUsage.Unique_Id__c = 'usg001';
        oUsage.Billable__c = 'Yes';
        oUsage.Reported_Date__c = system.today().adddays(-10);
        insert oUsage;
        Test.StartTest();
        UsageUpdateHelper oUsageUpdateHelper = new UsageUpdateHelper();
        database.executeBatch(oUsageUpdateHelper);
        Test.StopTest();
    }
    
    @isTest
    private static void UnitTest2() {
        Subscriber__c oSubscriber = new Subscriber__c();
        oSubscriber.Name = 'Sub001';
        insert oSubscriber;
        
        Usage__c oUsage = new Usage__c();
        oUsage.Subscriber_ID__c = oSubscriber.Id;
        oUsage.Unique_Id__c = 'usg001';
        oUsage.Billable__c = 'Yes';
        oUsage.Reported_Date__c = system.today().adddays(-10);
        //insert oUsage;
        Test.StartTest();
        list<Usage__c> lstUsage = new list<Usage__c>();
        lstUsage.add(oUsage);
        UsageUpdateHelper oUsageUpdateHelper = new UsageUpdateHelper();
        oUsageUpdateHelper.execute(null ,lstUsage);
        Test.StopTest();
    }
}
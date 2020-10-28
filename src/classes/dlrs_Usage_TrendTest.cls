/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Usage_TrendTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Usage_TrendTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Usage_Trend__c());
    }
}
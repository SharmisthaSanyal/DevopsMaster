@isTest
public class H_LeadTest {
	@isTest
    public static void triggerLeadAssignmentRulesTest() {
        Lead ltp = new Lead();
        ltp.LastName = 'Test_LastName';
        ltp.Company = 'Test_Company';
        insert ltp;
        
        ltp.Status = 'Act Now';
        update ltp;
    }
}
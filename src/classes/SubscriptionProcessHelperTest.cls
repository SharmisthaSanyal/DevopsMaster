@isTest
private class SubscriptionProcessHelperTest {
    @isTest
    private static void UnitTest() {
        Test.StartTest();
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'test subject';
        email.fromAddress = 'testaddress@email.com';
        email.plainTextBody = 'test body';
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        string sAttBody = 'ANF Geo,Billable (Yes/No) (All Customer Usage),Usage %,Customer Name,Customer Name ,Customer Type ,NetApp Geo,Volumes,Region,Reported Date,Performance Tier,Azure ID,Unique_ID_Sub,Unique_ID_Usage,Sales Rep,SSO ID (User Name),Total Pool Allocated Avg Gib,Total Pool Logical Used Avg TB,Total Pool Snapshot Used Avg Gib,Snapshot MRR,Total NetApp revenue,Allocated TB,True Allocated Avg TB,Used with Snapshot TB,Used Avg GiB (Logic + Snapshot) ,Unique Id,NAGP ID,DP ID,Hyperscaler Indicator';
        sAttBody+='\nAMER,Yes,1.75E+00,Harbourvest,Harbourvest,Standard,AMER,1,southeastasia,2/12/2020,Premium,232cda59-aa39-497e-883d-6defbf1ecc63,232cda59-aa39-497e-883d-6defbf1ecc63,232cda59-aa39-497e-883d-6defbf1ecc63<=>Premium<=>southeastasia,Steve Squillace,ssquilla,4096,0.069892516,0,322.2068966,10.59310345,4,4,0.069892516,71.56993642,235425,1338857,11875032,ANF';
        sAttBody+='\nEMEA,Yes,5.52E+01,SAP,SAP,Hard deck,Globals,24,southeastasia,2/12/2020,Premium,0579d8ac-b33a-4f23-b8ad-0e55e021a49a,0579d8ac-b33a-4f23-b8ad-0e55e021a49a,0579d8ac-b33a-4f23-b8ad-0e55e021a49a<=>Premium<=>southeastasia,Lars Holstein,larsh,4096,2.207879342,0,386.6482759,12.71172414,4,4,2.207879342,2260.868446,235423,259926,19110912,ANF';
        attachmenttext.body = sAttBody;
        attachmenttext.fileName = 'testdata.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
        SubscriptionProcessHelper oSubscriptionProcessHelper=new SubscriptionProcessHelper();
        oSubscriptionProcessHelper.handleInboundEmail(email, env);
        Test.StopTest();
    }
    
    @isTest
    private static void UnitTest2() {
        Test.StartTest();
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'test subject';
        email.fromAddress = 'testaddress@email.com';
        email.plainTextBody = 'test body';
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        string sAttBody = 'ANF Geo,Billable (Yes/No) (All Customer Usage),Usage %,Customer Name,Customer Name ,Customer Type ,NetApp Geo,Volumes,Region,Reported Date,Performance Tier,Azure ID,Unique_ID_Sub,Unique_ID_Usage,Sales Rep,SSO ID (User Name),Total Pool Allocated Avg Gib,Total Pool Logical Used Avg TB,Total Pool Snapshot Used Avg Gib,Snapshot MRR,Total NetApp revenue,Allocated TB,True Allocated Avg TB,Used with Snapshot TB,Used Avg GiB (Logic + Snapshot) ,Unique Id,NAGP ID,DP ID,Hyperscaler Indicator';
        sAttBody+='\nAMER,Yes,1.75E+00,Harbourvest,Harbourvest,Standard,AMER,1,southeastasia,2/12/2020,Premium,232cda59-aa39-497e-883d-6defbf1ecc63,232cda59-aa39-497e-883d-6defbf1ecc63,232cda59-aa39-497e-883d-6defbf1ecc63<=>Premium<=>southeastasia,Steve Squillace,ssquilla,4096,0.069892516,0,322.2068966,10.59310345,4,4,0.069892516,71.56993642,235425,1338857,11875032,ANF';
        sAttBody+='\nEMEA,Yes,5.52E+01,SAP,SAP,Hard deck,Globals,24,southeastasia,2/12/2020,Premium,,,,Lars Holstein,larsh,4096,2.207879342,0,386.6482759,12.71172414,4,4,2.207879342,2260.868446,235423,,19110912,ANF';
        attachmenttext.body = sAttBody;
        attachmenttext.fileName = 'testdata.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
        SubscriptionProcessHelper oSubscriptionProcessHelper=new SubscriptionProcessHelper();
        oSubscriptionProcessHelper.handleInboundEmail(email, env);
        Test.StopTest();
    }
}
@isTest 
Private class TestCallouts {
    
    @isTest
    static void testPostCallout() {
        //create a lead test data
        lead ld = new lead();
        ld.LastName = 'Test';
        ld.Description = 'TEst Desc';
        ld.Company = 'ABC';
        ld.VSE_Geo__c ='APAC';
        ld.Status ='Qualified';
        ld.Send_to_Ascend__c = false;
        ld.VSE_Meeting_Start_Date__c = System.now() +1;
        insert ld;    
        //add the test id
        set<Id> nwLead = new set<Id>();
        nwLead.add(ld.Id);
        List<Lead> leadwithNoAscendList = new List<Lead>();
        leadwithNoAscendList.add(ld);
        //call the mock response
        Test.setMock(HttpCalloutMock.class, new LeadsHttpCalloutMock()); 
        
        //call the trigger which triggers the creatAPICall
        Test.startTest();
        LeadTriggerHandler handler = new LeadTriggerHandler();
        handler.OnAfterInsertCreateLeadInAscend(leadwithNoAscendList);
        test.stopTest();
        
        System.assertEquals('Test',ld.LastName);
        
    }
    @isTest
    static void testUpdateCallout() {
        // create an update the test lead
        lead ld = new lead();
        ld.LastName = 'Test';
        ld.Description = 'TestDesc';
        ld.Company = 'ABC';
        ld.VSE_Geo__c ='APAC';
        ld.Status ='stage';
        ld.Send_to_Ascend__c = false;
        insert ld; 
        
        Map<Id, Lead> oldMap = new Map<Id, Lead>();
        oldMap.put(ld.Id, ld);
        ld.LastName ='Test@123';
        ld.VSE_Ascend_Lead_Id__c = null;
        ld.Status ='Qualified';
        ld.VSE_Meeting_Set_Date__c = null;
        ld.VSE_Meeting_Start_Date__c = system.now()+1;
        ld.Send_to_Ascend__c = false;
        ld.Playbooks_Play_Name__c = 'Qualified_With_Meeting_Positive';
        update ld;
        
        //add it to set
        set<Id> nwLead = new set<Id>();
        nwLead.add(ld.Id);
        List<Lead> updateLeads = new List<Lead>([Select Id,LastName,Ascend_Lead_Update_failed__c,Send_to_Ascend__c,VSE_Ascend_Lead_Id__c,Status,VSE_Meeting_Set_Date__c,Playbooks_Play_Name__c,VSE_Meeting_Start_Date__c,VSE_SDR_Review__c from Lead where Id in: nwLead]);
        //call the mock response
        Test.setMock(HttpCalloutMock.class, new LeadsPatchHttpCalloutMock());
        
        Test.startTest();
        //Trigger the updateApiCall
        LeadTriggerHandler handler = new LeadTriggerHandler();
        handler.OnAfterUpdateUpdateLeadInAscend(updateLeads ,oldMap );
        test.stopTest();
        System.assertEquals('Test@123',ld.LastName);
        
    }
    
    @isTest
    static void testUpdateUpdateCallout() {
        // create an update the test lead
        lead ld = new lead();
        ld.LastName = 'Test';
        ld.Description = 'Hi';
        ld.Company = 'ABC';
        ld.VSE_Geo__c ='APAC';
        ld.Status ='Qualified';
        ld.Playbooks_Play_Name__c = null;
        ld.Send_to_Ascend__c = false;
        insert ld; 
        
        Map<Id, Lead> oldMap = new Map<Id, Lead>();
        oldMap.put(ld.Id, ld);
        ld.LastName ='Test@123';
        ld.VSE_Ascend_Lead_Id__c = '309556';
        ld.VSE_Meeting_Set_Date__c = null;
        ld.Send_to_Ascend__c = false;
        ld.Playbooks_Play_Name__c = 'Qualified_With_Meeting_Positive';
        update ld;
        //add it to set
        set<Id> nwLead = new set<Id>();
        nwLead.add(ld.Id);
        
        List<Lead> updateLeads = new List<Lead>([Select Id,LastName,Ascend_Lead_Update_failed__c,Send_to_Ascend__c,VSE_Ascend_Lead_Id__c,Status,VSE_Meeting_Set_Date__c,Playbooks_Play_Name__c,VSE_SDR_Review__c,VSE_Meeting_Start_Date__c from Lead where Id in: nwLead]);
        List<Ascend_Lead_Integration_Mapping__mdt> codeList = new List<Ascend_Lead_Integration_Mapping__mdt>();
        //call the mock response
        Test.setMock(HttpCalloutMock.class, new LeadsHttpCalloutMock());        
        
        Test.startTest();
        //Trigger the updateUpdateApiCall
        LeadTriggerHandler handler = new LeadTriggerHandler();
        handler.OnAfterUpdateUpdateLeadInAscend(updateLeads ,oldMap );
        LeadApiService.updateLeadStatus('309556', 'Z4', 'tqQuilerZrK1N31UzeotIg==', 'SAP_SESSIONID_LXW_011=44AVcWRjCzGHsog7RgCGdUpi80BiDRHqnFUAFj6SKrI%3d',codeList);
        test.stopTest();
        System.assert(!String.isBlank(ld.VSE_Ascend_Lead_Id__c));
        
    }
    
    @isTest
    static void testupdateLeadInAscend() {
        
        // create an update the test lead
        lead ld = new lead();
        ld.LastName = 'Test';
        ld.Description = 'Hi';
        ld.Company = 'ABC';
        ld.VSE_Geo__c ='APAC';
        ld.Status ='Qualified';
        ld.Playbooks_Play_Name__c = null;
        ld.Send_to_Ascend__c = false;
        insert ld; 
        
        Set<Id> leadIdSet = new Set<Id>{ld.Id};
        Test.setMock(HttpCalloutMock.class, new LeadsPostHttpCalloutMock());
        Test.startTest();
        LeadApiService.updateLeadInAscend('token', 'sessionId', 'Z1', 'Z2', leadIdSet);
        Test.stopTest();
        System.assert(ld != null);
    }
    
    
}
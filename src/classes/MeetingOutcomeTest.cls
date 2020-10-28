@isTest
public class MeetingOutcomeTest {
    /* testSetup() calls TestUtility.cls to build test objects */
    @testSetup static void testSetup() {
        Lead l = TestUtility.createLead();
        //l.Status = 'Qualified';
       	l.Status = 'Engage High';
        insert l;
        
        Meeting__c m = TestUtility.createMeeting(l);
        m.Lead__c = l.Id;
        m.Meeting_Notes__c = 'test meeting notes';
        insert m;
    }
    
    /* testing the setup methods getLead() and getMeeting() */
    private static testMethod void testSetupMethods() { 
    	test.startTest();
            List<Lead> ll = [SELECT Id FROM Lead];
            List<Meeting__c> ml = [SELECT Id FROM Meeting__c];
            
            Lead l;
            Meeting__c m;
    
            if(ll.size()>0) l = ll.get(0);
            if(ml.size()>0) m = ml.get(0);
    
            ApexPages.currentPage().getParameters().put('id',m.Id);
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(m);
            MeetingOutcome pg = new MeetingOutcome(stdCtrl);
            
            pg.recId = m.Id;
            pg.m = m;
            pg.l = l;
            
            pg.getLead();
            pg.getMeeting();
    	test.stopTest();
        
        system.assertEquals(pg.getLead(), l);
        system.assertEquals(pg.getMeeting(), m);
    }
    
    /* testing Meeting__c.Outcome__c == 'Thumbs Up' */
    private static testMethod void testThumbsUp() {
        test.startTest();
            List<Lead> ll = [SELECT Id, Status, VSE_SDR_Review__c, VSE_Opportunity_Number__c FROM Lead];
            List<Meeting__c> ml = [SELECT Id, Lead__c, Meeting_Status__c, Short_Term_Opportunity__c, Meeting_Notes__c, Opportunity_Number__c FROM Meeting__c];
            
            Lead l;
            Meeting__c m;
    
            if(ll.size()>0) l = ll.get(0);
            if(ml.size()>0) m = ml.get(0);
    
            ApexPages.currentPage().getParameters().put('id',m.Id);
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(m);
            MeetingOutcome pg = new MeetingOutcome(stdCtrl);
            
            pg.recId = m.Id;
            pg.m = m;
            pg.l = l;
            
            m.Outcome__c = 'Thumbs Up';
    
            pg.save();   
        test.stopTest();
        
        system.assertEquals('Meeting Positive', l.VSE_SDR_Review__c);
        system.assertEquals('Meeting Completed - Opportunity Viable', m.Meeting_Status__c);
        
    }
    
    /* testing Meeting__c.Outcome__c == 'Thumbs Down' */
    private static testMethod void testThumbsDown() {
        test.startTest();
            List<Lead> ll = [SELECT Id, Status, VSE_SDR_Review__c, VSE_Opportunity_Number__c FROM Lead];
            List<Meeting__c> ml = [SELECT Id, Lead__c, Meeting_Status__c, Short_Term_Opportunity__c, Meeting_Notes__c, Opportunity_Number__c FROM Meeting__c];
            
            Lead l;
            Meeting__c m;
    
            if(ll.size()>0) l = ll.get(0);
            if(ml.size()>0) m = ml.get(0);
    
            ApexPages.currentPage().getParameters().put('id',m.Id);
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(m);
            MeetingOutcome pg = new MeetingOutcome(stdCtrl);
            
            pg.recId = m.Id;
            pg.m = m;
            pg.l = l;
            
            m.Outcome__c = 'Thumbs Down';
    
            pg.save(); 		
        test.stopTest();

        system.assertEquals('Initiate Rejection', l.VSE_SDR_Review__c);
        system.assertEquals('Meeting Completed', m.Meeting_Status__c );
    }
    
    /* testing Meeting__c.Outcome__c == 'Meeting Reschedule Request' */
    private static testMethod void testReschedule() {
        test.startTest();
            List<Lead> ll = [SELECT Id, Status, VSE_SDR_Review__c, VSE_Opportunity_Number__c FROM Lead];
            List<Meeting__c> ml = [SELECT Id, Lead__c, Meeting_Status__c, Short_Term_Opportunity__c, Meeting_Notes__c, Opportunity_Number__c FROM Meeting__c];
            
            Lead l;
            Meeting__c m;
    
            if(ll.size()>0) l = ll.get(0);
            if(ml.size()>0) m = ml.get(0);
    
            ApexPages.currentPage().getParameters().put('id',m.Id);
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(m);
            MeetingOutcome pg = new MeetingOutcome(stdCtrl);
            
            pg.recId = m.Id;
            pg.m = m;
            pg.l = l;
            
            m.Outcome__c = 'Meeting Reschedule Request';
    
            pg.save(); 		
        test.stopTest();
		
        system.assertEquals('Meeting Rescheduled', m.Meeting_Status__c );
    }
    
    /* testing Meeting__c.Short_Term_Opportunity__c validity */
    private static testMethod void testShortTermOpp() {
        test.startTest();
            List<Lead> ll = [SELECT Id, Status, VSE_SDR_Review__c, VSE_Opportunity_Number__c FROM Lead];
            List<Meeting__c> ml = [SELECT Id, Lead__c, Meeting_Status__c, Short_Term_Opportunity__c, Meeting_Notes__c, Opportunity_Number__c FROM Meeting__c];
            
            Lead l;
            Meeting__c m;
    
            if(ll.size()>0) l = ll.get(0);
            if(ml.size()>0) m = ml.get(0);
    
            ApexPages.currentPage().getParameters().put('id',m.Id);
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(m);
            MeetingOutcome pg = new MeetingOutcome(stdCtrl);
            
            pg.recId = m.Id;
            pg.m = m;
            pg.l = l;
            
            m.Outcome__c = 'Thumbs Up';
            m.Short_Term_Opportunity__c = 'Yes';
            m.Opportunity_Number__c = '';
            pg.save(); 	
            
            m.Opportunity_Number__c = '2419';
            pg.save();
        test.stopTest();
		
        system.assertEquals(l.VSE_Opportunity_Number__c, m.Opportunity_Number__c);
    }
    
    /* testing setting errMsg variable */
    private static testMethod void testErrMsg() {
        test.startTest();
            List<Meeting__c> ml = [SELECT Id, Lead__c FROM Meeting__c];
            Meeting__c m;
            if(ml.size()>0) m = ml.get(0);
    
            ApexPages.currentPage().getParameters().put('id',m.Id);
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(m);
            MeetingOutcome pg = new MeetingOutcome(stdCtrl);
            
            pg.recId = m.Id;
            m.Outcome__c = '--None--';
            
            pg.save();
        test.stopTest();
        
        system.assertNotEquals('', pg.errMsg);
    }
    
}
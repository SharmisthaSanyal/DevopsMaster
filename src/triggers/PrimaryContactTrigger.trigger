trigger PrimaryContactTrigger on Contact (before insert,before update) {
   /* set<id> accid= new Set<Id>();
        if(trigger.isinsert || trigger.isupdate){   
          for(Contact c:trigger.new){
            if(c.Accountid!=null && c.Primary__c==true){
                accid.add(c.accountid);
            }
        }   
    }
    List<Contact> conList = [Select id,name,Primary__c from Contact where Primary__c=true and Accountid in:accid];
        if(conList.size()>0) {
        for(Contact c:Trigger.new){
        c.adderror('No more Primary Contacts');
        }
    }*/
}
trigger primaryContactUpdateAccount on Contact (before insert,before update) {
/*Set<Id> accountIds = new Set<Id>();

for(Contact con : Trigger.new){
if(String.IsNotBlank(con.AccountId)){
system.debug(' **** account id *** ' + con.AccountId);
accountIds.add(con.AccountId);

 }
}
system.debug(' *** The new set contains **** ' + accountIds );

List<Account> accountlist = [Select Id,Account.Name,Account.Phone,(select contact.Name,Contact.Accountid,contact.Id,contact.Phone from contacts where contact.primary__c= true limit 1) from Account where ID in:accountIds];
Map<Id,boolean> accountevalmap = new Map<Id,boolean>();
if(accountlist.size() == 1)
accountevalmap.put(accountlist[0].Id,true);

for(Contact con :Trigger.new){
if(accountevalmap.containskey(con.AccountId) && con.primary__c == true)
  {
   system.debug(' *** inside the catch *** ' );
   con.Phone.addError('Already exists!!');
   }else if(!accountevalmap.containskey(con.AccountId)&& con.primary__c == true){
   accountlist[0].Phone = con.Phone ;
   system.debug(' %%%%%%%%%%%%%%  phone number updated '+accountlist[0].Phone);
   }
   else{
   system.debug(' **** Else why %%%% ');
   }
  }
  
  upsert accountlist; */
}
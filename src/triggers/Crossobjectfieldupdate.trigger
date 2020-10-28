//Hey guys I'm new to salesforce and I've to update all phone numbers on contact when account phone number changes, 
trigger Crossobjectfieldupdate  on Account (after update) {
List<Contact> con = new List<Contact>();
Account acc;
Contact cc;
List<Contact> upfdatedcontacts = new List<Contact>();
if(Trigger.isupdate){
acc = Trigger.new[0];
con = [Select Id,Name,Accountid,phone from contact where accountid = :acc.id];

}
if(con.size()>0){
for(Contact c : con){
cc = new Contact(id=c.id,phone=acc.phone);
upfdatedcontacts.add(cc);
   }
  }
  update upfdatedcontacts;
}
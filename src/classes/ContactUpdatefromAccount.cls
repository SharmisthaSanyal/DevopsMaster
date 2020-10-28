global class ContactUpdatefromAccount implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query= 'Select Id,BillingCity,BillingCountry,(Select AccountId,Id,MailingCity,MailingCountry from Contacts) from Account';
        
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope)
    {
        List<Contact> contacts = new List<Contact>();
/*compare account fields to contact fields to check if Contact record address fields (Mailing City, Mailing Country) same as parent Account address fields(Billing City, Billing Country) and if there is no address, populate 'Not available' string in address field  and populate a contact list to update*/
        for(Account acc:scope){
            
            for(Contact con: acc.contacts)
        {
            if(acc.id == con.accountid){
             if(String.isNotBlank(acc.BillingCity)&&String.isNotBlank(acc.BillingCountry)) {  
            con.MailingCity = acc.BillingCity;
            con.MailingCountry = acc.BillingCountry;
            contacts.add(con);   
            }else if(String.isNotBlank(acc.BillingCity)&&String.isBlank(acc.BillingCountry)){
                con.MailingCity = acc.BillingCity;
                con.MailingCountry = 'Not available';
                contacts.add(con);
            }
            else if(String.isNotBlank(acc.BillingCountry)&& String.isBlank(acc.BillingCity)){
                con.MailingCountry = acc.BillingCountry;
                con.MailingCity = 'Not available';
                contacts.add(con);
            }else if(String.isBlank(acc.BillingCountry)&&String.isBlank(acc.BillingCity)){
              con.MailingCountry = 'Not available';
              con.MailingCity = 'Not available';
                contacts.add(con);  
                
            }
           }
          } 
        } 
try{
        update contacts;
} catch(Exception e){
        
        System.debug('Exception e'+e.getMessage());
    }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}
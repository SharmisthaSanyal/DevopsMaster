/* this class creates a test Lead and test Meeting__c using a random string generator */
public class TestUtility {
    
    private static String randomStringFromString(Integer length, String chars)
    {
        String randomString = '';
        while (randomString.length() < length)
        {
            Integer randomInt = (Math.random() * chars.length()).intValue();
            randomString += chars.substring(randomInt, randomInt + 1);
        }
        return randomString;
    }
    
    public static String createRandomString(Integer length) {
        return randomStringFromString(length, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz');
    }
    
    public static Lead createLead() {
        Lead l = new Lead();
        l.LeadSource = 'Campaign';
        l.FirstName = createRandomString(8);
        l.LastName = createRandomString(10);
        l.Company = createRandomString(10);
        l.Street = createRandomString(10);
        l.City = createRandomString(8);
        l.State = 'Colorado';
        l.PostalCode = createRandomString(5);
        l.Email = l.LastName + '@test.com.invalid';
      
        return l;
    }
    
    public static Meeting__c createMeeting(Lead l) {
        Meeting__c m = new Meeting__c();
        m.Lead__c = l.Id;
        m.Event_DateTime__c = Date.today().toStartOfWeek().addDays(3);
        m.Meeting_Category__c = 'Zoom Meeting';
        m.Meeting_Location__c = 'zoom';
        
        return m;
    }
    
}
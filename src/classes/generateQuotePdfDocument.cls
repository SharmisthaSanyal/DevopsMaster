Public class generateQuotePdfDocument{
    
    @InvocableMethod   
    public static void CreateQuote(List<Id> quoteIds)  
    { 
        createQuoteFutureMethod(quoteIds);
    }
    
    @future(callout=true)
    public static void createQuoteFutureMethod (List<Id> quoteIds) {
        //Initialize the quote url
        String quoteUrl = '/quote/quoteTemplateDataViewer.apexp?';
        
        //Get the Quote Template Id from Custom Settings
        String quoteTemplateId = Label.QuoteTemplateId;
        
        //List variable to get all the Quote Documents
        List<QuoteDocument__c> lstQuoteDoc = new List<QuoteDocument__c>();
        
        if(!quoteIds.isEmpty() && quoteIds.size() > 0) {
            
            for(Id quoteId :quoteIds) {
                //Construct the quote URL to generate PDF
                quoteUrl += 'id=' + quoteId;
                quoteUrl += '&headerHeight=197&footerHeight=10';
                quoteUrl += '&summlid=' + quoteTemplateId;
                
                //call the quote url
                PageReference pageRef = new PageReference(quoteUrl);
                
                //get the quotePdf
                Blob quoteBlob;
                
                if(Test.isRunningTest()) {
                    quoteBlob = Blob.valueOf('Generate Pdf');
                } else {
                    quoteBlob = pageRef.getContentAsPDF();
                }
                
                //initialze the QuoteDocument to hold the quote pdf for insertion
                QuoteDocument__c quoteDoc = new QuoteDocument__c();
                quoteDoc.Document__c= EncodingUtil.base64Encode(quoteBlob);
                quoteDoc.QuoteId__c= quoteId;
                lstQuoteDoc.add(quoteDoc);
            }
        }
        
        if(!lstQuoteDoc.isEmpty() && lstQuoteDoc.size() > 0) {
            Database.insert(lstQuoteDoc);
        }
        
    }
}
global class SubscriptionProcessHelper implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        System.debug('@Developer -->SubscriptionProcessHelper.handleInboundEmail:' );

        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String sFileData = '';
        for(Messaging.InboundEmail.TextAttachment ta :email.textAttachments){
            System.debug('@Developer --> ta.fileName :' + ta.fileName);
            sFileData = ta.body;
        }
        
        if(sFileData.length() == 0){
            System.debug('@Developer --> Empty file. :' );
        }
        else{
            list<String> lstField = new list<String>();
            list<String> lstRecord = new list<String>();
            CSV_RowReader reader = New CSV_RowReader(sFileData,'\n');               
            String csvHeader = '';
            if(reader.hasNext()){
                csvHeader = reader.next();
                system.debug('@Developer --> csvHeader:' + csvHeader);
                
                lstField = csvHeader.split(',');
                system.debug('@Developer --> lstField:' + lstField);
                system.debug('@Developer --> lstField.size():' + lstField.size());
            }
            
            Integer indx = 1;
            while(reader.hasNext()){
                system.debug('@Developer --> Record Number:' + indx);
                String record = reader.next();
                record = record + ' ';
                system.debug('@Developer --> Record[' + indx + ']:-' + record);
                lstRecord.add(record);                
                indx++;
            }
            System.debug('@Developer --> lstRecord.size() :' + lstRecord.size());
            
            if(lstRecord.size() > 0){
                SubscriptionProcessHelperExtension oBatch = new SubscriptionProcessHelperExtension(lstRecord);
                Database.executeBatch(oBatch);
            }
            
        }
        return result;
    }
}
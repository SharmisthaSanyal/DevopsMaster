global class SearchAndReplace implements Database.Batchable<sObject>{

   public final String Query;
   public final String Entity;
   public final String Field;
   public final String Value;
   global String s;

   public SearchAndReplace(String q, String e, String f, String v){

      Query=q; Entity=e; Field=f;Value=v;
      s = 'ooo';
   }

   public Database.QueryLocator start(Database.BatchableContext BC){
    s ='Sharmistha ';
    system.debug(' **** value of s %%%' + s);
      return Database.getQueryLocator(query);
     
   }

   public void execute(Database.BatchableContext BC, List<sObject> scope){
     for(sobject s : scope){
     s.put(Field,Value); 
     }
     update scope;
     system.debug(' **** Batch Printed %%%%%%' + s);
    }

   public void finish(Database.BatchableContext BC){
   }
}
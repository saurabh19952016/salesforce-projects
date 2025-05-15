public class clearRecorderDataBatch implements  database.Batchable<sobject>,schedulable{
   
   public void execute(schedulableContext sc){
       database.executeBatch(new clearRecorderDataBatch(),500);
   }
       
    public  iterable<sobject> start(database.BatchableContext bc){
        string query='select id from contentDocument where LatestPublishedVersion.FirstPublishLocation.DeveloperName='
        +Screen_recorder_settings__c.getInstance('libraryName').field_value__c + ' and createddate!=LAST_N_DAYS:' 
        +Screen_recorder_settings__c.getInstance('file_deletion_Interval').field_value__c;
        if(test.isRunningTest()){
            query='select id from contentDocument';
        }
        return database.query(query);
    }

    public void execute(Database.BatchableContext bc,List<sobject> scope){
        delete scope;
    }

    public void finish(Database.BatchableContext bc){

    }
}
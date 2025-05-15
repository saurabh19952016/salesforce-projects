public class deleteBigObjectsBatch implements database.Batchable<data_migration__b> {
public Iterable<data_migration__b> start(Database.BatchableContext BC){
    List<data_migration__b> datamigrationList=[select indexValue__c,DateTimeStampIndex__c,targetOrg__c,Object__c from Data_Migration__b];
            return datamigrationList;
}

public void execute(Database.BatchableContext BC, List<data_migration__b> scope){
   database.deleteImmediate(scope);
}
public void finish(Database.BatchableContext BC){
      String Body='Report for data Migration is now available. Please check in the application';
        MetadataHandlerClass.sendmail('Migration Report settings reset',body);
}
}
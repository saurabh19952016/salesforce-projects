public class deleteBigObjectsBatch implements database.Batchable<data_migration_record__b> {
public Iterable<data_migration_record__b> start(Database.BatchableContext BC){
    List<data_migration_record__b> datamigrationList=[select indexValue__c,objectAPIname__c from data_migration_record__b];
            return datamigrationList;
}

public void execute(Database.BatchableContext BC, List<data_migration_record__b> scope){
    List<data_migration_record__b> listtoDelete=new List<data_migration_record__b> ();
    for(data_migration_record__b rec:scope){
            listtoDelete.add(rec);
    }
   database.deleteImmediate(listtoDelete);
}
public void finish(Database.BatchableContext BC){
            database.insertImmediate(new Data_migration_Record__b(indexValue__c=0,objectAPIName__c='Header',record_id__c='headerIndex'));
                    data_migration_Index__c index=data_migration_Index__c.getInstance('migrationIndex');
          update new data_migration_Index__c(id=index.record_id__c,indexValue__c=1);

}
}
public class childArchivalBatch implements database.Batchable<sobject>,database.stateful{
    //global List<id,data_archival_obeject_settings__c> archivelist;
    private string query;
    private string objectname;   
    private string relationship;
    private Set<Id> sobjectIds=new Set<Id>();
    
    public childArchivalBatch(string objectName,string relationship){
        this.objectname=objectname;
        this.relationship=relationship;
        List<data_archival_object_settings__c> archivelist=[select id,object_Name__c,object_type__c from data_archival_object_settings__c where submitted_by__c=:userinfo.getuserId().substring(0,15) and object_type__c='Parent'];
        dataArchivalBatch dataBatch=new dataArchivalBatch(archivelist[0].object_Name__c,archivelist[0].object_type__c,true);
        query=databatch.query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
       Map<Id,sobject> temp=new Map<Id,sobject>(scope);
        sobjectIds.addAll(temp.keyset());
    }
    
    public void finish(Database.BatchableContext BC){
        dataArchivalBatch databatch=new dataArchivalBatch(objectName,relationship,false);
        databatch.parentIds=sobjectIds;
        database.executeBatch(databatch,600);
    }
}
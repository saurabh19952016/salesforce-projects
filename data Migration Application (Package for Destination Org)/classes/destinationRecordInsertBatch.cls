public class destinationRecordInsertBatch implements database.Batchable<data_migration_record__b>,database.stateful{
    private List<objectOrderWrapper> objOrderWrapList;
    public List<string> errors=new List<String>();
    public List<string> selfLookupList=new List<String>();
    private  objectOrderWrapper objOrderWrap;
    private string query;
    private Map<string,string> fieldNameTypeMap=new Map<string,string>();
    private Map<String,String> recordtypMap=new Map<String,String>();
    private string defaultRecordTypeId;
    private Map<String,String> dataMigrationIdMap=new Map<String,String>();
    
    public destinationRecordInsertBatch(List<objectOrderWrapper> objOrderWrapList){
        this.objOrderWrapList=objOrderWrapList;
        this.objOrderWrap=objOrderWrapList.remove(0);
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjSchema = schemaMap.get(objOrderWrap.objectName);
        Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keyset()) 
        {
            Schema.DescribeFieldResult field=fieldMap.get(fieldName).getDescribe();  
            if(field.getType() == Schema.DisplayType.REFERENCE)
            {
                List<Schema.SObjectType> parents=field.getReferenceTo();
                for(Schema.SObjectType parentobj: parents ){
                    
                    string parentname=parentobj.getDescribe().getName();
                    if(field.isAccessible() && field.isCreateable() && field.isUpdateable() ){
                        fieldNameTypeMap.put(field.getName(),parentName);
                    }
                }
            }
        } 
        Map<String,schema.recordTypeInfo> rectypeInfoMap=objschema.getDescribe().getRecordTypeInfosByName();
        for(String rectype:rectypeInfoMap.keyset()){
            schema.RecordTypeInfo rectypeInfo=rectypeInfoMap.get(rectype);
            recordtypMap.put(rectypeInfo.getrecordtypeId(),rectype);
            if(rectypeInfo.isDefaultRecordTypeMapping()){
                defaultRecordTypeId=rectypeInfo.getRecordTypeId();
            }
        }
        
    }
    
    public Iterable<data_migration_record__b>  start(Database.BatchableContext BC){
        string objectname=objOrderWrap.objectName;
        Decimal index=data_migration_Index__c.getInstance('migrationIndex').indexValue__c;
        List<data_migration_record__b> recordList=database.query('select indexValue__c,objectAPIname__c,record_id__c,recordjson__c from data_migration_record__b where objectAPIname__c=:objectname and indexValue__c<:index'+
                                                                 ' order by objectAPIname__c,indexValue__c DESC');        
        return recordList;
    }
    
    public void execute(Database.BatchableContext BC, List<data_migration_record__b> bigObjList){     
        try{
            Map<String,migration_record_Id_Map__c> mgrationMap=migration_record_Id_Map__c.getAll();
            for(string key:mgrationMap.keyset()){
                dataMigrationIdMap.put(key,mgrationMap.get(key).new_record_id__c);
            }            
            List<sobject> sobjectList=new List<sobject>();      
            List<String> oldRecIdList=new List<String>();
            for(data_migration_record__b bigObj:bigObjList){
                sobject sobj=(sobject)json.deserialize(bigObj.recordJson__c,sobject.class);
                sobjectList.add(sobj);
                oldRecIdList.add((String)sobj.get('Id'));                  
                for(string fieldName:fieldNameTypeMap.keyset()){
                    string oldvalue=(String)sobj.get(fieldName);
                    oldRecIdList.add(oldvalue);                  
                }            
            }
            
            List<Data_migration_record_Id__b> recordIdBigList=[select oldRecordId__c,newRecordId__c from Data_migration_record_Id__b where
                                                               oldRecordId__c IN :oldRecIdList];
            
            for(Data_migration_record_Id__b recordIdBig:recordIdBigList){
                dataMigrationIdMap.put(recordIdBig.oldRecordId__c,recordIdBig.newRecordId__c);
            }
            system.debug('executed');
            Map<Id,sobject> sobjectToUpdateMap=new Map<Id,sobject>();
            Map<Id,sobject> sobjectToInsertMap=new Map<Id,sobject>();
            Map<String,data_migration_record__b> recordtypeBigMap=new Map<String,data_migration_record__b>();
            List<sobject> sobjectToTemp=new List<sobject>();
            List<String> objectNeedtoQuery=new List<String>();
            
            List<String> processedIds=new List<String>();
            List<migration_record_Id_Map__c> migrationIdInsertList=new List<migration_record_Id_Map__c>();
            for(sobject sobj:sobjectList){
                string recordId=(String)sobj.get('Id');
                if(!processedIds.contains(recordId)){
                    if(recordtypMap.size()!=1 && !recordtypMap.containskey((String)sobj.get('RecordTypeId'))){
                        sobj.put('RecordTypeId',defaultRecordTypeId);
                    }
                    if(dataMigrationIdMap.containsKey(recordId) && dataMigrationIdMap.get(recordId)!=null){
                        sobj.put('Id',dataMigrationIdMap.get(recordId));
                        for(string fieldName:fieldNameTypeMap.keyset()){
                            string oldvalue=(String)sobj.get(fieldName);
                            if(dataMigrationIdMap.containskey(oldvalue)){
                                sobj.put(fieldName,dataMigrationIdMap.get(oldvalue));
                            }
                            if(fieldNameTypeMap.get(FieldName)=='User'){
                                sobj.put(FieldName,userinfo.getUserId());
                            }  
                        }
                        sobjectToUpdateMap.put(recordId,sobj);
                    }
                    else{
                        for(string fieldName:fieldNameTypeMap.keyset()){
                            string oldvalue=(String)sobj.get(fieldName);
                            if(dataMigrationIdMap.containskey(oldvalue)){
                                sobj.put(fieldName,dataMigrationIdMap.get(oldvalue));
                            }
                            if(fieldNameTypeMap.get(FieldName)=='User'){
                                sobj.put(FieldName,userinfo.getUserId());
                            }
                        }
                        sobj.put('Id',null);
                        sobjectToInsertMap.put(recordId,sobj);             
                    }
                    
                }
                processedIds.add(recordId);
                
            }
            system.debug(sobjectToUpdateMap);
            system.debug(sobjectToInsertMap);
            
            if(!sobjectToUpdateMap.isEmpty()){
                processErrors(database.update(sobjectToUpdateMap.values(),false));
            }
            
            if(!sobjectToInsertMap.isEmpty()){
                processErrors(database.insert(sobjectToInsertMap.values(),false));
                
            }
            for(string recordId:sobjectToInsertMap.keyset()){
                string recId=(String)(sobjectToInsertMap.get(recordId)).get('Id');
                //recordMapBigNew.add(new Data_Migration_Id_Map__b(newRecordId__c=(String)(sobjectToUpsertMap.get(recordId)).get('Id'),oldRecordId__c=recordId));
                if(recId!=null){
                     migrationIdInsertList.add(new migration_record_Id_Map__c(name=recordId,new_Record_Id__c=recId));
                }
            }
            insert migrationIdInsertList;
        }
        catch(exception ex){
            errors.add('message : '+ ex.getMessage() + '<br/>Line Number : ' + ex.getLineNumber());
        }
    }
    
    public void finish(Database.BatchableContext BC){
        List<migration_record_Id_Map__c> migRecordIdList=[select id,name,new_record_id__c from migration_record_Id_Map__c];
        List<Data_migration_record_Id__b> newRecidList=new List<Data_migration_record_Id__b>();
        for(migration_record_Id_Map__c recId:migRecordIdList){
            newRecidList.add(new Data_migration_record_Id__b(oldRecordId__c=recId.name,newRecordId__c=recId.new_Record_Id__c));
        }
        database.insertImmediate(newRecidList);            
        
        list<Messaging.SingleEmailMessage> messages =new list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        // Set recipients to two contact IDs.
        // Replace IDs with valid record IDs in your org.
        message.toAddresses = new String[] {userinfo.getuserId()};       
            if(!objOrderWrapList.isEmpty()){
                

                integer batchSize=50;
                for(string lookup:selfLookupList){
                    system.debug(objOrderWrapList[0]);
                    if(lookup==objOrderWrapList[0].objectName){
                        batchSize=1;
                        break;
                    }
                }
                destinationRecordInsertBatch btch=new destinationRecordInsertBatch(objOrderWrapList);
                btch.errors=errors;
                btch.selfLookupList=selfLookupList;
                system.debug('batchSize'+batchSize);
                database.executeBatch(btch,batchSize);
            }
        else{
            delete migRecordIdList;
            message.subject = 'Data migration Completed';
            message.htmlbody = string.join(errors,'<br/>'); 
            messages.add(message);
            if(errors.size()==0){
                database.executeBatch(new deleteBigObjectsBatch(),2000);         
            }
        }
        if(!messages.isempty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }
    
    public void processErrors(List<Database.SaveResult> srList){
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    string error='error code:'+ err.getStatusCode() + '<br/>error message: ' + err.getMessage();
                    error += '<br/fields affected : '+err.getFields() + '<br/>'; 
                    errors.add(error);
                }
            }            
        }
    }
    
    public void replaceHeader(){
        
        
    }
    
    public class objectOrderWrapper implements comparable{
        public string objectName{get;set;}
        public decimal order{get;set;}
        public ObjectorderWrapper(string objectName,decimal order){
            this.objectName=objectName;
            this.order=order;
        }
        
        public Integer compareTo(Object objToCompare) {
            return Integer.valueOf(order - ((objectOrderWrapper)objToCompare).order);
        }
    }
    
    
}
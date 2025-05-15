@RestResource(urlMapping='/DataMigration/*')
Global class destinationDataMigration {
    
    @HttpGET
    global static void getObjectsInBigObj() {
        RestRequest req = RestContext.Request;
        RestResponse res = RestContext.response;
        String method=req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);        
        system.debug(method);        
        if(method=='deleteAll'){
            database.executeBatch(new deleteBigObjectsBatch(),2000);
        }
        else{              
            Data_migration_Record__b headerRecord=[select indexValue__c,objectAPIName__c,record_id__c,recordjson__c from Data_migration_Record__b 
                                                   where indexValue__c=0 and objectAPIName__c='Header'];
            if(headerRecord.recordJSON__c!=null && !headerRecord.recordjson__c.contains('null')){
                List<String> headerList=headerRecord.recordjson__c.split(',');
                res.responseBody = Blob.valueOf(json.serialize(headerList));
                res.statusCode = 200;
            }
            else{
                res.responseBody = Blob.valueOf(json.serialize(new list<String>()));
                res.statusCode = 200;
            }
        }
    }
    
    @HttpPost
    global static void recordInsertion() {
        
        RestRequest req = RestContext.Request;
        RestResponse res = RestContext.response;
        String method=req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);        
        String body = req.requestbody.toString();
        if(method=='saveRecords'){
            string MainObject = req.headers.get('MainObject');
            boolean selflookup = boolean.valueof(req.headers.get('selfLookup'));
            data_migration_Index__c index=data_migration_Index__c.getInstance('migrationIndex');
            List<Data_migration_Record__b> bigObjList=new List<Data_migration_Record__b>();
            
            Data_migration_Record__b headerRecord=[select indexValue__c,objectAPIName__c,record_id__c,recordjson__c,self_lookups__c from Data_migration_Record__b 
                                                   where indexValue__c=0 and objectAPIName__c='Header'];
            Data_migration_Record__b newheader=new Data_migration_Record__b(indexValue__c=0,recordjson__c=headerrecord.recordjson__c,
                                                                            objectAPIName__c='Header');
            if(!string.isblank(headerRecord.recordjson__c)){
                List<String> headerStringList=headerRecord.recordjson__c.split(',');
                integer count=0;
                for(string head:headerStringList){
                    if(!head.equalsIgnoreCase(MainObject)){
                        count++;
                    }  
                }
                if(count==headerStringList.size()){
                    newheader.recordjson__c =newheader.recordjson__c + ',' +MainObject;
                }
                
            }
            else{
                newheader.recordjson__c =MainObject;
            } 
            if(selflookup==true && !string.isblank(headerRecord.self_lookups__c)){
                List<String> lookupList=headerRecord.self_lookups__c.split(',');
                integer lookups=0;
                for(string head:lookupList){
                    if(!head.equalsIgnoreCase(MainObject)){
                        lookups++;
                    }  
                }
                if(lookups==lookupList.size()){
                    newheader.self_lookups__c =newheader.self_lookups__c + ',' +MainObject;
                }
                
            }
            else if(selflookup==true){
                newheader.self_lookups__c =MainObject;
            }
            bigObjList.add(newheader);
            Map<String,Object> objectMap=(Map<String,Object>)json.deserializeUntyped(body);
            for(string recId: objectMap.keyset()){
                
                Data_migration_Record__b bb = new Data_migration_Record__b();
                bb.recordjson__c = json.serialize(objectMap.get(recId));
                bb.indexValue__c=index.indexValue__c;
                bb.objectAPIName__c=MainObject;
                bb.record_id__c=recId;
                bigObjList.add(bb);
                index.indexValue__c++;
            }
            List<Database.SaveResult> saveResult = database.insertImmediate(bigObjList);  
            update new data_migration_Index__c(id=index.record_id__c,indexValue__c=index.indexValue__c);
            for(Database.SaveResult result:saveResult){
                System.debug( ' success ' + result.isSuccess() + ' ' + result );
            } 
            
        }
        else if(method=='commitRecords'){
            List<destinationRecordInsertBatch.objectOrderWrapper> commitOrderList=(List<destinationRecordInsertBatch.objectOrderWrapper>)json.deserialize(body,List<destinationRecordInsertBatch.objectOrderWrapper>.class);
            commitOrderList.sort();
            system.debug(commitOrderList);
            Data_migration_Record__b headerRecord=[select indexValue__c,objectAPIName__c,record_id__c,recordjson__c,self_lookups__c from Data_migration_Record__b 
                                                   where indexValue__c=0 and objectAPIName__c='Header'];
            integer batchSize=50;

            List<String> selfLookupList=new list<String>();
            if(headerRecord.self_lookups__c!=null){
                selfLookupList=headerRecord.self_lookups__c.split(',');
                
                for(string lookup:selfLookupList){
                    if(lookup==commitorderList[0].objectName){
                        batchSize=1;
                        break;
                    }
                }
                
            }
            destinationRecordInsertBatch batch=new destinationRecordInsertBatch(commitOrderList);
            batch.selfLookupList=selfLookupList;
            database.executeBatch(batch,batchSize);
        }
    }
    
    
    
}
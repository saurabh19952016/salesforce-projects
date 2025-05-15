public class processObjectMetadataBatch implements database.Batchable<sobject>,database.allowscallouts,database.stateful{
    private string query;
    private List<string> objectNames=new List<String>();
    private string targetOrgId;
    private data_archival_settings__c currentIndex=data_archival_settings__c.getAll().get('currentIndexMigration');
    private boolean considerValidation;
    private MetadataHandlerClass.responseWrapper respwrapper;
    private boolean SFDCtoSFDC;
    
    public processObjectMetadataBatch(Boolean considerValidation,string targetOrgId,MetadataHandlerClass.responseWrapper respwrapper,Boolean SFDCtoSFDC){
        this.respwrapper=respwrapper;
        this.considerValidation=considerValidation;
        this.SFDCtoSFDC=SFDCtoSFDC;
        this.targetOrgId=targetOrgId;
        query='select Id,name,objectName__c,hierarchy__c from Migration_Objects__c';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Migration_Objects__c> scope){
             Migration_Objects__c obj=scope[0];
       try{  
            Map<String,Data_Migration__b> bigObjMap=new  Map<String,Data_Migration__b>();
            Map<String,String> parentMap=new Map<String,String>();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType ObjSchema = schemaMap.get(obj.objectName__c);
            Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
            for(Schema.SobjectField strFld: fieldMap.Values())
            {   
                Schema.DescribeFieldResult describe=strFld.getDescribe();
                if(describe.isUpdateable() ){
                    Data_Migration__b dataMigrationBig=new Data_Migration__b();
                    dataMigrationBig.targetOrg__c=targetOrgId;
                    dataMigrationBig.Object__c=obj.objectName__c;
                    dataMigrationBig.indexValue__c=currentIndex.indexNumber__c;
                    dataMigrationBig.DateTimeStampIndex__c=String.valueof(system.now()+'-'+system.now().millisecond());
                    dataMigrationBig.fieldLabel__c= describe.getLabel();
                    dataMigrationBig.hierarchy__c= obj.hierarchy__c;
                    dataMigrationBig.fieldName__c= describe.getName();
                      dataMigrationBig.requiredInLayout__c= 'false';
                    if(SFDCtoSFDC==false && !describe.isNillable() && describe.getType() != schema.DisplayType.BOOLEAN){
                      dataMigrationBig.required__c= 'true';
                    }
                       if(describe.getType()==Schema.DisplayType.PICKLIST){
                           dataMigrationBig.picklistValuesCurrent__c= json.serialize(describe.getPicklistValues());    
                     }
                   if(describe.getType() == Schema.DisplayType.REFERENCE){
                        dataMigrationBig.fieldType__c= string.valueOf(describe.getType()) + ' {';
                        for(Schema.SObjectType parentobj: describe.getReferenceTo() ){
                            dataMigrationBig.fieldType__c+=parentobj.getDescribe().getName() + ',';
                        }
                        dataMigrationBig.fieldType__c=dataMigrationBig.fieldType__c.removeEnd(',') + '}';
                    }
                    else
                        dataMigrationBig.fieldType__c=string.valueOf(describe.getType());
                    currentIndex.indexNumber__c+=1;
                    
                    bigObjMap.put(describe.getName(),dataMigrationBig);                    
                }
            }
           if(SFDCtoSFDC==true){
            Http http=new Http();
            httprequest request=new httpRequest();
            request.setMethod('GET');
            request.setHeader('Authorization','Bearer ' +respwrapper.access_Token);
            request.setEndpoint(respwrapper.instance_url +'/services/apexrest/getFields/'+obj.objectName__c);
            HttpResponse resp=http.send(request);
            
            List<Object> objectList=(List<Object>)json.deserializeUntyped(resp.getBody());
            for(Object objtarget:objectList){
                Map<String,Object> objectMap=(Map<String,Object>)objtarget;
                string fieldName=(String)objectMap.get('fieldName');
                if(bigObjMap.containsKey(fieldName)){
                    Data_Migration__b dataMigrationBig= bigObjMap.get(fieldName);
                    dataMigrationBig.fieldNameTarget__c=fieldName;
                    dataMigrationBig.fieldLabelTarget__c=(String)objectMap.get('fieldLabel');
                    dataMigrationBig.fieldTypeTarget__c=(String)objectMap.get('fieldType');
                    dataMigrationBig.required__c=(String)objectMap.get('required');
                     if(objectMap.containsKey('pickListValues') && objectMap.get('pickListValues')!=null){
                     system.debug((List<Object>)objectMap.get('pickListValues'));
                   	dataMigrationBig.pickListValuesTarget__c=json.serialize(objectMap.get('pickListValues'));
                    }
                    system.debug(fieldName + dataMigrationBig.required__c);
                    bigObjMap.put(fieldName,dataMigrationBig);
                    
                }
                else{
                    Data_Migration__b dataMigrationBig= new Data_Migration__b();
                    dataMigrationBig.targetOrg__c=targetOrgId;
                    dataMigrationBig.Object__c=obj.objectName__c;
                    dataMigrationBig.indexValue__c=currentIndex.indexNumber__c;
                    dataMigrationBig.DateTimeStampIndex__c=String.valueof(system.now()+'-'+system.now().millisecond());  
                    dataMigrationBig.fieldNameTarget__c=fieldName;
                    dataMigrationBig.fieldLabelTarget__c=(String)objectMap.get('fieldLabel');
                    dataMigrationBig.fieldTypeTarget__c=(String)objectMap.get('fieldType');
                     dataMigrationBig.hierarchy__c= obj.hierarchy__c;
                     dataMigrationBig.requiredInLayout__c= 'false';
                   
                    dataMigrationBig.required__c=(String)objectMap.get('required');
                     if(objectMap.containsKey('pickListValues') && objectMap.get('pickListValues')!=null){
                    
                   dataMigrationBig.pickListValuesTarget__c=json.serialize(objectMap.get('pickListValues'));
                    }
                    system.debug(fieldName + dataMigrationBig.required__c);
                    bigObjMap.put(fieldName,dataMigrationBig);
                    currentIndex.indexNumber__c+=1;
                }
            }
           }
           system.debug('values :' +bigObjMap.values());
            if(considerValidation==false)
            {
                system.enqueueJob(new getValidationRequiredQueueable(obj,respwrapper,bigObjMap,currentIndex,new List<String>(),true));
            }
            else{
               system.enqueueJob(new getLayoutRequiredQueueable(obj,respwrapper,bigObjMap,currentIndex,new List<String>(),true));
               /* database.insertImmediate(bigObjMap.values());
                update new data_archival_settings__c(indexNumber__c=currentIndex.indexNumber__c,id=currentIndex.Record_id__c);
                obj.status__c='Completed';
                update obj;  */    
            }
           }
        catch(Exception e){
            obj.status__c='Failed';
            update obj;                          
        }
    }
    public void finish(Database.BatchableContext BC){
        String Body='Report for data Migration is now available. Please check in the application';
        MetadataHandlerClass.sendmail('Metadata Report Available' , body);
    }}
public class dataMigrationSourceBatch implements database.Batchable<sObject>,database.stateful,database.allowsCallouts{
    
    private sobject objectSetting;
    private List<String> fields;
    private List<String> parentIdList=new List<String>();
    private string query='select Id,';
    public boolean recordTypeEligible=false;
    private List<Schema.DisplayType> stringtypes=new List<Schema.DisplayType>{Schema.DisplayType.STRING,Schema.DisplayType.Picklist,Schema.DisplayType.Combobox,Schema.DisplayType.Phone,Schema.DisplayType.Email,Schema.DisplayType.URL,Schema.DisplayType.Reference,Schema.DisplayType.ID,Schema.DisplayType.EncryptedString,Schema.DisplayType.Long};
        private List<Schema.DisplayType> numbertypes=new List<Schema.DisplayType>{Schema.DisplayType.Boolean,Schema.DisplayType.Currency,Schema.DisplayType.Double,Schema.DisplayType.Integer,Schema.DisplayType.Percent};
            
            public dataMigrationSourceBatch(){}  
    
    public dataMigrationSourceBatch(Migration_objects__c objectSetting,List<String> fields, List<String> parentIdList){
        
        this.objectSetting=(sobject)objectSetting;
        this.fields=fields;
        this.parentIdList=parentIdList;
        constructQuery();
        
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug(query);
        return Database.getQueryLocator(query);  
        
    }
    
    public void execute(Database.BatchableContext BC, List<sobject> sobjectList){   
        Map<string,sObject> sobjectMap=new Map<string,sObject>();
        for(sobject sobj:sobjectList){
            sobjectMap.put((string)sobj.get('Id'),sobj);
        }
        string body=json.serialize(sobjectMap);
        Http http=new Http();
        HttpRequest request=new HttpRequest();
        Data_Migration_Auth__c authsetting=Data_Migration_Auth__c.getValues('migration');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer {!$' + authsetting.named_credentials__c + '.OAuthToken}');
        request.setEndPoint('callout:' + authsetting.named_credentials__c + '/services/apexrest/DataMigration/saveRecords');  
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('MainObject',(String)objectSetting.get('objectName__c'));
        request.setHeader('selfLookup',string.valueof(objectSetting.get('self_lookup__c')));
        request.setBody(body);
        httpresponse resp=http.send(request);
    }
    
    public void finish(Database.BatchableContext BC){
        objectSetting.put('status__c','Completed');
        update objectSetting;
    }
    
    public void constructQuery(){
        Map<String, Schema.SObjectField> fieldMap=getsobjectSchema((String)objectSetting.get('objectName__c'));
        if((String)objectSetting.get('Object_type__c')=='Child'){
            for (String fieldName:fields) 
            {  
                Schema.DescribeFieldResult field=fieldMap.get(fieldName).getDescribe();
                if(field.isUpdateable())
                    query+=fieldname + ',';
            }
        }
        else{
            for(string fieldName : fieldmap.keyset()){
                Schema.DescribeFieldResult field= fieldMap.get(fieldName).getDescribe();
                if(field.isUpdateable())
                    query+=fieldname + ',';
            }
        }
        query=query.removeEnd(',');
        query+=' from ' + (String)objectSetting.get('objectName__c');
        if((String)objectSetting.get('Object_type__c')=='Child'){
            if(recordTypeEligible==true && !string.isblank((String)objectSetting.get('RecordType__c'))){
                query+=' WHERE recordType.Name=\'' + (String)objectSetting.get('RecordType__c') + '\'';              
            }
            for(integer i=1;i<=2;i++){
                string fieldName=(String)objectSetting.get('FilterField_' + i + '__c');
                string value=(String)objectSetting.get('FilterValue_' + i + '__c');
                if(fieldName !=null && value !=null ){
                    
                    if(!query.contains(' WHERE ')){
                        query+=' WHERE '+ fieldName+ ' IN ' + value;
                    }
                    else{
                        query+=' AND '+ fieldName+ ' IN ' + value;
                    }
                }
            }
            query+=' ORDER BY CreatedDate desc  LIMIT 1000';
        }
        else {
            query +=' where id IN  :parentIdList';
        }
    }
    
    public Map<String, Schema.SObjectField> getsobjectSchema(string objName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjSchema = schemaMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
        Map<String,schema.recordTypeInfo> rectypeInfoMap=objschema.getDescribe().getRecordTypeInfosByName();
        system.debug(rectypeInfoMap);
        if(rectypeInfoMap.size()==1){
            recordTypeEligible=false;
        }
        else{
            recordTypeEligible=true;
        }
        return fieldMap;
    }
}
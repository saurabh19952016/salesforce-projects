public class dataMigrationFormController {
    private static Map<String,Migration_Objects__c> migObjectMap=Migration_Objects__c.getAll();
    
    @AuraEnabled
    public static List<Migration_Objects__c>  getMaxHierarchyLevel(){
        List<Migration_Objects__c> settingsList=[select id,ObjectName__c,hierarchy_level__c from Migration_Objects__c where object_type__c Like 'Child%' order by hierarchy_level__c];
        if(!settingsList.isempty()){
            return settingsList;
        }
        else{
            return new List<Migration_Objects__c> {new Migration_Objects__c(objectName__c='Child Object',object_type__c='Child',Hierarchy_Level__c=1)} ;
                }
    }
    
    @AuraEnabled
    public static List<Migration_Objects__c> getSettings(Integer HierarchyLevel){
        system.debug(HierarchyLevel);
        List<Migration_Objects__c> settingsList= new List<Migration_Objects__c> ();
        settingsList=[select id,Name,ObjectName__c,Status__c,FilterField_2__c,filterValue_1__c,filterField_1__c,filterValue_2__c,recordtype__c,self_lookup__c,
                      Object_type__c,relationship_field__c,Hierarchy_Level__c,child_setting_name__c from Migration_Objects__c where Hierarchy_Level__c=:HierarchyLevel or Hierarchy_Level__c=:(HierarchyLevel+1) order by name]; 
        
        if(settingslist.isempty()==false){
            List<Migration_Objects__c> returnList=new List<Migration_Objects__c>();
            Migration_Objects__c child=new Migration_Objects__c();
            for(Migration_Objects__c dataArch:settingslist){
                if(dataArch.Object_type__c.contains('Child')){
                    child=dataArch;
                    break;
                }
            }
            if(child.id!=null)
            { 
                returnList.add(child);
                for(Migration_Objects__c dataArch:settingslist){
                    system.debug(dataArch.child_setting_name__c +  ' -- > ' + child.Name);
                    if(dataArch.child_setting_name__c==child.Name){
                        returnList.add(dataArch);
                    }
                }
                system.debug(returnlist.size());
                return returnList;
            }
            else 
                return new List<Migration_Objects__c> ();
        }
        else{
            settingslist.add(new Migration_Objects__c(object_type__c='Child',Hierarchy_Level__c=1));
            
            return settingslist;
        }
    }
    
    @AuraEnabled
    public static void deleteAllSettings(Migration_Objects__c setting){
        List<Migration_Objects__c> deleteList=[select id from Migration_Objects__c];
        if(deleteList.size()>0){
            Data_Migration_Auth__c authsetting=Data_Migration_Auth__c.getValues('migration');
            /*MetadataHandlerClass.authwrapper auth=new MetadataHandlerClass.authwrapper(authsetting);
            MetadataHandlerClass.responseWrapper responseWrap=MetadataHandlerClass.getSessionId(auth);*/
            Http http=new Http();
            HttpRequest request=new HttpRequest();
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer {!$' + authsetting.named_credentials__c + '.OAuthToken}');
            request.setEndPoint('callout:' + authsetting.named_credentials__c +'/services/apexrest/DataMigration/deleteAll');
            request.setHeader('Content-Type', 'application/json');
            httpresponse resp=http.send(request); 
            delete deleteList;
        }
    }
    
    @AuraEnabled
    public static List<Migration_Objects__c> saveSettings(Migration_Objects__c setting,Integer HierarchyLevel){
        Boolean newCustomsetting=false;
        try{
            if(setting.id==null){
                newCustomsetting=true;
                setting.name=String.valueof(system.now()+'-'+system.now().millisecond());
                setting.Hierarchy_Level__c=HierarchyLevel;
                setting.Operation_type__c='migrate';
            }
            Map<String,Migration_Objects__c> settingMap=new  Map<String,Migration_Objects__c> ();
            settingMap.put(setting.ObjectName__c,setting);
            upsert settingMap.values();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType ObjSchema = schemaMap.get(setting.ObjectName__c);
            Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
            integer i=0;
            boolean selfLookupdone=false;
            for (String fieldName: fieldMap.keyset()) 
            {  
                Schema.DescribeFieldResult field=fieldMap.get(fieldName).getDescribe();  
                if(field.getType() == Schema.DisplayType.REFERENCE)
                {
                    List<Schema.SObjectType> parents=field.getReferenceTo();
                    for(Schema.SObjectType parentobj: parents ){
                        schema.describeSobjectResult parentobject=parentobj.getDescribe();
                        string parentname=parentobject.getName();
                        if(field.isCreateable() && parentObject.createable){
                            
                            if(!settingMap.containsKey(parentName) || (parentname==setting.ObjectName__c && selfLookupdone==false))
                            {
                                Migration_Objects__c newsetting=new Migration_Objects__c();
                                newsetting.name=String.valueof(system.now()+'-'+system.now().millisecond() + i);
                                system.debug('name-'+newsetting.name);
                                newsetting.ObjectName__c=parentname;
                                system.debug(newsetting.ObjectName__c);
                                newsetting.relationship_field__c=String.valueOf(field.getName());
                                newsetting.object_type__c='Parent';
                                newsetting.Operation_type__c='migrate';
                                newsetting.child_setting_name__c=setting.Name;
                                newsetting.Hierarchy_Level__c=setting.Hierarchy_Level__c+1;
                                if(parentname==setting.ObjectName__c){
                                    selfLookupdone=true;
                                newsetting.self_lookup__c=true;
                                }
                                settingMap.put(newsetting.ObjectName__c,newsetting); 
                            }
                            else{
                                Migration_Objects__c existingSetting= settingMap.get(parentName);
                                if(existingSetting.relationship_field__c==null){
                                    existingSetting.relationship_field__c= String.valueOf(field.getName());
                                    
                                }
                                else if((existingSetting.relationship_field__c+ ',' + String.valueOf(field.getName())).length()<=255){
                                    existingSetting.relationship_field__c+=',' + String.valueOf(field.getName());
                                    
                                }
                                settingMap.put(existingSetting.ObjectName__c,existingSetting);
                            }
                        }
                    }
                }
            }   
            upsert settingmap.values();
            return getSettings(HierarchyLevel);
            
        }
        catch(exception e){
            return new List<Migration_Objects__c>();
        }
    }
    
    
    @AuraEnabled    
    public static objectWrapper getFieldList(string selectedObj) 
    {   
        system.debug(selectedObj);
        objectWrapper objWrap = new objectWrapper();
        List<String> fieldNames = new List<string>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjSchema = schemaMap.get(selectedObj);
        Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keyset()) 
        {  
            Schema.DescribeFieldResult field=fieldMap.get(fieldName).getDescribe();
            fieldNames.add(fieldMap.get(fieldName).getDescribe().getName());
        }
        fieldNames.sort();
        objWrap.fieldList=fieldNames;
        set<string> recordtypeSet=Schema.getGlobalDescribe().get(selectedObj).getDescribe().getRecordTypeInfosByName().keySet();
        objwrap.recordtypes=new List<String>();
        objwrap.recordtypes.addAll(recordtypeSet);
        return objWrap;
    }
    
    @AuraEnabled    
    public static void runBatch(Migration_Objects__c objectName,List<String> fields) 
    {   
        /*Data_Migration_Auth__c authsetting=Data_Migration_Auth__c.getValues('data migration auth');
        MetadataHandlerClass.authwrapper auth=new MetadataHandlerClass.authwrapper(authsetting);
        MetadataHandlerClass.responseWrapper responseWrap=MetadataHandlerClass.getSessionId(auth);*/
        objectName.Status__c='Running';
        update objectName;
        /* if(objectName.hierarchy_level__c=='3'){
Migration_Objects__c newchild=[select id,Name,ObjectName__c,Status__c,FilterField_2__c,filterValue_1__c,filterValue_2__c,filterField_1__c,recordtype__c,
Object_type__c,relationship_field__c,Hierarchy_Level__c,child_setting_name__c  from migration_objects__c where Hierarchy_Level__c='1' limit 1];
Migration_Objects__c newParent=[select id,Name,ObjectName__c,Status__c,filterField_1__c,FilterField_2__c,filterValue_1__c,filterValue_2__c,recordtype__c,
Object_type__c,relationship_field__c,Hierarchy_Level__c,child_setting_name__c  from migration_objects__c where objectName__c=:objectName.child_setting_name__c limit 1];
system.debug(newParent);
system.debug(newchild);


}
else*/ if(objectName.hierarchy_level__c!=1){
    migration_objects__c newChild=getLastChild(objectName,1);
    migration_objects__c newParent=getLastChild(objectName,2);
    newChild =[select id,Name,ObjectName__c,Status__c,FilterField_2__c,filterValue_1__c,filterValue_2__c,filterField_1__c,recordtype__c,self_lookup__c,
               Object_type__c,relationship_field__c,Hierarchy_Level__c,child_setting_name__c  from migration_objects__c where name=:newchild.name];
    newparent =[select id,Name,ObjectName__c,Status__c,FilterField_2__c,filterValue_1__c,filterValue_2__c,filterField_1__c,recordtype__c,self_lookup__c,
                Object_type__c,relationship_field__c,Hierarchy_Level__c,child_setting_name__c  from migration_objects__c where name=:newParent.name];
    database.executeBatch(new parentArchivalBatch(objectName,newParent,newchild,1,2,new List<String>()),200);  
    /*  Migration_Objects__c newchild=[select id,Name,ObjectName__c,Status__c,FilterField_2__c,filterValue_1__c,filterValue_2__c,filterField_1__c,recordtype__c,
Object_type__c,relationship_field__c,Hierarchy_Level__c,child_setting_name__c  from migration_objects__c where Hierarchy_Level__c='1' limit 1];
*/
}
        else{
            database.executeBatch(new dataMigrationSourceBatch(objectName,fields,new List<String>()),50);
        }
    }
    
    @AuraEnabled    
    public static List<ObjectorderWrapper> getObjectsPushed() 
    {   
        Data_Migration_Auth__c authsetting=Data_Migration_Auth__c.getValues('migration');
       /* MetadataHandlerClass.authwrapper auth=new MetadataHandlerClass.authwrapper(authsetting);
        MetadataHandlerClass.responseWrapper responseWrap=MetadataHandlerClass.getSessionId(auth);*/
        Http http=new Http();
        HttpRequest request=new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer {!$' + authsetting.named_credentials__c + '.OAuthToken}');
        request.setEndPoint('callout:' + authsetting.named_credentials__c + '/services/apexrest/DataMigration/');
        request.setHeader('Content-Type', 'application/json');
        httpresponse resp=http.send(request); 
        list<ObjectorderWrapper> wraplist=new List<ObjectorderWrapper>();
        List<String> objectsList=(List<String>)json.deserialize(resp.getBody(),List<String>.class);
        for(String obj:objectsList){
            wraplist.add(new ObjectorderWrapper(obj,null));
        }
        return wraplist;
    }
    
    @AuraEnabled    
    public static void commitRecords(List<ObjectorderWrapper> objectOrders) 
    {   
        system.debug(objectOrders);
       Data_Migration_Auth__c authsetting=Data_Migration_Auth__c.getValues('migration');
       /*  MetadataHandlerClass.authwrapper auth=new MetadataHandlerClass.authwrapper(authsetting);
        MetadataHandlerClass.responseWrapper responseWrap=MetadataHandlerClass.getSessionId(auth);*/
        Http http=new Http();
        HttpRequest request=new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer {!$' + authsetting.named_credentials__c + '.OAuthToken}');
        request.setEndPoint('callout:' + authsetting.named_credentials__c + '/services/apexrest/DataMigration/commitRecords');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(json.serialize(objectOrders));
        httpresponse resp=http.send(request); 
    }
    
    @AuraEnabled
    public static Integer changeParent(Migration_Objects__c newsetting,Migration_Objects__c parentRecord){
        try{
            List<Migration_Objects__c> deleteList=new List<Migration_Objects__c>();
            deleteList=[select id from Migration_Objects__c where Hierarchy_level__c>:newsetting.Hierarchy_Level__c or name=:newsetting.name  or Object_type__c=:('Child' + newsetting.Hierarchy_Level__c)];
            if(deleteList.size()>0)
                delete deleteList;
            parentRecord.Object_type__c='Child' + newsetting.Hierarchy_Level__c;
            parentRecord.Id=null;	
            parentrecord.ObjectName__c=newsetting.ObjectName__c;
            parentrecord.relationship_Field__c=newsetting.relationship_Field__c;
            parentRecord.child_setting_name__c=parentRecord.Name;	
            parentRecord.status__c=newsetting.status__c;
            saveSettings(parentRecord,Integer.valueof(newsetting.Hierarchy_Level__c));
            return Integer.valueof(newsetting.Hierarchy_Level__c);
        }
        catch(Exception ex){
            throw ex;
        } 
    }
    
    public static migration_objects__c getLastChild(migration_objects__c objectName,integer newParentIndex){
        system.debug(newParentIndex);
        system.debug(objectName);
        if(migObjectMap.get(objectName.Name).child_setting_name__c!=null && newParentIndex!=migObjectMap.get(objectName.Name).Hierarchy_Level__c){
            migration_objects__c childSettingName= migObjectMap.get(objectName.child_setting_name__c);
            system.debug(childSettingName);
            if(newParentIndex==childSettingName.Hierarchy_Level__c)
                return childSettingName;
            else
                return getLastChild(childSettingName,newParentIndex);
        }
        else{
            return objectName;
        }
    }
    
    public class objectWrapper{
        @AuraEnabled
        public List<String> fieldList{get;set;}
        @AuraEnabled
        public List<String> recordTypes{get;set;}        
    }
    
    public class objectOrderWrapper{
        @AuraEnabled
        public string objectName{get;set;}
        @AuraEnabled
        public Decimal order{get;set;}
        public ObjectorderWrapper(string objectName,decimal  order){
            this.objectName=objectName;
            this.order=order;
        }
        public ObjectorderWrapper(){}
    }
    
}
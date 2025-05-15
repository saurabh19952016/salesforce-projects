public class DataMigrationController {
    // private static Map<String,ObjectPayload> ObjectWrapperMap=new Map<String,ObjectPayload>();
    private static List<Schema.DisplayType> stringtypes=new List<Schema.DisplayType>{Schema.DisplayType.STRING,Schema.DisplayType.Picklist,Schema.DisplayType.Phone,Schema.DisplayType.Email,Schema.DisplayType.URL,Schema.DisplayType.Reference,Schema.DisplayType.ID,Schema.DisplayType.EncryptedString};
        private static List<Schema.DisplayType> numbertypes=new List<Schema.DisplayType>{Schema.DisplayType.Boolean,Schema.DisplayType.Combobox,Schema.DisplayType.Currency,Schema.DisplayType.Date,Schema.DisplayType.DateTime,Schema.DisplayType.Double,Schema.DisplayType.Integer,Schema.DisplayType.Long,Schema.DisplayType.Percent,Schema.DisplayType.Time};
            private static string requesturi;
    
    @AuraEnabled
    public static initializeWrapper deleteBigObjectRecords(){
        system.debug('test');
        try{
            delete [select id from migration_objects__c];
            database.executebatch(new deleteBigObjectsBatch(),200);
            initializeWrapper initWrap=new initializeWrapper();    
            initWrap.isDeleteRunning=true;
            initWrap.isBigObjPresent=true;
            return initWrap;
        }
        catch(Exception e){
            return new initializeWrapper();
        }
    } 
    
    
    @AuraEnabled
    public static MetadataHandlerClass.authWrapper getAuthWrapper(){
       return new MetadataHandlerClass.authWrapper();
    } 
    
    @AuraEnabled
    public static List<String> getsobjectList(String QualifiedName){
        QualifiedName=QualifiedName+'%';
        List<String> sobjectlist=new List<String> ();
        List<EntityDefinition> sobjList = [SELECT MasterLabel, PluralLabel, KeyPrefix, DeveloperName, QualifiedApiName, NamespacePrefix FROM EntityDefinition WHERE IsCustomSetting = false and     
                                           IsEverCreatable=true and IsWorkflowEnabled=true and QualifiedApiName like :QualifiedName and  QualifiedApiName!='Attachment' order by QualifiedApiName limit 10];
        
        for(EntityDefinition s:sobjList)
            
        {
            sobjectlist.add(s.QualifiedApiName);
        }
        return sobjectlist;      
    }
    @AuraEnabled
    public static initializeWrapper getBigObjects(){
        initializeWrapper initWrap=new initializeWrapper();       
        initWrap.isBigObjPresent=!([select indexValue__c from Data_Migration__b]).isEmpty();
        initWrap.isJobRunning=!([select id from Migration_Objects__c where status__c='']).isempty();
         initwrap.isDeleteRunning=([select id from asyncapexjob where status NOT IN ('Aborted','Completed','Failed') and ApexClassID='01p3C0000038ZSMQA2']).isempty();
        return initWrap;
    }    
    
    @AuraEnabled
    public static initializeWrapper submitJob(String selectedObj,boolean getChild,boolean considerValidation,boolean SFDCtoSFDC,MetadataHandlerClass.authWrapper authwrap){
        try{
            system.debug(SFDCtoSFDC);
            initializeWrapper initWrap=new initializeWrapper();       
            Map<String,String> parentMap=new Map<String,String>();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType ObjSchema = schemaMap.get(selectedObj);
            Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
            Map<string,Migration_Objects__c> migrationSettings=new Map<string,Migration_Objects__c>();
             migrationSettings.put(selectedObj,new Migration_Objects__c(name=String.valueof(system.now()+'-'+system.now().millisecond())
                                                                                 ,objectName__c=selectedObj,hierarchy__c='parent'));
            if(getChild==true){
                List<Schema.ChildRelationship> relationships=ObjSchema.getDescribe().getChildRelationships();
                for (Schema.ChildRelationship cr: relationships) 
                {   
                    Schema.DescribeSobjectResult describe=cr.getChildSObject().getDescribe();
                    string childname=describe.getName();
                    if(describe.isAccessible() && describe.isCreateable() && describe.isUpdateable() && !migrationSettings.containskey(childname)){          
                        migrationSettings.put(childname,new Migration_Objects__c(name=String.valueof(system.now()+'-'+system.now().millisecond())+ relationships.indexof(cr)
                                                                                 ,objectName__c=childname,hierarchy__c='child'));
                    }
                }
            }
            for(Schema.SobjectField strFld: fieldMap.Values())
            {
                Schema.describefieldResult describe= strfld.getDescribe();
                if(describe.getType() == Schema.DisplayType.REFERENCE)
                {
                    List<Schema.SObjectType> parents=describe.getReferenceTo();
                    for(Schema.SObjectType parentobj: parents ){
                        string parentname=parentobj.getDescribe().getName();
                        if(describe.isAccessible() && describe.isCreateable() && describe.isUpdateable()  && !migrationSettings.containskey(parentname))
                        {
                            migrationSettings.put(parentname,new Migration_Objects__c(name=String.valueof(system.now()+'-'+system.now().millisecond()) + parents.indexof(parentobj)
                                                                                      ,objectName__c=parentname,hierarchy__c='parent'));
                        }
                        else if(migrationSettings.containskey(parentname)){
                            Migration_Objects__c tempMig=migrationSettings.get(parentName);
                            if(!tempMig.hierarchy__c.contains('parent'))
                            tempMig.hierarchy__c+=',parent';
                            migrationSettings.put(parentName,tempMig);
                        }
                    }
                }
                
            }

            //migrationSettings.put('settings',new Migration_Objects__c(name='settings',get_child__c=getChild,consider_validation__c=considerValidation));
            MetadataHandlerClass.responseWrapper respwrapper=new MetadataHandlerClass.responseWrapper();
            if(SFDCtoSFDC ==true){
            respwrapper=MetadataHandlerClass.getSessionId(authwrap);
            }
            else{
           respwrapper.instance_url=url.getSalesforceBaseUrl().toexternalform();
            /*String content =Page.APXTConga4__SessionId.getContent().toString();
            Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            e= content.indexOf('End_Of_Session_Id');
             respwrapper.access_token=content.substring(s, e);*/
             respwrapper.access_token=MetadataHandlerClass.getSessionId();
             respwrapper.status='SUCCESS';
            authwrap.targetOrgId='00D3C000000LsVw';
            }
            if(respwrapper.status=='SUCCESS'){
             insert  migrationSettings.values();  
             database.executeBatch(new processObjectMetadataBatch(considerValidation,authwrap.targetOrgId,respwrapper,SFDCtoSFDC),1);
             initWrap.isBigObjPresent=false;
             initWrap.isJobRunning=true;
             initWrap.isDeleteRunning=true;
            }
            else{
             initWrap.isBigObjPresent=false;
             initWrap.isJobRunning=false;
             initWrap.isDeleteRunning=true;
             initWrap.errorMessage=respWrapper.error;
            }
             return initWrap;
        }
        catch(exception ex){
            system.debug(ex.getMessage());  
            return new initializeWrapper();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<string,ObjectPayload> getBigObjectRecords(string hierarchy){
        List<Data_Migration__b> objectList=[select indexValue__c,DateTimeIndex__c,requiredInValidation__c,targetOrg__c,Object__c,fieldLabel__c,fieldLabelTarget__c,fieldNameTarget__c,fieldName__c,
                                            fieldType__c,fieldTypeTarget__c,requiredInLayout__c,hierarchy__c,required__c from Data_Migration__b];
        List<ObjectWrapper> relObjectList=new List<ObjectWrapper> ();
        for(Data_Migration__b obj:objectList){
                if(obj.hierarchy__c.containsIgnoreCase(hierarchy)){
        ObjectWrapper objWrap= new ObjectWrapper();
            objWrap.fieldLabel=obj.fieldLabel__c;
            objWrap.fieldName= obj.fieldName__c;
            objWrap.objectName= obj.object__c;
            objWrap.fieldType= obj.fieldType__c;
            if(obj.required__c!=null)
                objWrap.required= Boolean.valueof(obj.required__c);
            if(obj.requiredInValidation__c!=null)
                objWrap.requiredInValidation= Boolean.valueof(obj.requiredInValidation__c);
            if(obj.requiredInLayout__c!=null)
                objWrap.requiredInLayout= Boolean.valueof(obj.requiredInLayout__c);
            objWrap.fieldLabelTarget=obj.fieldLabelTarget__c;
            objWrap.fieldNameTarget= obj.fieldNameTarget__c;
            objWrap.fieldTypeTarget=obj.fieldTypeTarget__c;
                relObjectList.add(objWrap);
            }
        }
        system.debug('test' + relObjectList);
        ObjectPayload relObjectWrap=new ObjectPayload(hierarchy,relObjectList);
        Map<String,ObjectPayload> relObjectMap=new Map<String,ObjectPayload>();
        for(ObjectWrapper obj:relObjectWrap.ObjectWrapList){
            if(relObjectMap.containsKey(obj.Objectname)){
                ObjectPayload payload=relObjectMap.get(obj.Objectname);
                payload.objectWrapList.add(obj);
                relObjectMap.put(obj.Objectname,payload);
                system.debug('test' + relObjectList);
           }
            else{
                List<ObjectWrapper> newrellist=new List<ObjectWrapper>();
                newrellist.add(obj);
                relObjectMap.put(obj.Objectname,new ObjectPayload(hierarchy,newrellist));
            }
        }
        return relObjectMap;
    }
    
  @AuraEnabled(cacheable=true)
    public static List<ObjectWrapper> getBigObjectPicklist(string hierarchy){
        List<Data_Migration__b> objectList=[select indexValue__c,fieldLabel__c,object__c,fieldName__c,fieldLabelTarget__c,
                                            fieldNameTarget__c,DateTimeIndex__c,hierarchy__c,fieldType__c,fieldTypeTarget__c,picklistValuesCurrent__c,picklistValuesTarget__c  from Data_Migration__b];
        List<ObjectWrapper> relObjectList=new List<ObjectWrapper> ();
            system.debug (hierarchy);
          for(Data_Migration__b obj:objectList){
            system.debug (obj);
            if(obj.hierarchy__c!=null && obj.hierarchy__c.containsIgnoreCase(hierarchy) 
               && obj.fieldType__c!=null && obj.fieldType__c.equalsIgnoreCase('PICKLIST')
               && obj.fieldTypeTarget__c!=null && obj.fieldTypeTarget__c.equalsIgnoreCase('PICKLIST')){
                ObjectWrapper objWrap= new ObjectWrapper();
                objWrap.fieldLabel=obj.fieldLabel__c;
               objWrap.objectName= obj.object__c;
                objWrap.fieldName= obj.fieldName__c; 
                objWrap.fieldLabelTarget=obj.fieldLabelTarget__c;
                objWrap.fieldNameTarget= obj.fieldNameTarget__c;
                objWrap.picklistCurrent=obj.picklistValuesCurrent__c;
                objWrap.picklistTarget=obj.picklistValuesTarget__c;
                relObjectList.add(objWrap);
            }
          }   
        system.debug (relObjectList);
        return relObjectList;
    }
    
    public class ObjectWrapper{
        @AuraEnabled
        public string objectName{get;set;}
        @AuraEnabled
        public string fieldLabel{get;set;}
        @AuraEnabled
        public string fieldName{get;set;}
        @AuraEnabled
        public string fieldType{get;set;}
        @AuraEnabled
        public boolean required{get;set;}
        @AuraEnabled
        public string fieldLabelTarget{get;set;}
        @AuraEnabled
        public string fieldNameTarget{get;set;}
        @AuraEnabled
        public string fieldTypeTarget{get;set;}
        @AuraEnabled
        public Boolean requiredInValidation{get;set;}       

        @AuraEnabled
        public Boolean requiredInLayout{get;set;} 

        @AuraEnabled
        public string picklistCurrent{get;set;} 
        @AuraEnabled
        public string picklistTarget{get;set;} 
    }
    public class ObjectPayload{
        @AuraEnabled
        public String hierarchy{get;set;}
        @AuraEnabled
        public List<ObjectWrapper> ObjectWrapList{get;set;}
        public ObjectPayload(string hierarchy,List<ObjectWrapper> ObjectWrapList){
            this.ObjectWrapList=ObjectWrapList;
            this.hierarchy=hierarchy;
        }
    }
    
   
    
        
     public class initializeWrapper{
        @AuraEnabled
        public Boolean isBigObjPresent{get;set;}
        @AuraEnabled
        public Boolean isJobRunning{get;set;}
        @AuraEnabled
         public Boolean isDeleteRunning{get;set;}
        @AuraEnabled
         public string errorMessage{get;set;}
         public initializeWrapper(){}
    }
  
  
}
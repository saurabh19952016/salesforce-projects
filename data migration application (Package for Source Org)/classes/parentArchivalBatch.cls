public class parentArchivalBatch  implements database.Batchable<sobject>,database.stateful, database.allowsCallouts{
    //global List<id,data_archival_obeject_settings__c> archivelist;
    private string query ;
    private  Map<String,Migration_Objects__c> migObjectMap=Migration_Objects__c.getAll();
    private migration_objects__c parentObjectName;   
    private List<string> parentIdList=new List<string> ();
    private List<string> newParentIdList=new List<string> ();
    private migration_objects__c actualParent;
    private migration_objects__c childObjectName;
    private Integer index1;
    private Integer index2;
    private List<Schema.DisplayType> stringtypes=new List<Schema.DisplayType>{Schema.DisplayType.STRING,Schema.DisplayType.Picklist,Schema.DisplayType.Combobox,Schema.DisplayType.Phone,Schema.DisplayType.Email,Schema.DisplayType.URL,Schema.DisplayType.Reference,Schema.DisplayType.ID,Schema.DisplayType.EncryptedString,Schema.DisplayType.Long};
        private List<Schema.DisplayType> numbertypes=new List<Schema.DisplayType>{Schema.DisplayType.Boolean,Schema.DisplayType.Currency,Schema.DisplayType.Double,Schema.DisplayType.Integer,Schema.DisplayType.Percent};
            
            public parentArchivalBatch(migration_objects__c actualParent,migration_objects__c parentObjectName,migration_objects__c childObjectName,Integer index1,integer index2,List<string> parentIdList){
                this.parentObjectName=parentObjectName;
                this.childObjectName=childObjectName;
                this.actualParent=actualParent;
                this.index1=index1;
                this.index2=index2;
                this.parentIdList=parentIdList;
                constructChildQuery();
                
            }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug(query);
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sobject sobj:scope){
            for(string fieldName:parentObjectName.relationship_field__c.split(',')){
                string value=(String)sobj.get(fieldName);
                if(!newParentIdList.contains(value) && value!=null){
                    newParentIdList.add(value);               
                    system.debug(value);
                    
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        system.debug(newParentIdList);
        if(actualParent.hierarchy_level__c!=index2){
            index1=index1+1; 
            index2=index2+1;
            migration_objects__c newChild=dataMigrationFormController.getLastChild(actualParent,index1);
            migration_objects__c newParent=dataMigrationFormController.getLastChild(actualParent,index2);
            
            system.debug(newchild);
            system.debug(newParent);
            newChild =[select id,Name,ObjectName__c,Status__c,FilterField_2__c,filterValue_1__c,filterValue_2__c,filterField_1__c,recordtype__c,self_lookup__c,
                       Object_type__c,relationship_field__c,Hierarchy_Level__c,child_setting_name__c  from migration_objects__c where name=:newchild.name];
            newparent =[select id,Name,ObjectName__c,Status__c,FilterField_2__c,filterValue_1__c,filterValue_2__c,filterField_1__c,recordtype__c,self_lookup__c,
                        Object_type__c,relationship_field__c,Hierarchy_Level__c,child_setting_name__c  from migration_objects__c where name=:newParent.name];
            /*migration_Objects__c migObject=[select id,Name,ObjectName__c,Status__c,filterField_1__c,FilterField_2__c,filterValue_1__c,filterValue_2__c,recordtype__c,
Object_type__c,relationship_field__c,Hierarchy_Level__c,child_setting_name__c from migration_Objects__c where Id =:superParent limit 1];*/
            database.executeBatch(new parentArchivalBatch(actualParent,newparent,newChild,index1++,index2++,newParentIdList),200);
        }
        else{
            
            /*MetadataHandlerClass.authwrapper auth=new MetadataHandlerClass.authwrapper(authsetting);
            MetadataHandlerClass.responseWrapper responseWrap=MetadataHandlerClass.getSessionId(auth);*/
           database.executeBatch(new dataMigrationSourceBatch(actualParent,new List<String>(),newParentIdList),50);   
        }
    }
    
    public void constructChildQuery(){
        dataMigrationSourceBatch batch=new dataMigrationSourceBatch();
        sobject childObjectName2=(sobject)childObjectName;
        Map<String, Schema.SObjectField> fieldMap = batch.getsobjectSchema(childObjectName.objectName__c);
        system.debug(childObjectName);
        system.debug(parentObjectName);
        query='select Id,' + parentObjectName.relationship_field__c+ ' from ' + childObjectName.objectName__c;
        if(childObjectName.hierarchy_level__c==1){
            if(batch.recordTypeEligible==true && !string.isblank(childObjectName.RecordType__c)){
                query+=' WHERE recordType.Name=\'' + childObjectName.RecordType__c + '\'';
            }
            for(integer i=1;i<=2;i++){
                string fieldName=(String)childObjectName2.get('FilterField_' + i + '__c');
                string value=(String)childObjectName2.get('FilterValue_' + i + '__c');
                if(fieldName !=null && value !=null ){
                    
                    if(!query.contains(' WHERE ')){
                        query+=' WHERE '+ fieldName+ ' IN ' + value;
                    }
                    else{
                        query+=' AND '+ fieldName+ ' IN ' + value;
                    }
                }
            }
            query+=' ORDER BY createddate desc  LIMIT 1000';
        }
            else {
                
                query+=' Where Id IN :parentIdList';
            }
            
        }
        
        
        
    }
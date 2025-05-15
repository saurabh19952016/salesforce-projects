public class dataArchivalController {
    /*@AuraEnabled
public static Boolean validateObjectAPIName(String objName){

return Schema.getGlobalDescribe().containsKey(objName);
}*/
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
    public static List<string> getObjectFields(string selectedObj) 
    {   
        system.debug(selectedObj);
        List<String> fieldNames = new List<string>();
        if(!String.isBlank(selectedObj))
        {
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType ObjSchema = schemaMap.get(selectedObj);
            Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
            for (String fieldName: fieldMap.keyset()) 
            {  
                Schema.DescribeFieldResult field=fieldMap.get(fieldName).getDescribe();
                if(!(field.getType()==Schema.DisplayType.TEXTAREA && field.length>=216 && field.length<=131072) && !field.isNillable())
                    fieldNames.add(fieldMap.get(fieldName).getDescribe().getName());
            }
        }
        return fieldNames;
    }
    
    @AuraEnabled
    public static List<Data_Archival_Object_Settings__c> getSettings(String HierarchyLevel){
        system.debug(userinfo.getuserid());
        List<Data_Archival_Object_Settings__c> settingsList= new List<Data_Archival_Object_Settings__c> ();
        settingsList=[select id,Name,Object_Name__c,Status__c,Archival_From_Date__c,Archival_To_Date__c,FilterField_1__c,FilterField_2__c,filterValue_1__c,filterValue_2__c,Submitted_By__c,
                      Object_type__c,relationship_field__c,Hierarchy_Level__c,Parent_setting_name__c from Data_Archival_Object_Settings__c where Submitted_By__c=:userinfo.getuserid().substring(0,15) order by name]; 
        
        if(settingslist.isempty()==false){
            List<Data_Archival_Object_Settings__c> returnList=new List<Data_Archival_Object_Settings__c>();
            Data_Archival_Object_Settings__c parent=new Data_Archival_Object_Settings__c();
            for(Data_Archival_Object_Settings__c dataArch:settingslist){
                if(dataArch.Hierarchy_Level__c==HierarchyLevel && dataArch.Object_type__c=='Parent'){
                    parent=dataArch;
                    break;
                }
            }
            if(parent.id!=null)
            {   returnList.add(parent);
             for(Data_Archival_Object_Settings__c dataArch:settingslist){
                 if(dataArch.Parent_setting_name__c==parent.Name){
                     returnList.add(dataArch);
                 }
             }
             system.debug(returnlist.size());
             return returnList;
            }
            else 
                return new List<Data_Archival_Object_Settings__c> ();
        }
        else{
            if(HierarchyLevel=='1')
                settingslist.add(new Data_Archival_Object_Settings__c(object_type__c='Parent',Hierarchy_Level__c='1'));
            else
                settingsList= new List<Data_Archival_Object_Settings__c> ();
            return settingslist;
        }
    }
    
    
    @AuraEnabled
    public static void deleteSettings(Data_Archival_Object_Settings__c setting){
        List<Data_Archival_Object_Settings__c> deleteList=[select id from Data_Archival_Object_Settings__c where submitted_By__c=:userinfo.getuserId().substring(0,15)
                                                           and (Name=:setting.Name or parent_setting_Name__c=:setting.Name or Hierarchy_level__c='3')];
        if(deleteList.size()>0)
            delete deleteList;
    }
    
    @AuraEnabled
    public static List<Data_Archival_Object_Settings__c> saveSettings(Data_Archival_Object_Settings__c setting,String HierarchyLevel){
        Boolean newCustomsetting=false;
        try{
            if(setting.id==null){
                newCustomsetting=true;
                setting.status__c='Submitted';
                setting.name=String.valueof(system.now()+'-'+system.now().millisecond());
                setting.Hierarchy_Level__c=HierarchyLevel;
            }
            Map<string,Data_Archival_Object_Settings__c> settingMap=new  Map<string,Data_Archival_Object_Settings__c>();
            settingMap.put(setting.object_name__c,setting);
            upsert settingMap.values();
            boolean selfLookupdone=false;
            if(newCustomsetting && setting.Object_Name__c!='EmailMessage'){
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType ObjSchema = schemaMap.get(setting.Object_Name__c);
                Schema.DescribeSObjectResult Relationships = ObjSchema.getDescribe();
                List<Schema.ChildRelationship> relationshiplist= Relationships.getChildRelationships();
                for (Schema.ChildRelationship cr:relationshiplist) {
                    Schema.DescribeSObjectResult describe=cr.getChildSObject().getdescribe();
                    string objname=String.valueOf(describe.getName());
                    if(describe.isCreateable() && describe.isUpdateable() && objname!='EmailMessage' && objName!='Attachment' ){
                        if(!settingMap.containsKey(objname) || (objname==setting.Object_Name__c && selfLookupdone==false)){
                           Data_Archival_Object_Settings__c newsetting=new Data_Archival_Object_Settings__c();
                           newsetting.name=String.valueof(system.now()+'-'+system.now().millisecond() + relationshiplist.indexof(cr));
                           system.debug('name-'+newsetting.name);
                           newsetting.Object_Name__c=objname;
                           system.debug(newsetting.Object_Name__c);
                           newsetting.relationship_field__c=String.valueOf(cr.getField());
                           newsetting.Parent_Setting_Name__c=setting.Name;
                           newsetting.object_type__c='Child';
                           if(setting.Hierarchy_Level__c=='1')
                               newsetting.Hierarchy_Level__c='2';
                           else
                               newsetting.Hierarchy_Level__c='3';
                           if(objname==setting.Object_Name__c){
                                    selfLookupdone=true;
                             }
                           settingMap.put(objname,newsetting);
                        }
                            else{
                                 Data_Archival_Object_Settings__c existingSetting=settingMap.get(objname);
                                 if(existingSetting.relationship_field__c==null){
                                    existingSetting.relationship_field__c= String.valueOf(cr.getField());
                                    
                                }
                                else if((existingSetting.relationship_field__c+ ',' + String.valueOf(cr.getField())).length()<=255){
                                    existingSetting.relationship_field__c+=',' + String.valueOf(cr.getField());
                                    
                                }
                                settingMap.put(existingSetting.Object_Name__c,existingSetting);
                            }
                       }
                }
            }
            upsert settingMap.values();
            return getSettings(HierarchyLevel);
            
        }
        catch(exception e){
            return new List<Data_Archival_Object_Settings__c>();
        }
    }
    
    @AuraEnabled
    public static string runBatch(String objectName,string objectType){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjSchema;
        if(objectName=='EmailMessage'){
            ObjSchema = schemaMap.get('Case');
        }
        else
            ObjSchema = schemaMap.get(objectName);
        system.debug(objectName +objectType);
        Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
        if(fieldMap.containsKey('Archive_Indexes__c')){
            List<Data_Archival_Object_Settings__c> settingsList= new List<Data_Archival_Object_Settings__c> ();
            settingsList=[select id,Name,Object_Name__c,Status__c,Archival_From_Date__c,Archival_To_Date__c,FilterField_1__c,FilterField_2__c,filterValue_1__c,filterValue_2__c,Submitted_By__c
                          from Data_Archival_Object_Settings__c where Submitted_By__c=:userinfo.getuserid().substring(0,15) and object_name__c=:objectname]; 
            if(settingsList.isempty()==false)
            { 
                if(objectName=='EmailMessage')
                    Database.executeBatch(new emailArchivalBatch(),12);
                    
                else if(objectType=='Parent')
                    Database.executeBatch(new dataArchivalBatch(objectName,objectType,false),600);
                else if(objectType=='Child')
                    Database.executeBatch(new childArchivalBatch(objectName,objectType),2000);
                return 'success';
            }
            else
                return 'fail';
        }
        else
            return 'Please create the archive index field with API name Archive_Indexes__c to run the batch';
    }
    
    @AuraEnabled
    public static Boolean getBatchStatus(){
        List<asyncapexjob> asyncList= [select ApexClass.Name,Status from asyncapexjob where ApexClass.Name='dataArchivalBatch' and status IN ('Holding','Queued','Processing','Preparing')];
        return asyncList.isEmpty();
    }
    
    @AuraEnabled
    public static List<Data_Archival_Object_Settings__c> changeParent(Data_Archival_Object_Settings__c newsetting,Data_Archival_Object_Settings__c parentRecord){
        try{
            List<Data_Archival_Object_Settings__c> deleteList=new List<Data_Archival_Object_Settings__c>();
            deleteList=[select id from Data_Archival_Object_Settings__c where submitted_By__c=:userinfo.getuserId().substring(0,15)
                        and (Name=:newsetting.Name or (Hierarchy_level__c='2' and object_type__c='Parent') or Hierarchy_level__c='3')];
            if(deleteList.size()>0)
                delete deleteList;
            parentRecord.Object_type__c='Parent';
            parentRecord.Id=null;
            parentrecord.Object_Name__c=newsetting.Object_Name__c;
            parentrecord.parent_setting_name__c=parentRecord.Name;
            return saveSettings(parentRecord,'2');
        }
        catch(Exception ex){
            throw ex;
        } 
    }
    
}
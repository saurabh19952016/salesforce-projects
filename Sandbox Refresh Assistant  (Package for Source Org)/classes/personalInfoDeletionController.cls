public class personalInfoDeletionController {
private static List<Schema.DisplayType> stringtypes=new List<Schema.DisplayType>{Schema.DisplayType.STRING,Schema.DisplayType.Phone,Schema.DisplayType.TextArea,Schema.DisplayType.Long,schema.DisplayType.EMAIL};
private static List<Schema.DisplayType> numbertypes=new List<Schema.DisplayType>{Schema.DisplayType.Currency,Schema.DisplayType.Double,Schema.DisplayType.Integer,Schema.DisplayType.Long,Schema.DisplayType.Percent};

    @AuraEnabled    
public static List<string> getObjectFields(string selectedObj) 
{   
    system.debug(selectedObj);
    List<String> fieldNames = new List<string>();
    if(selectedObj!='User')
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjSchema = schemaMap.get(selectedObj);
        Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keyset()) 
        {  
            Schema.DescribeFieldResult field=fieldMap.get(fieldName).getDescribe();
            string objectname=fieldMap.get(fieldName).getDescribe().getName();
            if(objectname!='User' && !field.isCalculated() && field.isUpdateable() && (stringtypes.contains(field.getType()) || numbertypes.contains(field.getType()))){
                fieldNames.add(objectname);
            }
        }
    }
    else{
        for(Profile prof:[select id,name from Profile]){
            fieldNames.add(prof.name);
        }
    }
    return fieldNames;
}

@AuraEnabled    
public static Boolean checkJobRunning(string objectName) 
{   try{
    return (customMetadataService.getQuery('select id,developerName,status__c from refresh_setting_met__mdt where developername=\'' + objectName+ '\' and status__c NOT IN (\'Completed\',\'Failed\')')).isEmpty();
}
 catch(exception ex){
     return false;
 }
}

@AuraEnabled    
public static boolean deleteMetadata(string recId) 
{   
    try{
        List<fieldList__mdt> fieldList=(List<fieldList__mdt>) customMetadataService.getQuery('select id,developerName from fieldList__mdt where refresh_settings__r.Id=\'' + recId + '\'');
    if(!fieldList.isEmpty()){

        List<String> recordsToDelete = new List<String>();
    
    for(fieldList__mdt fields:fieldList){
        recordsToDelete.add('fieldList__mdt.' + fields.developerName);
    }

    MetaDataService.MetadataPort service=new MetaDataService.MetadataPort();
    service.SessionHeader = new MetadataService.SessionHeader_element();
    service.SessionHeader.sessionId = MetadataHandlerClass.getsessionId();
    service.deleteMetadata('CustomMetadata', recordsToDelete);
    return true;

}
else{
    return false;
}

}
catch(exception ex){
    return false;
}
}


@AuraEnabled    
public static List<refresh_setting_met__mdt> checkJobs() 
{   try{
    
    List<refresh_setting_met__mdt> settingsList=new List<refresh_setting_met__mdt>();
    settingsList =(List<refresh_setting_met__mdt>) customMetadataService.getQuery('select id,masterlabel,developername,status__c,jobId__c,(select id,fieldList__c from fieldLists__r) from refresh_setting_met__mdt');
    if(settingsList.size()>0){
        return settingsList;
    } 
    else{
        return new List<refresh_setting_met__mdt>();
    }
}
 catch(exception ex){
     return new List<refresh_setting_met__mdt>();
 }
}

@AuraEnabled    
public static string submitJob(string selectedObj,List<string> fieldList) 
{   
    try{
      List<fieldList__mdt> fieldListmet=(List<fieldList__mdt>) customMetadataService.getQuery('select id,fieldList__c from fieldList__mdt where refresh_settings__r.developerName=\'' +selectedObj+'\'');
      if(fieldListmet.size()<5){
        //List<refresh_setting_met__mdt> settingsList=[select id,status__c from refresh_setting_met__mdt where DeveloperName=:selectedObj];
        String nameSpacePrefix = '';
        string batchInstanceId = database.executeBatch(new clearPersonalInfoBatch(selectedObj,fieldList),100);
        string fieldValues=string.join(fieldList,',');
        system.debug('fieldList' + fieldList);
        // Set up custom metadata to be created in the subscriber org.
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            customMetadata.fullName = nameSpacePrefix + 'refresh_setting_met.' + selectedObj;
            customMetadata.label = selectedObj;

            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = 'jobId__c';
            customField.value = batchInstanceId;
            customMetadata.values.add(customField);
            
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'Status__c';
            customField.value = 'Processing';
            customMetadata.values.add(customField);
            
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            for(fieldList__mdt fieldListmetRecord:fieldListMet){
            if(fieldListmetRecord.fieldList__c==fieldValues){
                selectedObj=null;
                break;
            }
        }
            personalInfoDeletionCallback callback = new personalInfoDeletionCallback(selectedObj,fieldValues);
          if(!Test.isRunningTest()){
                          Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);

          }
            /* if(settingsList.size()>0){
            settingsList[0].status__c='Processing';
            settingsList[0].jobId__c=batchInstanceId;
            update settingsList[0];
        }
        else{
            insert new refresh_settings__c(name=selectedObj,Batch_processed__c=0,
            Total_Batches__c=0,status__c='Processing',jobId__c=batchInstanceId);
        }*/
    return 'SUCCESS';
      }
      else{
          return 'ERROR';
      }
}
    catch(exception ex){
        system.debug(ex);
        return 'EXCEPTION';
    }
}


}
public class clearPersonalInfoBatch implements Database.Batchable<sobject>{
private string ObjectName;
private List<string> fieldNames;
    @TestVisible
    private boolean forceException=false;

private static List<Schema.DisplayType> stringtypes=new List<Schema.DisplayType>{Schema.DisplayType.STRING,Schema.DisplayType.Phone,Schema.DisplayType.TextArea,Schema.DisplayType.Long,Schema.DisplayType.EMAIL};
private static List<Schema.DisplayType> numbertypes=new List<Schema.DisplayType>{Schema.DisplayType.Currency,Schema.DisplayType.Double,Schema.DisplayType.Integer,Schema.DisplayType.Percent};

public clearPersonalInfoBatch(String ObjectName,List<string> fieldList) {
        this.ObjectName=ObjectName;
        this.fieldNames=fieldList;
       
}

public Database.QueryLocator start(Database.BatchableContext BC){
        string query='select id from ' + ObjectName;
        if(objectName=='User'){
            query+=' WHERE Profile.name IN :fieldNames';
        }
        return Database.getQueryLocator(query);
}
    
public void execute(Database.BatchableContext BC, List<sObject> scope){
   /* asyncApexJob job=[select ApexClassID,JobItemsProcessed,TotalJobItems from asyncApexJob where Id=:BC.getJobId()];
    refresh_settings__c setting=[select id,status__c from refresh_settings__c where name=:objectName limit 1];     
    setting.Batch_processed__c=job.JobItemsProcessed+1;
    setting.Total_Batches__c=job.TotalJobItems;
    update setting;*/
    try{
        if(forceException==true){
               throw new system.DMLException('test exception');
        }
        else{
               if(objectName=='User'){
                for(sobject user:scope){
                    UserManagement.obfuscateUser((Id)user.get('Id'));
                }
            }
            else{
            Map<String, Schema.SObjectField> fieldMap=getsobjectSchema(ObjectName);
            List<sobject> sobjectList=new List<sobject>();
            for(sobject s : scope){
                for(string field:fieldNames){
                    system.debug('field-' + field);
                    Schema.DescribeFieldResult fieldDescribe=fieldMap.get(field).getDescribe();
                    string stringvalue=String.valueof(system.now()+'-'+system.now().millisecond());

                    decimal numberValue=1;
                    Integer integerValue=1;
                    if(stringtypes.contains(fieldDescribe.getType())){
                    stringvalue=stringvalue.replaceAll('[^0-9+]','');
                    system.debug('stringvalueafter' + stringvalue);
                        if(fieldDescribe.getType()==Schema.DisplayType.EMAIL){
                            stringvalue+=stringvalue+ '@noreply.com';
                        }
                        if(stringvalue.length()>fieldDescribe.getLength()){
                            stringvalue= stringvalue.substring(0, fieldDescribe.getLength()-1);
                        }
                        system.debug('stringvalue' + stringvalue);
                        s.put(Field,stringvalue); 
                    }
                    else if(numbertypes.contains(fieldDescribe.getType())){
                        if(fieldDescribe.getScale()==0){
                            s.put(Field,integerValue); 
                        }
                        else{
                            s.put(Field,numberValue); 
                        }
                    }
                }
                sobjectList.add(s);
            }
            update sobjectList;
           }
        }
    }
    catch(exception ex){
        system.abortJob(bc.getJobId());
        MetadataHandlerClass.sendMail('Error in ' + objectname+ ' update', ex.getMessage()+'\n'+ex.getLineNumber() 
        + '\n' + ex.getStackTraceString());
       /* setting.status__c='Failed';
        update setting;*/
            string nameSpacePrefix='';
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = nameSpacePrefix + 'refresh_setting_met.' + ObjectName;
        customMetadata.label = ObjectName;
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'status__c';
        customField.value = 'Failed';
        customMetadata.values.add(customField);
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        personalInfoDeletionCallback callback = new personalInfoDeletionCallback(null,null);
        if(!test.isRunningTest()){
                    Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);

            } 
    }
}

public void finish(Database.BatchableContext BC){
    asyncApexJob job=[select ApexClassID,JobItemsProcessed,TotalJobItems from asyncApexJob where Id=:BC.getJobId()];
    MetadataHandlerClass.sendMail( ObjectName + ' Update Successful', 'Personal information in fields of ' + ObjectName 
    + ' records have been cleared.');
    /*refresh_settings__c setting=[select id,status__c from refresh_settings__c where name=:objectName limit 1];
    setting.status__c='Completed';
    setting.Batch_processed__c=job.JobItemsProcessed;
    setting.Total_Batches__c=job.TotalJobItems;
    update setting;*/
        string nameSpacePrefix='';
    Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
    customMetadata.fullName = nameSpacePrefix + 'refresh_setting_met.' + ObjectName;
    customMetadata.label = ObjectName;
    Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
    customField.field = 'status__c';
    customField.value = 'Completed';
    customMetadata.values.add(customField);
    Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
    mdContainer.addMetadata(customMetadata);
    personalInfoDeletionCallback callback = new personalInfoDeletionCallback(null,null);
       if(!test.isRunningTest()){
                    Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);

        } 
}  

public Map<String, Schema.SObjectField> getsobjectSchema(string objName){
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType ObjSchema = schemaMap.get(objName);
    Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
    return fieldMap;
}

}
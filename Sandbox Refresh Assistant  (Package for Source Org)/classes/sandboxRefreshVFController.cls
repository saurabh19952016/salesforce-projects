public class sandboxRefreshVFController {
    public List<SelectOption> customSettingList{get;set;}
    public List<SelectOption> objectList{get;set;}
    public List<SelectOption> fieldOrUserList{get;set;}
    public List<String> selectedCSList{get;set;}
    public List<SelectOption> metadataList{get;set;}
    public List<String> selectedMetadataList{get;set;}
    public List<String> FldOrUsrSelected{get;set;}
    public string selectedTab{get;set;}
    public string selectedObject{get;set;}
     public string selectedTabRestore{get;set;}
   public Id workSpaceId{get;set;}
      public boolean enableDeleteJobs{get;set;}
      public boolean enableDataObscureJobs{get;set;}
   
    public sandboxRefreshVFController(){
        data_migration_auth__c authMig=data_migration_auth__c.getInstance('refresh');
        objectList=new List<selectOption>();
		fieldOrUserList=new List<selectOption>();
        FldOrUsrSelected=new List<String>();
         customSettingList=new List<selectOption>();
        metadataList=new List<selectOPtion>();
        selectedCSList=new List<String>();
        selectedMetadataList=new List<String>();
        system.debug('authMig:::'+authMig+''+authMig.library_name__c);
        ContentWorkspace cw =[SELECT Id FROM ContentWorkspace WHERE DeveloperName = :authMig.library_name__c];
        workspaceId=cw.Id;
        boolean settingJob=customSettingBkpController.isJobRunning();
        selectedTab='setting';
        selectedObject='';
        selectedTabRestore='setting';
        enableDeleteJobs=deleteJobController.checkJobRunning();
        List<String> csList=customSettingBkpController.csList();
        if(settingJob==false){
            for(String setting:csList){
                customSettingList.add(new selectOption(setting,setting));
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Custom Setting Backup Job Running'));
            
        }
        List<String> metalist=MetadataBackupController.getAllMetadata();
        for(String metadata:metalist){
            metadataList.add(new selectOption(metadata,metadata));
        }
        customSettingBkpController.getSaved(false);
		List<entitydefinition> entDefList=[SELECT MasterLabel, PluralLabel, KeyPrefix, DeveloperName, QualifiedApiName, NamespacePrefix FROM EntityDefinition WHERE IsCustomSetting = false and     
                                           IsEverCreatable=true and IsWorkflowEnabled=true  and  QualifiedApiName!='Attachment' order by QualifiedApiName];
        objectList.add(new selectoption('','--None--'));
        for( EntityDefinition entDef:entDefList){
            objectList.add(new selectOption(entdef.QualifiedApiName,entdef.QualifiedApiName));
        }
        
    }
    
    public void submitJob(){
        
        customSettingBkpController.submitJob(selectedCSList);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Job Submitted Successfully'));
        customSettingList=new List<SelectOption>();
    }
    
    public void deleteExisting(){
        List<metadata_backup_jobs__c> bkpList=[select id from metadata_backup_jobs__c];
        if(bkpList.size()>0){
            delete bkpList;
        }
    }
        public void submitAbortBatch(){
      	deleteJobController.deleteJobMethod();
            enableDeleteJobs=false;
    }
    
    public void getObjectFields(){
        fieldOrUserList=new List<selectoption>();
        if(!string.isblank(selectedObject)){
            
        enableDataObscureJobs=personalInfoDeletionController.checkJobRunning(selectedObject);
        if(enableDataObscureJobs==true ){
            for(string str:personalInfoDeletionController.getObjectFields(selectedObject)){
            	fieldOrUserList.add(new selectOption(Str,str));
        	}  
        }
        else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A job is In Progress for ' + selectedObject + ' object.'));
           
        }
                    }
        else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please make a valid object selection'));
        }
    }
    
   public void submitObscureJob(){
               if(FldOrUsrSelected.isempty()==false){

       string status=personalInfoDeletionController.submitJob(selectedObject,FldOrUsrSelected);
       if(status=='SUCCESS'){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Job submitted successfully'));
       }
       else{
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while submitting the job'));
       }
       selectedObject=null;
       fieldOrUserList=new List<selectOption>();
               }
       else{
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select fields or users before submitting'));
           
       }
    }
    
    @RemoteAction
    public static MetadataBackupController.jobWrapper submitRetreiveJob(string metadataSelected){
        return MetadataBackupController.submitRetreiveJob(metadataSelected);
    }
    
    
    
    @RemoteAction
    public static MetadataBackupController.jobWrapper checkRetrieveStatus(string jobSetting){
        MetadataBackupController.jobWrapper wrapperObj=(MetadataBackupController.jobWrapper)json.deserialize(jobSetting,MetadataBackupController.jobWrapper.class);
        system.debug(wrapperObj.jobId);
        return MetadataBackupController.checkJobRetrieve(wrapperObj.jobId);
    }
    
    
    @RemoteAction
    public static void  uploadFile(string body,string name,string mode){
        system.debug(body);
        if(mode=='setting'){
            
            customSettingBkpController.saveFile(name,encodingUtil.urlEncode(body,'UTF-8'),'.zip');
        }else{
            MetadataBackupController.saveFile(name,encodingUtil.urlEncode(body,'UTF-8'),'.zip');
        }
    }
    
}
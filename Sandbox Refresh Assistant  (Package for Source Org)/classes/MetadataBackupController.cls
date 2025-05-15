public with sharing class MetadataBackupController {
    private static final Integer METADATA_API_VERSION = Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));
   
    @AuraEnabled
    public static List<jobWrapper> getMetadataJobIds(string operation){
        List<metadata_backup_Jobs__c> metasettings=[select id,name,job_id__c from metadata_backup_Jobs__c where job_type__c=:operation];
        List<jobWrapper> jobWrapList=new List<jobWrapper>();
        for(metadata_backup_Jobs__c job:metasettings){
            jobWrapper wrap=new jobWrapper();
            wrap.status='InProgress';
            wrap.jobId=job;
            jobWrapList.add(wrap);
        }
        
        return jobWrapList;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAllMetadata() {
        List<String> metadataTypeNames = new List<String>();

        MetadataService.MetadataPort service = createService();                 
        MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(METADATA_API_VERSION);
        for(MetadataService.DescribeMetadataObject metadataObject : describeResult.metadataObjects)
        {
            metadataTypeNames.add(metadataObject.xmlName);
            // Include child Metadata Types (such as CustomField, ValidationRule etc..)
         
        }   
        metadataTypeNames.sort();
        return metadataTypeNames;  
    }

@AuraEnabled
public static jobWrapper checkJobRetrieve(metadata_backup_Jobs__c jobId) {
jobWrapper jobWrap=new jobWrapper();
jobWrap.jobId=jobId;
 try{
        MetadataService.MetadataPort service = createService(); 
        system.debug(jobId.job_Id__c);
        MetadataService.RetrieveResult retrieveResult=service.checkRetrieveStatus(jobId.job_Id__c, true);
        system.debug(retrieveResult.status);
        if(retrieveResult.status=='Succeeded'){
           Data_Migration_Auth__c authsetting=Data_Migration_Auth__c.getValues('refresh');
            /* MetadataHandlerClass.authwrapper auth=new MetadataHandlerClass.authwrapper(authsetting);
            MetadataHandlerClass.responseWrapper responseWrap=MetadataHandlerClass.getSessionId(auth);   */    
            Http http=new Http();
            HttpRequest request=new HttpRequest();
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer {!$' + authsetting.named_credentials__c + '.OAuthToken}');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('orgName',authsetting.org_name__c);
            request.setHeader('libraryName',authsetting.library_name__c);
            request.setHeader('fileName', jobId.Name + '.zip');
            request.setEndPoint('callout:' + authsetting.named_credentials__c + '/services/apexrest/saveZipFile/');
            request.setTimeout(10000);
            Map<String,String> contentBodyMap=new Map<String,String>();
            contentBodyMap.put('contentBody',retrieveResult.zipFile);
            system.debug(json.serialize(contentBodyMap));
            request.setBody(json.serialize(contentBodyMap));
            HttpResponse response=http.send(request);
            if(response.getStatusCode()==200){
                /*ContentWorkspace cw =[SELECT Id FROM ContentWorkspace WHERE DeveloperName = :authsetting.library_name__c];
                List<contentDocument> cdList=[select Id from contentDocument where LatestPublishedVersion.recordType.Name='refresh backup'
                and LatestPublishedVersion.org_Name__c=:authsetting.org_name__c and title=:(jobId.Name+'.zip') limit 1]; 
    
                ContentVersion docVersion = new ContentVersion(
                    Title = jobId.Name + '.zip',
                    PathOnClient =jobId.Name +'.zip',
                    contentLocation='S',
                    recordtypeid=schema.sobjecttype.contentversion.getRecordtypeInfosByname().get('refresh backup').getrecordtypeid(),
                    VersionData = encodingUtil.base64Decode(retrieveResult.zipFile),
                    IsMajorVersion = true,
                    org_name__c=authsetting.org_name__c
                );   
                if(cdList.size()>0){
                    docVersion.ContentDocumentId= cdList[0].Id;
                }
                else{
                    docVersion.FirstPublishLocationId = cw.Id;
                }
                insert docVersion;*/
                jobwrap.status='Succeeded';
            }
            else{
                MetadataHandlerClass.sendMail(jobId.name + ' Retrival Failed',  response.getBody());
                jobwrap.status='Failed';
            }
        }
        else{
            jobwrap.status= retrieveResult.status;

        }
        if(retrieveResult.done==true){
            delete jobId;
        }
    }
catch(exception ex){
    if(!([select id from metadata_backup_Jobs__c where id=:jobId.Id]).isempty()){
        delete jobId; 
}
jobWrap.status='Exception';

}
return jobWrap;

}

 @AuraEnabled
public static jobWrapper submitRetreiveJob(String metadataSelected) {
        jobWrapper wrap=new jobWrapper();
        try{
        MetadataService.MetadataPort service = createService(); 
        system.debug('s ' + metadataSelected);
        MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
        retrieveRequest.apiVersion = 42;
        retrieveRequest.packageNames = null;
        retrieveRequest.singlePackage = true;
        retrieveRequest.specificFiles = null;
        retrieveRequest.unpackaged = new MetadataService.Package_x();
        retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
        MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
        packageType.name = metadataSelected; 
        packageType.members = new String[] { '*' };
            retrieveRequest.unpackaged.types.add(packageType);
        MetadataService.AsyncResult AsyncResult = service.retrieve(retrieveRequest); 
        Integer i = 2000;
        system.debug(AsyncResult.Id);
        metadata_backup_Jobs__c jobrecord=new metadata_backup_Jobs__c(name=metadataSelected,job_type__c='retreive',job_Id__c=asyncResult.Id);
        insert jobRecord;
        wrap.status='InProgress';
        wrap.jobId=jobRecord;
        return wrap;
        }
        catch(exception ex){
            return wrap;
        }
    }



    @AuraEnabled
    public static void saveFile(String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Blob zipBody=EncodingUtil.base64Decode(base64Data);
        MetadataService.MetadataPort service = createService(); 
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles=false;
        deployOptions.autoUpdatePackage=false;
        deployOptions.checkOnly=false;  
        deployOptions.ignoreWarnings=false;
        deployOptions.performRetrieve=false;
        deployOptions.purgeOnDelete=false;
        deployOptions.rollbackOnError=true;
        deployOptions.testLevel='NoTestRun';
        deployOptions.singlePackage=true;
        MetadataService.AsyncResult AsyncResult = service.deploy(base64Data,deployOptions);
        system.debug(AsyncResult.Id);
        metadata_backup_Jobs__c jobrecord=new metadata_backup_Jobs__c(name=filename,job_type__c='deploy',job_Id__c=asyncResult.Id);
        insert jobRecord;
      }
        // Get the response by using the unique label
        // Set the result variable to have the response body
       
    public static MetadataService.MetadataPort createService()
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = MetadataHandlerClass.getSessionId();
        return service;
    }

    @AuraEnabled
    public static jobWrapper cancelDeployment(metadata_backup_Jobs__c jobId) {
        jobwrapper jobWrap=new jobwrapper();
        jobWrap.jobId=jobId;
        try{
            MetadataService.MetadataPort service = createService(); 
            MetadataService.CancelDeployResult cancelResult=service.cancelDeploy(jobId.job_Id__c);
            if(cancelResult.done==true){
                delete jobId;
                jobwrap.status='Success';
            }
            else{
                jobwrap.status='InProgress';
            }
            return jobwrap;   
        }    
        catch(exception ex){
            jobwrap.status='Failed'; 
            return jobwrap;
            }
        }

    @AuraEnabled
    public static jobWrapper checkJobDeploy(metadata_backup_Jobs__c jobId) {
        jobwrapper jobWrap=new jobwrapper();
        jobWrap.jobId=jobId;
        system.debug(jobId);
        try{
            MetadataService.MetadataPort service = createService(); 
            MetadataService.DeployResult deployresult=service.checkDeployStatus(jobId.job_Id__c, true);
            if(deployresult.done==true){
                delete jobId;
            }
            system.debug(deployResult);
            jobWrap.status=deployresult.status;
            jobwrap.numberComponentsTotal=deployresult.numberComponentsTotal;
            jobwrap.numberComponentErrors=deployresult.numberComponentErrors;
            jobwrap.numberComponentsDeployed=deployresult.numberComponentsDeployed;
            return jobwrap;
        }
        catch(exception ex){
            jobwrap.status='Failed'; 
            if(!([select id from metadata_backup_Jobs__c where id=:jobId.Id]).isempty()){
                delete jobId; 
            }
            return jobwrap;
        }
    }

    public class jobWrapper{
        @AuraEnabled
        public metadata_backup_Jobs__c jobId{get;set;}

        @AuraEnabled
        public String status{get;set;}

        @AuraEnabled
        public Integer numberComponentsTotal{get;set;}

        @AuraEnabled
        public Integer numberComponentsDeployed{get;set;}
        @AuraEnabled
        public Integer numberComponentErrors{get;set;}

      }

}
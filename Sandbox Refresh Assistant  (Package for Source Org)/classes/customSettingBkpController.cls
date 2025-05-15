public class customSettingBkpController {

@AuraEnabled
public static string deleteSavedData(string objects) 
{    
    Data_Migration_Auth__c authsetting=Data_Migration_Auth__c.getValues('refresh');
   /* MetadataHandlerClass.authwrapper auth=new MetadataHandlerClass.authwrapper(authsetting);
    MetadataHandlerClass.responseWrapper responseWrap=MetadataHandlerClass.getSessionId(auth);*/
    Http http=new Http();
    HttpRequest request=new HttpRequest(); 
    request.setMethod('DELETE');
    request.setHeader('Authorization', 'Bearer {!$' + authsetting.named_credentials__c + '.OAuthToken}');
    request.setEndPoint('callout:' + authsetting.named_credentials__c + '/services/apexrest/saveZipFile/');
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('orgName',authsetting.org_name__c);
    request.setHeader('libraryName',authsetting.library_name__c);
    request.setHeader('objects', objects);
    httpresponse resp=http.send(request);
    if(resp.getStatusCode()==200){
      /*  string query='SELECT id,Title FROM ContentDocument where LatestPublishedVersion.recordtype.name=\'refresh backup\' and fileextension=\'zip\'';
        if(objects=='custom settings'){
           query+=' and title like \'custom settings%\'';
        }
        else if(objects=='metadata'){
            query+=' and (not title  like \'custom settings%\')';          
        }
        delete database.query(query);*/
        return 'Success';
   }
    else{
        Map<String,Object> objectMap=(Map<String,Object>)json.deserializeUntyped(resp.getBody());
        return 'Failed deleting files: ' +(String)objectMap.get('exception');

    }
}

@AuraEnabled
public static Boolean isJobRunning() 
{   
    return !([select id from asyncApexJob where (apexclass.Name='readZipQueueable'  or apexclass.Name='createZipQueueable')  and status  NOT IN ('Completed','Failed','Aborted')].isEmpty());
}

@AuraEnabled
public static List<String> CSList()
{
    List<String> customsettings=new List<String>();
    List<EntityDefinition> entityList=[select QualifiedApiName from entitydefinition where iscustomsetting = true];
    for(entitydefinition ed: entityList){
            customsettings.add(ed.QualifiedApiName);
    }   
    return customsettings;
}   
@AuraEnabled
public static void submitJob(List<String> customSettings)
{

    system.enqueueJob(new createZipQueueable(customSettings,new zippex()));
} 

@AuraEnabled
public static returnBackup getSaved(boolean isMetadata){
    Data_Migration_Auth__c authsetting=Data_Migration_Auth__c.getValues('refresh');
    Http http=new Http();
    HttpRequest request=new HttpRequest(); 
    request.setMethod('GET');
    request.setHeader('Authorization', 'Bearer {!$' + authsetting.named_credentials__c + '.OAuthToken}');
    request.setEndPoint('callout:' + authsetting.named_credentials__c + '/services/apexrest/saveZipFile/');
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('orgName',authsetting.org_name__c);
    request.setHeader('isMetadata',string.valueof(isMetadata));
    httpresponse resp=http.send(request);
    returnBackup retBkpObj=(returnBackup)json.deserialize(resp.getBody(),returnBackup.class);
    return retBkpObj;
            // ContentWorkspace cw =[SELECT Id FROM ContentWorkspace WHERE DeveloperName = 'Custom_Setting_Backup'];
   /* string query='select id,Title,CreatedDate,CreatedBy.Name from contentVersion where recordtype.name=\'refresh backup\' and fileextension=\'zip\'';
    if(isMetadata==false){
        query+=' and title=\'custom settings.zip\'';
    }

    else{
        query+=' and title!=\'custom settings.zip\'';  
    }
    query+=' order by title';
    List<ContentVersion> contVerList=database.query(query);
    return contVerList;*/
}

@AuraEnabled
public static void saveFile(String fileName, String base64Data, String contentType) {
    
    base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
    Blob zipBody=EncodingUtil.base64Decode(base64Data);
    Zippex zipfile = new Zippex(zipBody);
    Set <String> fileNames = zipfile.getFileNames();
    List<String> fileNameList=new List<String>();
    fileNameList.addAll(fileNames);
    system.enqueueJob(new readZipQueueable(zipFile,fileNameList));
}

@AuraEnabled
public static List<customSettingFileWrapper> getFileNames(String base64Data) {
    
    base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
    Blob zipBody=EncodingUtil.base64Decode(base64Data);
    Zippex zipfile = new Zippex(zipBody);
    List <String> fileNames = new List<String>();
    List<customSettingFileWrapper> customSettingList=new List<customSettingFileWrapper>();
    for(string fileName: zipfile.getFileNames()){
        customSettingFileWrapper customsettingWrap=new customSettingFileWrapper();
        customsettingWrap.base64Data=EncodingUtil.base64Encode(zipFile.getFile(fileName));
        customsettingWrap.name=fileName.removeEnd('.csv');
        customSettingList.add(customsettingWrap);
    }
    return customSettingList;
}  

@AuraEnabled
public static void mergeAllSettings(List<customSettingFileWrapper> settingsList){
    Zippex zipFile=new Zippex();
    List<String> fileNameList=new List<String>();
    for(customSettingFileWrapper setting:settingsList){
       if(setting.Merged!=true){
        zipFile.addFile(setting.Name + '.csv', blob.valueof(setting.base64Data), null);
        fileNameList.add(setting.Name + '.csv');
       }
       
    }
    system.enqueueJob(new readZipQueueable(zipFile,fileNameList));
}

public class customSettingFileWrapper{
    @AuraEnabled
    public Boolean Merged{get;set;}

    @AuraEnabled
    public string Name{get;set;}
    @AuraEnabled
    public string base64Data{get;set;}
}

public class returnBackup{
    @AuraEnabled
    public List<contentversion > docList{get;set;}
    @AuraEnabled
    public String downloadResourceURL{get;set;}
    @AuraEnabled
    public boolean isSizeExceeded{get;set;}
}
}
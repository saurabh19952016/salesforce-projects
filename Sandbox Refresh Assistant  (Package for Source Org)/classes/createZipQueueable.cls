public class createZipQueueable implements Queueable,Database.allowscallouts{
    private List<String> customSettingsList=new List<String>();
    private String customSetting;
    private Zippex zipFile = new Zippex();
    
    public createZipQueueable(List<String> customSettingsList,Zippex zipFile){
        this.customSettingsList=customSettingsList;
        this.zipFile=zipFile;
        this.customSetting=customSettingsList.remove(0);
    }
    
    public void execute(QueueableContext context) {
        try{
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType ObjSchema = schemaMap.get(customSetting);
            Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
            List<string> fieldNames=new List<string>();
            string query='select ';
            for (String fieldName: fieldMap.keyset()) 
            {  
                Schema.DescribeFieldResult field=fieldMap.get(fieldName).getDescribe();
                if(field.isUpdateable()){
                    fieldNames.add('"' + field.getName() + '"' );
                }
            }
            string columnHeader=string.join(fieldNames,',');
            query+=columnHeader.replaceAll('"','').removeEnd(',');
            query+=' from '+customSetting;
            system.debug(query);
            List<sobject> sobjectList=database.query(query);
            columnHeader=columnHeader.removeEnd(',')+'\n';
            string csvContent='';
            for(sobject sobj:sobjectList){
                for(string fieldName:fieldNames){
                    string value=String.valueof(sobj.get(fieldName.remove('"')));
                    
                    if(!string.isblank(value)){
                        value=value.replaceAll('"',':quotes:');
                        value=value.replaceAll(',',':comma:');
                        value='"' + value.replaceAll('(\r\n|\r)','\n') + '"';
                    }
                    else {
                        value='""';
                    }
                    
                    csvContent += value + ',';
                }
                csvContent=csvContent.removeEnd(',')+'\n';
            }
            string csvFile=columnHeader + csvContent;
            Blob fileData = Blob.valueOf(csvFile);
            zipFile.addFile(customSetting + '.csv', fileData, null);
            //Blob zipData = sampleZip.getZipArchive();
            if(customSettingsList.size()>0){
                system.enqueueJob(new createZipQueueable(customSettingsList,zipFile));
            }
            else{
                Blob zipData = zipFile.getZipArchive();
                Http http=new Http();
                HttpRequest request=new HttpRequest();
                Data_Migration_Auth__c authsetting=Data_Migration_Auth__c.getValues('refresh');
                /*ContentWorkspace cw =[SELECT Id FROM ContentWorkspace WHERE DeveloperName = :authsetting.library_name__c];
                List<contentDocument> cdList=[select Id from contentDocument where LatestPublishedVersion.recordType.Name='refresh backup'
                                              and LatestPublishedVersion.org_Name__c=:authsetting.org_name__c and title='custom settings.zip' limit 1];  
                */
                                              /* MetadataHandlerClass.authwrapper auth=new MetadataHandlerClass.authwrapper(authsetting);
MetadataHandlerClass.responseWrapper responseWrap=MetadataHandlerClass.getSessionId(auth);
*/
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('orgName',authsetting.org_name__c);
                request.setHeader('fileName', 'custom settings.zip');
                request.setHeader('libraryName',authsetting.library_name__c);
                request.setHeader('Authorization', 'Bearer {!$' + authsetting.named_credentials__c + '.OAuthToken}');
                request.setTimeOut(120000);
                request.setEndPoint('callout:' + authsetting.named_credentials__c + '/services/apexrest/saveZipFile/');
                Map<String,String> contentBodyMap=new Map<String,String>();
                contentBodyMap.put('contentBody',encodingUtil.base64Encode(zipData));
                system.debug(json.serialize(contentBodyMap));
                request.setBody(json.serialize(contentBodyMap));
                httpresponse resp=http.send(request);
                /*if(resp.getStatusCode()==200){
                    ContentVersion docVersion = new ContentVersion(
                        Title = 'custom settings.zip',
                        PathOnClient ='custom settings.zip',
                        contentLocation='S',
                        recordtypeid=schema.sobjecttype.contentversion.getRecordtypeInfosByname().get('refresh backup').getrecordtypeid(),
                        VersionData = zipData,
                        IsMajorVersion = true,
                        org_name__c=authsetting.org_name__c
                    );   
                    if(cdList.size()>0){
                        docVersion.ContentDocumentId= cdList[0].Id;
                    }
                    else{
                        docVersion.FirstPublishLocationId = cw.Id;
                    }
                    
                    insert docVersion;
                }
                else{*/
                    if(resp.getStatusCode()!=200){
                    Map<String,Object> objectMap=(Map<String,Object>)json.deserializeUntyped(resp.getBody());
                    MetadataHandlerClass.sendMail('custom setting backup failed', (String)objectMap.get('exception'));
                }
            }
        }
        catch(exception ex){
            MetadataHandlerClass.sendMail(ex.getMessage(), ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }
}
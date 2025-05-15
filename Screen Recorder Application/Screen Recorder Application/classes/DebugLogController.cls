public without sharing class DebugLogController {
    //private static String baseUrl = label.record_url + '/services/data/v46.0/tooling/';
    private static List<Id> LogIdList=new List<Id>();
    public string subject{get;set;}
    public string description{get;set;}
    public boolean disabled{get;set;}
    public string radio{get;set;}
    public List<String> instructionSet{get;set;}
    public String Note{get;set;}
    public boolean clickCapture{get;set;}
    public boolean clickRecord{get;set;}
    /* @TestVisible
private static ContentWorkspace cw =database.query(getContentWorkSpaceQuery());



public DebugLogController(){
disabled=true;
radio='record';
Custom_support_Instruction__mdt metadata=(Custom_support_Instruction__mdt)customMetadataService.getQuery('select DeveloperName,issue_in__Instructions__c,issue_in__Note__c from issue_in__Custom_support_Instruction__mdt where developerName=\'Instructions\' limit 1')[0];
instructionSet=metadata.Instructions__c.split('\n');
Note=metadata.Note__c;
}
*/
    
    private static string getContentWorkSpaceQuery(){
        string query ='SELECT Id FROM ContentWorkspace ';
        if(!test.isrunningTest()){
            query+=' WHERE DeveloperName =\'' + Screen_recorder_settings__c.getInstance('libraryName').field_value__c + '\'';
        }
        query+= ' lIMIT 1';
        return query;
    }
    
    public void checkTraceFlagAndLogs(){
        try{
            integer jobcount=[select count() from asyncapexjob where apexclass.name='logDeleteQueueable' and createdbyId=:userinfo.getuserId() and status NOT IN ('Completed','Aborted')];
            Http http = new Http();
            HttpRequest req =  new HttpRequest();
            HttpResponse res = new HttpResponse();  
            
            string endpoint=Screen_recorder_settings__c.getInstance('API_getUser_endpoint').field_Value__c;
            req.setEndpoint('callout:self_org/services/data/v46.0/tooling/query?q=select+id+from+traceflag+where+TracedEntityId=\''+userinfo.getuserid()+'\'');
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);  
            HttpResponse getTraceFlagCountResponse = http.send(req);
            List<String> traceFlagIdList=getIdFromResponse(getTraceFlagCountResponse);
            
            req.setEndpoint('callout:self_org/services/data/v46.0/tooling/query?q=select+SUM(LogLength)+from+ApexLog');
            HttpResponse getLogCountResponse = http.send(req);
            Map<String,Object> responseMap=(Map<String,Object>)json.deserializeUntyped(getLogCountResponse.getBody());
            decimal logSize;
            for(Object size:(List<object>)responseMap.get('records')){
                Map<String,Object> sizeObj=(Map<String,Object>)size;
                logSize=(decimal)sizeObj.get('expr0');
            }
            if(traceFlagIdList.size()>0 && jobcount==0){
                system.enqueueJob(new logDeleteQueueable('TraceFlag',traceFlagIdList));
                apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,label.trace_flag_deletion_notification));
            }
            if(logSize>300000000 && jobcount==0){
                getLogsForDeletion();
                apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,label.apex_log_deletion_notification));
            }
        }
        catch(exception ex){
            apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
    }
    
    
    
    private static List<String> getIdFromResponse(HttpResponse res){
        Map<String,Object> TraceFlagMap=(Map<String,Object>)json.deserializeUntyped(res.getBody());
        List<String> idList=new List<String>();
        for(Object traceFlag:(List<object>)TraceFlagMap.get('records')){
            Map<String,Object> tfObj=(Map<String,Object>)traceFlag;
            idList.add((String)tfObj.get('Id'));
        }
        system.debug(idlist);
        return idList;
    }    
    
    @RemoteAction
    public static String setTraceFlag(){
        HTTPRequest req = new HTTPRequest();
        //req.setEndpoint(baseUrl + 'sobjects/TraceFlag');
        req.setEndpoint('callout:self_org/services/data/v46.0/tooling/sobjects/TraceFlag');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer {!$self_org.OAuthToken}');
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        Map<String,String> bodyMap=new Map<String,String>();
        bodyMap.put('TracedEntityId',userinfo.getuserid());
        bodyMap.put('ExpirationDate',string.valueof(system.now().addMinutes(10).formatGMT('yyyy-MM-dd\'T\'kk:mm:ss\'Z\'')));
        bodyMap.put('StartDate',string.valueof(system.now().formatGMT('yyyy-MM-dd\'T\'kk:mm:ss\'Z\'')));
        bodyMap.put('LogType','USER_DEBUG');
        bodyMap.put('DebugLevelId',Screen_recorder_settings__c.getInstance('debugLevelId').field_value__c);
        req.setBody(json.serialize(bodyMap));
        system.debug(req.getBody());
        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug(res.getBody());
        if(res.getStatus()=='Created'){
            Map<String,Object> responseMap=(Map<String,Object>)json.deserializeUntyped(res.getBody()); 
            String TraceFlagId=(String)responseMap.get('id');
            return TraceFlagId;
        }
        return null;
    }
    
    @RemoteAction
    public static List<Id> getDebugLogs(String TraceFlagId){
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('callout:self_org/services/data/v46.0/tooling/query?q=select+id,+LogUserId,+Status+FROM+ApexLog+WHERE+LogUserId=\''+userinfo.getuserid()+'\'+AND+StartTime+=today+LIMIT+20');
        req.setHeader('Authorization', 'Bearer {!$self_org.OAuthToken}');
        //req.setEndpoint(baseUrl + 'query?q=select+id,+LogUserId,+Status+FROM+ApexLog+WHERE+LogUserId=\''+userinfo.getuserid()+'\'+AND+StartTime>' +
        //                system.now().addMinutes(-10).formatGMT('yyyy-MM-dd\'T\'kk:mm:ss\'Z\'') + '+AND+StartTime<' +system.now().formatGMT('yyyy-MM-dd\'T\'kk:mm:ss\'Z\''));
        req.setMethod('GET');
        // OAuth header
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        Http h = new Http();
        HttpResponse res = h.send(req);
        List<String> logIdList=getIdFromResponse(res);
        system.debug(LogIdList);
        deleteTraceFlag(TraceFlagId);
        return LogIdList;
    }
    
    public static void deleteTraceFlag(String TraceFlagId){
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('callout:self_org/services/data/v46.0/tooling/sobjects/TraceFlag/'+TraceFlagId);
        //req.setEndpoint(baseUrl + 'sobjects/TraceFlag/'+TraceFlagId);
        req.setMethod('DELETE');
        // OAuth header
        req.setHeader('Authorization', 'Bearer {!$self_org.OAuthToken}');
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        Http h = new Http();
        HttpResponse res = h.send(req);
    }
    
    @RemoteAction
    public static void getLogBody(String LogId){
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('callout:self_org/services/data/v46.0/tooling/sobjects/ApexLog/'+LogId + '/Body/');
        req.setHeader('Authorization', 'Bearer {!$self_org.OAuthToken}');
        //req.setEndpoint(baseUrl + 'sobjects/ApexLog/'+LogId + '/Body/');
        req.setMethod('GET');
        // OAuth header
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'text/plain');
        Http h = new Http();
        HttpResponse res = h.send(req);
        //system.debug(res.getBody());
        Object Body;
        if(test.isRunningTest()){
            Body='test';
        }
        else{
            Body= json.deserializeUntyped(res.getBody());
        }
        system.debug(res.getBodyAsBlob());
        system.debug(res.toString());
        ContentVersion docVersion = new ContentVersion(
            Title = userinfo.getName() + '.txt',
            PathOnClient =userinfo.getName() + '.txt',
            contentLocation='S',
            //FirstPublishLocationId = cw.Id,
            VersionData = res.getBodyAsBlob(),
            IsMajorVersion = false
        );        
        req.setEndpoint('callout:self_org/services/data/v46.0/tooling/sobjects/ApexLog/'+LogId);
        req.setMethod('DELETE');
        res=h.send(req);
        insert docVersion;     
        /* Document d = new Document(); 
d.Name = userinfo.getName(); 
d.Body = res.getBodyAsBlob(); 
d.folderId='00l3C000000QuCD';
d.ContentType = 'text/plain';
d.Type = 'txt';
insert d;*/
    }
    
    @RemoteAction
    public static String doUploadAttachment( String attachmentBody, String attachmentName, String attachmentId) {
        
        if(attachmentBody != null) {
            ContentVersion content = getDocument(attachmentId);
            String newBody = '';
            if(content.VersionData != null) {
                newBody = EncodingUtil.base64Encode(content.VersionData);
            }
            newBody += attachmentBody;
            content.VersionData = EncodingUtil.base64Decode(newBody);
            /*  if(!test.isrunningTest())

{
content.FirstPublishLocationId=cw.id;
}*/
            if(attachmentId == null) {
                content.Title = userinfo.getName()+ ' ' +system.today();
                content.PathOnClient = attachmentName;
                content.contentLocation='S';
                content.IsMajorVersion = false;
            }
            upsert content;
            return content.Id;
        } else {
            return 'Attachment Body was null';
        }
    }
    
    
    
    private static ContentVersion getDocument(String docId) {
        list<ContentVersion> contentVersions = [SELECT Id, versionData,title,pathonClient
                                                FROM ContentVersion 
                                                WHERE Id =: docId];
        if(contentVersions.isEmpty()) {
            ContentVersion a = new ContentVersion();
            return a;
        } else {
            return ContentVersions[0];
        }
    }
    
    public void  sendToSnow(){ 
        try{
            
            if(!string.isblank(description) && !string.isblank(Subject)){
                Http http = new Http();
                HttpRequest req =  new HttpRequest();
                HttpResponse res = new HttpResponse();  
                Map<String, object> JsonMap = new Map<String, Object>();
                Map<String, object> JsonMap2 = new Map<String, Object>();
                
                string files= 'Log File links below:\n' ;
                string username=userinfo.getName();
                string query='select id,Title,fileType from ContentVersion where createdbyId=\'' + userinfo.getuserid() + '\' and createddate>= '+system.now().addMinutes(-10).formatGMT('yyyy-MM-dd\'T\'kk:mm:ss\'Z\'')  
                    +' and createddate <' + system.now().formatGMT('yyyy-MM-dd\'T\'kk:mm:ss\'Z\'') +' and title LIKE \''+username+'%\' order by fileType desc';
                List<ContentVersion> contentVersionList=database.query(query);
                List<Id> docIdList=new List<Id>();
                for(ContentVersion cv: contentVersionList){
                    docIdList.add(cv.id);
                    if(cv.Title.contains('.txt')){
                        files+=URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + cv.Id + '\n';
                    }     
                    else{
                        files+='\nVideo File link below:\n';
                        files+=URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + cv.Id + '\n';
                    }
                }
                string endpoint=Screen_recorder_settings__c.getInstance('API_creation_endpoint').field_Value__c;
                string fileStorageField=Screen_recorder_settings__c.getInstance('API_comments').field_value__c;
                string callerField= Screen_recorder_settings__c.getInstance('API_Caller_Id_Field').field_value__c;
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');            
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();  
                user currentUser=database.query('select id,' + Screen_recorder_settings__c.getInstance('targetEnvUserMappingField').field_value__c + ' from user where id=\'' + userinfo.getuserId()+'\'');
                gen.writeStringField(callerField,(String)currentUser.get(Screen_recorder_settings__c.getInstance('targetEnvUserMappingField').field_value__c)); 
                if(contentVersionList.isEmpty()==false){
                    gen.writeStringField(fileStorageField,files); 
                    
                }
                
                List<Screen_recorder_settings__c> screenRecorderAPIPredefined=[select name,field_value__c from Screen_recorder_settings__c where isapi__c=true];
                for(Screen_recorder_settings__c predef:screenRecorderAPIPredefined){
                    system.debug(predef);
                    gen.writeStringField(predef.Name.remove('API_'),predef.field_value__c);
                }
                string recordVidLimitNote=Screen_recorder_settings__c.getInstance('recorded_video_alert_note').field_Value__c;
                gen.writeStringField(Screen_recorder_settings__c.getInstance('FLDVF_description_field').field_Value__c,description + '\n'+recordVidLimitNote);
                gen.writeStringField(Screen_recorder_settings__c.getInstance('FLDVF_default_group_field').field_Value__c,Screen_recorder_settings__c.getInstance('API_default_group').field_Value__c);
                
                gen.writeStringField(Screen_recorder_settings__c.getInstance('FLDVF_subject_field').field_Value__c,subject);
                gen.writeEndObject(); 
                String jsonBody = gen.getAsString();  
                system.debug(jsonBody);
                req.setTimeout(120000);
                req.setBody(jsonBody);
                res = http.send(req);            
                system.debug('response ' + res.getBody());
                if(res.getStatusCode()>=200 && res.getStatusCode()<205){
                    if(res.getBody().startsWith('<html>'))
                    {
                        apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please refresh the instance.'));
                        
                    }
                    else{
                        string incidentNumber;
                        if(docIdList.size()>0){
                        ContentDocumentHelper.createContentDocLink(docIdList,Screen_recorder_settings__c.getInstance('chatter_group').field_value__c);
                            
                        }
                        JSONParser parser = JSON.createParser(res.getBody());
                        string incidentNumberToken=Screen_recorder_settings__c.getInstance('API_incidentNumber').field_Value__c;
                        while (parser.nextToken() != null) {
                            system.debug(parser.getCurrentName());
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getCurrentName() == incidentNumberToken)) {
                                
                                parser.nextToken();
                                incidentNumber=parser.getText();   
                                break;
                            }
                        }
                        apexpages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'SNOW ticket ' + incidentNumber + ' created successfully'));
                    }
                }
            }
            else{
                if(string.isBlank(description)){
                    apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill case description.'));
                }
                if(string.isblank(subject)){
                    apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill case subject.'));
                }
                
            }
        }
        catch(exception ex){
            apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
    }
    
    @future(callout=true)
    private static void getLogsForDeletion(){
        Http http = new Http();
        HttpRequest req =  new HttpRequest();
        HttpResponse res = new HttpResponse();  
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint('callout:self_org/services/data/v46.0/tooling/query?q=select+Id+from+ApexLog');
        req.setTimeout(120000);
        httpresponse resp2=http.send(req);
        List<String> LogIdList=getIdFromResponse(resp2);
        system.enqueueJob(new logDeleteQueueable('ApexLog',logIdList));
    }
}
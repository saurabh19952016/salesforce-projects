public without sharing class screenRecorderChatController {
    //@TestVisible
   // private static ContentWorkspace cw =database.query(getContentWorkSpaceQuery());
     @TestVisible
    private static object continuationstate;
    
   /* private static string getContentWorkSpaceQuery(){
        string query ='SELECT Id FROM ContentWorkspace ';
        if(!test.isrunningTest()){
           query+=' WHERE DeveloperName =\'' + Screen_recorder_settings__c.getInstance('libraryName').field_value__c + '\'';
         }
        query+= ' lIMIT 1';
        return query;
    }*/
    
    @AuraEnabled(continuation=true cacheable=true)
    public static object startRequest(){
        customMetaWrapper returnWrapper=new customMetaWrapper();
        try{
            returnWrapper.metaList= (List<Custom_support_Instruction__mdt>)customMetadataService.getQuery('select id,issue_in__Instructions__c,issue_in__radio__c,issue_in__searchbox__c,issue_in__Capture__c,issue_in__Note__c,issue_in__order__c,issue_in__fieldName__c from issue_in__Custom_support_Instruction__mdt where MasterLabel!=\'Instructions\' order by order__c ASC');
            returnWrapper.currentUser=database.query('select id,name,' +Screen_recorder_settings__c.getInstance('targetEnvUserMappingField').field_value__c + 
                                                     ' from user where id=\'' + userinfo.getUserId()  + '\' limit 1');          
            Http http = new Http();
            HttpRequest req =  new HttpRequest();
            HttpResponse res = new HttpResponse();  
            
            string endpoint=Screen_recorder_settings__c.getInstance('API_getUser_endpoint').field_Value__c;
            req.setEndpoint('callout:self_org/services/data/v46.0/tooling/query?q=select+id+from+traceflag+where+TracedEntityId=\''+userinfo.getuserid()+'\'');
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            
            Continuation con = new Continuation(120);
            con.continuationMethod='processResponse';
            // Add callout request to continuation
            con.state=returnWrapper;
            con.addHttpRequest(req); 
            boolean isTargetConfigured=false;
           
              req.setEndpoint('callout:self_org/services/data/v46.0/tooling/query?q=select+SUM(LogLength)+from+ApexLog');                
            con.addHttpRequest(req);
             for(Custom_support_Instruction__mdt ins:returnWrapper.metaList){
                if(ins.Radio__c==true && ins.fieldName__c.containsIgnoreCase('Target')){
                    isTargetConfigured=true;
                }
            }
            system.debug(isTargetConfigured);
            if(isTargetConfigured==true){
            req.setEndpoint(endpoint.replace('{!userId}',
           (String)returnWrapper.currentUser.get(Screen_recorder_settings__c.getInstance('targetEnvUserMappingField').field_value__c)));
            con.addHttpRequest(req); 
            }
            continuationstate=returnWrapper;
            system.debug('Continuation '+ con.getRequests());
            return con;
        }
        catch(exception ex){
            throw createAuraHandledException( ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static object processResponse(List<String> labels, Object state) {
        // Get the response by using the unique label
        customMetaWrapper returnWrapper=(customMetaWrapper)state;
        try{
            integer jobcount=[select count() from asyncapexjob where apexclass.name='logDeleteQueueable' and createdbyId=:userinfo.getuserId() and status NOT IN ('Completed','Aborted')];
            HttpResponse getTraceFlagCountResponse = Continuation.getResponse(labels[0]);
            List<String> traceFlagIdList=getIdFromResponse(getTraceFlagCountResponse);
            system.debug(traceFlagIdList.size());
            HttpResponse getLogCountResponse = Continuation.getResponse(labels[1]);
             system.debug(getLogCountResponse.getbody());
           Map<String,Object> responseMap=(Map<String,Object>)json.deserializeUntyped(getLogCountResponse.getBody());
            decimal logSize;
            for(Object size:(List<object>)responseMap.get('records')){
                    Map<String,Object> sizeObj=(Map<String,Object>)size;
                    logSize=(decimal)sizeObj.get('expr0');
            }
            system.debug(logSize);
            string errormessage;
            if(traceFlagIdList!=null && traceFlagIdList.size()==0 && logSize<300000000 && labels.size()>2){
                HttpResponse getDetailsResponse = Continuation.getResponse(labels[2]);
                string caller_Id;   
                if(getDetailsResponse.getStatusCode()>=200 && getDetailsResponse.getStatusCode()<205){
                    if(getDetailsResponse.getBody().startsWith('<html>'))
                    {
                        throw createAuraHandledException('Please refresh the Instance');
                    }
                    else{
                        
                        JSONParser parser = JSON.createParser(getDetailsResponse.getBody());
                        system.debug('parser--'+parser);
                        string userIdFieldToken=Screen_recorder_settings__c.getInstance('API_user_Id').field_Value__c;  
                        while (parser.nextToken() != null) {
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getCurrentName() == userIdFieldToken)) {
                                
                                parser.nextToken();
                                caller_id=parser.getText(); 
                                system.debug('Caller ID from SNOW '+caller_id);
                                break;
                            }
                        }
                        returnWrapper.targetId=caller_id;
                    }
                }
                else{
                    throw createAuraHandledException('ERROR getting user records.');
                }  
            }

            if(logSize>300000000 && jobcount==0){
                            returnWrapper.islogDeletion=true;                
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
            if(traceFlagIdList.size()>0){
                returnWrapper.isTraceFlagDeletion=true;
                if(jobcount==0){
                    system.enqueueJob(new logDeleteQueueable('TraceFlag',traceFlagIdList));
                }
            }
            return returnWrapper;
        }
        catch(exception ex){
            throw createAuraHandledException( ex.getMessage());
        }
    }
    
    private static List<String> getIdFromResponse(HttpResponse res){
        system.debug(res.getBody());
        Map<String,Object> TraceFlagMap=(Map<String,Object>)json.deserializeUntyped(res.getBody());
        List<String> idList=new List<String>();
        for(Object traceFlag:(List<object>)TraceFlagMap.get('records')){
            Map<String,Object> tfObj=(Map<String,Object>)traceFlag;
            idList.add((String)tfObj.get('Id'));
        }
        system.debug(idlist);
        return idList;
    }
    
    @AuraEnabled
    public static string setTraceFlag(){
        
        HTTPRequest req = new HTTPRequest();
        //req.setEndpoint(baseUrl + 'sobjects/TraceFlag');
        req.setEndpoint('callout:self_org/services/data/v46.0/tooling/sobjects/TraceFlag');
        req.setMethod('POST');
        req.setHeader('Authorization','Bearer {!$self_org.OAuthToken}');
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
        return res.getbody();
    }
    
    
    
    @AuraEnabled
    public static List<String> getDebugLogs(String TraceFlagId){
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('callout:self_org/services/data/v46.0/tooling/query?q=select+id,+LogUserId,+Status+FROM+ApexLog+WHERE+LogUserId=\''+userinfo.getuserid()+'\'+AND+StartTime+=today+LIMIT+20');
        req.setHeader('Authorization', 'Bearer {!$self_org.OAuthToken}');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        Http h = new Http();
        HttpResponse res = h.send(req);
        List<String> logIdList=getIdFromResponse(res);
        
        deleteTraceFlag(TraceFlagId);
        return LogIdList;
    }
    
    public static void deleteTraceFlag(String TraceFlagId){
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('callout:self_org/services/data/v46.0/tooling/sobjects/TraceFlag/'+TraceFlagId);
        req.setMethod('DELETE');
        // OAuth header
        req.setHeader('Authorization', 'Bearer {!$self_org.OAuthToken}');
        req.setHeader('Content-Type', 'application/json');
        Http h = new Http();
        HttpResponse res = h.send(req);
    }
    
    public static void deleteLog(string logId){
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('callout:self_org/services/data/v46.0/tooling/sobjects/ApexLog/'+LogId);
        req.setHeader('Authorization', 'Bearer {!$self_org.OAuthToken}');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('DELETE');
        Http h = new Http();
        HttpResponse res=h.send(req);
    }
    
    @AuraEnabled
    public static Id getLogBody(String LogId){
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('callout:self_org/services/data/v46.0/tooling/sobjects/ApexLog/'+LogId + '/Body/');
        req.setHeader('Authorization', 'Bearer {!$self_org.OAuthToken}');
        req.setMethod('GET');
        req.setTimeOut(120000);
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
        deleteLog(logId);
        insert docVersion;
        return docVersion.Id;
    }
    
    
    @AuraEnabled
    public static Id saveChunk(String fileName, String base64Data, String contentType, String fileId) {
        
        if (fileId == '') {
            fileId = saveTheFile(fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(String fileName, String base64Data, String contentType) {
        try{
            
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            ContentVersion content = new ContentVersion();
            content.VersionData = EncodingUtil.base64Decode(base64Data);
         /*   if(!test.isrunningTest())
            {
                content.FirstPublishLocationId=cw.id;
            }*/
            content.Title = userinfo.getName()+ ' ' +system.today();
            content.PathOnClient = fileName;
            content.contentLocation='S';
            content.IsMajorVersion = false;
            insert content;
            return content.Id;
        }
        catch(exception ex){
            throw createAuraHandledException(ex.getMessage());
        }
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion contentVersion = [SELECT Id, versionData,title,pathonClient
                                         FROM ContentVersion 
                                         WHERE Id =: fileId];
        String existingBody = EncodingUtil.base64Encode(contentVersion.versionData);
        
        contentVersion.versionData = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update contentVersion;
    }
    
    @AuraEnabled
    public static string createCase(Map<String,string> responseMap,List<string> docIdList){ 
        try{
            sobject newCase=schema.getGlobalDescribe().get('Case').newSObject();    
            List<Screen_recorder_settings__c> screenRecorderAPIPredefined=[select name,field_value__c from Screen_recorder_settings__c where isSfdc__c=true];
            for(Screen_recorder_settings__c predef:screenRecorderAPIPredefined){
                newCase.put(predef.name,predef.field_value__c);
            }
            string recordVidLimitNoteField=Screen_recorder_settings__c.getInstance('recordedVidAlertSFDC_FieldName').field_Value__c;
            string recordVidLimitNote=Screen_recorder_settings__c.getInstance('recorded_video_alert_note').field_Value__c;
            for(string key:responseMap.keyset()){
                List<String> keylist=key.split(';');
                if(recordVidLimitNoteField==keylist[0]){
                    newCase.put(keylist[0],responseMap.get(key) +'\n' + recordVidLimitNote);
                }
                else{
                    newCase.put(keylist[0],responseMap.get(key));
                    
                }
            }
            
            insert newCase;
           /* List<ContentDocumentLink> contentDocLinkList=new List<ContentDocumentLink>();
            List<Id> contentDocumentIdList=new List<Id>();
            for(ContentVersion conversion:[select id,contentdocumentId from ContentVersion where Id in :docIdList]){
                contentDocumentIdList.add(conversion.contentdocumentId);
            }
            for(Contentdocument conDoc:[select id from Contentdocument where Id in :contentDocumentIdList]){
                contentDocLinkList.add(new ContentDocumentLink(ContentDocumentId=conDoc.id,
                                                               linkedEntityId=newCase.Id));
            }
            insert contentDocLinkList;*/
            if(docIdList.size()>0){
               ContentDocumentHelper.createContentDocLink(docIdList,Screen_recorder_settings__c.getInstance('chatter_group').field_value__c);
            }
            ContentDocumentHelper.createContentDocLink(docIdList,newCase.Id);
         return [select casenumber from case where id=:newCase.id].casenumber;
        }
        catch(exception ex){
            throw createAuraHandledException( ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static string sendToSnow(Map<String,string> responseMap,List<string> docIdList,string targetId){ 
        system.debug(responseMap);
        try{
            Http http = new Http();
            HttpRequest req =  new HttpRequest();
            HttpResponse res = new HttpResponse();  
            Map<String, object> JsonMap = new Map<String, Object>();
            Map<String, object> JsonMap2 = new Map<String, Object>();
            
            string files= 'Log File links below:\n' ;
            string query='select id,Title,fileType from ContentVersion where Id in :docIdList order by fileType desc';
            List<ContentVersion> contentVersionList=database.query(query);
            for(ContentVersion cv: contentVersionList){
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
            system.debug('callerField--'+callerField+'--targetId'+targetId); 
            gen.writeStringField(callerField,targetId);
            if(docIdList.isEmpty()==false){
                system.debug('fileStorageField--'+fileStorageField+'--files'+files); 
                gen.writeStringField(fileStorageField,files); 
               
            }
            
            List<Screen_recorder_settings__c> screenRecorderAPIPredefined=[select name,field_value__c from Screen_recorder_settings__c where isapi__c=true];
            for(Screen_recorder_settings__c predef:screenRecorderAPIPredefined){
                system.debug('376--'+predef);
                 system.debug('predef.Name'+predef.Name+'--predef.field_value__c');
                gen.writeStringField(predef.Name.remove('API_'),predef.field_value__c);
            }
            string recordVidLimitNoteField=Screen_recorder_settings__c.getInstance('recordedVidAlertTarget_FieldName').field_Value__c;
            string recordVidLimitNote=Screen_recorder_settings__c.getInstance('recorded_video_alert_note').field_Value__c;
                        List<Screen_recorder_settings__c> grpID=[select name,field_value__c from Screen_recorder_settings__c where name='API_default_group'];

            for(string key:responseMap.keyset()){
                system.debug(key);
                
                List<String> keylist=key.split(';');
                 system.debug(keylist[1]);

       /*         if(grpID!=null && grpID[0].field_value__c!=null){
              //   Screen_recorder_settings__c grpID=[select name,field_value__c from Screen_recorder_settings__c where name='API_default_group'];

                    system.debug('key matched'+grpID[0].field_value__c);
                    gen.writeStringField('assignment_group',grpID[0].field_value__c);
                }*/
                if(recordVidLimitNoteField==keylist[1]){
                    system.debug('keylist[1]--'+keylist[1]+'--val--'+responseMap.get(key)  +'\n' + recordVidLimitNote);
                    gen.writeStringField(keylist[1],responseMap.get(key)  +'\n' + recordVidLimitNote);
                    
                }
                else{
                system.debug('keylist[1]--'+keylist[1]+'--val--'+responseMap.get(key));
                    gen.writeStringField(keylist[1],responseMap.get(key));
                }
            }
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
                    throw createAuraHandledException( 'Please refresh the Instance');
                    
                }
                else{
                       if(docIdList.size()>0){
                        ContentDocumentHelper.createContentDocLink(docIdList,Screen_recorder_settings__c.getInstance('chatter_group').field_value__c);
                            
                        }
                    string incidentNumber;
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
                    return incidentNumber;
                }
            }
            else{
                throw createAuraHandledException( 'ERROR creating ticket.');
                
            }
        }
        catch(exception ex){
            throw createAuraHandledException( ex.getMessage());
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RemoteSiteWrapper> sendToSnowGetGroup(){
        try{
            List<RemoteSiteWrapper> RemoteSiteWrapperList=new List<RemoteSiteWrapper>();
            Http http = new Http();
            HttpRequest req =  new HttpRequest();
            HttpResponse res = new HttpResponse();            
            string endpoint=Screen_recorder_settings__c.getInstance('API_getGroup_endpoint').field_Value__c;
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');            
            req.setTimeout(120000);            
            res = http.send(req); 
            
            if(res.getStatusCode()>=200 && res.getStatusCode()<205){
                if(res.getBody().startsWith('<html>'))
                {
                    throw createAuraHandledException( 'Please refresh the Instance');
                    
                }
                else{
                    
                    string incidentNumber;
                    system.debug(res.getBody());
                    JSONParser parser = JSON.createParser(res.getBody());
                    string groupNameToken=Screen_recorder_settings__c.getInstance('API_group_name').field_Value__c;
                    string groupIdToken=Screen_recorder_settings__c.getInstance('API_group_Id').field_Value__c;
                    RemoteSiteWrapper wrapper1=new RemoteSiteWrapper();
                    wrapper1.value=Screen_recorder_settings__c.getInstance('API_default_group').field_Value__c;
                    wrapper1.name='Default';
                    RemoteSiteWrapperList.add(wrapper1);
                    while (parser.nextToken() != null) {
                        // Start at the array of invoices.
                        RemoteSiteWrapper wrapper=new RemoteSiteWrapper();
                             system.debug(parser.getCurrentName() );
                       
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getCurrentName() == groupNameToken || parser.getCurrentName() == groupIdToken)) {
                            if(parser.getCurrentName() == groupNameToken){
                                parser.nextToken();
                                wrapper.name=parser.getText();
                                parser.nextToken();
                                parser.nextToken();
                                wrapper.value=parser.getText();
                            }
                            else if(parser.getCurrentName() == groupIdToken){
                                parser.nextToken();
                                wrapper.value=parser.getText();
                                parser.nextToken();
                                parser.nextToken();
                                wrapper.name=parser.getText();
                                RemoteSiteWrapperList.add(wrapper);
                            }
                        }
                    }
                    return RemoteSiteWrapperList;
                    
                }
            }
            else{
                throw createAuraHandledException( 'ERROR getting Group records');
            }
        }
        catch(exception ex){
            throw createAuraHandledException( ex.getMessage());
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RemoteSiteWrapper> createCaseGetGroup(){
        List<RemoteSiteWrapper> RemoteSiteWrapperList=new List<RemoteSiteWrapper>();
        RemoteSiteWrapper wrapper1=new RemoteSiteWrapper();
        wrapper1.value=Screen_recorder_settings__c.getInstance('Salesforce_default_group').field_Value__c;
        wrapper1.name='Default';
        RemoteSiteWrapperList.add(wrapper1);
        for(QueueSobject qsObject:[SELECT QueueId, Queue.Name, SobjectType FROM QueueSobject WHERE SobjectType = 'Case']){
            RemoteSiteWrapperList.add(new RemoteSiteWrapper(qsObject.queue.name,qsobject.queueId));
        }
        return RemoteSiteWrapperList;
    }
    
    
    private static AuraHandledException createAuraHandledException(String Message){
        AuraHandledException e = new AuraHandledException(Message);
        e.setMessage(Message);
        return e; 
    }
    
    public class RemoteSiteWrapper{
        @AuraEnabled
        public string Name{get;set;}
        @AuraEnabled
        public string Value{get;set;}
        public RemoteSiteWrapper(){}
        public RemoteSiteWrapper(string name,string value){
            this.name=name;
            this.value=value;
        }
    }
    
  
    
    public class customMetaWrapper{
        @AuraEnabled
        public List<Custom_support_Instruction__mdt> metaList{get;set;}
        @AuraEnabled
        public sObject currentUser{get;set;}
        @AuraEnabled
        public string targetId{get;set;}
        @AuraEnabled
        public boolean isTraceFlagDeletion{get;set;}
        @AuraEnabled
        public boolean isLogDeletion{get;set;}
    }
    
 
}
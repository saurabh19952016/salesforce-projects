//Covers screenRecorderChatController, logDeleteQueueable, clearRecorderDataBatch apex classes
@istest
public class screenRecorderChatControllerTest {
    
    @testsetup
    private static void testsetup(){
        List<Screen_recorder_settings__c> srsList=new List<Screen_recorder_settings__c>();
        srsList.add(new Screen_recorder_settings__c(name='API_Caller_Id_Field',field_value__c='calId'));
        srsList.add(new Screen_recorder_settings__c(name='API_comments',field_value__c='testComments'));
        srsList.add(new Screen_recorder_settings__c(name='API_creation_endpoint',field_value__c='callout:endpoint/create'));
        srsList.add(new Screen_recorder_settings__c(name='API_default_group',field_value__c='defGroup'));
        srsList.add(new Screen_recorder_settings__c(name='API_getGroup_endpoint',field_value__c='callout:endpoint/getGroup'));
        srsList.add(new Screen_recorder_settings__c(name='API_getUser_endpoint',field_value__c='callout:endpoint/getUser/{!userId}'));
        srsList.add(new Screen_recorder_settings__c(name='API_group_Id',field_value__c='groupId'));
        srsList.add(new Screen_recorder_settings__c(name='API_group_name',field_value__c='groupName'));
        srsList.add(new Screen_recorder_settings__c(name='API_incidentNumber',field_value__c='incNumber'));
        srsList.add(new Screen_recorder_settings__c(name='API_user_Id',field_value__c='userId'));
        srsList.add(new Screen_recorder_settings__c(name='debugLevelId',field_value__c=userinfo.getuserId()));
        srsList.add(new Screen_recorder_settings__c(name='file_deletion_Interval',field_value__c='0'));
        srsList.add(new Screen_recorder_settings__c(name='libraryName',field_value__c='scrRecorder'));
        srsList.add(new Screen_recorder_settings__c(name='recordedVidAlertSFDC_FieldName',field_value__c='subject'));
        srsList.add(new Screen_recorder_settings__c(name='recordedVidAlertTarget_FieldName',field_value__c='desc'));
        srsList.add(new Screen_recorder_settings__c(name='recorded_video_alert_note',field_value__c='deletes after 2 weeks'));
        srsList.add(new Screen_recorder_settings__c(name='Salesforce_default_group',field_value__c='defGroup'));
        srsList.add(new Screen_recorder_settings__c(name='targetEnvUserMappingField',field_value__c='username'));
        srsList.add(new Screen_recorder_settings__c(name='FLDVF_description_field',field_value__c='description'));
        srsList.add(new Screen_recorder_settings__c(name='FLDVF_subject_field',field_value__c='subject'));
        srsList.add(new Screen_recorder_settings__c(name='defaultType',field_value__c='support',isApi__c=true));
        srsList.add(new Screen_recorder_settings__c(name='subject',field_value__c='phone',isSFDC__c=true));
        insert srsList;
        insert new ContentVersion(
            Title = userinfo.getName() + '.txt',
            PathOnClient =userinfo.getName() + '.txt',
            contentLocation='S',
            FirstPublishLocationId = screenRecorderChatController.cw.Id,
            VersionData = blob.valueof('test'),
            IsMajorVersion = false
        );  
        insert new ContentVersion(
            Title = userinfo.getName() + ' ' + system.today(),
            PathOnClient =userinfo.getName() + ' ' + system.today(),
            contentLocation='S',
            FirstPublishLocationId = screenRecorderChatController.cw.Id,
            VersionData = blob.valueof('test'),
            IsMajorVersion = false
        );  
    }
    
    @isTest    
    private static void screenRecorderContinuationTest1(){
        Custom_support_Instruction__mdt cSI_mdt=new Custom_support_Instruction__mdt(Instructions__c='test',Note__c='test',radio__c=true);
        customMetadataService.bigObjectQueryMap.put('select DeveloperName,Instructions__c,Note__c from Custom_support_Instruction__mdt where developerName=\'Instructions\' limit 1',
                                                    new List<Custom_support_Instruction__mdt>{cSI_mdt});
        Test.setMock(HttpCalloutMock.class, new DebugLogControllerMock());
        logDeleteQueueable.isSkipTest=true;
        test.starttest();
        
        continuation conti=(Continuation)screenRecorderChatController.startRequest();
        Map<String,HttpRequest> requests=conti.getRequests();
        List<String> keylist=new List<String>();
        keylist.addAll(requests.keyset());
        system.debug(requests);
        system.assert(requests.size() == 3); 
        DebugLogControllerMock mock=new DebugLogControllerMock();
        HttpRequest req1=requests.get(keylist[0]);
        req1.setEndpoint('callout:self_org/services/data/v46.0/tooling/query?q=select+id+from+traceflag+where+TracedEntityId=\''+userinfo.getuserid()+'\'');
        HttpResponse response1 =mock.respond(req1);
        Test.setContinuationResponse('Continuation-1', response1);
        HttpRequest req2=requests.get(keylist[1]);
        req2.setEndpoint('callout:self_org/services/data/v46.0/tooling/query?q=select+SUM(LogLength)+from+ApexLog');
        HttpResponse response2a =mock.respond(req2);
        Test.setContinuationResponse('Continuation-2', response2a);
        HttpRequest req3=requests.get(keylist[2]);
        screenRecorderChatController.customMetaWrapper returnWrapper =(screenRecorderChatController.customMetaWrapper)screenRecorderChatController.continuationstate;
        req3.setEndpoint(Screen_recorder_settings__c.getInstance('API_getUser_endpoint').field_Value__c.replace('{!userId}',
                                                                                                                (String)returnWrapper.currentUser.get(Screen_recorder_settings__c.getInstance('targetEnvUserMappingField').field_value__c)));
        HttpResponse response3a =mock.respond(req3);
        Test.setContinuationResponse('Continuation-3', response3a);
        screenRecorderChatController.processResponse(keylist,screenRecorderChatController.continuationstate);
        test.stoptest();
    }
    
    @isTest    
    private static void screenRecorderContinuationTest2(){
        Custom_support_Instruction__mdt cSI_mdt=new Custom_support_Instruction__mdt(Instructions__c='test',Note__c='test',radio__c=true);
        customMetadataService.bigObjectQueryMap.put('select DeveloperName,Instructions__c,Note__c from Custom_support_Instruction__mdt where developerName=\'Instructions\' limit 1',
                                                    new List<Custom_support_Instruction__mdt>{cSI_mdt});
        Test.setMock(HttpCalloutMock.class, new DebugLogControllerMock());
        logDeleteQueueable.isSkipTest=true;
        test.starttest();
        
        continuation conti=(Continuation)screenRecorderChatController.startRequest();
        Map<String,HttpRequest> requests=conti.getRequests();
        List<String> keylist=new List<String>();
        keylist.addAll(requests.keyset());
        system.debug(requests);
        system.assert(requests.size() == 3); 
        DebugLogControllerMock mock=new DebugLogControllerMock();
        HttpRequest req1=requests.get(keylist[0]);
        req1.setEndpoint('callout:self_org/services/data/v46.0/tooling/query?q=select+id+from+traceflag+where+TracedEntityId=\''+userinfo.getuserid()+'\'');
        HttpResponse response1b=new httpresponse();
        response1b.setHeader('Content-Type', 'text/plain');
        response1b.setBody('{"records":[]}');
        response1b.setStatusCode(200); 
        Test.setContinuationResponse('Continuation-4', response1b);
        HttpRequest req2=requests.get(keylist[0]);
        req2.setEndpoint('callout:self_org/services/data/v46.0/tooling/query?q=select+SUM(LogLength)+from+ApexLog');
        HttpResponse response2b =new httpresponse();
        response2b.setHeader('Content-Type', 'text/plain');
        response2b.setBody('{"records":[{"expr0":80}]}');
        response2b.setStatusCode(200); 
        Test.setContinuationResponse('Continuation-5', response2b); 
        HttpRequest req3=requests.get(keylist[0]);
        screenRecorderChatController.customMetaWrapper returnWrapper =(screenRecorderChatController.customMetaWrapper)screenRecorderChatController.continuationstate;
        req3.setEndpoint(Screen_recorder_settings__c.getInstance('API_getUser_endpoint').field_Value__c.replace('{!userId}',
                                                                                                                (String)returnWrapper.currentUser.get(Screen_recorder_settings__c.getInstance('targetEnvUserMappingField').field_value__c)));
        HttpResponse response3b =new httpresponse();
        response3b.setHeader('Content-Type', 'text/plain');
        response3b.setBody('{"'+Screen_recorder_settings__c.getInstance('API_user_Id').field_value__c+'":"'+userinfo.getuserId()+'"}');
        response3b.setStatusCode(200); 
        Test.setContinuationResponse('Continuation-6', response3b);    
        screenRecorderChatController.processResponse(keylist,screenRecorderChatController.continuationstate);
        test.stoptest();
    }
    
    @isTest
    private static void screenRecorderChatControllerTest(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DebugLogControllerMock());
        String traceFlagId=screenRecorderChatController.setTraceFlag();
        List<String> logIdList=screenRecorderChatController.getdebugLogs(traceFlagId);
        screenRecorderChatController.getLogBody(logIdList[0]); 
        
		string fileId=screenRecorderChatController.saveChunk('test file',
                                               encodingutil.urlencode(encodingutil.base64Encode(blob.valueOf('testdata')),'UTF-8'),
                                               'txt',
                                               ''
                                              );
        fileId=screenRecorderChatController.saveChunk('test file',
                                               encodingutil.urlencode(encodingutil.base64Encode(blob.valueOf('testdata')),'UTF-8'),
                                               'txt',
                                               fileId
                                              );
        test.stoptest();
    }
    
        @isTest
    private static void screenRecorderChatCaseTest(){
        test.startTest();
        List<screenRecorderChatController.RemoteSiteWrapper> wrapperList=screenRecorderChatController.createCaseGetGroup();
        Map<String,string> requestMap=new Map<String,string>();
        for(Screen_recorder_settings__c setting:[select name,field_value__c from Screen_recorder_settings__c where issfdc__c=true limit 1]){
            requestMap.put(setting.name+';test;',setting.field_value__c);
        }
        List<id> contentVersionIdList=new List<Id>();
        for(contentVersion contVer:[select id from contentVersion]){
            contentVersionIdList.add(contVer.id);
        }
        string caseId=screenRecorderChatController.createCase(requestMap,contentVersionIdList,[select id from user limit 1]);
        test.stoptest();
    }
    
    @isTest
    private static void screenRecorderChatSnowTest(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new DebugLogControllerMock());
        List<screenRecorderChatController.RemoteSiteWrapper> wrapperList=screenRecorderChatController.sendToSnowGetGroup();
        Map<String,string> requestMap=new Map<String,string>();
        for(Screen_recorder_settings__c setting:[select name,field_value__c from Screen_recorder_settings__c where isApi__c=true limit 1]){
            requestMap.put('test;'+setting.name+';',setting.field_value__c);
        }
        List<id> contentVersionIdList=new List<Id>();
        for(contentVersion contVer:[select id from contentVersion]){
            contentVersionIdList.add(contVer.id);
        }
        string snowId=screenRecorderChatController.sendToSnow(requestMap,contentVersionIdList,[select id,username from user limit 1]);
		requestMap.put('test','test');
       
        try{
            snowId=screenRecorderChatController.sendToSnow(requestMap,contentVersionIdList,[select id,username from user limit 1]);
        }
        catch(exception ex){
            
        }
       test.stoptest();
    }
    

    @isTest    
    private static void clearRecorderDataBatchTest(){
        Custom_support_Instruction__mdt cSI_mdt=new Custom_support_Instruction__mdt(Instructions__c='test',Note__c='test',radio__c=true);
        customMetadataService.bigObjectQueryMap.put('select DeveloperName,Instructions__c,Note__c from Custom_support_Instruction__mdt where developerName=\'Instructions\' limit 1',
                                                    new List<Custom_support_Instruction__mdt>{cSI_mdt});
        Test.setMock(HttpCalloutMock.class, new DebugLogControllerMock());
        test.starttest();
        logDeleteQueueable.isSkipTest=false;
        logDeleteQueueable q1=new logDeleteQueueable('ApexLog',new List<String>{userinfo.getuserId()});
        queueableContext qc;
        q1.execute(qc);
        logDeleteQueueable q2=new logDeleteQueueable('TraceFlag',new List<String>{userinfo.getuserId()});
        q2.execute(qc);
        
        system.schedule('test job', '0 0  0 * * ?', new clearRecorderDataBatch());
        database.executeBatch(new clearRecorderDataBatch(),500);        
        test.stoptest();
    }
    
}
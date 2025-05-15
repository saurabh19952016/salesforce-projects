//Covers DebugLogController, logDeleteQueueable, clearRecorderDataBatch apex classes
@istest
private class DebugLogControllerTest{
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
        srsList.add(new Screen_recorder_settings__c(name='recordedVidAlertSFDC_FieldName',field_value__c='description'));
        srsList.add(new Screen_recorder_settings__c(name='recordedVidAlertTarget_FieldName',field_value__c='desc'));
        srsList.add(new Screen_recorder_settings__c(name='recorded_video_alert_note',field_value__c='deletes after 2 weeks'));
        srsList.add(new Screen_recorder_settings__c(name='Salesforce_default_group',field_value__c='defGroup'));
        srsList.add(new Screen_recorder_settings__c(name='targetEnvUserMappingField',field_value__c='Name'));
        srsList.add(new Screen_recorder_settings__c(name='FLDVF_description_field',field_value__c='description'));
        srsList.add(new Screen_recorder_settings__c(name='FLDVF_subject_field',field_value__c='subject'));
        srsList.add(new Screen_recorder_settings__c(name='defaultType',field_value__c='support',isApi__c=true));
        srsList.add(new Screen_recorder_settings__c(name='defaultOrigin',field_value__c='phone',isSFDC__c=true));
        insert srsList;
        insert new ContentVersion(
            Title = userinfo.getName() + '.txt',
            PathOnClient =userinfo.getName() + '.txt',
            contentLocation='S',
            FirstPublishLocationId = DebugLogController.cw.Id,
            VersionData = blob.valueof('test'),
            IsMajorVersion = false
        );  
        insert new ContentVersion(
            Title = userinfo.getName() + ' ' + system.today(),
            PathOnClient =userinfo.getName() + ' ' + system.today(),
            contentLocation='S',
            FirstPublishLocationId = DebugLogController.cw.Id,
            VersionData = blob.valueof('test'),
            IsMajorVersion = false
        );  
    }
    
    @isTest    
    private static void DebugLogCreationTestMethod(){
        Custom_support_Instruction__mdt cSI_mdt=new Custom_support_Instruction__mdt(Instructions__c='test',Note__c='test',radio__c=true);
        customMetadataService.bigObjectQueryMap.put('select DeveloperName,Instructions__c,Note__c from Custom_support_Instruction__mdt where developerName=\'Instructions\' limit 1',
                                                    new List<Custom_support_Instruction__mdt>{cSI_mdt});
        DebugLogController logCont=new DebugLogController ();
        Test.setMock(HttpCalloutMock.class, new DebugLogControllerMock());
        
        string fileId=DebugLogController.doUploadAttachment('test','test att',null);
        DebugLogController.doUploadAttachment('test','test att',fileId);
        test.starttest();
        logCont.description='test';
        logCont.Subject='test';
        logCont.clickCapture=false;
        logCont.clickRecord=true;
        logCont.sendToSnow(); 
        string traceFlagId=DebugLogController.setTraceFlag();
        DebugLogController.getDebugLogs(traceFlagId);
        DebugLogController.deleteTraceFlag('testId');
        DebugLogController.getLogBody('testId');   
        test.stopTest();
    }
    
    @isTest    
    private static void DebugLogCreationTestMethod2(){
        Custom_support_Instruction__mdt cSI_mdt=new Custom_support_Instruction__mdt(Instructions__c='test',Note__c='test',radio__c=true);
        customMetadataService.bigObjectQueryMap.put('select DeveloperName,Instructions__c,Note__c from Custom_support_Instruction__mdt where developerName=\'Instructions\' limit 1',
                                                    new List<Custom_support_Instruction__mdt>{cSI_mdt});
        DebugLogController logCont=new DebugLogController ();
        Test.setMock(HttpCalloutMock.class, new DebugLogControllerMock());
        test.starttest();
        logCont.sendToSnow(); 
        logDeleteQueueable.isSkipTest=true;
        logCont.checkTraceFlagAndLogs();
       
        test.stoptest();
    }
    
    @isTest    
    private static void clearRecorderDataBatchTest(){
        Custom_support_Instruction__mdt cSI_mdt=new Custom_support_Instruction__mdt(Instructions__c='test',Note__c='test',radio__c=true);
        customMetadataService.bigObjectQueryMap.put('select DeveloperName,Instructions__c,Note__c from Custom_support_Instruction__mdt where developerName=\'Instructions\' limit 1',
                                                    new List<Custom_support_Instruction__mdt>{cSI_mdt});
        DebugLogController logCont=new DebugLogController ();
        Test.setMock(HttpCalloutMock.class, new DebugLogControllerMock());
        test.starttest();
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
@Istest(SeeAllData=false)
private class personalInfoDeletionTest {
    
    @testSetup
    private static void personalInfoTestSetup(){
        List<metadata_backup_Jobs__c> listJobsData = New List<metadata_backup_Jobs__c>();
        
        metadata_backup_Jobs__c setting = new metadata_backup_Jobs__c();
        setting.Name = 'Test Setting';
        setting.job_Id__c = 'TestID';
        setting.job_type__c = 'Service';
        setting.date_Field_Test__c = System.today();
        setting.datetime_field_test__c = System.now();
        setting.Boolean_Field_Test__c = true;
        setting.number_field_Test__c = 2;
        listJobsData.add(setting);
        insert listJobsData;
    }
    
    @isTest
    private static void submitJobTestPositiveTest(){
        refresh_setting_met__mdt testRefreshMeta=new refresh_setting_met__mdt(developerName='metadata_backup_Jobs__c',jobId__c='test',status__c='Processing');
        customMetadataService.bigObjectQueryMap.put('select id,masterlabel,developername,status__c,jobId__c,(select id,fieldList__c from fieldLists__r) from refresh_setting_met__mdt',new List<sobject>{testRefreshMeta});
        system.assertEquals(1,personalInfoDeletionController.checkJobs().size());
        customMetadataService.bigObjectQueryMap.put('select id,developerName,status__c from refresh_setting_met__mdt where developername=\'metadata_backup_Jobs__c\' and status__c NOT IN (\'Completed\',\'Failed\')',new List<sobject>{testRefreshMeta});
        system.assertEquals(false,personalInfoDeletionController.checkJobRunning('metadata_backup_Jobs__c'));
        //List<String> searchResults=searchComponentController.getsobjectList('metadata_backup_Jobs__c');
        List<String> fieldList=personalInfoDeletionController.getObjectFields('metadata_backup_Jobs__c');
        fieldList.remove(fieldList.size()-1);
        fieldList__mdt testfieldMeta=new fieldList__mdt(fieldList__c=string.join(fieldList,','),developerName='fld');
        List<fieldList__mdt> fieldMetaList=new List<Sobject>{testfieldMeta};
            customMetadataService.bigObjectQueryMap.put('select id,fieldList__c from fieldList__mdt where refresh_settings__r.developerName=\'metadata_backup_Jobs__c\'',fieldMetaList);
        test.startTest();
        system.assertEquals('SUCCESS',personalInfoDeletionController.submitJob('metadata_backup_Jobs__c',fieldList));
        test.stopTest();
        fieldMetaList.add(testfieldMeta.clone());
        fieldMetaList.add(testfieldMeta.clone());
        fieldMetaList.add(testfieldMeta.clone());
        fieldMetaList.add(testfieldMeta.clone());
        fieldMetaList.add(testfieldMeta.clone());
        customMetadataService.bigObjectQueryMap.put('select id,fieldList__c from fieldList__mdt where refresh_settings__r.developerName=\'metadata_backup_Jobs__c\'',fieldMetaList);
        system.assertEquals('ERROR',personalInfoDeletionController.submitJob('metadata_backup_Jobs__c',fieldList));
        
    }
    
    @isTest
    private static void deleteMetadataTest(){
        List<String> fieldList=personalInfoDeletionController.getObjectFields('metadata_backup_Jobs__c');
        system.assertEquals(false,personalInfoDeletionController.deleteMetadata('test'));
        customMetadataService.bigObjectQueryMap.put('select id,developerName from fieldList__mdt where refresh_settings__r.Id=\'test\'',new List<fieldList__mdt>());
        system.assertEquals(false,personalInfoDeletionController.deleteMetadata('test'));
        fieldList__mdt testfieldMeta=new fieldList__mdt(fieldList__c=string.join(fieldList,','),developerName='fld');
        List<fieldList__mdt> fieldMetaList=new List<Sobject>{testfieldMeta};
         fieldMetaList.add(testfieldMeta.clone());
        fieldMetaList.add(testfieldMeta.clone());
        fieldMetaList.add(testfieldMeta.clone());
        fieldMetaList.add(testfieldMeta.clone());
        fieldMetaList.add(testfieldMeta.clone());
        customMetadataService.bigObjectQueryMap.put('select id,developerName from fieldList__mdt where refresh_settings__r.Id=\'test\'',fieldMetaList);
        test.startTest();
        Test.setMock(WebServiceMock.class, new metadataCalloutMock());
        system.assertEquals(true,personalInfoDeletionController.deleteMetadata('test'));
        test.stoptest();
    }
    
    @isTest
    private static void submitJobTestNegativeTest(){
        system.assertEquals(0,personalInfoDeletionController.checkJobs().size());
        List<String> fieldList=personalInfoDeletionController.getObjectFields('metadata_backup_Jobs__c');
        system.assertEquals('EXCEPTION',personalInfoDeletionController.submitJob('metadata_backup_Jobs__c',fieldList));
        customMetadataService.bigObjectQueryMap.put('select id,masterlabel,developername,status__c,jobId__c,(select id,fieldList__c from fieldLists__r) from refresh_setting_met__mdt',new List<sobject>());
        customMetadataService.bigObjectQueryMap.put('select id,fieldList__c from fieldList__mdt where refresh_settings__r.developerName=\'metadata_backup_Jobs__c\'',new List<Sobject>());
        customMetadataService.bigObjectQueryMap.put('select id,developerName,status__c from refresh_setting_met__mdt where developername=\'metadata_backup_Jobs__c\' and status__c NOT IN (\'Completed\',\'Failed\')', new List<sobject>());
        system.assertEquals(0,personalInfoDeletionController.checkJobs().size());
        // List<String> searchResults=searchComponentController.getsobjectList('metadata_backup_Jobs__c');
        system.assertEquals(true,personalInfoDeletionController.checkJobRunning('metadata_backup_Jobs__c'));
        clearPersonalInfoBatch batch=new clearPersonalInfoBatch('metadata_backup_Jobs__c',fieldList);
        batch.forceException=true;
        test.startTest();
        database.executeBatch(batch,100);
        test.stopTest();
    }
    
    
    @isTest
    private static void PersonalInfoCallbackTest(){
        refresh_setting_met__mdt testRefreshMeta=new refresh_setting_met__mdt(developerName='metadata_backup_Jobs__c',jobId__c='test',status__c='Processing');
        List<String> fieldList=personalInfoDeletionController.getObjectFields('metadata_backup_Jobs__c');
        
        Metadata.DeployCallback callback = new personalInfoDeletionCallback('metadata_backup_Jobs__c',string.join(fieldList,','));
        List<String> sobjectList=searchCOmponentController.getsobjectList('metadata_backup_Jobs__c');
        // Create test result and context objects.
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.status =  Metadata.DeployStatus.Succeeded;
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
        test.startTest();
        callback.handleResult(result, context);
        test.stopTest();
        customMetadataService.bigObjectQueryMap.put('select id,developerName from refresh_setting_met__mdt where developerName=\'metadata_backup_Jobs__c\' limit 1',new List<sobject>{testRefreshMeta});
        callback.handleResult(result, context);
    }
}
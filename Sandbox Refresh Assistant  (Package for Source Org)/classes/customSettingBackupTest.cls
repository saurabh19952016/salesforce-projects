@isTest  
private class customSettingBackupTest
{
    
    /****************************************************
        testSetup
    *****************************************************/
    @testSetup public static void setup(){

        // create all custom setttings records which is being used in the Apex Code

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
        
        List<Data_Migration_Auth__c> listAuthData = New List<Data_Migration_Auth__c>();

        Data_Migration_Auth__c authInstance = new Data_Migration_Auth__c();
        authInstance.Name = 'refresh';
        authInstance.org_name__c = 'testorg';
        authInstance.named_credentials__c = 'selfOrg';
        authInstance.library_name__c = 'refresh_backup';
        listAuthData.add(authInstance);
        
        insert listAuthData;

    }
    
    @isTest
    private static void testGetSaved(){
         Test.startTest();
            	Test.setMock(HttpCalloutMock.class, new customSettingBackupTestMock());     
        customsettingBkpController.returnBackup verInstance = customSettingBkpController.getSaved(false);
        Test.stopTest();
    }
    
    @IsTest
    private static void coverAllCSOperations()
    {   
        
        List<String> listCSName = new List<String>();
        listCSName = customSettingBkpController.CSList();
        boolean isRunning = customSettingBkpController.isJobRunning();
        Test.startTest();
            	Test.setMock(HttpCalloutMock.class, new customSettingBackupTestMock());     

        Integer metaIndex = listCSName.indexOf('metadata_backup_Jobs__c');
        List<String> listCSApi = new List<String>();        
        if(metaIndex!=null){
            listCSApi.add(listCSName[metaIndex]);
            system.assertEquals('metadata_backup_Jobs__c',listCSApi[0]);
            customSettingBkpController.submitJob(listCSApi);
        }
        Test.stopTest();
    }
    
    @IsTest
    private static void testSaveCSOperations()
    {   
             	Test.setMock(HttpCalloutMock.class, new customSettingBackupTestMock());     
        metadata_backup_Jobs__c metaInst = [select id,Name,job_type__c,date_Field_Test__c,datetime_field_test__c,Boolean_Field_Test__c,number_field_Test__c from metadata_backup_Jobs__c where Name='Test Setting' limit 1 ];
        string header = '"id,Name,job_type__c,date_Field_Test__c,datetime_field_test__c,Boolean_Field_Test__c,number_field_Test__c"\n';
        string recordString = '"'+metaInst.id+'","'+metaInst.Name+'","'+metaInst.job_type__c+'","'+metaInst.date_Field_Test__c+'","'+metaInst.datetime_field_test__c+'","'+metaInst.Boolean_Field_Test__c+'","'+metaInst.number_field_Test__c +'"';
        string finalstr = header +recordString;
        Blob fileData = Blob.valueOf(finalstr);
        system.assertEquals('Test Setting',[select id,job_Id__c,Name,job_type__c from metadata_backup_Jobs__c limit 1].Name );
        Zippex zipFile = new Zippex();
        zipFile.addFile('metadata_backup_Jobs__c' + '.csv', fileData, null);
        Blob zipData = zipFile.getZipArchive();
        String myFile = EncodingUtil.base64Encode(zipData);
        String finalString = EncodingUtil.URLENCODE(myFile,'UTF-8');
        customSettingBkpController.saveFile('metadataFile',finalString,'');
        List<customSettingBkpController.customSettingFileWrapper> listSetting = customSettingBkpController.getFileNames(finalString);
        customSettingBkpController.mergeAllSettings(listSetting);
    } 
      
    @isTest    
    public static void deleteSavedDataTestMethod(){
        
        Test.setMock(HttpCalloutMock.class, new customSettingBackupTestMock());
        test.starttest();
        String delData1 = customSettingBkpController.deleteSavedData('custom settings');
        test.stopTest();
    }
    
    @isTest    
    public static void deleteSavedDataTestMethod1(){
        
        Test.setMock(HttpCalloutMock.class, new customSettingBackupTestMock());
        test.starttest();
        String delData1 = customSettingBkpController.deleteSavedData('metadata');
        test.stopTest();
    }
}
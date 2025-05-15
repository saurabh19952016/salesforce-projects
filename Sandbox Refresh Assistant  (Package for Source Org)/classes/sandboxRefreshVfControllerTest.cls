@isTest
private class sandboxRefreshVfControllerTest {
    @testSetup public static void setup(){
        
        // create all custom setttings records which is being used in the Apex Code
        
        List<metadata_backup_Jobs__c> listJobsData = New List<metadata_backup_Jobs__c>();
        
        metadata_backup_Jobs__c setting = new metadata_backup_Jobs__c();
        setting.Name = 'ApexClass';
        setting.job_Id__c = 'testApexClassId';
        setting.job_type__c = 'retrieve';
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
        
        /*ContentWorkspace cw = new ContentWorkspace();
        cw.Name = 'refresh_backup';
        cw.DeveloperName = 'refresh_backup';
        insert cw;*/
    }
    
    @istest
    private static void MetadataRetrieveSubmitTest(){
        List<Data_Migration_Auth__c> authData = New List<Data_Migration_Auth__c>();
        authData = [select id, Name, org_name__c, named_credentials__c,library_name__c from Data_Migration_Auth__c where Name= 'refresh'];
        system.debug('authData:::'+authData);
        /*test.startTest();
        sandboxRefreshVFController controller=new sandboxRefreshVFController();
        MetadataBackupController.getMetadataJobIds('retrieve');
        MetadataBackupController.jobWrapper retrieveWrap=sandboxRefreshVFController.submitRetreiveJob('ApexClass');
        test.stoptest();*/
         test.startTest();
           Test.setMock(WebserviceMock.class, new metadataCalloutMock());
        test.setMock(HttpCalloutMock.class, new MetadataBackupTestMock());
        sandboxRefreshVFController controller=new sandboxRefreshVFController();
        MetadataBackupController.jobWrapper jobWrap=new  MetadataBackupController.jobWrapper ();
        jobWrap.status='InProgress';
        jobWrap.jobId=[select id,job_Id__c,job_type__c from metadata_backup_Jobs__c];
        sandboxRefreshVFController.submitRetreiveJob('ApexClass');
        controller.submitAbortBatch();
        controller.deleteExisting(); 
        controller.getObjectFields();
        controller.selectedObject='Account';
        controller.getObjectFields();
        controller.submitObscureJob();
        controller.FldOrUsrSelected=new List<string>{'Name'};
        controller.submitObscureJob();
        test.stopTest();

    }
    @istest
    private static void MetadataCheckRetrieveTest(){
        test.setMock(HttpCalloutMock.class, new MetadataBackupTestMock());
        Test.setMock(WebserviceMock.class, new metadataCalloutMock());
        MetadataBackupController.jobWrapper jobWrap=new  MetadataBackupController.jobWrapper ();
        jobWrap.status='InProgress';
        jobWrap.jobId=[select id,job_Id__c,job_type__c from metadata_backup_Jobs__c];
        test.startTest();
        sandboxRefreshVFController.checkRetrieveStatus(json.serialize(jobWrap));
        test.stopTest();
    }
    
    @istest
    private static void MetadataCancelDeployTest(){
        Test.setMock(WebserviceMock.class, new metadataCalloutMock());
        test.startTest();
        MetadataBackupController.cancelDeployment([select id,job_Id__c,Name,job_type__c from metadata_backup_Jobs__c limit 1][0]);
        test.stopTest();
    }
    
    @istest
    private static void MetadataDeployTest(){
        zippex zpFile=new zippex();
        zpfile.addFile('test file',blob.valueOf('test'),null);
        string zipFileString=encodingUtil.base64Encode(zpfile.getZipArchive());
        Test.setMock(WebserviceMock.class, new metadataCalloutMock());
        test.startTest();
        sandboxRefreshVFController.uploadFile(zipFileString,'ApexClass','metadata');
        test.stoptest();
    }
    
    @istest
    private static void MetadatacheckJobDeployTest(){
        
        Test.setMock(WebserviceMock.class, new metadataCalloutMock());
        test.startTest();
        MetadataBackupController.checkJobDeploy([select id,job_Id__c,Name,job_type__c from metadata_backup_Jobs__c limit 1][0]);
        test.stopTest();
    }
    
    @istest
    private static void customSettingBackupTest(){

	       metadata_backup_Jobs__c metaInst = [select id,Name,job_type__c,date_Field_Test__c,datetime_field_test__c,Boolean_Field_Test__c,number_field_Test__c from metadata_backup_Jobs__c where Name='ApexClass' limit 1 ];
        string header = '"id,Name,job_type__c,date_Field_Test__c,datetime_field_test__c,Boolean_Field_Test__c,number_field_Test__c"\n';
        string recordString = '"'+metaInst.id+'","'+metaInst.Name+'","'+metaInst.job_type__c+'","'+metaInst.date_Field_Test__c+'","'+metaInst.datetime_field_test__c+'","'+metaInst.Boolean_Field_Test__c+'","'+metaInst.number_field_Test__c +'"';
        string finalstr = header +recordString;
        System.debug('finalStr++'+finalstr);
        Blob fileData = Blob.valueOf(finalstr);
        Zippex zipFile = new Zippex();
        zipFile.addFile('metadata_backup_Jobs__c' + '.csv', fileData, null);
        Blob zipData = zipFile.getZipArchive();
        String myFile = EncodingUtil.base64Encode(zipData);  
        test.startTest();
          Test.setMock(WebserviceMock.class, new metadataCalloutMock());
        test.setMock(HttpCalloutMock.class, new MetadataBackupTestMock());
        sandboxRefreshVFController controller=new sandboxRefreshVFController();
        controller.selectedCSList=new List<String>{'metadata_backup_jobs__c'};
            controller.submitJob();
        sandboxRefreshVFController.uploadFile(myFile,'metadata_backup_jobs__c','setting');
        test.stopTest();
    }
}
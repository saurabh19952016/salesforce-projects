@istest
private  class MetadataBackupControllerTest {
    @testsetup
    private static void testData()
    {
        metadata_backup_Jobs__c setting = new metadata_backup_Jobs__c();
        setting.Name = 'ApexClass';
        setting.job_Id__c = 'testApexClassId';
        setting.job_type__c = 'retrieve';
        setting.date_Field_Test__c = System.today();
        setting.datetime_field_test__c = System.now();
        setting.Boolean_Field_Test__c = true;
        setting.number_field_Test__c = 2;
        insert setting;
        Data_Migration_Auth__c AuthData = new Data_Migration_Auth__c();
        AuthData.Name = 'refresh';
        AuthData.username__c = 'TestID';
        AuthData.Password__c = 'abc123';
        AuthData.client_id__c = 'Test';
        AuthData.client_secret__c = 'Test';
        AuthData.endpoint__c = 'ttest';
        AuthData.security_token__c = 'TestToken';
        AuthData.TargetOrgId__c = 'Test123';
        
        insert AuthData;
        data_migration_auth__c auth = new data_migration_auth__c();
        auth.Name = 'refresh';
        auth.org_name__c = 'testorg';
        auth.named_credentials__c = 'selfOrg';
        auth.library_name__c = 'refresh_backup';
        insert auth;
        
    }
    @istest
   private static void testjobWrapper()
    {
        data_migration_auth__c dataauth = [select id,client_id__c,endpoint__c,client_secret__c,username__c,TargetOrgId__c,Password__c,Name,security_token__c from data_migration_auth__c limit 1];
        metadata_backup_Jobs__c metabackid = [select id,job_Id__c,Name,job_type__c from metadata_backup_Jobs__c limit 1 ];
        test.setMock(WebServiceMock.class, new metadataCalloutMock());
        /*PageReference pageRef1 = Page.MetadataHandlerClass;
Test.setCurrentPage(pageRef1);*/
        
        MetadataBackupController.jobWrapper jw=new MetadataBackupController.jobWrapper();
        
        jw.jobId=metabackid;
        jw.status='test';
        jw.numberComponentsTotal=1;
        jw.numberComponentsDeployed=1;
        jw.numberComponentErrors=0;
       
      
}

    @istest
    private static void testgetresponse()
    {
        Test.startTest();
        
        MetadataHandlerClass.getSessionId();
        // MetadataHandlerClass.
        Test.stopTest();
    }
    @istest
    private static void testMetaDataBackupMethod()
    {
        
        metadata_backup_Jobs__c metabackid = [select id,job_Id__c,Name,job_type__c from metadata_backup_Jobs__c limit 1 ];
        data_migration_auth__c dataauth=[select id,name,org_name__c,named_credentials__c,library_name__c from data_migration_auth__c limit 1];
        test.setMock(HttpCalloutMock.class, new MetadataBackupTestMock());
        MetadataHandlerClass.sendMail('subject', 'body');
        
        test.setMock(WebServiceMock.class, new metadataCalloutMock());
        // MetadataBackupController.checkJobRetrieve(metabackid); 
        Test.startTest();
        MetadataBackupController.createService();
       system.assertEquals('Success', MetadataBackupController.cancelDeployment(metabackid).status );
        Test.stopTest();
    }
    @istest
    public static void  testcheckJobRetrieve()
    {
        
        test.setMock(WebServiceMock.class, new metadataCalloutMock());
        metadata_backup_Jobs__c metabackid = [select id,job_Id__c,Name,job_type__c from metadata_backup_Jobs__c limit 1 ];
         zippex zpFile=new zippex();
        zpfile.addFile('test file',blob.valueOf('test'),null);
        string zipFileString=encodingUtil.base64Encode(zpfile.getZipArchive());
        test.starttest();
        MetadataBackupController.saveFile('ApexClass',zipFileString , 'text/xml');
        system.assertEquals('ApexClass',[select id,job_Id__c,Name,job_type__c from metadata_backup_Jobs__c limit 1].Name );
        test.stoptest();
        
        // MetadataBackupController.submitRetreiveJob(metadataSelected)
    }
    @istest
    private static void BackupCheckJobRetrieveTest(){
        test.setMock(HttpCalloutMock.class, new MetadataBackupTestMock());
        Test.setMock(WebserviceMock.class, new metadataCalloutMock());
                data_migration_auth__c dataauth=[select id,name,org_name__c,named_credentials__c,library_name__c from data_migration_auth__c limit 1];

        MetadataBackupController.jobWrapper jobWrap=new  MetadataBackupController.jobWrapper ();
        jobWrap.status='InProgress';
        jobWrap.jobId=[select id,name,job_Id__c,job_type__c from metadata_backup_Jobs__c];
        test.startTest();
       system.assertEquals('Succeeded',  MetadataBackupController.checkJobRetrieve(jobWrap.jobId).status);

        test.stopTest();
    }
     @istest
    private static void MetadatacheckJobDeployTest(){
        
        Test.setMock(WebserviceMock.class, new metadataCalloutMock());
        test.startTest();
     system.assertEquals('success', MetadataBackupController.checkJobDeploy([select id,job_Id__c,Name,job_type__c from metadata_backup_Jobs__c limit 1]).status);
        test.stopTest();
             //  system.assertEquals(Null,MetadataBackupController.checkJobDeploy([select id,job_Id__c,Name,job_type__c from metadata_backup_Jobs__c limit 1]).status );

    }
    
    @istest
    private static void BackupGetAllmetadata()
    {
        // getMetadataJobIds
        test.setMock(HttpCalloutMock.class, new MetadataBackupTestMock());
        Test.setMock(WebserviceMock.class, new metadataCalloutMock());
      // MetadataBackupController.METADATA_API_VERSION=234234;
        MetadataBackupController.jobWrapper jobWrap=new  MetadataBackupController.jobWrapper ();
        jobWrap.status='InProgress';
        jobWrap.jobId=[select id,job_Id__c,job_type__c from metadata_backup_Jobs__c];
        Test.startTest();
       system.assertEquals('InProgress',MetadataBackupController.getMetadataJobIds( 'retrieve')[0].status );
       system.assertEquals('ApexClass',  MetadataBackupController.getAllMetadata()[0]);
        Test.stopTest();
    }
     @istest
    private static void BackupsubmitRetreiveJobTest(){
        Test.setMock(WebserviceMock.class, new metadataCalloutMock());

        MetadataBackupController.jobWrapper jobWrap=new  MetadataBackupController.jobWrapper ();
        jobWrap.status='InProgress';
        jobWrap.jobId=[select id,name,job_Id__c,job_type__c from metadata_backup_Jobs__c];
        test.startTest();
            system.assertEquals('InProgress', MetadataBackupController.submitRetreiveJob('ApexClass').status );

        test.stopTest();
              //  system.assertEquals('InProgress', MetadataBackupController.submitRetreiveJob('ApexClass').status );

    }
}
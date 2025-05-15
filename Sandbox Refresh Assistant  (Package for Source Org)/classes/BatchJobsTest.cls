@istest
private class BatchJobsTest {
    
       @testSetup
    private static void BatchJobsTestSetup(){        
        data_migration_auth__c auth = new data_migration_auth__c();
        auth.Name = 'refresh';
        auth.org_name__c = 'testorg';
        auth.named_credentials__c = 'selfOrg';
        auth.library_name__c = 'refresh_backup';
        insert auth;
    }
    
    @istest
    private static void testdeleteJobController()
    {
        Test.StartTest();
        deleteJobController.checkJobRunning();
        //delcon.checkJobRunning();
        deleteJobController.deleteJobMethod();
        Test.stopTest();
    }
@istest
    private static void testdeleteScheduledJobs()
    {
        Test.startTest();
        deleteScheduledJobs deljob=new deleteScheduledJobs('AsyncApexJob');
        Database.executeBatch(deljob);
        Test.stopTest();
    }
    @istest
     private static void testdeleteScheduledJobs1()
    {
        Test.startTest();
        deleteScheduledJobs deljob=new deleteScheduledJobs('CronTrigger');
        Database.executeBatch(deljob);
        Test.stopTest();
    }
    
    @isTest 
    private static void testsobjectDMLBatch(){ 
         data_migration_auth__c auth = new data_migration_auth__c();
        auth.Name = 'refresh2';
        auth.org_name__c = 'testorg';
        auth.named_credentials__c = 'selfOrg';
        auth.library_name__c = 'refresh_backup';
        Test.startTest();
        database.executeBatch(new sojbectDmlBatch(new List<sobject>{auth},'insert'),1);
        Test.stopTest();
        system.assertEquals(1,[select id from data_migration_auth__c where name='refresh2'].size());
    }
    
    @isTest 
    private static void testsobjectDMLBatch2(){ 
         data_migration_auth__c auth = [select id,name,org_name__c from data_migration_auth__c limit 1];
        auth.org_name__c='testNewOrg';
        Test.startTest();
        database.executeBatch(new sojbectDmlBatch(new List<sobject>{auth},'update'),1);
        Test.stopTest();
        system.assertEquals('testNewOrg',[select id,org_name__c from data_migration_auth__c where name='refresh'][0].org_name__c);

    }
}
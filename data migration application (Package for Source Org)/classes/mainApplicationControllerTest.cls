@isTest
private  class mainApplicationControllerTest {
   @testSetup
    private static void mainApplicationControllerSetup(){        
        data_migration_auth__c auth = new data_migration_auth__c();
        auth.Name = 'refresh';
        auth.org_name__c = 'testorg';
        auth.named_credentials__c = 'selfOrg';
        auth.library_name__c = 'refresh_backup';
        insert auth;
    }
    
    @isTest
    private static void mainApplicationControllerTestNewSetup(){
        delete [select id from data_migration_auth__c];
        test.startTest();
        test.setMock(webserviceMock.class,new metadatacalloutMock());
        mainApplicationController.appWrapper appWrap=mainApplicationController.getIsAuthenticated('refresh');
        system.assertEquals(false,appWrap.isAuthenticated);
        system.assertEquals([select id,DeveloperName from ContentWorkspace where developername!=null],appwrap.libraryList);
        system.assertEquals(new List<string>{'selfOrg'},appwrap.namedCredentialList);
        test.stopTest();
        data_migration_auth__c auth = new data_migration_auth__c();
        auth.Name = 'refresh';
        auth.org_name__c = 'testorg';
        auth.named_credentials__c = 'selfOrg';
        auth.library_name__c = 'refresh_backup';
        system.assertEquals(true,mainApplicationController.saveDetails('refresh',auth).success);
        system.assertEquals(false,mainApplicationController.saveDetails('refresh',auth).success);
        
   }
}
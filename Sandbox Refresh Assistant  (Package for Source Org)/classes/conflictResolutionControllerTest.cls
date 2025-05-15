@isTest  
private class conflictResolutionControllerTest
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
        
               
    }
    
    @IsTest
    private static void testGetObjectFields()
    {   
        ConflictResolutionController.getObjectFields('metadata_backup_Jobs__c');
    }
    
    @IsTest
    private static void testGetConflicts()
    {   
        metadata_backup_Jobs__c metaInst = [select id,Name,job_type__c,date_Field_Test__c,datetime_field_test__c,Boolean_Field_Test__c,number_field_Test__c from metadata_backup_Jobs__c where Name='Test Setting' limit 1 ];
        String header = '"id,Name,job_type__c,date_Field_Test__c,datetime_field_test__c,Boolean_Field_Test__c,number_field_Test__c"\n';
        String recordString = '"'+metaInst.id+'","'+metaInst.Name+'","'+metaInst.job_type__c+'","'+metaInst.date_Field_Test__c+'","'+metaInst.datetime_field_test__c+'","'+metaInst.Boolean_Field_Test__c+'","'+metaInst.number_field_Test__c +'"';
        String finalstr = header +recordString;
        Blob fileData = Blob.valueOf(finalstr);
        String myFile = EncodingUtil.base64Encode(fileData);
        ConflictResolutionController.getConflicts('metadata_backup_Jobs__c',myFile);
        system.assertEquals('Test Setting',[select id,job_Id__c,Name,job_type__c from metadata_backup_Jobs__c limit 1].Name );
    }
    
    
    
    @IsTest
    private static void testSaveMergedRecords()
    {   
        metadata_backup_Jobs__c metaInst = [select id,Name,job_type__c,date_Field_Test__c,datetime_field_test__c,Boolean_Field_Test__c,number_field_Test__c from metadata_backup_Jobs__c where Name='Test Setting' limit 1 ];
        List<sobject> listSObject = new List<sobject>();
        listSObject.add(metaInst);
        system.assertEquals('Test Setting',[select id,job_Id__c,Name,job_type__c from metadata_backup_Jobs__c limit 1].Name );
        ConflictResolutionController.saveMergedRecords(listSObject);
        
    }
    
}
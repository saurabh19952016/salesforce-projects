//Covers ScreenRecorderCustomSettingController, AddingMetadata, Create_Update_Metadata apex classes
@isTest
private class ScreenRecorderCSControllerTest {
    
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
        srsList.add(new Screen_recorder_settings__c(name='debugLevelId',field_value__c='levelId'));
        srsList.add(new Screen_recorder_settings__c(name='file_deletion_Interval',field_value__c='14'));
        srsList.add(new Screen_recorder_settings__c(name='libraryName',field_value__c='scrRecorder'));
        srsList.add(new Screen_recorder_settings__c(name='recordedVidAlertSFDC_FieldName',field_value__c='description'));
        srsList.add(new Screen_recorder_settings__c(name='recordedVidAlertTarget_FieldName',field_value__c='desc'));
        srsList.add(new Screen_recorder_settings__c(name='recorded_video_alert_note',field_value__c='deletes after 2 weeks'));
        srsList.add(new Screen_recorder_settings__c(name='Salesforce_default_group',field_value__c='defGroup'));
        srsList.add(new Screen_recorder_settings__c(name='targetEnvUserMappingField',field_value__c='Id'));
        srsList.add(new Screen_recorder_settings__c(name='defaultType',field_value__c='support',isApi__c=true));
        srsList.add(new Screen_recorder_settings__c(name='defaultOrigin',field_value__c='phone',isSFDC__c=true));
        insert srsList;
    }
    
    @isTest
    private static void ApiSettingTest(){
        Map<String,String> settingMap=ScreenRecorderCustomSettingController.getApiSettingRecords();
        settingMap.put('API_comments','comments2');
        ScreenRecorderCustomSettingController.saveSettingRecords(settingMap);
        system.assertEquals('comments2',Screen_recorder_settings__c.getInstance('API_comments').field_value__c);
    }
    
    @isTest
    private static void defaultValuesTest(){
        List<Screen_recorder_settings__c> settingList=ScreenRecorderCustomSettingController.getDefaultSettingRecords('Salesforce');
        settingList.remove(0);
        settingList.add(new Screen_recorder_settings__c(name='defaultOrigin',field_value__c='phone',isSFDC__c=true));
        Integer listSize=settingList.size();
        ScreenRecorderCustomSettingController.saveDefaultSettingRecords(settingList,'Salesforce');
        system.assertEquals(listSize,([select id from Screen_recorder_settings__c where isSFDC__c=true]).size());
        Screen_recorder_settings__c targetEnvUserMappingField=[select id from Screen_recorder_settings__c where name='targetEnvUserMappingField' limit 1];
        ScreenRecorderCustomSettingController.deleteSingleRecord(targetEnvUserMappingField.Id);
        system.assertEquals(0,([select id from Screen_recorder_settings__c where name='targetEnvUserMappingField']).size());
        List<Screen_recorder_settings__c> settingList2=ScreenRecorderCustomSettingController.getDefaultSettingRecords('Target Environment');
        settingList2.remove(0);
        settingList.add(new Screen_recorder_settings__c(name='defaultType',field_value__c='phone',isAPI__c=true));
        Integer listSize2=settingList2.size();
        ScreenRecorderCustomSettingController.saveDefaultSettingRecords(settingList2,'Target Environment');
        system.assertEquals(listSize2,([select id from Screen_recorder_settings__c where isApi__c=true]).size());
    }
    
    @isTest
    private static void negativeCustomSettingTest(){
        Map<String,String> settingMap=new Map<String,String>{''=>'test'};
            try{
                ScreenRecorderCustomSettingController.saveSettingRecords(settingMap);
            }
        catch(exception ex){}
        try{
            ScreenRecorderCustomSettingController.getDefaultSettingRecords(null);
        }
        catch(exception ex){}
        try{
            ScreenRecorderCustomSettingController.saveDefaultSettingRecords(new List<Screen_recorder_settings__c>(),'');
            
        }
        catch(exception ex){}
        try{
            ScreenRecorderCustomSettingController.deleteSingleRecord('testId');
        }
        catch(exception ex){}
    }
    
    @isTest
    private static void addingMetadataTest(){
        Custom_support_Instruction__mdt cSI_mdt=new Custom_support_Instruction__mdt(developerName='X1',Instructions__c='test',Note__c='test',fieldName__c='desciption;order;',radio__c=true,capture__c=false,searchbox__c=false);
        Custom_support_Instruction__mdt cSI_mdt2=new Custom_support_Instruction__mdt(developerName='X1',Instructions__c='test',Note__c='test',fieldName__c='{"Salesforce":"SFDC","Target":"target"}',radio__c=true,capture__c=false,searchbox__c=false);
        Custom_support_Instruction__mdt cSI_mdt3=new Custom_support_Instruction__mdt(developerName='X1',Instructions__c='test',Note__c='test',fieldName__c='',radio__c=true,capture__c=false,searchbox__c=false);
        
        List<Custom_support_Instruction__mdt> metadataList= new List<Custom_support_Instruction__mdt>{cSI_mdt,cSI_mdt2,cSI_mdt3};
            customMetadataService.bigObjectQueryMap.put('SELECT id, MasterLabel,DeveloperName, Capture__c,fieldName__c,Instructions__c,Note__c,order__c,Radio__c,SearchBox__c' +
                                                        ' FROM Custom_support_Instruction__mdt  where DeveloperName!=\'Instructions\' order by DeveloperName',
                                                        metadataList );  
        List<AddingMetadata.Metadatawrap> wrpperList=AddingMetadata.getAllRecords();
	for(AddingMetadata.Metadatawrap wrap:wrpperList){
            wrap.Id='1';
        	wrap.SfdcFieldName='test';
        }
        try{
            AddingMetadata.saveRecord(json.serialize(wrpperList),3);
        } 
        catch(exception ex){}
        for(AddingMetadata.Metadatawrap wrap:wrpperList){
            wrap.Id=userinfo.getuserId();
        }
        try{
            AddingMetadata.saveRecord(json.serialize(wrpperList),3);
        } 
        catch(exception ex){}
        Create_Update_Metadata callbacktest=new Create_Update_Metadata();
        Metadata.DeployResult result=new Metadata.DeployResult();
        result.status=Metadata.DeployStatus.Succeeded;
        callbacktest.handleResult(result,new Metadata.DeployCallbackContext());
        result.status=Metadata.DeployStatus.Failed;
        callbacktest.handleResult(result,new Metadata.DeployCallbackContext());
    }
}
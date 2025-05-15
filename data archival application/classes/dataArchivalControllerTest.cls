@isTest  
public class dataArchivalControllerTest {
    @testSetup public static void setup()
    {
        Data_Archival_Object_Settings__c datsetting = new Data_Archival_Object_Settings__c();
        datsetting.Object_Name__c='Case';
        datsetting.Object_type__c='parent';
        datsetting.Archival_From_Date__c=system.Now();
        datsetting.Archival_To_Date__c=system.Now()+5;
        datsetting.Name='Test';
        datsetting.FilterField_1__c='status';
        datsetting.FilterField_2__c='type';
        datsetting.filterValue_1__c='open';
        datsetting.filterValue_2__c='other';
        datsetting.Submitted_By__c=userinfo.getuserId().substring(0,15);
        datsetting.Hierarchy_Level__c='1';
        datsetting.relationship_field__c='ParentId';  
        datsetting.Status__c='completed';
        insert datsetting;
        
        Data_Archival_Object_Settings__c datsetting1 = new Data_Archival_Object_Settings__c();
        datsetting1.Object_Name__c='Case';
        datsetting1.Object_type__c='parent';
        datsetting1.Archival_From_Date__c=system.Now();
        datsetting1.Archival_To_Date__c=system.Now()+5;
        datsetting1.Name='Test1';
        datsetting1.FilterField_1__c='status';
        datsetting1.FilterField_2__c='type';
        datsetting1.filterValue_1__c='open';
        datsetting1.filterValue_2__c='other';
        datsetting1.Submitted_By__c=userinfo.getuserId().substring(0,15);
        datsetting1.Hierarchy_Level__c='3';
        datsetting1.relationship_field__c='ParentId';  
        datsetting1.Status__c='completed';
        insert datsetting1;
    }

     public static testmethod void dataArchivalController()
     {
      test.startTest();
      dataArchivalController.getsobjectList('Account');
      dataArchivalController.getObjectFields('Account');
      test.stoptest();
     }
     public static testmethod void Settings()
     {
         Data_Archival_Object_Settings__c settingsList1= new Data_Archival_Object_Settings__c();
         List<Data_Archival_Object_Settings__c> settingsList= new List<Data_Archival_Object_Settings__c> ();
         settingsList=[select id,Name,Hierarchy_Level__c from Data_Archival_Object_Settings__c where Object_Name__c='Case'];
         test.startTest();
         dataArchivalController.getSettings('1');
         dataArchivalController.deleteSettings(settingsList[0]);
         dataArchivalController.saveSettings(settingsList1,'1');
         dataArchivalController.changeParent(settingsList[1],settingsList[0]);
         test.stoptest();
     }
    public static testmethod void Settings1()
     {
         List<Data_Archival_Object_Settings__c> settingsList= new List<Data_Archival_Object_Settings__c> ();
         settingsList=[select id,Name,Hierarchy_Level__c from Data_Archival_Object_Settings__c where Name ='Test'];
         test.startTest();
         dataArchivalController.saveSettings(settingsList[0],'1');
         test.stoptest();

     }
         public static testmethod void batch()
         {
             List<Data_Archival_Object_Settings__c> settingsList= new List<Data_Archival_Object_Settings__c> ();
             settingsList=[select id,Name,Hierarchy_Level__c,Object_Name__c from Data_Archival_Object_Settings__c where Object_Name__c='Case'];
             settingsList[0].Object_Name__c = 'EmailMessage'; update settingsList[0];
             test.startTest();
             dataArchivalController.runBatch('EmailMessage','Parent');
             dataArchivalController.getBatchStatus();
             test.stoptest();
         }

}
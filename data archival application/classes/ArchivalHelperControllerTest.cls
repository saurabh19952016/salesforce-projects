@isTest
public class ArchivalHelperControllerTest {
  
    @istest 
    public static void getSetupRequired1()
    {
        Map<String,Decimal> sobjectlist=new Map<String,Decimal>();
        DataArchive__b headerRec=new DataArchive__b (indexNumber__c=0,datetimestampindex__c='HeadersIndex',recordjson0__c=json.serialize(sobjectlist),recordJson1__c=json.serialize(sobjectlist));
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampindex__c,recordjson0__c,recordJson1__c from DataArchive__b where indexNumber__c=0 and datetimestampindex__c=\'HeadersIndex\'',new List<DataArchive__b>{headerRec}); 
        Test.startTest();
        ArchivalHelperController.getSetupRequired();
        ArchivalHelperController.createSetupForArchival();
        ArchivalHelperController.getReportingData();
        Test.stopTest();
    }
   
}
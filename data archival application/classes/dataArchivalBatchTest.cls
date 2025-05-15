@isTest
public class dataArchivalBatchTest {
     @TestVisible
    private static Boolean isError=false;
    @testsetup public static void  dataArchivalBatch ()
    {
       
        Data_Archival_Object_Settings__c datsetting = new Data_Archival_Object_Settings__c();
        // datsetting.Id=null;
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
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Type = 'OEM';
        insert acc;
        
        
        Contact con = new Contact();
        con.LastName = 'Gupta';
        con.FirstName = 'Sumit';
        con.AccountId = acc.Id;
        con.Email='sumit13.gupta@nttdata.com';
        insert con;
        
        Case cseLow1 = new Case();
        cseLow1.Origin = 'Email-EMS-Norcross';
        cseLow1.Status = 'Open';
        cseLow1.ContactId = con.Id;
        cseLow1.Type = 'Other';
        
        
        //    cseLow1.LastViewedDate=system.today();
        insert cseLow1; 
        
        //  Archival_date__c ar=new Archival_date__c(name='EmailMessage',Days__c='30');
        //ar.Object_Name__c='EmailMessage';
        // insert ar;
        Data_Archival_Object_Settings__c datsetting1 = new Data_Archival_Object_Settings__c();
        // datsetting.Id=null;
        datsetting1.Object_Name__c='EmailMessage';
        datsetting1.Object_type__c='Child';
        datsetting1.Archival_From_Date__c=system.Now();
        datsetting1.Archival_To_Date__c=system.Now()+5;
        datsetting1.Name='Test1';
        datsetting1.FilterField_1__c='status';
        datsetting1.FilterField_2__c='type';
        datsetting1.filterValue_1__c='open';
        datsetting1.filterValue_2__c='other';
        datsetting1.Parent_Setting_Name__c='2020-05-29 05:02:50-673';
        datsetting1.Submitted_By__c=userinfo.getuserId().substring(0,15);
        datsetting1.Hierarchy_Level__c='2';
        datsetting1.Status__c='completed';
        datsetting1.relationship_field__c='ParentId';
        
        insert datsetting1;
        
        data_archival_settings__c	dataarchive= new data_archival_settings__c();
        dataarchive.indexNumber__c=1;
        dataarchive.Name='currentIndex';
        
        insert dataarchive;
        dataarchive.Record_id__c=dataarchive.id;
        update dataarchive;
        
    }
    public static testmethod void databatcharchivalTest3()
    {
        Map<String,Decimal> sobjectlist=new Map<String,Decimal>();
        
        //DataArchive__b header = new DataArchive__b();
        DataArchive__b headerRec=new DataArchive__b (indexNumber__c=0,datetimestampindex__c='HeadersIndex',recordjson0__c=json.serialize(sobjectlist),recordJson1__c=json.serialize(sobjectlist));
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampindex__c,recordjson0__c,recordJson1__c from DataArchive__b where indexNumber__c=0 and datetimestampindex__c=\'HeadersIndex\'',new List<DataArchive__b>{headerRec}); 
        //  DataArchive__b header = new DataArchive__b();
        Test.startTest();
        system.debug('test debug ='+[select id from case]);
        dataArchivalBatch databatch = new dataArchivalBatch('Case','parent',false);
        DataBase.executeBatch(databatch);     
        Map<string,string> indexmap=new Map<string,string>();
        integer varindex=0;
        List<Decimal> indexList=new List<Decimal>(1);
        
        data_archival_settings__c	dataarchive= new data_archival_settings__c();
        
        
        DataArchive__b data = new DataArchive__b();
        // DataArchive__b archived =new DataArchive__b (indexNumber__c=0,datetimestampindex__c='HeadersIndex',recordjson0__c='1-0',recordjson1__c='1-0',recordjson2__c='1-0',recordjson3__c='1-0',recordjson4__c='1-0',recordjson5__c='1-0',recordjson6__c='1-0',recordjson7__c='1-0',recordjson8__c='1-0',recordjson9__c='1-0',recordjson10__c='1-0',recordjson11__c='1-0');
        DataArchive__b archived =new DataArchive__b (indexNumber__c=1,datetimestampindex__c='HeadersIndex',recordjson0__c='null');
        system.debug(indexmap);
        system.debug(sobjectlist);
        system.debug(indexList);
        system.debug(archived);
        
        system.debug(varindex + ' ' +data);
        List<String> processedIndexes=new List<String>();
        system.debug('processedIndexes'+processedIndexes);
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampIndex__c,recordjson0__c,recordjson1__c,recordjson2__c, recordjson3__c, recordjson4__c,'+
                                                    'recordjson5__c, recordjson6__c, recordjson7__c, recordjson8__c, recordjson9__c, recordjson10__c,recordjson11__c from DataArchive__b where indexNumber__c IN ' +indexlist,new List<DataArchive__b>{archived});
        //  system.debug('select indexNumber__c,datetimestampIndex__c,recordjson0__c,recordjson1__c,recordjson2__c, recordjson3__c, recordjson4__c,'+
        //              'recordjson5__c, recordjson6__c, recordjson7__c, recordjson8__c, recordjson9__c, recordjson10__c,recordjson11__c from DataArchive__b where indexNumber__c IN ' +indexlist);
        system.debug(indexmap);
        system.debug(archived);
        
        system.debug(varindex + ' ' +data);      
        
        
        Test.stopTest();
        
    }
    public static testmethod void databatcharchivalTest4()
    {
        
        Map<String,Decimal> sobjectlist=new Map<String,Decimal>();
        //DataArchive__b header = new DataArchive__b();
        DataArchive__b headerRec=new DataArchive__b (indexNumber__c=0,datetimestampindex__c='HeadersIndex',recordjson0__c='1-0');
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampindex__c,recordjson0__c,recordJson1__c from DataArchive__b where indexNumber__c=0 and datetimestampindex__c=\'HeadersIndex\'',new List<DataArchive__b>{headerRec}); 
        //  DataArchive__b header = new DataArchive__b();
        Test.startTest();
        system.debug('test debug ='+[select id from case]);
        dataArchivalBatch databatch = new dataArchivalBatch('Case','parent',false);
        DataBase.executeBatch(databatch);     
        Map<string,string> indexmap=new Map<string,string>();
        integer varindex=0;
        List<Decimal> indexList=new List<Decimal>(1);
        
        data_archival_settings__c	dataarchive= new data_archival_settings__c();
        
        
        DataArchive__b data = new DataArchive__b();
        // DataArchive__b archived =new DataArchive__b (indexNumber__c=0,datetimestampindex__c='HeadersIndex',recordjson0__c='1-0',recordjson1__c='1-0',recordjson2__c='1-0',recordjson3__c='1-0',recordjson4__c='1-0',recordjson5__c='1-0',recordjson6__c='1-0',recordjson7__c='1-0',recordjson8__c='1-0',recordjson9__c='1-0',recordjson10__c='1-0',recordjson11__c='1-0');
        DataArchive__b archived =new DataArchive__b (indexNumber__c=1,datetimestampindex__c='HeadersIndex',recordjson0__c='null');
        system.debug(indexmap);
        system.debug(sobjectlist);
        system.debug(indexList);
        system.debug(archived);
        
        system.debug(varindex + ' ' +data);
        List<String> processedIndexes=new List<String>();
        system.debug('processedIndexes'+processedIndexes);
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampIndex__c,recordjson0__c,recordjson1__c,recordjson2__c, recordjson3__c, recordjson4__c,'+
                                                    'recordjson5__c, recordjson6__c, recordjson7__c, recordjson8__c, recordjson9__c, recordjson10__c,recordjson11__c from DataArchive__b where indexNumber__c IN ' +indexList,new List<DataArchive__b>());
        
        //   system.debug('select indexNumber__c,datetimestampIndex__c,recordjson0__c,recordjson1__c,recordjson2__c, recordjson3__c, recordjson4__c,'+
        //            'recordjson5__c, recordjson6__c, recordjson7__c, recordjson8__c, recordjson9__c, recordjson10__c,recordjson11__c from DataArchive__b where indexNumber__c IN ' +indexlist);
        
        system.debug(indexmap);
        system.debug(archived);
        
        system.debug(varindex + ' ' +data);      
        
        Test.stopTest();
        
    }
    public static testmethod void databatcharchivalTest1()
    {
        Boolean isError=true;
        Map<String,Decimal> sobjectlist=new Map<String,Decimal>();
        DataArchive__b header = new DataArchive__b(indexNumber__c=1,datetimestampindex__c='HeadersIndex');
        DataArchive__b headerRec=new DataArchive__b (indexNumber__c=0,datetimestampindex__c='HeadersIndex');
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampindex__c,recordjson0__c,recordJson1__c from DataArchive__b where indexNumber__c=0 and datetimestampindex__c=\'HeadersIndex\'',new List<DataArchive__b>{headerRec}); 
        // DataArchive__b header = new DataArchive__b();
        Test.startTest();
        system.debug('test debug ='+[select id from case]);
        dataArchivalBatch databatch = new dataArchivalBatch('Case','parent',false);
        DataBase.executeBatch(databatch);
        
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampIndex__c,recordjson0__c,recordjson1__c,recordjson2__c, recordjson3__c, recordjson4__c,'+'recordjson5__c, recordjson6__c, recordjson7__c, recordjson8__c, recordjson9__c, recordjson10__c,recordjson11__c from DataArchive__b where indexNumber__c!=0 and indexNumber__c=1',new List<DataArchive__b>{header}); 
        
        Test.stopTest();
        
    }
    
    public static testmethod void databatcharchivalTest2()
    {
        Boolean isError=false;
        Map<String,Decimal> sobjectlist=new Map<String,Decimal>();
        //DataArchive__b header = new DataArchive__b();
        DataArchive__b headerRec=new DataArchive__b (indexNumber__c=0,datetimestampindex__c='HeadersIndex');
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampindex__c,recordjson0__c,recordJson1__c from DataArchive__b where indexNumber__c=0 and datetimestampindex__c=\'HeadersIndex\'',new List<DataArchive__b>{headerRec}); 
        //  DataArchive__b header = new DataArchive__b();
        Test.startTest();
        system.debug('test debug ='+[select id from case]);
        dataArchivalBatch databatch = new dataArchivalBatch('Case','parent',false);
        DataBase.executeBatch(databatch);
        
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampIndex__c,recordjson0__c,recordjson1__c,recordjson2__c, recordjson3__c, recordjson4__c,'+'recordjson5__c, recordjson6__c, recordjson7__c, recordjson8__c, recordjson9__c, recordjson10__c,recordjson11__c from DataArchive__b where indexNumber__c!=0 and indexNumber__c=1',new List<DataArchive__b>()); 
        
        DataBase.executeBatch(databatch);
        
        
        Test.stopTest();
        
    }
    
    
    public static testmethod void childArchivalBatchTest()
    { 
        DataArchive__b headerRec=new DataArchive__b (indexNumber__c=0,datetimestampindex__c='HeadersIndex');
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampindex__c,recordjson0__c,recordJson1__c from DataArchive__b where indexNumber__c=0 and datetimestampindex__c=\'HeadersIndex\'',new List<DataArchive__b>{headerRec});   
        Test.startTest();
        childArchivalBatch childbatch = new childArchivalBatch('EmailMessage','child');
        DataBase.executeBatch(childbatch);
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampIndex__c,recordjson0__c,recordjson1__c,recordjson2__c, recordjson3__c, recordjson4__c,'+'recordjson5__c, recordjson6__c, recordjson7__c, recordjson8__c, recordjson9__c, recordjson10__c,recordjson11__c from DataArchive__b where indexNumber__c!=0 and indexNumber__c=1',new List<DataArchive__b>()); 
        Test.stopTest();
        
    }
     @TestVisible
     public static testmethod void insertBigobjectqueueTest()
    {
        insertBigObjectQueueable.isError=true;
        Boolean isError=false;
        Map<String,Decimal> sobjectlist=new Map<String,Decimal>();
        DataArchive__b header = new DataArchive__b(indexNumber__c=1,datetimestampindex__c='HeadersIndex');
        DataArchive__b headerRec=new DataArchive__b (indexNumber__c=1);
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampindex__c,recordjson0__c,recordJson1__c from DataArchive__b where indexNumber__c=0 and datetimestampindex__c=\'HeadersIndex\'',new List<DataArchive__b>{headerRec}); 
        // DataArchive__b header = new DataArchive__b();
        Test.startTest();
        system.debug('test debug ='+[select id from case]);
        dataArchivalBatch databatch = new dataArchivalBatch('Case','parent',false);
        DataBase.executeBatch(databatch);
        
        bigObjectQueryService.bigObjectQueryMap.put('select indexNumber__c,datetimestampIndex__c,recordjson0__c,recordjson1__c,recordjson2__c, recordjson3__c, recordjson4__c,'+'recordjson5__c, recordjson6__c, recordjson7__c, recordjson8__c, recordjson9__c, recordjson10__c,recordjson11__c from DataArchive__b where indexNumber__c!=0 and indexNumber__c=1',new List<DataArchive__b>{header}); 
        
        Test.stopTest();
        
    }
    
}
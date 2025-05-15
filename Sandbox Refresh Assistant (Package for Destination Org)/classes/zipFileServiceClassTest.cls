@isTest
private class zipFileServiceClassTest {
    @testSetup
    private static void testSetup(){
        ContentVersion docVersion = new ContentVersion(
            Title = 'metadata.txt',
            PathOnClient ='metadata.txt',
            contentLocation='S',
            recordtypeid=schema.sobjecttype.contentversion.getRecordtypeInfosByname().get('refresh backup').getrecordtypeid(),
            VersionData = blob.valueOf('test'),
            IsMajorVersion = true,
            org_Name__c='testOrg',
            FirstPublishLocationId=[select id,developerName from contentWorkspace limit 1 ].developerName
        );  
        
    }
       @isTest
    private static void doGetTest(){
           RestRequest request=new RestRequest();
        restContext.response=new restResponse();
        zipFileServiceClass.doGet();
        system.assertEquals(400,restcontext.response.statusCode);

         request.addHeader('isMetadata','false');
         request.addHeader('orgName','testOrg');
        restContext.request=request;
        zipFileServiceClass.doGet();
        system.assertEquals(200,restcontext.response.statusCode);
           request.addHeader('isMetadata','true');
         restContext.request=request;
        zipFileServiceClass.doGet();
        system.assertEquals(200,restcontext.response.statusCode);
    }
    
    @isTest
    private static void doPostTest(){
        string fileBody=encodingUtil.base64Encode(blob.valueOf('test'));
        Map<String,string> contentBody=new Map<String,string>();
        contentBody.put('contentBody',fileBody);
        RestRequest request=new RestRequest();
        restContext.request=request;
        restContext.response=new restResponse();
        test.startTest();
        zipFileServiceClass.doPost();
        system.assertEquals(400,restcontext.response.statusCode);
        request.addHeader('orgName','testOrg');
        request.addHeader('fileName','custom setting.txt');
        request.addHeader('libraryName',[select id,developerName from contentWorkspace limit 1 ].developerName);
        request.requestBody=Blob.valueof(json.serialize(contentBody));
        zipFileServiceClass.doPost();
        system.assertEquals(200,restcontext.response.statusCode);
        test.stopTest();
    }
    
    @isTest
    private static void doDeleteTest(){
         string fileBody=encodingUtil.base64Encode(blob.valueOf('test'));
       Map<String,string> contentBody=new Map<String,string>();
        contentBody.put('contentBody',fileBody);
        RestRequest request=new RestRequest();
        restContext.response=new restResponse();
        test.startTest();
        zipFileServiceClass.doDelete();
        system.assertEquals(400,restcontext.response.statusCode);
        restContext.request=request;
        request.addHeader('objects','custom settings');
        zipFileServiceClass.doDelete();
         system.assertEquals(200,restcontext.response.statusCode);
       request.addHeader('objects','metadata');
        zipFileServiceClass.doDelete();
        system.assertEquals(200,restcontext.response.statusCode);
        test.stopTest();
    }
}
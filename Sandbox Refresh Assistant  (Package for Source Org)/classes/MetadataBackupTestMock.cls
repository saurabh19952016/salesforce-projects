@isTest(seeAllData = false)
public class MetadataBackupTestMock implements HttpCalloutMock{
  public HTTPResponse respond(HTTPRequest request)
  {
      HttpResponse response = new HttpResponse();
       String testEndPoint = (String) request.getEndpoint(); // get the end point 
      
      response.setBody(JSON.serialize(new responseWrapper()) );
      
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
      return response;
  }
    
    private with sharing class responseWrapper
    {
         public string id='test';
        public string access_token='test';
        public string instance_url='test';
        public string error='testtest';
        public string status='SUCCESS';
    }
}
@isTest
public class metadataCalloutMock implements WebServiceMock {
    public void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction, 
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
            // start - specify the response you want to send
        
            if(requestName=='listMetadata'){
                MetadataService.listMetadataResponse_element responseELement=new MetadataService.listMetadataResponse_element();
                List<MetadataService.FileProperties> fileProperties=new List<MetadataService.FileProperties>();
                MetadataService.FileProperties fileProp=new MetadataService.FileProperties();
                fileProp.fileName='self Org';
                fileProp.fullname='selfOrg';
                fileProp.createdDate=system.now();
                fileProperties.add(fileProp);
                responseElement.result=fileProperties;
                response.put('response_x',responseELement);
            }
       
        } 
}
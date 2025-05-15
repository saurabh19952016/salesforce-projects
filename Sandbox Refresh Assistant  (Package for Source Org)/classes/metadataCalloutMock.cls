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
            if(requestName=='deleteMetadata'){ 
                MetadataService.deleteMetadata_element requestElement=(MetadataService.deleteMetadata_element )request;
                List<String> fieldList=requestElement.fullNames;
                List<MetadataService.deleteResult> responseList= new List<MetadataService.deleteResult>();
                MetadataService.deleteResult result=new MetadataService.deleteResult();
                
                if(fieldList.size()>0){
                    result.success=true;
                }else{
                    result.success=false;
                } 
                responseList.add(result);
                MetadataService.deleteMetadataResponse_element responseElement=new MetadataService.deleteMetadataResponse_element();
                responseELement.result=responseList;
                response.put('response_x',responseELement);
            }
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
            if(requestName=='cancelDeploy'){ 
                MetadataService.cancelDeploy_element requestElements=(MetadataService.cancelDeploy_element )request;
                // List<String> fieldList=requestElements.String_x ;
                // List<MetadataService.CancelDeployResult> responseLists= new List<MetadataService.CancelDeployResult>();
                MetadataService.CancelDeployResult results=new MetadataService.CancelDeployResult();
                results.done =true;
                MetadataService.cancelDeployResponse_element responseElements=new MetadataService.cancelDeployResponse_element();
                responseELements.result =results;
                response.put('response_x',responseELements);
            }
            if(requestName=='checkDeployStatus'){ 
                MetadataService.checkDeployStatus_element requestEle=(MetadataService.checkDeployStatus_element )request;
                // List<MetadataService.DeployResult> responseList= new List<MetadataService.DeployResult>();
                MetadataService.DeployResult resultdata=new MetadataService.DeployResult();
                
                resultdata.done  =true;
                resultdata.status='success';
                MetadataService.checkDeployStatusResponse_element responseElement=new MetadataService.checkDeployStatusResponse_element();
                responseELement.result=resultdata;
                response.put('response_x',responseELement);
            }
            if(requestName=='deploy'){ 
                MetadataService.deploy_element requestEle=(MetadataService.deploy_element )request;
                // List<MetadataService.DeployResult> responseList= new List<MetadataService.DeployResult>();
                MetadataService.AsyncResult resultdata=new MetadataService.AsyncResult();
               
                resultdata.done  =true;
                
                MetadataService.deployResponse_element responseElement=new MetadataService.deployResponse_element();
                responseELement.result=resultdata;
                response.put('response_x',responseELement);
            }
            if(requestName=='describeMetadata'){ 
                // MetadataService.describeMetadata_element reqEle=(MetadataService.describeMetadata_element )request;
                
                // List<MetadataService.DeployResult> responseList= new List<MetadataService.DeployResult>();
                MetadataService.DescribeMetadataResult resdata=new MetadataService.DescribeMetadataResult();
                
                List<MetadataService.DescribeMetadataObject> metadataObjects=new List<MetadataService.DescribeMetadataObject>();
                MetadataService.DescribeMetadataObject metobject=new MetadataService.DescribeMetadataObject();
                metobject.xmlName= 'ApexClass';
                    metadataObjects.add(metObject);
                resdata.metadataObjects=metadataObjects;
                MetadataService.describeMetadataResponse_element responseElement=new MetadataService.describeMetadataResponse_element();
                
                responseElement.result=resdata;
                response.put('response_x',responseElement);
            }
            if(requestName=='checkRetrieveStatus')
            { 
                MetadataService.checkRetrieveStatus_element requestElements=(MetadataService.checkRetrieveStatus_element )request;
                // List<MetadataService.DeployResult> responseList= new List<MetadataService.DeployResult>();
                MetadataService.RetrieveResult resltdata=new MetadataService.RetrieveResult();
                resltdata.status='Succeeded';
                
                resltdata.done  =true;
                zippex zpFile=new zippex();
                zpfile.addFile('test file',blob.valueOf('test'),null);
                resltdata.zipFile=encodingUtil.base64Encode(zpfile.getZipArchive());
                MetadataService.checkRetrieveStatusResponse_element responseElement=new MetadataService.checkRetrieveStatusResponse_element();
                responseELement.result=resltdata;
                response.put('response_x',responseELement);
            }
                if(requestName=='retrieve')
            { 
                MetadataService.retrieve_element  requestElements=(MetadataService.retrieve_element  )request;
                // List<MetadataService.DeployResult> responseList= new List<MetadataService.DeployResult>();
               MetadataService.AsyncResult  resltdata=new MetadataService.AsyncResult();
                resltdata.Id='testApexClassId';
                
                resltdata.done  =true;
                
                MetadataService.retrieveResponse_element responseElement=new MetadataService.retrieveResponse_element();
                responseELement.result=resltdata;
                response.put('response_x',responseELement);
            }
            
        } 
}
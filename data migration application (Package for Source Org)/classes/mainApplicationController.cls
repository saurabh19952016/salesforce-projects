public without sharing class mainApplicationController {
    private static final Integer METADATA_API_VERSION = Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));
    
    @AuraEnabled(cacheable=true)
    public static appWrapper getIsAuthenticated(string appName){
        Map<String,Data_Migration_Auth__c> authMap=Data_Migration_Auth__c.getAll();
        appWrapper appwrap=new appWrapper();
        appwrap.isAuthenticated=authMap.containskey(appName);
        system.debug(authMap.containsKey(appName));
        appwrap.isSandbox=[select isSandbox from organization limit 1].isSandbox;
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = getSessionId();
        List<MetadataService.ListMetadataQuery> query = new list<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery queryString = new MetadataService.ListMetadataQuery();
        queryString.type_x = 'NamedCredential';
        query.add(queryString);
        List<String> namedCredList=new List<String>();
        MetadataService.FileProperties[] listMetadata = service.listMetadata(query,METADATA_API_VERSION);
        for(MetadataService.FileProperties namedCred:listMetadata){
            namedCredList.add(namedCred.fullname);
        }
        if(namedCredList.size()>0){
            appwrap.namedCredentialList=namedCredList;
        }
        else{
            appwrap.namedCredentialList=new List<String>();
        }
        
        List<ContentWorkspace> libList=[select id,DeveloperName from ContentWorkspace where developername!=null];
        if(liblist.size()>0){
            appwrap.libraryList=libList;
        }
        else{
            appwrap.libraryList=new List<ContentWorkspace>();
        }
        
        return appwrap;
    }
    
    @AuraEnabled
    public static responseWrapper saveDetails(string appName,Data_Migration_Auth__c authsetting){
        responseWrapper respWrap=new  responseWrapper();
        try{
            /*  if(appName=='refresh'){
List<ContentWorkspace> cwlist=[select id from ContentWorkspace where developerName=:authsetting.library_name__c];
if(cwlist.isempty()){
respwrap.success=false;
respWrap.message='Library Name doesn\'t exist. Please provide the API Name of a valid library.';
return respWrap;
}
}   */    
            List<Data_Migration_Auth__c> authsettingList=[select id from Data_Migration_Auth__c where name=:appName];
            if(authsettingList.size()>0){
                delete authsettingList;
            }
            authsetting.name=appName;
            authsetting.org_name__c=url.getSalesforceBaseUrl().toExternalForm();
            insert authsetting;
            respWrap.success=true;
        }
        catch(exception ex){
            respWrap.success=false;
            respWrap.message=ex.getMessage();
        }
        return respWrap;
    }
    
    public static string getSessionId(){
        string sessionId;
        PageReference reportPage = Page.SessionIdpage;
        if(!test.isrunningTest()){
            String vfContent= reportPage.getContent().toString();
            Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                endP = vfContent.indexOf('End_Of_Session_Id');
            sessionId = vfContent.substring(startP, endP);
        }
        else{
            sessionId='sfiqh4oqwpdkad';
        }        
        return sessionid;
    }         

    public class appWrapper{
        @AuraEnabled
        public boolean isSandbox{get;set;}
        @AuraEnabled
        public boolean isAuthenticated{get;set;}
        @AuraEnabled
        public List<ContentWorkspace> libraryList{get;set;}
        @AuraEnabled
        public List<string> namedCredentialList{get;set;}
        
    }
    
    public class responseWrapper{
        @AuraEnabled
        public boolean success{get;set;}
        @AuraEnabled
        public string message{get;set;}
    }
}
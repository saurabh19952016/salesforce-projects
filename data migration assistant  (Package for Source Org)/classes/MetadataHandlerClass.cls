public class MetadataHandlerClass {
    private static string sessionId;
    public static string getSessionId(){
        PageReference reportPage = Page.SessionIdpage;
        String vfContent='';
        if(!test.isrunningTest()){
            vfContent= reportPage.getContent().toString();
        }
        else{
            vfContent='Start_Of_Session_Idsfiqh4oqwpdkadEnd_Of_Session_Id';
        } 
            Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
            sessionId = vfContent.substring(startP, endP);
             
        return sessionid;
    }   
    
    public static responseWrapper getSessionId(authWrapper oauth){
        Http http=new Http();
        httprequest request=new httpRequest();
        request.setMethod('POST');
        
        request.setEndpoint(oauth.endpoint + '/services/oauth2/token?grant_type=password&client_id='
                            + oauth.clientId +'&client_secret=' + oauth.clientSecret +'&username=' + oauth.username + 
                            + '&password=' +oauth.password + oauth.securityToken);
        HttpResponse resp=http.send(request);
        system.debug(resp.getBody());
        responseWrapper respWrapper=new responseWrapper();
        if(resp.getStatusCode()==200){
            respWrapper=(responseWrapper)json.deserialize(resp.getBody(),responseWrapper.class);
            system.debug(resp.getBody());
            respwrapper.status='SUCCESS';
        }
        else{
            respWrapper.error='Authentication Failed. Please check if you have remote site settings saved for the endpoint or check your credentials and try again.';
            respwrapper.status='ERROR';
        }
        return respWrapper;
    }
    
    public static HttpRequest getRequest(string requestUri,String body,string method,Boolean isSoapAction){
        HttpRequest request=new HttpRequest();
        request.setEndpoint(requestUri);
        if(isSoapAction){
            request.setHeader('SoapAction','""');
            request.setHeader('Content-Type','text/xml');
        }
        request.setMethod(method);
        if(method != 'GET')
            request.setBody(body);
        request.setHeader('Authorization' , 'Bearer ' + sessionId);
        return request;
    }
    
    public static httpresponse getResponse(HttpRequest req){
        http h=new http();
        return h.send(req);
    }
    
    public static Dom.XMLNode InitializeXML(DOM.Document doc,String XMLmethod,string sessionId){
        dom.XmlNode envelope = doc.createRootElement('Envelope',System.label.env_namespace , 'sopaenv');
        envelope.setNamespace('met',System.label.meta_namespace);
        envelope.setNamespace('xsi',System.label.ins_namespace);
        dom.XmlNode Header=envelope.addChildElement('Header',System.label.env_namespace,'soapenv');
        if(xmlMethod=='updateMetadata')
            header.addChildElement('AllOrNoneHeader',System.label.meta_namespace,'met').addChildElement('allOrNone',null,null).addTextNode('true');
        header.addChildElement('SessionHeader',System.label.meta_namespace,'met').addChildElement('sessionId',null,null).addTextNode(sessionId);
        return envelope.addChildElement('Body',System.label.env_namespace,'soapenv').addChildElement(XMLmethod,System.label.meta_namespace,'met');
    }
    
    public static void sendMail(String subject,String body){
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserInfo.getUserEmail()};
            mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Data Migration Application');
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public class responseWrapper {
        public string id;
        public string access_token;
        public string instance_url;
        @AuraEnabled
        public string error{get;set;}
        @AuraEnabled
        public string status{get;set;}
    }
    
    public class authWrapper{
        @AuraEnabled
        public string clientId{get;set;}
        @AuraEnabled
        public string username{get;set;}
        @AuraEnabled
        public string password{get;set;}
        @AuraEnabled
        public string clientSecret{get;set;}
        @AuraEnabled
        public string securityToken{get;set;}
        @AuraEnabled
        public string targetOrgId{get;set;}
        @AuraEnabled
        public string endPoint{get;set;}
        public authWrapper(){}
        public authWrapper(Data_Migration_Auth__c authSettings){
            this.clientId=authSettings.client_id__c;
            this.username=authSettings.username__c;
            this.password=authSettings.password__c;
            this.clientSecret=authSettings.client_secret__c;
            this.securityToken=authSettings.security_Token__c;
            this.targetOrgId=authSettings.targetOrgId__c;
            this.endPoint=authSettings.endpoint__c ;
        }
    }
}
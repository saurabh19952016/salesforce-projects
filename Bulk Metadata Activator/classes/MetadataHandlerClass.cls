public class MetadataHandlerClass {
    private static string sessionId;
    
    public static void getSessionId(){
         String data = Page.SessionIdpage.getContent().toString();
        PageReference reportPage = Page.SessionIdpage;
        String vfContent = reportPage.getContent().toString();
        System.debug('vfContent '+vfContent);
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
        sessionId = vfContent.substring(startP, endP);
        System.debug('sessionId '+sessionId);       
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
    
    public static Dom.XMLNode InitializeXML(DOM.Document doc,String XMLmethod){
        dom.XmlNode envelope = doc.createRootElement('Envelope',System.label.env_namespace , 'sopaenv');
        envelope.setNamespace('met',System.label.meta_namespace);
        envelope.setNamespace('xsi',System.label.ins_namespace);
        dom.XmlNode Header=envelope.addChildElement('Header',System.label.env_namespace,'soapenv');
        if(xmlMethod=='updateMetadata')
            header.addChildElement('AllOrNoneHeader',System.label.meta_namespace,'met').addChildElement('allOrNone',null,null).addTextNode('true');
        header.addChildElement('SessionHeader',System.label.meta_namespace,'met').addChildElement('sessionId',null,null).addTextNode(sessionId);
        return envelope.addChildElement('Body',System.label.env_namespace,'soapenv').addChildElement(XMLmethod,System.label.meta_namespace,'met');
    }
    
    public static void sendMail(String body){
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserInfo.getUserEmail()};
            mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Metadata Activator');
        mail.setSubject('Metadata Ativation result');
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
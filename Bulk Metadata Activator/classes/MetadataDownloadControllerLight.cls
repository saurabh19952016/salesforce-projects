public class MetadataDownloadControllerLight {
    private static Map<String,query_settings__c> querymap;
    public static Map<String,Map<String,metadata>> metadatamap=new  Map<String,Map<String,metadata>>();  
    private static string requesturi=system.URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/45.0';
    private static string toolingUri=system.URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v45.0/tooling/query';
    private static Map<String,metadata> tempMap=new  Map<String,metadata> ();  
    private static String objName;
    
    @AuraEnabled
    public static List<String> getsobjectList(){
        List<String> SObjectList = new List<String>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
            system.debug(objTyp.getDescribe().getName());
            String name = objTyp.getDescribe().getName();
            if (!objTyp.getDescribe().isCustomSetting() && (objTyp.getDescribe().isCustom() || objTyp.getDescribe().isCreateable())){
                sobjectList.add(objTyp.getDescribe().getName());    
            }
        }
        sobjectList.sort();
        return sobjectlist;
    }
    
    @AuraEnabled
    public static Map<String,Map<String,metadata>> getMetadata(String objectname){
        MetadataHandlerClass.getSessionId();
        objname=objectname;
        querymap=query_settings__c.getAll();
        metadatamap=new  Map<String,Map<String,metadata>>();
        for(String meta:queryMap.keySet()){
            tempMap=new  Map<String,metadata> ();
            if(queryMap.get(meta).query__c != null && queryMap.get(meta).query__c != '')
                callToolingAPI(meta);
            else if((meta=='EntitlementProcess' && objName=='Case') || (meta!='EntitlementProcess'))
            {
                DOM.Document doc = new DOM.Document();
                DOM.xmlNode listmeta =MetadataHandlerClass.initializeXML(doc,'listMetadata');
                DOM.xmlNode queries=listmeta.addChildElement('queries',null,null);
                queries.addChildElement('folder',System.label.meta_namespace,'met').addTextNode(objname);
                queries.addChildElement('type',System.label.meta_namespace,'met').addTextNode(meta);
                listmeta.addChildelement('asOfVersion',System.label.meta_namespace,'met').addTextNode('40.0');
                HttpRequest req=MetadataHandlerClass.getRequest(requesturi,doc.toXmlString(),'POST',true);
                HttpResponse res=MetadataHandlerClass.getResponse(req);
                system.debug(res.getBody());
                //date new account(id='0010o00002ITPExAAP',description=doc.toXMLString());
                Dom.Document responseXML=res.getBodyDocument();
                dom.XmlNode[] result=responseXML.getRootELement().getChildElement('Body',System.label.env_namespace)
                    .getChildElement('listMetadataResponse',System.label.meta_namespace).getChildElements();
                readMetadata(result,meta);
                system.debug(metadataMap);
            }
        }  
        return metadatamap;
    }
    
    public static void readMetadata(dom.XmlNode[] result,string metatype){
        for(dom.XmlNode res:result){
            metadata m=new metadata();
            m.metid=res.getChildElement('id',System.label.meta_namespace).getText();
            system.debug(m.metid);
            String fullName=res.getChildElement('fullName',System.label.meta_namespace).getText();
            m.objectName=objname;
            m.metadatatype=metatype;
            m.componentname=fullName.contains('.')?fullName.substringAfterLast('.'):fullName;
            tempMap.put(fullName,m);
        }
        if(tempMap.size()>0)
        { 
            getStatus(tempMap,metatype);
            if(tempMap.size()>0)
            { 
                metadataMap.put(metatype,tempmap);
            }
        }
        
    }
    
    public static void callToolingAPI(String metatype){
        HttpRequest req=MetadataHandlerClass.getRequest(toolinguri+ queryMap.get(metatype).query__c+objname+'\'','','GET',true);
        HttpResponse res=MetadataHandlerClass.getResponse(req);
        map<String,object>  respMap=(map<String,object> )json.deserializeUntyped(res.getBody());
        list<object> objList=( list<object>)respMap.get('records');
        for(Object obj : objList){
            Map<String,Object> objMap=(Map<String,Object>)obj;
            system.debug(objMap);
            metadata m=new metadata();
            m.metid=String.valueof(objMap.get('Id'));
            m.objectName=objname;
            m.metadatatype=metatype;
            m.componentname=String.valueof(objMap.get('Name'));
            if(metatype=='ApexTrigger'){
                m.status=String.valueof(objMap.get('Status'));
                String body=String.valueof(objMap.get('Body'));
                m.triggerType=body.substringAfter('(').substringBefore(')').replace(',',';');
            }
            else
                m.status=String.valueof(objMap.get('Active'));  
            tempMap.put(m.componentname,m);
        }
        if(tempMap.size()>0)
            metadataMap.put(metatype,tempmap);
    }
    
    public static void getStatus(Map<String,metadata> metaMap,String metatype){
        DOM.Document doc = new DOM.Document();
        DOM.xmlNode readmeta =MetadataHandlerClass.initializeXML(doc,'readMetadata');
        readmeta.addChildElement('type',null,null).addTextNode(metatype);
        for(String key:metaMap.keyset())
            readmeta.addChildElement('fullNames',null,null).addTextNode(key);
        HttpRequest request=MetadataHandlerClass.getRequest(requesturi,doc.toXmlString(),'POST',true);
        HttpResponse response=MetadataHandlerClass.getResponse(request);
        Dom.Document responseXML=response.getBodyDocument();
        dom.XmlNode[] readresult=responseXML.getRootELement().getChildElement('Body',System.label.env_namespace)
            .getChildElement('readMetadataResponse',System.label.meta_namespace).getChildElement('result',System.label.meta_namespace).getChildElements();
        for(dom.XmlNode record: readresult)
        {
            updateStatusInMap(record,metaMap,metatype);   
        }
    }
    
    public static void updateStatusInMap(dom.XmlNode record,Map<String,metadata> metamap,string metatype){
        metadata m=new metadata();
        String fullName;
        dom.XmlNode[] recordElements=record.getChildElements();
        for(dom.XmlNode element: recordElements)
        {
            if(element.getText() != '' && element.getText() !=' ' && element.getText()!=null){
                if(element.getName() == 'fullName')
                {
                    fullName=element.getText();
                    m= metaMap.get(fullName);
                }
                else if(metatype=='Flow' && element.getName() == 'processType') {
                    m.processType=element.getText()=='Workflow'?'Process Builder':'Flow';
                    metamap.put(fullname,m);  
                }
                else if(element.getName() == 'active' || element.getName() == 'status' )
                {
                    
                    m.status=element.getText();
                    metamap.put(fullname,m);
                }
                else if(element.getName() == 'TriggerType' )
                {
                    
                    m.triggerType=element.getText();
                    metamap.put(fullname,m);
                }
            }
            else if(metatype=='Flow' && element.getName() == 'processMetadataValues'){
                string type=element.getChildElement('name',System.label.meta_namespace).getText();
                if(type=='ObjectType' || type=='TriggerType'){
                    string value=element.getChildElement('value',System.label.meta_namespace).getChildElement('stringValue',System.label.meta_namespace).getText();
                    if(type == 'ObjectType' && value!=objName)
                    {
                        metamap.remove(fullname);
                        break;
                    }
                    else if(type == 'TriggerType'){
                        m.triggerType=value;
                        metamap.put(fullname,m);  
                    } 
                }
            }
        }
    }
    

    public class metadata{
        @AuraEnabled
        public string metid;
        @AuraEnabled
        public string objectName;
        @AuraEnabled
        public string componentname;
        @AuraEnabled
        public string triggerType;
        @AuraEnabled
        public string metadatatype;
        @AuraEnabled
        public string status;
        @AuraEnabled
        public string processType;
    }
}
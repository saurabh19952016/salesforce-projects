public class MetadataActivationControllerLight {

    private static string metadataType;
    private static string requesturi=system.URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/45.0';
    public static List<string> errorList=new List<String>();    
    
    @AuraEnabled
    public static List<String> getMetadataValues(){
        Map<String,query_settings__c> querymap=query_settings__c.getAll();
        List<String> metalist=new List<String>();
        for(String meta:queryMap.keyset()){
          if(queryMap.get(meta).isActivateEnabled__c)  
            metalist.add(meta);
        }
        return metalist;
    }
    
    @AuraEnabled
    public static List<String> importCSVFile(String csvAsString,String metadata){
					metadatatype=metadata;
        try{
            List<String> csvFileLines = csvAsString.split('\n'); 
            List<String> validStatus=system.label.valid_flow_status.split(',');
            List<string> csvFieldNames = csvFileLines.get(0).split(',');
            Map<String,String> activationMap=new Map<String,String>();
            String column1Header=csvFileLines.get(0);
            if(csvFieldNames.size() == 3 && column1Header.containsIgnoreCase('Object Name') 
               && column1Header.containsIgnoreCase('Component Name') && column1Header.containsIgnoreCase('Status/ Active')){
                   List<String> ObjectApiNames= new List<String>();
                   for(Schema.SObjectType o : Schema.getGlobalDescribe().values()){
                       Schema.DescribeSObjectResult objResult = o.getDescribe();
                       ObjectApiNames.add(objResult.getName().toLowerCase());
                   }
                   system.debug(csvFileLines);
                   for(Integer i=1;i<csvFileLines.size();i++){
                       String objectName=csvFileLines.get(i).split(',').get(0).trim();
                       String componentName=csvFileLines.get(i).split(',').get(1).trim();
                       String status=csvFileLines.get(i).split(',').get(2).trim().toLowerCase();
                       if(ObjectApiNames.contains(objectName.toLowerCase())){
                           if(metadatatype=='Flow')
                           {
                               if(Pattern.matches(system.label.pattern,componentName) && validStatus.contains(status)){
                                   activationMap.put(componentName,status);
                               }
                               else
                               {
                                   errorList.add(system.label.invalid_flow_name1 + i + system.label.invalid_flow_name2);
                               }
                           }
                           else if(metadatatype=='EntitlementProcess'){
                               activationMap.put(componentName,status);
                           }
                           else
                           {
                               if(status.equals('true') || status.equals('false')){
                                   activationMap.put(objectName.toLowerCase().capitalize()+'.'+componentName,status);
                               }
                               else
                               {
                                   errorList.add(system.label.invalid_row1 + i  + system.label.invalid_row2);
                               }
                           }
                       }
                       else
                       {
                          errorList.add(system.label.invalid_object + i);
                       }
                   }
                   System.debug(activationMap);
                   if(errorList.size() == 0)
                   {
                       return makeUpdateRequest(activationMap);
                   }
               }
            else
                errorList.add(system.label.invalid_column);
        }
        catch (Exception e)
        {
            errorList.add(system.label.csv_error);
        } 
        return errorList;
    }
    
    public static List<String> makeUpdateRequest(Map<String,String> activationMap){
        try{
        DOM.Document doc = new DOM.Document();
        MetadataHandlerClass.getSessionId();
        DOM.xmlNode readmeta =MetadataHandlerClass.initializeXML(doc,'readMetadata');
        readmeta.addChildElement('type',null,null).addTextNode(metadatatype);
        for(String key:activationMap.keyset())
            readmeta.addChildElement('fullNames',null,null).addTextNode(key);
        HttpRequest request=MetadataHandlerClass.getRequest(requesturi,doc.toXmlString(),'POST',true);
        system.debug(doc.toXMLString());
        HttpResponse response=MetadataHandlerClass.getResponse(request);
        Dom.Document responseXML=response.getBodyDocument();
        //system.debug(responseXML.getRootELement().getChildElement('Body',System.label.env_namespace));
        dom.XmlNode[] result=responseXML.getRootELement().getChildElement('Body',System.label.env_namespace)
            .getChildElement('readMetadataResponse',System.label.meta_namespace).getChildElement('result',System.label.meta_namespace).getChildElements();
        doc= new Dom.Document();
        Dom.XmlNode updatemethod=MetadataHandlerClass.initializeXML(doc,'updateMetadata');
        for(dom.XmlNode record: result)
        {
            Dom.XmlNode updatemeta=updatemethod.addChildElement('metadata',System.label.meta_namespace,'met');
            updatemeta.setAttributeNS('type', metadatatype,System.label.ins_namespace,System.label.meta_namespace);
            system.debug(record.getAttributeValue('nil',System.label.ins_namespace));
            if(record.getAttributeValue('nil',System.label.ins_namespace)!='true')
                updateMeta=createXMLBody(record,updatemeta,activationMap);
            else
            {
                Integer Rownumber=result.indexOf(record) + 1;
                errorList.add(system.label.invalid_component_name + Rownumber);
            }
        }
        //update new account(id='0010o00002ITPExAAP',description=doc2.toXMLString());
        request=MetadataHandlerClass.getRequest(requesturi,doc.toXmlString(),'POST',true);
        if(errorList.size()==0)
        {
            String Message;
            response=MetadataHandlerClass.getResponse(request);
            if(response.getStatusCode() != 200)
            {
                Message=system.label.metadata_act_error1 + metadatatype + system.label.metadata_act_error2;
                Message+=response.getBodyDocument().toXMLString();
                errorList.add(Message);
            }
            else
            {
                Message=system.label.meta_act_successful;
                errorList.add(Message);
            }
            //MetadataHandlerClass.sendMail(Message);
        }
        else
        { 
           // MetadataHandlerClass.sendMail(string.join(errorList,'\n'));
        }
        }
        catch(Exception e){
            errorList.add('Unexpected Error occured while sending request.');
        }
                   return errorList;

    }
    
    public static Dom.XMLNode createXMLBody(dom.XmlNode record, dom.XmlNode updatemeta,Map<String,String> activationMap){
        String fullname;
        dom.XmlNode[] recordElements=record.getChildElements();
        dom.XMLNode tempNode;
        for(dom.XmlNode element: recordElements)
        {
            tempNode=updatemeta.addChildElement(element.getName(),null,null);
            if(element.getText() != '' && element.getText() !=' ' && element.getText()!=null){
                if(element.getName() == 'fullName')
                    fullname=element.getText();
                if(element.getName() == 'active' || (element.getName() == 'status' && metadatatype=='Flow' ))
                    tempNode.addTextNode(activationMap.get(fullName));
                else
                    tempNode.addTextNode(element.getText());                    
            }
            else
               tempNode=createXMLBody(element,tempNode,activationMap);
        }
        return updatemeta;
    }

}
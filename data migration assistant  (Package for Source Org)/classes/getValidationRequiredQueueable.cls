public class getValidationRequiredQueueable implements Queueable,Database.AllowsCallouts{
    private Map<String,Data_Migration__b> migrationMap;
    private MetadataHandlerClass.responseWrapper respwrapper;
    private data_archival_settings__c currentIndex;
    private Migration_Objects__c selectedObj;
    private List<String> tempList=new  List<String>();    
    private boolean getListData;
    
    public getValidationRequiredQueueable(Migration_Objects__c selectedObj,MetadataHandlerClass.responseWrapper respwrapper,Map<String,Data_Migration__b> migrationMap,data_archival_settings__c currentIndex,List<String> tempList,Boolean getListData){
        this.migrationMap=migrationMap;
        this.respwrapper=respwrapper;
        this.currentIndex=currentIndex;
        this.selectedObj=selectedObj;
        this.tempList=tempList;
        this.getListData=getListData;
    }
    public void execute(QueueableContext context){
        try{
           
            string requesturi= respwrapper.instance_url+'/services/Soap/m/45.0';
            if(getListData){
			 Http http=new Http();
            httprequest request=new httpRequest();
            request.setMethod('GET');
            DOM.Document doc = new DOM.Document();
            DOM.xmlNode listmeta =MetadataHandlerClass.initializeXML(doc,'listMetadata',respwrapper.access_token);
            DOM.xmlNode queries=listmeta.addChildElement('queries',null,null);
            queries.addChildElement('folder',System.label.meta_namespace,'met').addTextNode(selectedObj.objectName__c);
            queries.addChildElement('type',System.label.meta_namespace,'met').addTextNode('ValidationRule');
            listmeta.addChildelement('asOfVersion',System.label.meta_namespace,'met').addTextNode('47.0');
            HttpRequest req=MetadataHandlerClass.getRequest(requesturi,doc.toXmlString(),'POST',true);	
            HttpResponse res=MetadataHandlerClass.getResponse(req);
            system.debug(res.getBody());
            //update new case(id='5002v00002g3EWz',description=doc.toXmlString());	
            Dom.Document responseXML=res.getBodyDocument();
            dom.XmlNode[] result=responseXML.getRootELement().getChildElement('Body',System.label.env_namespace)
                .getChildElement('listMetadataResponse',System.label.meta_namespace).getChildElements();
                readMetadata(result,'ValidationRule',selectedObj.objectName__c);
            }
            if(templist.size()>0){
                 getStatus(tempList,'ValidationRule',respwrapper,requesturi);
                 system.enqueueJob(new getValidationRequiredQueueable(selectedObj,respwrapper,migrationMap,currentIndex,templist,false));
                }
            else{
                 system.enqueueJob(new getLayoutRequiredQueueable(selectedObj,respwrapper,migrationMap,currentIndex,new List<String>(),true));
                    /*database.insertImmediate(migrationMap.values());
                    update new data_archival_settings__c(indexNumber__c=currentIndex.indexNumber__c,id=currentIndex.Record_id__c);                
                    selectedObj.status__c='Completed';
                    update selectedObj;*/
                }
            
        }
        catch(Exception e){
            selectedObj.status__c='Failed';
            update selectedObj;                          
        }
    }
    private void readMetadata(dom.XmlNode[] result,string metatype,string objname){
        for(dom.XmlNode res:result){
            String fullName=res.getChildElement('fullName',System.label.meta_namespace).getText();
            tempList.add(fullName);
        }
    }
    
    private Map<String,Data_Migration__b> getStatus(List<String> metaList,String metatype,MetadataHandlerClass.responseWrapper respwrapper,string requesturi){
 		Map<String,Data_Migration__b> tempMap=new Map<String,Data_Migration__b> ();
        DOM.Document doc = new DOM.Document();
        DOM.xmlNode readmeta =MetadataHandlerClass.initializeXML(doc,'readMetadata',respwrapper.access_token);
        readmeta.addChildElement('type',null,null).addTextNode(metatype);
        for(integer index=0;index<metaList.size() && index<10;index++){
			            
            readmeta.addChildElement('fullNames',null,null).addTextNode(metalist[index]);
            templist.remove(index);
        }
        ///update new case(id='5002v00002g3EWz',description=doc.toXmlString());	
        HttpRequest request=MetadataHandlerClass.getRequest(requesturi,doc.toXmlString(),'POST',true);
        HttpResponse response=MetadataHandlerClass.getResponse(request);
        system.debug(response);
        Dom.Document responseXML=response.getBodyDocument();
        dom.XmlNode[] readresult=responseXML.getRootELement().getChildElement('Body',System.label.env_namespace)
            .getChildElement('readMetadataResponse',System.label.meta_namespace).getChildElement('result',System.label.meta_namespace).getChildElements();
        for(dom.XmlNode record: readresult)
        {
            dom.XmlNode[] recordElements=record.getChildElements();
            for(dom.XmlNode element: recordElements)
            {
                if(element.getName()=='active' && element.getName()=='false'){
                    break;
                }
                if(element.getName() == 'errorConditionFormula')
                {
                    string body=element.getText();
                    for(String fieldName:migrationmap.keyset()){
                        if(body.containsIgnoreCase(fieldName)){
                            migrationmap.get(fieldName).requiredInValidation__c='true';
                        }
                    }
                }
            }
        }
        return tempMap;
    }
    
}
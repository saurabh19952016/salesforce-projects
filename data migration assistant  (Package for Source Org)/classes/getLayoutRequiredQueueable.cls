public class getLayoutRequiredQueueable implements Queueable,Database.AllowsCallouts{
    private Map<String,Data_Migration__b> migrationMap;
    private MetadataHandlerClass.responseWrapper respwrapper;
    private data_archival_settings__c currentIndex;
    private Migration_Objects__c selectedObj;
    private List<String> tempList=new  List<String>();    
    private boolean getListData;
    
    public getLayoutRequiredQueueable(Migration_Objects__c selectedObj,MetadataHandlerClass.responseWrapper respwrapper,Map<String,Data_Migration__b> migrationMap,data_archival_settings__c currentIndex,List<String> tempList,Boolean getListData){    
        this.migrationMap=migrationMap;
        this.respwrapper=respwrapper;
        this.currentIndex=currentIndex;
        this.selectedObj=selectedObj;
        this.tempList=tempList;
        this.getListData=getListData;
    }
    
    public void execute(QueueableContext context){
        try{
            string requestUriMet= respwrapper.instance_url+'/services/Soap/m/45.0';
            string requestUriTooling= respwrapper.instance_url+'/services/data/v47.0/tooling/query?q=select+name+from+layout+where+TableEnumOrId=\'' + selectedObj.objectName__c + '\'';
            if(getListData){
                Http http=new Http();
                httprequest request=new httpRequest();
                request.setMethod('GET');
                request.setEndpoint(requestUriTooling);
                request.setHeader('Authorization', 'Bearer ' + respwrapper.access_token);
                httpresponse response=http.send(request);
                system.debug(response.getBody());
                Map<String,Object> responseMap=(Map<String,Object>)json.deserializeUntyped(response.getBody());
                List<Object> responseList=(List<Object>)responseMap.get('records');
                for(Object res:responseList){
                    Map<String,Object> resmap=(Map<String,Object>)res;
                    tempList.add(selectedObj.objectName__c +'-' + (String)resmap.get('Name'));
                    system.debug(tempList);
                }
            }
            system.debug(tempList);
            if(tempList.size()>0){
                getStatus(tempList,'Layout',respwrapper,requesturiMet);
                system.enqueueJob(new getLayoutRequiredQueueable(selectedObj,respwrapper,migrationMap,currentIndex,templist,false));
            }
            else{
                database.saveresult[] result=database.insertImmediate(migrationMap.values());
                for (Database.SaveResult sr : result) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                update new data_archival_settings__c(indexNumber__c=currentIndex.indexNumber__c,id=currentIndex.Record_id__c);                
                selectedObj.status__c='Completed';
                update selectedObj;
            }
            
        }
        catch(Exception e){
            selectedObj.status__c='Failed';
            update selectedObj;                          
        }
    }
    
    private void getStatus(List<String> metaList,String metatype,MetadataHandlerClass.responseWrapper respwrapper,string requesturi){
        DOM.Document doc = new DOM.Document();
        DOM.xmlNode readmeta =MetadataHandlerClass.initializeXML(doc,'readMetadata',respwrapper.access_token);
        readmeta.addChildElement('type',null,null).addTextNode(metatype);
        for(integer index=0;index<metaList.size() && index<10;index++){
            readmeta.addChildElement('fullNames',null,null).addTextNode(metalist[index]);
            templist.remove(index);
        }
        //update new case(id='5003C0000037pON',description=doc.toXmlString());	
        HttpRequest request=MetadataHandlerClass.getRequest(requesturi,doc.toXmlString(),'POST',true);
        HttpResponse response=MetadataHandlerClass.getResponse(request);
        //update new case(id='5003C0000037pON',description=response.getbody());	
        system.debug(response.getbody());
        Dom.Document responseXML=response.getBodyDocument();
        List<String> fieldStringList=new list<String>();
        fieldStringList.addAll(migrationmap.keyset());
        string fieldString=string.join(fieldStringList,',');
        dom.XmlNode[] readresult=responseXML.getRootELement().getChildElement('Body',System.label.env_namespace)
            .getChildElement('readMetadataResponse',System.label.meta_namespace).getChildElement('result',System.label.meta_namespace).getChildElements();
        for(dom.XmlNode record: readresult)
        {
            dom.XmlNode[] recordElements=record.getChildElements();
            for(dom.XmlNode element: recordElements)
            {
                if(element.getName()=='layoutSections'){
                    dom.XmlNode[] sectionElements=element.getChildElements();
                    for(dom.XmlNode section: sectionElements)
                    {	
                        if(section.getName()=='layoutColumns'){
                            dom.XmlNode[] columnElements=section.getChildElements();
                            for(dom.XmlNode column: columnElements)
                            {
                                dom.XmlNode[] itemElements=column.getChildElements();
                                if(itemElements[0].getName()=='behavior' && itemElements[1].getName()=='field'){
                                    string behavior=itemElements[0].getText();
                                    string field=itemElements[1].getText();
                                    if(behavior=='Required' && migrationmap.containsKey(field) && fieldString.containsIgnoreCase(field)){
                                        migrationmap.get(field).requiredInLayout__c='true';
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
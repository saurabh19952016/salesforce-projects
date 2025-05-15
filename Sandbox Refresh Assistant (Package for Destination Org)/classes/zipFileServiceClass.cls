@RestResource(urlMapping='/saveZipFile/*')
global class zipFileServiceClass{


@HttpGET
global static void doGet(){
    restresponse res=restcontext.response;
    returnBackup returnBkpObj=new returnBackup();
  try{
  restrequest req=restcontext.request;
    string orgName=req.headers.get('orgName');
    boolean isMetadata=boolean.valueof(req.headers.get('isMetadata'));
     string query='select Id,Title,CreatedDate,CreatedBy.Name,VersionNumber from contentversion where recordtype.name=\'refresh backup\' and fileextension=\'zip\' and org_name__c=:orgName';
        if(isMetadata==false){
           query+=' and title like \'custom settings%\'';
        }
        else if(isMetadata==true){
            query+=' and (not title  like \'custom settings%\')';          
        }
     returnBkpObj.docList=database.query(query);
     returnBkpObj.isSizeExceeded=getSize();
     returnBkpObj.downloadResourceURL=URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/';
       res.statusCode=200;
       res.responsebody=blob.valueof(json.serialize(returnBkpObj));
     }
    catch(Exception ex){
           res.statusCode=400;
           res.responsebody=blob.valueof('{"exception":"' + ex.getMessage() + ex.getLineNumber() +'","Status":"Failure"}');
  }
  
}

@HttpDELETE
global static void doDelete(){
  restresponse res=restcontext.response;
  try{
  restrequest req=restcontext.request;
    string orgName=req.headers.get('orgName');
    string objects=req.headers.get('objects');
    string query='select Id from contentDocument where LatestPublishedVersion.recordType.Name=\'refresh backup\' and LatestPublishedVersion.org_Name__c=:orgName';
        if(objects=='custom settings'){
           query+=' and title like \'custom settings%\'';
        }
        else if(objects=='metadata'){
            query+=' and (not title  like \'custom settings%\')';          
        }
     List<contentDocument> contentDocList=database.query(query);
     if(contentDocList.size()>0 && !test.isRunningTest()){
        delete contentDocList;
     }
     
     res.statusCode=200;
   res.responsebody=blob.valueof('{"Status":"Success"}');
    
  }
  catch(Exception ex){
   res.statusCode=400;
   res.responsebody=blob.valueof('{"exception":"' + ex.getMessage() + ex.getLineNumber() +'","Status":"Failure"}');
  }
}

@HttpPOST
global static void doPost(){
  restresponse res=restcontext.response;
  try{
  restrequest req=restcontext.request;
  string body=req.RequestBody.tostring().trim();
  string orgName=req.headers.get('orgName');
  string fileName=req.headers.get('fileName');
  string libraryName=req.headers.get('libraryName');
  system.debug(req.RequestBody.tostring());
  system.debug(req.RequestBody);
  Map<String,Object> zipFileMap=( Map<String,Object>)json.deserializeUntyped(body);
  String zipFileBody=(String)zipFileMap.get('contentBody');
  ContentWorkspace cw =[SELECT Id FROM ContentWorkspace WHERE DeveloperName = :libraryName limit 1];
  List<contentDocument> cdList=[select Id from contentDocument where LatestPublishedVersion.recordType.Name='refresh backup'
                       and LatestPublishedVersion.org_Name__c=:orgName and title=:fileName limit 1];
  ContentVersion docVersion = new ContentVersion(
            Title = fileName,
            PathOnClient =fileName,
            contentLocation='S',
            recordtypeid=schema.sobjecttype.contentversion.getRecordtypeInfosByname().get('refresh backup').getrecordtypeid(),
            VersionData = EncodingUtil.base64decode(zipFileBody),
            IsMajorVersion = true,
            org_Name__c=orgName
  );   
  if(cdList.size()>0){
        docVersion.ContentDocumentId= cdList[0].Id;
  }
  else{
        docVersion.FirstPublishLocationId = cw.Id;
  }
      if(!test.isRunningTest()){
        insert docVersion;
       }
  res.statusCode=200;
  res.responsebody=blob.valueof('{"Id":"' + docVersion.id +'","Status":"Success"}');
  }
  catch(Exception ex){
   res.statusCode=400;
   res.responsebody=blob.valueof('{"exception":"' + ex.getMessage() + ex.getLineNumber() +'","Status":"Failure"}');
  }
}


public static boolean getSize(){
    boolean returnVal=false;
    List<AggregateResult> aggrResultList=[select sum(contentSize) size from contentDocument where LatestPublishedVersion.recordType.Name='refresh backup'];
     for(AggregateResult aggrResult: aggrResultList){
    if((decimal)aggrResult.get('size')>decimal.valueOf(label.backup_library_size_limit)){
        returnVal=true;        
     }
     else{
        returnVal=false;        
      }
    }
    return returnVal;
}

public class returnBackup{
    public List<contentversion> docList{get;set;}
    public String downloadResourceURL{get;set;}
    public boolean isSizeExceeded{get;set;}
}

}
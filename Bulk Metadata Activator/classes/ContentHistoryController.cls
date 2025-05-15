public class ContentHistoryController {
    @AuraEnabled
    public static void documentHistory(String csvFileBody,string metadata,string objectName){
        Blob body=blob.valueOf(csvFileBody);
        ContentWorkspace cw =[SELECT Id FROM ContentWorkspace WHERE DeveloperName = 'Metadata_Activation_History'];
        ContentVersion docVersion = new ContentVersion(
            Title = objectname + ' ' +metadata,
            PathOnClient = objectname + ' ' +metadata +'.csv',
            contentLocation='S',
            FirstPublishLocationId = cw.Id,
            VersionData = body,
            IsMajorVersion = false 
        );        
        insert docVersion;
        system.debug(docversion);
    }
    
    @AuraEnabled
    public static List<contentVersion> getDownloadHistory(){
                ContentWorkspace cw =[SELECT Id FROM ContentWorkspace WHERE DeveloperName = 'Metadata_Activation_History'];
        List<ContentVersion> contVerList=[select id,Title,CreatedDate,CreatedBy.Name from contentVersion where FirstPublishLocationId=:cw.id];
        system.debug(contVerList);
        return contVerList;
    }
}
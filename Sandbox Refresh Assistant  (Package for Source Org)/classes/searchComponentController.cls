public class searchComponentController {
 @AuraEnabled(cacheable=true)
    public static List<String> getsobjectList(String QualifiedName){
        QualifiedName=QualifiedName+'%';
        List<String> sobjectlist=new List<String> ();
        List<EntityDefinition> sobjList = [SELECT MasterLabel, PluralLabel, KeyPrefix, DeveloperName, QualifiedApiName, NamespacePrefix FROM EntityDefinition WHERE IsCustomSetting = false and     
                                           IsEverCreatable=true and IsWorkflowEnabled=true and QualifiedApiName like :QualifiedName and  QualifiedApiName!='Attachment' order by QualifiedApiName limit 10];
        
        for(EntityDefinition s:sobjList)
            
        {
            sobjectlist.add(s.QualifiedApiName);
        } 
        return sobjectlist;      
    }
    
}
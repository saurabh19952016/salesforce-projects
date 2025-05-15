public class CustomSearchController {
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
    
}
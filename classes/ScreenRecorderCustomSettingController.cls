public class ScreenRecorderCustomSettingController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getApiSettingRecords(){
        Map<String,string> apiSettingMap=new Map<String,string>();
        for(Screen_recorder_settings__c apiSettings:[select id,name,field_value__c from Screen_recorder_settings__c where (NOT name  LIKE '%FLDVF%') and isApi__c=false and issfdc__c=false]){
            apiSettingMap.put(apisettings.name,apisettings.field_value__c);
        }
        return apiSettingMap;
    }
    
    @AuraEnabled
    public static void saveSettingRecords(Map<String,string> settingMap){
        try{
            system.debug(settingMap);
            delete [select id,name,field_value__c from Screen_recorder_settings__c where isApi__c=false and issfdc__c=false];
            List<Screen_recorder_settings__c> insertList=new List<Screen_recorder_settings__c>();
            for(string key:settingMap.keyset()){
                insertList.add(new Screen_recorder_settings__c(name=key,field_value__c=settingMap.get(key)));
            }
            if(insertList.size()>0){
                insert insertList;
            }
        }
        catch(exception ex){
            throw createAuraHandledException( ex.getMessage());
        }
    }
    
    @AuraEnabled 
    public static List<Screen_recorder_settings__c> getDefaultSettingRecords(string environment){
        try{
            string query='select id,name,field_value__c,isApi__c,isSFDC__c from Screen_recorder_settings__c where';
            if(environment=='Salesforce'){
                query+=' isSFDC__c=true';
            }
            else if(environment=='Target Environment'){
                query+=' isApi__c=true';
            }
            return database.query(query);
        }
        catch(exception ex){
            throw createAuraHandledException( ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void saveDefaultSettingRecords(List<Screen_recorder_settings__c> settingRecords, string environment){
        system.debug(settingRecords);
        try{
            string query='select id,name,field_value__c from Screen_recorder_settings__c where ';
            if(environment=='Salesforce'){
                query+=' isSFDC__c=true';
            }
            else if(environment=='Target Environment'){
                query+=' isApi__c=true';
            }
            database.delete(database.query(query));
            if(settingRecords.size()>0){
                insert settingRecords;
            }
        }
        catch(exception ex){
            throw createAuraHandledException( ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteSingleRecord(String settingRecordId){
        try{
            database.delete(database.query('select id from Screen_recorder_settings__c where Id=\''+settingRecordId+'\''));
        }
        catch(exception ex){
            throw createAuraHandledException( ex.getMessage());
        }
    }    
    
    
    private static AuraHandledException createAuraHandledException(String Message){
        AuraHandledException e = new AuraHandledException(Message);
        e.setMessage(Message);
        return e; 
    }
}
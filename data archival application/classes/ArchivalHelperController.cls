public class ArchivalHelperController {
    
    @AuraEnabled
    public static List<DataArchive__b> getSetupRequired(){     
        List<DataArchive__b> dataArchive=bigObjectQueryService.getQuery('select indexNumber__c,recordjson1__c from DataArchive__b where indexNumber__c=0 and datetimestampindex__c=\'HeadersIndex\'');
        return dataArchive;
    }
    
    @AuraEnabled
    public static void createSetupForArchival(){
        try{
            
            List<EntityDefinition> sobjList = [SELECT MasterLabel, PluralLabel, KeyPrefix, DeveloperName, QualifiedApiName, NamespacePrefix FROM EntityDefinition WHERE IsCustomSetting = false and     
                                               IsEverCreatable=true and IsWorkflowEnabled=true and  QualifiedApiName!='Attachment'];
            Map<String,Decimal> sobjectlist=new Map<String,Decimal>();
            for(EntityDefinition s:sobjList)
            {
                sobjectlist.put(s.QualifiedApiName,0);
            }
            DataArchive__b dtb=new DataArchive__b(indexNumber__c=0,datetimestampindex__c='HeadersIndex',recordjson1__c=json.serialize(sobjectlist));
            if(!test.isRunningTest()){
                            database.insertImmediate(dtb);
            }
        }
        catch(exception e){
            throw new AuraHandledException('Something went wrong. ' + e.getMessage() );
        }
    }
    
    @AuraEnabled
    public static List<reportdata>   getReportingData(){
        try{
            List<dataArchive__b> reportjson=getSetupRequired();
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(reportjson[0].recordJson1__c);
            List<reportdata> returnData=new List<reportData>();
            
		Decimal count=0;
            for(String key : result.keyset()) { 
                count=(Decimal)result.get(key);
                if(count!=0)
                    returnData.add(new reportdata(key,count));
                } 
            return returnData;
        }
        catch(exception e){
            throw new AuraHandledException('Something went wrong. ' + e.getMessage() );
        }
    }
    
    public class reportData{
        @auraenabled
        public string name{get;set;}
        @auraenabled
        public decimal y{get;set;}
       
        public reportdata(string name,decimal y){
            this.name=name;
            this.y=y;
        }
    }
}
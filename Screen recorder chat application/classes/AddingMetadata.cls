public class AddingMetadata {

    @AuraEnabled
    public static list<Metadatawrap> getAllRecords() {
        list<Metadatawrap> newwr=new list<Metadatawrap>();
        list<Custom_support_Instruction__mdt> alllist=(list<Custom_support_Instruction__mdt>)customMetadataService.getQuery('SELECT id, MasterLabel,DeveloperName, Capture__c,fieldName__c,Instructions__c,Note__c,order__c,Radio__c,SearchBox__c' +
                                                                                                                            ' FROM Custom_support_Instruction__mdt  where DeveloperName!=\'Instructions\' order by DeveloperName');
        
        for(Custom_support_Instruction__mdt mdt:alllist){
            newwr.add(new Metadatawrap(mdt));
        }
        system.debug('listwrap'+newwr);
        return newwr;
    }
    
    
    
    @AuraEnabled
    public static void saveRecord(string wrap, Integer length) {
        try{            
        string mergedfield='';
        list<Metadatawrap> newmt= (list<Metadatawrap>) JSON.deserialize(wrap, list<Metadatawrap>.class);
        
        system.debug('wrap val is'+newmt);
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            for(Metadatawrap mtdwr:newmt){
                mergedField='';
                Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
                if(!string.isblank(mtdwr.id) && mtdwr.id.length()<15){
                    length++;
                    
                    customMetadata.label = 'X'+string.valueOf(length);
                    customMetadata.fullName = 'Custom_support_Instruction.'+'X'+string.valueOf(length);
                }
                else{
                    customMetadata.label =  mtdwr.developerName.replace('X','');
                    customMetadata.fullName = 'Custom_support_Instruction.'+ mtdwr.DeveloperName;  
                }
                system.debug('mtdwr is'+mtdwr);
                if(mtdwr.SfdcFieldName==null && mtdwr.TargetFieldName==null){
                    mergedfield='';
                }
                else if(mtdwr.SfdcFieldName!=null && mtdwr.TargetFieldName==null){
                    mergedfield=mtdwr.SfdcFieldName+';;';  
                }
                else if(mtdwr.SfdcFieldName==null && mtdwr.TargetFieldName!=null){
                    mergedfield=';'+mtdwr.TargetFieldName+';'; 
                }
                else{
                    mergedfield=mtdwr.SfdcFieldName+';'+mtdwr.TargetFieldName+';';
                }
                customField = new Metadata.CustomMetadataValue();
                
                customField.field = 'Instructions__c';
                customField.value = mtdwr.Instruction;
                customMetadata.values.add(customField);
                customField = new Metadata.CustomMetadataValue();
                customField.field = 'Note__c';
                customField.value = mtdwr.Note;
                customMetadata.values.add(customField);
                customField = new Metadata.CustomMetadataValue();
                customField.field = 'order__c';
                customField.value = mtdwr.order;
                customMetadata.values.add(customField);
                customField = new Metadata.CustomMetadataValue();
                customField.field = 'Capture__c';
                customField.value = mtdwr.Capture;
                customMetadata.values.add(customField);
                customField = new Metadata.CustomMetadataValue();
                customField.field = 'Radio__c';
                customField.value = mtdwr.Radio;
                customMetadata.values.add(customField);
                if(mtdwr.Radio==true){
                    customField = new Metadata.CustomMetadataValue();
                    customField.field = 'fieldName__c';
                    if(mtdwr.SfdcFieldName==null && mtdwr.TargetFieldName==null){
                        customField.value =''; 
                    }
                    else if(string.isblank(mtdwr.SfdcFieldName) && !string.isblank(mtdwr.TargetFieldName)){
                        customField.value = '{"Target":"'+mtdwr.TargetFieldName+'"}';  
                    }
                    else if(!string.isblank(mtdwr.SfdcFieldName) && string.isblank(mtdwr.TargetFieldName)){
                        customField.value = '{"Salesforce":"'+mtdwr.SfdcFieldName+'"}';  
                    }
                    else{
                        customField.value = '{"Salesforce":"'+mtdwr.SfdcFieldName+'","Target":"'+mtdwr.TargetFieldName+'"}';
                    }
                    customMetadata.values.add(customField);  
                }
                else{
                    customField = new Metadata.CustomMetadataValue();
                    customField.field = 'fieldName__c';
                    customField.value = mergedfield;
                    customMetadata.values.add(customField);  
                }
                customField = new Metadata.CustomMetadataValue();
                customField.field = 'SearchBox__c';
                
                customField.value = mtdwr.SearchBox;
                customMetadata.values.add(customField);
                
                System.debug( ' >>>> Created custom metadata object >>> ' + customMetadata );
                mdContainer.addMetadata(customMetadata);
            }
            Create_Update_Metadata callback = new Create_Update_Metadata();
            
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            
            // return jobId;
            
        }catch(Exception ex){
            throw createAuraHandledException(ex.getmessage());
            //return 'Error while creating new button.';
        }
        
    }
    
    private static AuraHandledException createAuraHandledException(String Message){
        AuraHandledException e = new AuraHandledException(Message);
        e.setMessage(Message);
        return e; 
    }
    
    public class Metadatawrap
    {
        @auraenabled
        public string id {get;set;}
        @auraenabled
        public string DeveloperName {get;set;}
        @auraenabled
        public string Instruction {get;set;}
        @auraenabled
        public string SfdcFieldName {get;set;}
        @auraenabled
        public string TargetFieldName {get;set;}
        @auraenabled
        public string Note {get;set;}
        @auraenabled
        public Decimal order {get;set;}
        @auraenabled
        public Boolean SearchBox {get;set;}
        @auraenabled
        public Boolean Capture {get;set;}
        @auraenabled
        public Boolean Radio {get;set;}
        
        public Metadatawrap(Custom_support_Instruction__mdt csimdt)
        {
            this.id= csimdt.id;
            this.DeveloperName = csimdt.DeveloperName;
            this.Instruction = csimdt.Instructions__c;
            this.Note = csimdt.Note__c;
            this.order = csimdt.order__c;
            this.SearchBox = csimdt.SearchBox__c;
            this.Capture = csimdt.Capture__c;
            this.Radio = csimdt.Radio__c;
            string fieldval=csimdt.fieldName__c;
            if(!String.isBlank(csimdt.fieldName__c) && fieldval.contains(';') &&  !fieldval.contains('"'))
            {
                
                string fielvalue= csimdt.fieldName__c;
                //list<string> splitedlist=fielvalue.split(';');
                string sfdcfield=fielvalue.substringBetween('', ';');
                string trgtfield=fielvalue.substringBetween(';',';');
                this.SfdcFieldName=sfdcfield;
                this.TargetFieldName=trgtfield;
                
            }
            else if(!String.isBlank(csimdt.fieldName__c) && csimdt.Radio__c==true){
                Map<String,Object> objectMap=(Map<String,Object>)json.deserializeUntyped(csimdt.fieldName__c);
                if(objectMap.containsKey('Salesforce')){
                    this.SfdcFieldName=(String)objectMap.get('Salesforce');
                }
                if(objectMap.containsKey('Target')){
                    this.TargetFieldName=(String)objectMap.get('Target');
                }
            }
            else{
                this.SfdcFieldName='';
                this.TargetFieldName='';
            }
        }
    }
    
}
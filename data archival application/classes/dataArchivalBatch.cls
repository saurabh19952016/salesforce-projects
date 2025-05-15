public class dataArchivalBatch implements database.Batchable<sObject>,database.stateful{
    public String Query; 
    private string objecttype;
    private string relationship;
    private Boolean Idsonly;
    private Map<String,Object> recordCountMap=new Map<String,Object>();
    public Set<Id> parentIds=new Set<Id>();
    private DataArchive__b ParentIdRecord=new DataArchive__b();
    private List<Id> parentIdList=new List<Id>();
    private List<Schema.DisplayType> stringtypes=new List<Schema.DisplayType>{Schema.DisplayType.STRING,Schema.DisplayType.Picklist,Schema.DisplayType.Phone,Schema.DisplayType.Email,Schema.DisplayType.URL,Schema.DisplayType.Reference,Schema.DisplayType.ID,Schema.DisplayType.EncryptedString};
        private List<Schema.DisplayType> numbertypes=new List<Schema.DisplayType>{Schema.DisplayType.Boolean,Schema.DisplayType.Combobox,Schema.DisplayType.Currency,Schema.DisplayType.Date,Schema.DisplayType.DateTime,Schema.DisplayType.Double,Schema.DisplayType.Integer,Schema.DisplayType.Long,Schema.DisplayType.Percent,Schema.DisplayType.Time};
            private list<String> textAreaFields=new list<String>();
    private list<String> nullableFields=new list<String>();
    private Data_Archival_Object_Settings__c datsetting;
    
    public dataArchivalBatch(String objecttype,string relationship,Boolean Idsonly){
        this.objecttype=objecttype;
        this.relationship=relationship;
        this.Idsonly=Idsonly;
        constructQuery();
        datsetting.Status__c='Running';
        update datsetting;
        update new case(description=	query,id='5003C0000037pON');
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        sendEmail('Data Archival Initiated for '+ objecttype ,'Data Archival has been initiated with Job Id-' + BC.getJobId()+'. Please wait until it is completed to start archiving other objects.');
        
        return Database.getQueryLocator(query);        
    }    
    public void execute(Database.BatchableContext BC, List<sobject> sobjectList){
        List<sobject > datBigObj = new List<sobject >();
        try{
            Map<Id,sobject> stmap=new Map<Id,sobject>();
            List<Attachment> textAreaAttachList=new List<Attachment> ();
            data_archival_settings__c setting=data_archival_settings__c.getValues('currentIndex');
            system.debug('emMess' +sobjectList.size() );
            for(sobject sobj:sobjectList){
                for(string textareafield: textAreaFields){
                    if(sobj.get(textareafield)!=null && textareafield!='Archive_Indexes__c'){
                        textAreaAttachList.add(new attachment(body =blob.valueof(String.valueof(sobj.get(textareafield)).striphtmlTags()), name=textareafield,contentType='text/plain',parentid=sobj.id));
                    }
                }
            }
            Map<Id,sobject> newMap=new Map<Id,sobject>(sobjectList);
            parentIdrecord  =bigObjectQueryService.getQuery('select indexNumber__c,datetimestampindex__c,recordjson0__c,recordJson1__c from DataArchive__b where indexNumber__c=0 and datetimestampindex__c=\'HeadersIndex\'')[0];
            if(parentIdrecord.recordJson1__c!=null){
                 recordCountMap=(Map<String,Object>)json.deserializeUntyped(parentIdrecord.recordJson1__c);
           
            }
            DataArchive__b unarchivedRec=parentIdRecord.clone();
            Map<string,string> indexmap=new Map<string,string>();
            List<Decimal> indexList=new List<Decimal>();
            if(unarchivedRec.recordjson0__c!='null' && unarchivedRec.recordjson0__c!=null){
                for(String ind:unarchivedRec.recordjson0__c.split(';'))
                {
                    indexList.add(decimal.valueof(ind.substringbefore('-')));
                    indexmap.put(ind,ind.substringafter('-'));
                }
                system.debug(indexmap);
                List<DataArchive__b> unarchivedData=bigObjectQueryService.getQuery('select indexNumber__c,datetimestampIndex__c,recordjson0__c,recordjson1__c,recordjson2__c, recordjson3__c, recordjson4__c,'+
                                                     'recordjson5__c, recordjson6__c, recordjson7__c, recordjson8__c, recordjson9__c, recordjson10__c,recordjson11__c from DataArchive__b where indexNumber__c IN ' + indexList);
                 system.debug('select indexNumber__c,datetimestampIndex__c,recordjson0__c,recordjson1__c,recordjson2__c, recordjson3__c, recordjson4__c,'+
                     'recordjson5__c, recordjson6__c, recordjson7__c, recordjson8__c, recordjson9__c, recordjson10__c,recordjson11__c from DataArchive__b where indexNumber__c IN ' +indexlist);
    
                integer varindex=0;
                List<String> processedIndexes=new List<String>();
                for(DataArchive__b unarch:unarchivedData)
                {
                    system.debug(varindex + ' ' +unarch);
                    if(sobjectlist.size()>varindex){
                        sobject sobj=sobjectList[varindex];
                        system.debug(sobj);
                        sobject fillerRecord=unarch.clone();
                        for(integer idx=0;idx<12;idx++){
                          if((String)fillerRecord.get('RecordJson'+idx + '__c')=='null' && indexmap.containskey(unarch.indexNumber__c.toplainstring()+'-' + idx)){
                                processedIndexes.add(unarch.indexNumber__c+'-' + idx);
                                sobj.put('Archive_Indexes__c',((Decimal)fillerRecord.get('indexNumber__c')).toplainstring() + ';');
                                fillerRecord.put('RecordJson' + idx + '__c',json.serialize(sobj));
                                newMap.remove(sobj.id);
                                sobject st=initializesobject(sobj);
                                parentIdList.add(St.id);
                                stmap.put(st.id,st);
                                //system.debug('test RecordJson0__c + ' + fillerRecord.RecordJson0__c);
                            }

                        }
                         varindex++;
                         datBigObj.add(fillerRecord);

                    }
                    else break;
                }                        

                sobjectList=newMap.values();
                system.debug('processedIndexes'+processedIndexes);
                if(processedIndexes.size()>0){
                    for(string ind:processedIndexes)
                {  
                    system.debug('ind' + ind);
                    indexmap.remove(ind);
                }
                   List<String> indexes=new List<String>();
                    indexes.addAll(indexmap.keyset());
                    if(!indexes.isempty())
                    unarchivedRec.RecordJson0__c=String.join(indexes,';')+';';
                    else
                     unarchivedRec.RecordJson0__c='null';
                       
                }
            }
            
            system.debug(datBigObj.size());
            system.debug(sobjectList);
            List<DataArchive__b> latestdata=bigObjectQueryService.getQuery('select indexNumber__c,datetimestampIndex__c,recordjson0__c,recordjson1__c,recordjson2__c, recordjson3__c, recordjson4__c,'+
                                             'recordjson5__c, recordjson6__c, recordjson7__c, recordjson8__c, recordjson9__c, recordjson10__c,recordjson11__c from DataArchive__b where indexNumber__c!=0 and indexNumber__c=' + setting.indexNumber__c);
            if(latestdata.size()>0 && setting.indexNumber__c!=0 && !newMap.keyset().isempty() ){
                sobject newbigRecord=latestdata[0].clone();
                for(sobject sobj :sobjectList){
                    if(sobjectlist.indexof(sobj)<12){
                        
                    for(integer idx=0;idx<12;idx++){
                        if((String)newbigRecord.get('RecordJson'+idx +'__c')==null){
                        system.debug('sobj - '+ sobj);
                        sobj.put('Archive_Indexes__c',((Decimal)newbigRecord.get('indexNumber__c')).toplainstring() + ';');
                        newbigRecord.put('RecordJson' + idx+'__c',json.serialize(sobj));
                        sobject st=initializesobject(sobj);
                        parentIdList.add(St.id);
                        newMap.remove(sobj.id);
                        system.debug('test '+idx);
                        stmap.put(sobj.id,sobj);
                    }
                    }
                   }
                    else{
                        break;
                    }
                 }

                datBigObj.add(newbigRecord);
                system.debug(datbigobj);
                sobjectList=newMap.values();
            }
            //for(Integer i=0;i<sobjectList.size();i=i+12){
            while(!newMap.values().isEmpty()){
                sobject Bigrecord = new dataarchive__b();
                setting.indexNumber__c+=1;
                Bigrecord.put('indexNumber__c',setting.indexNumber__c);
                Bigrecord.put('DateTimeStampIndex__c',String.valueof(system.now()+'-'+system.now().millisecond()));
                integer i=0;
                for(sobject sobj:sobjectList){
                system.debug('sobj - '+ sobj);
                if((String)sobj.get('Archive_Indexes__c')==null)
                {
                    sobj.put('Archive_Indexes__c',((Decimal)Bigrecord.get('indexNumber__c')).toplainstring() + ';');
                    Bigrecord.put('RecordJson' +i+'__c',json.serialize(sobj));
                    sobject st0=initializesobject(sobj);
                    parentIdList.add(St0.id);
                    newMap.remove(st0.Id);
                   stmap.put(St0.id,St0);
                    i++;
                    if(i>11){
                        break;
                    }
                } 
             }
              datBigObj.add(Bigrecord);
            }
     
            system.debug('parentIdList+' +parentIdList);
            
            system.debug(stmap);
                savepoint sp=database.setSavepoint();
            try{
                unarchivedRec.recordjson1__c=json.serialize(recordCountMap);
                datBigObj.add(unarchivedRec);
                 setting.id=setting.Record_id__c;
                update setting;
                update stmap.values();
                insert textAreaAttachList;
               system.enqueuejob(new insertBigObjectQueueable(datBigObj,bc.getjobId()));                                       
            }
            catch(exception ex){
                database.rollback(sp);
                throw ex;
            }

        }
        catch(Exception ex){
           system.debug(ex);
            datsetting.Status__c='Failed';
            update datsetting;
            sendEmail('Data Archival Failed for '+objecttype ,'Data Archival has failed for Job Id-' + BC.getJobId()+'. \n Exception:' + ex.getMessage() + '\n StackTrace:' +ex.getStackTraceString());
            System.abortJob(BC.getJobId());
        }
    }  
    
    public void finish(Database.BatchableContext BC){
        system.debug('parentIdListfinish' +parentIdList);
        system.debug('relationship' +relationship.length());

            sendEmail('Data Archival Completed for '+ objecttype ,'Data Archival has completed for Job Id-' + BC.getJobId()+'. You can proceed with archiving child records of ' + objecttype + '.');
            datsetting.Status__c='Completed';
            update datsetting;
    }
    
    public void constructQuery(){
        parentIdrecord  =bigObjectQueryService.getQuery('select indexNumber__c,datetimestampindex__c,recordjson0__c,recordJson1__c from DataArchive__b where indexNumber__c=0 and datetimestampindex__c=\'HeadersIndex\'')[0];
        system.debug(objecttype + relationship);
        datsetting = [select id,name,object_name__c,Archival_From_Date__c,Archival_To_Date__c,filterValue_1__c,filterValue_2__c,FilterField_1__c,FilterField_2__c,Object_type__c,relationship_field__c from Data_Archival_Object_Settings__c 
                      where object_name__c=:objecttype and submitted_By__c=:userinfo.getuserid().substring(0,15) and object_type__c=:relationship];
        Map<String, Schema.SObjectField> fieldMap=getsobjectSchema(datsetting.object_name__c);
        string totalfields='';
        system.debug(datsetting);
        if(IdsOnly==true){
            totalfields='Id';
        }
        else{
            for (String fieldName: fieldMap.keyset()) 
            {  
                Schema.DescribeFieldResult field= fieldMap.get(fieldName).getDescribe();
                if(field.isNillable() && field.isUpdateable() && field.getType()!=schema.DisplayType.REFERENCE ){
                    nullableFields.add(fieldName);
                }
                if (field.getType() == Schema.DisplayType.TEXTAREA && field.getLength() >= 256 && field.getLength() <= 131072) {
                    textAreaFields.add(fieldName);
                }
                totalfields +=  ', '+ fieldName;
            }
            system.debug(datsetting.Archival_From_Date__c);
            string filter;
            
            totalfields = totalfields.removeStart(',');
        }
        query='select ' +totalfields + ' FROM ' + datsetting.Object_Name__c;
        if(datSetting.Object_type__c=='Parent'){
            query+=  ' where CreatedDate >' + datsetting.Archival_From_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+ ' AND CreatedDate < '+ datsetting.Archival_To_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            if(datsetting.FilterField_1__c !=null && datsetting.filterValue_1__c !=null && stringtypes.contains(fieldMap.get(datsetting.FilterField_1__c).getdescribe().getType())){
                query+=' AND ' +datsetting.FilterField_1__c+ '=\'' + datsetting.filterValue_1__c + '\'';
            }
            if(datsetting.FilterField_1__c !=null && datsetting.filterValue_1__c !=null && numbertypes.contains(fieldMap.get(datsetting.FilterField_1__c).getdescribe().getType())){
                query+=' AND ' +datsetting.FilterField_1__c+ '=' + datsetting.filterValue_1__c ;
            }
            if(datsetting.FilterField_2__c !=null && datsetting.filterValue_2__c !=null && stringtypes.contains(fieldMap.get(datsetting.FilterField_2__c).getdescribe().getType())){
                query+=' AND ' +datsetting.FilterField_2__c+ '=\'' + datsetting.filterValue_2__c + '\'';
            }
            if(datsetting.FilterField_2__c !=null && datsetting.filterValue_2__c !=null && numbertypes.contains(fieldMap.get(datsetting.FilterField_2__c).getdescribe().getType())){
                query+=' AND ' +datsetting.FilterField_2__c+ '=' + datsetting.filterValue_2__c ;
            }
        }
        else {
            if(IdsOnly==false){
                 query+=' Where ';
                List<String> relList=datsetting.relationship_field__c.split(',');
                for( string relfld:relList){
                       query+=relfld + ' IN :parentIds ';
                    if(relList.size()-1!=relList.indexOf(relFld)){
                         query+=' AND ';
                    }
                }
            }

        }
        if(IdsOnly==false){
            query+=' AND Archive_Indexes__c=null';        
        }
    }
    
    
    public sobject initializeSobject(sobject globalobj){
      Decimal count=0;
      if(recordCountMap.containsKey(objectType)){
            count=(Decimal)recordCountMap.get(objecttype);
        }
                count=count+1;

        recordCountMap.put(objecttype,count);
        for (String fieldName: nullableFields) 
        {  
            if(fieldName!='Archive_Indexes__c' && fieldName!='Id' )  
                globalobj.put(fieldName,null);
        }
        return globalobj;
    }
    
    public Map<String, Schema.SObjectField> getsobjectSchema(string objName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjSchema = schemaMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
        return fieldMap;
    }
    
    public void sendEmail(string subject,string body){
        Messaging.SingleEmailMessage message=new  Messaging.SingleEmailMessage ();
        message.toAddresses = new String[] {userinfo.getuserid()};
            message.subject = subject;
        message.orgwideemailaddressid=label.orgWideAddress;
        message.plainTextBody = body;
        Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
}
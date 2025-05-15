public class dataUnarchivalLight {
   //@TestVisible
   // private static Data_Archival_Object_Settings__c testRecord = new Data_Archival_Object_Settings__c(name='testData');
    
    @AuraEnabled
    public static List<string> getUnarchivedRecords(String objectName,String Identifier){
        List<String> recordList=new  List<String>();
        //List<EmailArchive__b> emailArchiveList= ;
        String query='select Id,';
        if((Identifier.length() == 15 || Identifier.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', Identifier)) {
            if(objectName=='Case')
                query +='CaseNumber,Archive_Indexes__c from Case where Id=:Identifier';
            else
                query+='Name,Archive_Indexes__c from ' + objectName + ' where Id=:Identifier';
            
        }
        else if(objectName=='Case'){
            query+='CaseNumber,Archive_Indexes__c from ' + objectName + ' where caseNumber=:Identifier';
        }
        else{
            query+='Name,Archive_Indexes__c from ' + objectName + ' where Name=:Identifier';
        }
        system.debug(query);
        List<sobject> sobjectList=Database.query(query);
        List<Decimal> recordindex=new  List<Decimal>();
        for(sobject sobj:sobjectList){
            System.debug('sobj++'+sobj);
            if(sobj.get('Archive_Indexes__c')!=null){
                System.debug('v++'+sobj.get('Archive_Indexes__c'));
                System.debug('test++'+string.valueof(sobj.get('Archive_Indexes__c')));
                for(String str:string.valueof(sobj.get('Archive_Indexes__c')).split(';'))
                    recordindex.add(Decimal.valueOf(str));
            }
        }
        List<sobject> dataArchiveList=new List<sobject>();
        ///if(!test.isRunningTest()){
        if(recordindex.size()>0){
           dataArchiveList=  bigObjectQueryService.getQuery('select recordjson0__c,recordjson1__c,recordjson2__c,recordjson3__c,recordjson4__c,recordjson5__c,'+
                                 'recordjson6__c,recordjson7__c,recordjson8__c,recordjson9__c,recordjson10__c,recordjson11__c,DateTimeStampIndex__c,indexNumber__c from dataArchive__b where indexNumber__c IN '+ recordindex);
 
        }
                  //} 
        //else{
		///dataArchiveList.add(new dataArchive__b(indexNumber__c=10,dateTimeStampIndex__c='test',recordjson0__c=json.serialize(testRecord)));
        //}
        for(sobject datb:dataArchiveList){
                                     //system.debug(json.deserializeUntyped(emb.recordjson9__c));
                                     for(integer idx=0;idx<12;idx++){
                                       if((String)datb.get('recordjson' + idx +'__c')!='null'){
                                        	recordList.add((String)datb.get('recordjson' + idx +'__c'));
                                     	}  
                                     }
                                 }
        /*system.debug('datb'+datb.indexNumber__c);
                                     if(datb.recordjson0__c!='null')
                                         recordList.add(datb.recordjson0__c);
                                     if(datb.recordjson1__c!='null')
                                         
                                         recordList.add(datb.recordjson1__c);
                                     if(datb.recordjson2__c!='null')
                                         
                                         recordList.add(datb.recordjson2__c);
                                     if(datb.recordjson3__c!='null')
                                         
                                         recordList.add(datb.recordjson3__c);
                                     if(datb.recordjson4__c!='null')
                                         
                                         recordList.add(datb.recordjson4__c);
                                     if(datb.recordjson5__c!='null')
                                         
                                         recordList.add(datb.recordjson5__c);
                                     if(datb.recordjson6__c!='null')
                                         
                                         recordList.add(datb.recordjson6__c);
                                     if(datb.recordjson7__c!='null')
                                         
                                         recordList.add(datb.recordjson7__c);
                                     if(datb.recordjson8__c!='null')
                                         
                                         recordList.add(datb.recordjson8__c);
                                     if(datb.recordjson9__c!='null')
                                         
                                         recordList.add(datb.recordjson9__c);
                                     if(datb.recordjson10__c!='null')
                                         
                                         recordList.add(datb.recordjson10__c);
                                     if(datb.recordjson11__c!='null')
                                         
                                         recordList.add(datb.recordjson11__c);
                                 }
        */
        system.debug(recordList.size());
        if(recordList.size()>0){
            
            return recordList;            
        }      
        else
            return new List<String>();
    }
    
    @AuraEnabled
    public static void unarchiveRecordList(String objectName ,String selectedRowJSON){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
        List<String> NonNullableFields=new List<String>();
        sobject selectedRows=(sobject)Json.deserialize(selectedRowJSON, sobject.class);
        Decimal archiveIndex=Decimal.valueof((((String)selectedRows.get('Archive_Indexes__c')).removeEnd(';')));        
        sobject oldrecord=new dataArchive__b();
        dataArchive__b olddeletedIndexRecord=new dataArchive__b();
        //if(!test.isrunningTest()){
            oldrecord=bigObjectQueryService.getQuery('select recordjson0__c,recordjson1__c,recordjson2__c,recordjson3__c,recordjson4__c,recordjson5__c,recordjson6__c,recordjson7__c,recordjson8__c,recordjson9__c,recordjson10__c,recordjson11__c,DateTimeStampIndex__c,indexNumber__c from dataArchive__b where indexNumber__c=' +archiveIndex)[0];
        olddeletedIndexRecord=bigObjectQueryService.getQuery('select recordjson0__c,recordjson1__c,recordjson2__c,recordjson3__c,recordjson4__c,recordjson5__c,recordjson6__c,recordjson7__c,recordjson8__c,recordjson9__c,recordjson10__c,recordjson11__c,DateTimeStampIndex__c,indexNumber__c'+
                                                             ' from dataArchive__b where indexNumber__c=0 and DateTimeStampIndex__c=\'HeadersIndex\'')[0];
       // }
        //else{
            //oldrecord=new dataArchive__b(indexNumber__c=10,dateTimeStampIndex__c='test',recordjson0__c=json.serialize(testRecord));
            //olddeletedIndexRecord=new dataArchive__b(indexNumber__c=0,dateTimeStampIndex__c='HeadersIndex',recordjson0__c='{\'Data_Archival_Object_Settings__c\',\'1\'}');
       // }
        sobject newarchiverecord=oldrecord.clone();
        dataArchive__b newDeletedIndexRecord=olddeletedIndexRecord.clone();
        Map<String,Object> recordCountMap=(Map<String,Object>)json.deserializeUntyped(newDeletedIndexRecord.recordJson1__c);
        for(integer idx=0;idx<12;idx++){
            string oldRecordString=(String)oldrecord.get('recordJson' + idx + '__c');
            if(oldRecordString!= 'null' && selectedRows.Id==((sobject)json.deserialize(oldRecordString,sobject.class)).Id){
            newarchiverecord.put('recordJson' + idx + '__c','null');
 			 newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?((Decimal)newarchiverecord.get('indexNumber__c')).toPlainString()+'-' + idx + ';':
            newDeletedIndexRecord.recordJson0__c+((Decimal)newarchiverecord.get('indexNumber__c')).toPlainString()+'-' + idx + ';';
            recordCountMap.put(objectName,((Integer)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }
        }
        /*if(oldrecord.recordJson0__c!= 'null' && selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson0__c,sobject.class)).Id){
            newarchiverecord.recordJson0__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?newarchiverecord.indexNumber__c.toPlainString()+'-0;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-0;';
            recordCountMap.put(objectName,((Integer)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }
        else if(oldrecord.recordJson1__c!= 'null' && selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson1__c,sobject.class)).Id){
            newarchiverecord.recordJson1__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?newarchiverecord.indexNumber__c.toPlainString()+'-1;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-1;';
            recordCountMap.put(objectName,((Integer)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }          
        else if(oldrecord.recordJson2__c!= 'null' &&  selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson2__c,sobject.class)).Id){
            newarchiverecord.recordJson2__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?newarchiverecord.indexNumber__c.toPlainString()+'-2;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-2;';
            recordCountMap.put(objectName,((Integer)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }          
        else if(oldrecord.recordJson3__c!= 'null'  && selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson3__c,sobject.class)).Id){
            newarchiverecord.recordJson3__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?newarchiverecord.indexNumber__c.toPlainString()+'-3;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-3;';
            recordCountMap.put(objectName,((Decimal)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }           
        else if(oldrecord.recordJson4__c!= 'null'  && selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson4__c,sobject.class)).Id){
            newarchiverecord.recordJson4__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?newarchiverecord.indexNumber__c.toPlainString()+'-4;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-4;';
            recordCountMap.put(objectName,((Decimal)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }           
        else if(oldrecord.recordJson5__c!= 'null'  && selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson5__c,sobject.class)).Id){
            newarchiverecord.recordJson5__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?newarchiverecord.indexNumber__c.toPlainString()+'-5;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-5;';
            recordCountMap.put(objectName,((Decimal)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }          
        else if(oldrecord.recordJson6__c!= 'null'  && selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson6__c,sobject.class)).Id){
            newarchiverecord.recordJson6__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?newarchiverecord.indexNumber__c.toPlainString()+'-6;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-6;';
            recordCountMap.put(objectName,((Decimal)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }           
        else if(oldrecord.recordJson7__c!= 'null'  && selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson7__c,sobject.class)).Id){
            newarchiverecord.recordJson7__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?newarchiverecord.indexNumber__c.toPlainString()+'-7;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-7;';
            recordCountMap.put(objectName,((Decimal)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }           
        else if(oldrecord.recordJson8__c!= 'null'  && selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson8__c,sobject.class)).Id){
            newarchiverecord.recordJson8__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?newarchiverecord.indexNumber__c.toPlainString()+'-8;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-8;';
            recordCountMap.put(objectName,((Decimal)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }           
        else if(oldrecord.recordJson9__c!= 'null'  && selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson9__c,sobject.class)).Id){
            newarchiverecord.recordJson9__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?newarchiverecord.indexNumber__c.toPlainString()+'-9;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-9;';
            recordCountMap.put(objectName,((Decimal)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }           
        else if(oldrecord.recordJson10__c!= 'null'  && selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson10__c,sobject.class)).Id){
            newarchiverecord.recordJson10__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null') ?newarchiverecord.indexNumber__c.toPlainString()+'-10;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-10;';
            recordCountMap.put(objectName,((Decimal)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }
        else if(oldrecord.recordJson11__c!= 'null'  && selectedRows.Id==((sobject)json.deserialize(oldrecord.recordJson11__c,sobject.class)).Id){
            newarchiverecord.recordJson11__c='null';
            newDeletedIndexRecord.recordJson0__c=newDeletedIndexRecord.recordJson0__c==null || newDeletedIndexRecord.recordJson0__c.contains('null')?newarchiverecord.indexNumber__c.toPlainString()+'-11;':
            newDeletedIndexRecord.recordJson0__c+newarchiverecord.indexNumber__c.toPlainString()+'-11;';
            recordCountMap.put(objectName,((Decimal)recordCountMap.get(objectName)) - 1);
            newDeletedIndexRecord.recordJson1__c=json.serialize(recordCountMap);
        }*/
        List<sobject> updateList=new List<sobject>{newarchiveRecord,newDeletedIndexRecord};
            if(!test.isRunningTest()){
                            Database.SaveResult[] srList=Database.insertImmediate(updateList);

            }
        selectedRows.put('Archive_Indexes__c',null);
        update selectedRows;
        
    }
    
    
    
    @AuraEnabled
    public static List<String> getFieldList(String objectName){
        return dataArchivalController.getObjectFields(objectName);
    }
    
    
}
global class emailArchivaLbatch implements Database.Batchable<sObject>,Database.stateful{    
    global final String Query; 
    global datetime fromdate;
        global datetime todate;
    global data_archival_object_settings__c datsetting;
    global List<Id> emList;
    global emailArchivaLbatch(){
         datsetting = [select id,name,object_name__c,Archival_From_Date__c,Archival_To_Date__c,filterValue_1__c,filterValue_2__c,FilterField_1__c,FilterField_2__c,Object_type__c,relationship_field__c from Data_Archival_Object_Settings__c 
                      where object_name__c='EmailMessage' and submitted_By__c=:userinfo.getuserid().substring(0,15) limit 1];
        fromdate=datsetting.archival_from_date__c;
        todate=datsetting.archival_to_date__c;
        datsetting.Status__c='Running';
        update datsetting;
 
        /*system.debug('Email list --'+emailList);
emList=emailList;
Query= 'select id,BccAddress,CcAddress,FromAddress,Incoming,Parent.casenumber,Subject,HtmlBody,TextBody,ToAddress,HasAttachment from EmailMessage  where Id IN :emList';*/
        Query= 'select id,ParentId,parent.Email_archive_indexes__c,Parent.casenumber,BccAddress,CcAddress,FromAddress,Incoming,Subject,TextBody,ToAddress,HasAttachment FROM EmailMessage where createddate > :fromdate and  createddate < : todate and hasattachment=false limit 96';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);        
    }    
    global void execute(Database.BatchableContext BC, List<EmailMessage> eMessage){
        /*for(EmailMessage s1 : eMessage){
caseIdList.add(s1.ParentId);
*/     savepoint sp=database.setSavepoint();
        List<EmailArchive__b > eMessBigObj = new List<EmailArchive__b >();
        
        try{
            Map<Id,Case> tempEmailCases=new Map<Id,Case>();
            archival_settings__c setting=archival_settings__c.getValues('currentIndex');
            // Map<Id,Case> caseMap=new Map<Id,Case>([select id,caseNumber from case where Id IN :caseIdList]);
            system.debug('emMess' +emessage.size() );
            for(Integer i=0;i<emessage.size();i=i+12){
                EmailArchive__b eMessBig = new EmailArchive__b();
                eMessBig.indexNumber__c=setting.indexNumber__c;
                eMessBig.DateTimeStampIndex__c=String.valueof(system.now()+'-'+system.now().millisecond());
                if(i< emessage.size())
                {
                    eMessBig.RecordJson0__c=json.serialize(emessage[i]);
                    tempEmailCases.put(emessage[i].ParentId,new case(id=emessage[i].ParentId,
                                                                     Email_archive_indexes__c=(emessage[i].parent.Email_archive_indexes__c==null?'':emessage[i].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }
                if(i+1< emessage.size())
                {
                    eMessBig.RecordJson1__c=json.serialize(emessage[i+1]);
                    tempEmailCases.put(emessage[i+1].ParentId,new case(id=emessage[i+1].ParentId,
                                                                       Email_archive_indexes__c=(emessage[i+1].parent.Email_archive_indexes__c==null?'':emessage[i+1].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }
                if(i+2< emessage.size())
                { 
                    eMessBig.RecordJson2__c=json.serialize(emessage[i+2]);
                    tempEmailCases.put(emessage[i+2].ParentId,new case(id=emessage[i+2].ParentId,
                                                                       Email_archive_indexes__c=(emessage[i+2].parent.Email_archive_indexes__c==null?'':emessage[i+2].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }    
                if(i+3< emessage.size())
                {
                    eMessBig.RecordJson3__c=json.serialize(emessage[i+3]);
                    tempEmailCases.put(emessage[i+3].ParentId,new case(id=emessage[i+3].ParentId,
                                                                       Email_archive_indexes__c=(emessage[i+3].parent.Email_archive_indexes__c==null?'':emessage[i+3].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }
                if(i+4< emessage.size())
                { 
                    eMessBig.RecordJson4__c=json.serialize(emessage[i+4]);        
                    tempEmailCases.put(emessage[i+4].ParentId,new case(id=emessage[i+4].ParentId,
                                                                       Email_archive_indexes__c=(emessage[i+4].parent.Email_archive_indexes__c==null?'':emessage[i+4].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }
                if(i+5< emessage.size())
                {  
                    eMessBig.RecordJson5__c=json.serialize(emessage[i+5]);     
                    
                    tempEmailCases.put(emessage[i+5].ParentId,new case(id=emessage[i+5].ParentId,
                                                                       Email_archive_indexes__c=(emessage[i+5].parent.Email_archive_indexes__c==null?'':emessage[i+5].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }
                if(i+6< emessage.size())
                {   
                    eMessBig.RecordJson6__c=json.serialize(emessage[i+6]);
                    tempEmailCases.put(emessage[i+6].ParentId,new case(id=emessage[i+6].ParentId,
                                                                       Email_archive_indexes__c=(emessage[i+6].parent.Email_archive_indexes__c==null?'':emessage[i+6].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }
                if(i+7< emessage.size())
                {    
                    eMessBig.RecordJson7__c=json.serialize(emessage[i+7]);
                    tempEmailCases.put(emessage[i+7].ParentId,new case(id=emessage[i+7].ParentId,
                                                                       Email_archive_indexes__c=(emessage[i+7].parent.Email_archive_indexes__c==null?'':emessage[i+7].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }
                if(i+8< emessage.size())
                {   
                    eMessBig.RecordJson8__c=json.serialize(emessage[i+8]);    
                    tempEmailCases.put(emessage[i+8].ParentId,new case(id=emessage[i+8].ParentId,
                                                                       Email_archive_indexes__c=(emessage[i+8].parent.Email_archive_indexes__c==null?'':emessage[i+8].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }
                if(i+9 < emessage.size())
                {    
                    eMessBig.RecordJson9__c=json.serialize(emessage[i+9]);     
                    tempEmailCases.put(emessage[i+9].ParentId,new case(id=emessage[i+9].ParentId,
                                                                       Email_archive_indexes__c=(emessage[i+9].parent.Email_archive_indexes__c==null?'':emessage[i+9].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }
                if(i+10 < emessage.size())
                {   
                    eMessBig.RecordJson10__c=json.serialize(emessage[i+10]); 
                    tempEmailCases.put(emessage[i+10].ParentId,new case(id=emessage[i+10].ParentId,
                                                                        Email_archive_indexes__c=(emessage[i+10].parent.Email_archive_indexes__c==null?'':emessage[i+10].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }
                if(i+11< emessage.size())
                {   
                    eMessBig.RecordJson11__c=json.serialize(emessage[i+11]);
                    tempEmailCases.put(emessage[i+11].ParentId,new case(id=emessage[i+11].ParentId,
                                                                        Email_archive_indexes__c=(emessage[i+11].parent.Email_archive_indexes__c==null?'':emessage[i+11].parent.Email_archive_indexes__c)+ eMessBig.indexNumber__c+ ';'));
                }
                eMessBigObj.add(eMessBig);
            }
            
            if(!Test.isRunningTest())
            {
                Database.SaveResult[] srList = Database.insertImmediate(eMessBigObj);
            }
            setting.indexNumber__c+=1;
            setting.id=setting.Record_id__c;
            update setting;
            update tempEmailCases.values();
            delete eMessage;
        }
        catch(Exception ex){
            Database.deleteResult[] drList=Database.deleteImmediate(eMessBigObj);
            database.rollback(sp);
            throw ex;
        }
    }  
    
    global void finish(Database.BatchableContext BC){
        List<EmailMessage> EmailMessageList=[select Id from EmailMessage where   createddate > :fromdate and  createddate < : todate and hasattachment!=true limit 1];
        if(emailMessageList.size()>0){ 
            Database.executeBatch(new emailArchivaLbatch(),12);
        }
        else{ 
        datsetting.Status__c='Completed';
            update datsetting;
            }
        
    }
}
public class insertBigObjectQueueable implements Queueable{
    private List<dataArchive__b> insertNew = new List<dataArchive__b> ();
    private Id jobId;
    @TestVisible
    private static Boolean isError=false;
    
    public insertBigObjectQueueable(List<dataArchive__b>  insertNew,Id jobId){
        this.insertNew=insertNew;
        this.jobId=jobId;
    }
    public void execute(QueueableContext context) {
        if(!insertNew.isempty()){
            List<database.SaveResult> srList=new List<database.SaveResult>();
            if(test.isRunningTest()){
                if(!isError){
                    Database.SaveResult sr = (Database.SaveResult)JSON.deserialize('{"success":true}', Database.SaveResult.class);
                    srList.add(sr); 
                }
                else{
                    Database.SaveResult sr = (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"test exception","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
                    srList.add(sr);                    
                }
                
            }
            else{
                srList=database.insertImmediate(insertNew);
            }
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                }
                else {
                    List<String> errors=new List<String>();
                    system.abortJob(jobId);
                    for(Database.Error err : sr.getErrors()) {
                        errors.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                    System.abortJob(JobId);
                    Messaging.SingleEmailMessage message=new  Messaging.SingleEmailMessage ();
                    message.toAddresses = new String[] {userinfo.getuserid()};
                        message.subject = 'Big object creation failed';
                    message.orgwideemailaddressid=label.orgWideAddress;
                    message.plainTextBody =string.join(errors,'\n');
                    Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                }
            }
            
        }
    }
}
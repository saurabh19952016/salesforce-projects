public class logDeleteQueueable implements queueable,database.allowscallouts{
    public string objectName;
    public List<String> objectRecIdList=new List<String>();
    public List<String> templist=new List<String>();
    @testvisible
    private static boolean isSkipTest=false;
    public logDeleteQueueable(string objectName,List<String> objectRecIdList){
        this.objectRecIdList=objectRecIdList;
        this.objectName=objectName;
        this.templist=objectRecIdList;
        system.debug(this);
    }
    
    public void execute(queueableContext qc){
        HTTPRequest req = new HTTPRequest();
        req.setHeader('Authorization', 'Bearer {!$self_org.OAuthToken}');
        req.setHeader('Content-Type', 'application/json');
        Http h = new Http();
        req.setMethod('DELETE');
        for(integer index=0;index<templist.size() && index<100;index++){
            if(objectName=='ApexLog'){
                req.setEndpoint('callout:self_org/services/data/v46.0/tooling/sobjects/ApexLog/'+templist[index]);
            }
            else{
                req.setEndpoint('callout:self_org/services/data/v46.0/tooling/sobjects/TraceFlag/'+templist[index]);
            }
            if(isSkipTest==false){
            	HttpResponse res = h.send(req);
            }
            objectRecIdList.remove(index);
        }
        if(objectRecIdList.size()>0){
            system.enqueueJob(new logDeleteQueueable(objectName,objectRecIdList));
        }        
    }
}
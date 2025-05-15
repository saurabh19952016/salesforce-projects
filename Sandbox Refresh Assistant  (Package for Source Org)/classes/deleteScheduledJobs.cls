public class deleteScheduledJobs implements Database.Batchable<sObject> {
private string jobtype;
public deleteScheduledJobs(string jobtype){
    this.jobtype=jobtype;
}
// query all the scheduled jobs from the system
public iterable<sobject> start(Database.BatchableContext BC){
    /** Return all the scheduled jobs for processing  **/
    String query;
    if(jobtype=='AsyncApexJob'){
        query='select Id from AsyncApexJob where apexclass.Name NOT IN ('+ label.jobs_to_skip +')' +
        ' and status  NOT IN (\'Completed\',\'Failed\',\'Aborted\') and jobType!=\'ScheduledApex\'';
    }
    else{
        query= 'select Id from CronTrigger';
    }
    if(!test.isrunningTest()){
        return Database.query(query);
    
    }
    else{
        return new List<AsyncApexJob>{new AsyncApexJob()};
    }
}
public void execute(Database.BatchableContext BC, List<sobject> scope){
          For (Integer i = 0; i < scope.size(); i++){ 
              if(!test.isRunningTest()){
                  System.abortJob(scope[i].Id);
              }
        }
}
public void finish(Database.BatchableContext BC){

}
}
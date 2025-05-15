public class deleteJobController {

    @AuraEnabled    
public static Boolean checkJobRunning() 
{   
    return [select id from asyncApexJob where (apexclass.Name='deleteJobController')  and status  NOT IN ('Completed','Failed','Aborted')].isEmpty();
}

    @AuraEnabled
    public static void deleteJobMethod(){
            database.executeBatch(new deleteScheduledJobs('CronTrigger'),100);
        database.executeBatch(new deleteScheduledJobs('AsyncApexJob'),100);
    }
}
public class sojbectDmlBatch implements database.Batchable<sobject>{
public List<sobject> sobjectList;
public string dmlmethod;
    public sojbectDmlBatch(List<sobject> sobjectlist,string dmlMethod) {
        this.sobjectList=sobjectlist;
        this.dmlmethod=dmlmethod;
    }

    public Iterable<sobject> start(Database.BatchableContext BC){
        return sobjectList;
    }
    
    public void execute(Database.BatchableContext BC, List<sobject> scope){
        if(dmlMethod=='update'){
            database.update(scope);
        }
        else{
            database.insert(scope);
           
        }
    }

    public void finish(Database.BatchableContext BC){
    }
}
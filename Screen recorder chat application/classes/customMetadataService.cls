public class customMetadataService {
  @TestVisible
private static Map<String,List<sobject>> bigObjectQueryMap=new Map<String,List<sobject>>();
    
    public static List<sobject> getQuery(string query){
        system.debug(query);
        if(!test.isRunningTest()){
            bigObjectQueryMap.put(query,database.query(query));
        }
        return bigObjectQueryMap.get(query);
    } 
}
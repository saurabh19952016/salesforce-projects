public class bigObjectQueryService {
    @TestVisible
private static Map<String,List<DataArchive__b>> bigObjectQueryMap=new Map<String,List<DataArchive__b>>();
    
    public static List<DataArchive__b> getQuery(string query){
        system.debug(query);
        if(!test.isRunningTest()){
            bigObjectQueryMap.put(query,database.query(query));
        }
        return bigObjectQueryMap.get(query);
    } 
}
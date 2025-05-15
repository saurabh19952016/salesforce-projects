@RestResource(urlmapping='/getFields/*')
global class DataMigrationService {
    
    @HttpGet
    global static void GetFieldsFromOrg(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String selectedObj=req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);        
       List<ObjectWrapper> ObjectWrapperList=getFields(selectedObj);
        system.debug('objwrapper = '+ObjectWrapperList);
        if(!ObjectWrapperList.isempty()){
            res.responseBody = Blob.valueOf(JSON.serialize(ObjectWrapperList));
            res.statusCode = 200;
        }
        else    
        {
            res.responseBody = Blob.valueOf('{"errorMessage":"An Error Occured","errorCode":"500"}');
            res.statusCode = 500;
        }
    }
    
    public static List<ObjectWrapper> getFields(string selectedObject){
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType ObjSchema = schemaMap.get(selectedObject);
            Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
            List<ObjectWrapper> objList=new List<ObjectWrapper> ();
            for(Schema.SobjectField strFld: fieldMap.Values())
            {   
                Schema.DescribeFieldResult describe=strFld.getDescribe();
                if(describe.isUpdateable() ){
                 ObjectWrapper objwrap=new ObjectWrapper();
                    objwrap.fieldLabel= describe.getLabel();
                     if(describe.getType()!=Schema.DisplayType.BOOLEAN){
                     objwrap.required= String.valueof(!describe.isNillable());
                     }
                     if(describe.getType()==Schema.DisplayType.PICKLIST){
                            objwrap.pickListValues = describe.getPicklistValues();    
                     }
                   objwrap.fieldName= describe.getName();
                    if(describe.getType() == Schema.DisplayType.REFERENCE){
                        objwrap.fieldType= string.valueOf(describe.getType()) + ' {';
                        for(Schema.SObjectType parentobj: describe.getReferenceTo() ){
                            objwrap.fieldType+=parentobj.getDescribe().getName() + ',';
                        }
                        objwrap.fieldType=objwrap.fieldType.removeEnd(',') + '}';
                    }
                    else
                        objwrap.fieldType=string.valueOf(describe.getType());
                        objList.add(objwrap);                    
                     }
               }
               return objList;
          }
    
 
    public class ObjectWrapper{
        public string fieldLabel{get;set;}
        public string fieldName{get;set;}
        public string fieldType{get;set;}
        public string required{get;set;}
        public List<Schema.PicklistEntry> pickListValues{get;set;}
    }
    
  
}
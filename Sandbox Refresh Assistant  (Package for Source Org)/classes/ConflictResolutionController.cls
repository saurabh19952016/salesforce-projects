public with sharing class ConflictResolutionController {
    private static List<Schema.DisplayType> stringtypes=new List<Schema.DisplayType>{Schema.DisplayType.STRING,Schema.DisplayType.Phone,Schema.DisplayType.TextArea,Schema.DisplayType.Long,schema.DisplayType.EMAIL};
    private static List<Schema.DisplayType> numbertypes=new List<Schema.DisplayType>{Schema.DisplayType.Currency,Schema.DisplayType.Double,Schema.DisplayType.Integer,Schema.DisplayType.Long,Schema.DisplayType.Percent};
    
    @AuraEnabled    
public static List<fieldWrapper> getObjectFields(string selectedObj) 
{   
    system.debug(selectedObj);
    List<fieldWrapper> fieldNames = new List<fieldWrapper>();
    if(!String.isBlank(selectedObj))
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjSchema = schemaMap.get(selectedObj);
        Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keyset()) 
        {  
            Schema.DescribeFieldResult field=fieldMap.get(fieldName).getDescribe();
            fieldWrapper fieldwrap=new fieldWrapper();
            fieldwrap.fieldName=field.getName();
            fieldwrap.updateable=field.isUpdateable();
            if(numberTypes.contains(field.getType())){
                fieldwrap.fieldType='number';
            }
            else if(field.getType()==schema.DisplayType.DATE){
                fieldwrap.fieldType='date';
            }
            else if(field.getType()==schema.DisplayType.DATETIME){
                fieldwrap.fieldType='datetime';
            }
            else{
                    fieldwrap.fieldType='text';
            }
            fieldNames.add(fieldwrap);
        }
    }
    return fieldNames;
}

@AuraEnabled
public static List<settingWrapper> getConflicts(String name,string base64Data) {
    List<fieldWrapper> fieldWrapList=getObjectFields(name);
    List<String> fieldlist=new list<String>();
    for(fieldWrapper fieldwrap:fieldWrapList)
    {
        fieldlist.add(fieldWrap.fieldName);
    }
    Map<String,Integer> fieldNumberMap=new Map<String,Integer>();
    Blob fileData = EncodingUtil.base64Decode(base64Data);
    system.debug(fileData);
    name=name.removeEnd('.csv');
    system.debug('currentFileName ' + name);
    String csvFile= fileData.toString();
    system.debug(csvFile);
    List<sobject> sobjectList=database.query('select ' + string.join(fieldList,',').removeEnd(',') + ' from ' + name + ' order by name');
    Map<String,sobject> sobjectMap=new Map<String,sobject>();
    for(sobject s:sobjectList){
        sobjectMap.put((String)s.get('Name') + (String)s.get('SetupOwnerId'),s);
    }
    system.debug('keyset'+sobjectMap.keyset());
    List<String> csvFileList=csvFile.removeStart('"').removeEnd('"').split('"\n"');
    List<String> csvFieldNames = csvFileList[0].split(',');
    List<String> lstFieldNames = new List<String>() ;
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType ObjSchema = schemaMap.get(name);
    Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
    for (Integer i = 0; i < csvFieldNames.size(); i++) {
        string fldname=csvFieldNames[i].remove('"');
        fieldNumberMap.put(fldname.trim(), i);
        lstFieldNames.add(fldname.trim());
    }
    system.debug(lstFieldNames);
    List<settingWrapper> wraprecordList=new List<settingWrapper>();
    if(csvFileList.size()>1){

    for (Integer i = 1; i < csvFileList.size(); i++) {
        settingWrapper wraprecord=new settingWrapper();
        //csvFileList[i]=csvFileList[i].removeStart('"').removeEnd('"');
        system.debug(csvFileList[i]);
        //csvFileList[i]=csvFileList[i]+'"';
        string[] csvRecordData = csvFileList[i].split('","');
        System.debug('csvRecordData++'+csvRecordData);
        if(!csvRecordData.isEmpty()){
            sobject sobj =  Schema.getGlobalDescribe().get(name).newSObject();
            System.debug('sobj++'+sobj);
            System.debug('lstFieldNames++'+lstFieldNames);
            for (String fieldName: lstFieldNames) {
            Integer fieldNumber = fieldNumberMap.get(fieldName);
            System.debug('fieldNumber++'+fieldNumber);
            if(fieldNumber<csvRecordData.size())
            {
                system.debug(csvRecordData[fieldNumber]);
                String fieldValue = csvRecordData[fieldNumber].trim().removeStart('"').removeEnd('"');
                system.debug(fieldName + '->' +fieldValue);
                System.debug('fieldMap++'+fieldMap);
                describeFieldResult fieldDescribe=fieldMap.get(fieldName).getDescribe();

               if(!string.isblank(fieldValue))
                {
                    fieldValue=fieldValue.replaceAll(':comma:',',');
                    fieldValue=fieldValue.replaceAll(':quotes:','"');
                    if(fieldDescribe.getType()==schema.DisplayType.Integer || 
                        (numbertypes.contains(fieldDescribe.getType()) && fieldDescribe.getScale()==0))
                    {
                        sobj.put(fieldName, Integer.valueOf(fieldValue));
                    }
                    else if(numbertypes.contains(fieldDescribe.getType()) && fieldDescribe.getScale()>0)
                    {
                        sobj.put(fieldName, Decimal.valueOf(fieldValue));
                    }
                    else if(fieldDescribe.getType()==Schema.DisplayType.Boolean)
                    {
                        sobj.put(fieldName, Boolean.valueOf(fieldValue));
                    }
                    else if(fieldDescribe.getType()==Schema.DisplayType.DATE)
                    {
                        sobj.put(fieldName, Date.valueOf(fieldValue));
                    }
                    else if(fieldDescribe.getType()==Schema.DisplayType.DATETIME)
                    {
                        sobj.put(fieldName, DateTime.valueOf(fieldValue));
                    }
                    else{
                            sobj.put(fieldName , fieldValue );
                    }
                }
            }
        }
        string key=(String)sobj.get('Name') + (String)sobj.get('SetupOwnerId');
        if(sobjectMap.containsKey(key)){
            wraprecord.currentOrgRecord=sobjectMap.get(key);
            sobj.put('Id',sobjectMap.get(key).Id);
        }
        else{
            wraprecord.currentOrgRecord=Schema.getGlobalDescribe().get(name).newSObject();
        }
        wraprecord.backupRecord=sobj;
        wraprecordList.add(wrapRecord);
        }
    }
    
    }
    return wraprecordList;
}



@AuraEnabled
public static void saveMergedRecords(List<sobject> settingsList){
    list<sobject> updatelist=new list<sobject>();
    list<sobject> insertlist=new list<sobject>();
    for(sobject setting:settingslist){
        if(setting.get('Id')!=null){
            updatelist.add(setting);
        }
        else{
            insertlist.add(setting);
        }
    }
    if(updateList.size()>0){
        if(updateList.size()>10000){
        database.executeBatch(new sojbectDmlBatch(updatelist,'update'),200);
    }
    else{
        database.update(updateList);
        }
    }
    if(insertList.size()>0){

    if(insertList.size()>10000){
        database.executeBatch(new sojbectDmlBatch(insertList,'insert'),200);
    }
    else{
        database.insertImmediate(insertList);
    }

    }  
}

public class settingWrapper{
    @AuraEnabled
    public sobject currentOrgRecord{get;set;}
    @AuraEnabled
    public sobject backupRecord{get;set;}
}

public class fieldWrapper{
    @AuraEnabled
    public string fieldName{get;set;}
    @AuraEnabled
    public boolean updateable{get;set;}
    @AuraEnabled
    public string fieldType{get;set;}
}
}
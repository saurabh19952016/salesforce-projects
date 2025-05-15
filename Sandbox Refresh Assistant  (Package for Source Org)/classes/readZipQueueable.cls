public class readZipQueueable implements Queueable{
private Zippex zipFile = new Zippex();
private List <String> fileNames;
private String currentFileName;
private List<Schema.DisplayType> stringtypes=new List<Schema.DisplayType>{Schema.DisplayType.STRING,Schema.DisplayType.Phone,Schema.DisplayType.Email,Schema.DisplayType.URL,Schema.DisplayType.ID,Schema.DisplayType.REFERENCE};
private List<Schema.DisplayType> numbertypes=new List<Schema.DisplayType>{Schema.DisplayType.Currency,Schema.DisplayType.Double,Schema.DisplayType.Percent};

public readZipQueueable(Zippex zipFile, List <String> fileNames){
    this.zipFile=zipFile;
    this.fileNames=fileNames;
    this.currentFileName=fileNames.remove(0);
}

public void execute(QueueableContext context) {
  try{
        system.debug('limits : ' +limits.getDMLRows());
    List<String> lstFieldNames=new List<String>();
    List<sobject> insertList=new List<sobject>();
    List<sobject> updateList=new List<sobject>();
    Map<String,Integer> fieldNumberMap=new Map<String,Integer>();
    Blob fileData = zipFile.getFile(currentFileName);
    system.debug(fileData);
    currentFileName=currentFileName.removeEnd('.csv');
    system.debug('currentFileName ' + currentFileName);
    String csvFile= fileData.toString();
    List<sobject> sobjectList=database.query('select id,name,setupownerId from ' + currentFileName + ' order by name');
    Map<String,sobject> sobjectMap=new Map<String,sobject>();
    for(sobject s:sobjectList){
        sobjectMap.put((String)s.get('Name') + (String)s.get('SetupOwnerId'),s);
    }
    system.debug('keyset'+sobjectMap.keyset());
    List<String> csvFileList=csvFile.removeStart('"').removeEnd('"').split('"\n"');
    List<String> csvFieldNames = csvFileList[0].split(',');
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType ObjSchema = schemaMap.get(currentFileName);
    Map<String, Schema.SObjectField> fieldMap = ObjSchema.getDescribe().fields.getMap();
    for (Integer i = 0; i < csvFieldNames.size(); i++) {
        string fldname=csvFieldNames[i].remove('"');
        fieldNumberMap.put(fldname.trim(), i);
        lstFieldNames.add(fldname.trim());
    }
    system.debug(lstFieldNames);
    if(csvFileList.size()>1){

    for (Integer i = 1; i < csvFileList.size(); i++) {
        sobject sobj =  Schema.getGlobalDescribe().get(currentFileName).newSObject();
        //csvFileList[i]=csvFileList[i].removeStart('"').removeEnd('"');
        system.debug(csvFileList[i]);
        //csvFileList[i]=csvFileList[i]+'"';
        string[] csvRecordData = csvFileList[i].split('","');
        if(!csvRecordData.isEmpty()){
        for (String fieldName: lstFieldNames) {
            Integer fieldNumber = fieldNumberMap.get(fieldName);
            if(fieldNumber<csvRecordData.size())
            {
                system.debug(csvRecordData[fieldNumber]);
                String fieldValue = csvRecordData[fieldNumber].trim().removeStart('"').removeEnd('"');
                system.debug(fieldName + '->' +fieldValue);
            describeFieldResult fieldDescribe=fieldMap.get(fieldName).getDescribe();
            if(!string.isblank(fieldValue))
           {
               fieldValue=fieldValue.replaceAll(':comma:',',');
               fieldValue=fieldValue.replaceAll(':quotes:','"');
               if(stringtypes.contains(fieldDescribe.getType()))
            {
                sobj.put(fieldName , fieldValue );
            }
            else if(fieldDescribe.getType()==schema.DisplayType.Integer || 
                (numbertypes.contains(fieldDescribe.getType()) && fieldDescribe.getScale()==0))
            {
                sobj.put(fieldName.trim(), Integer.valueOf(fieldValue.trim()));
            }
            else if(numbertypes.contains(fieldDescribe.getType()) && fieldDescribe.getScale()>0)
            {
                sobj.put(fieldName.trim(), Decimal.valueOf(fieldValue.trim()));
            }
            else if(fieldDescribe.getType()==Schema.DisplayType.Boolean)
            {
                sobj.put(fieldName.trim(), Boolean.valueOf(fieldValue.trim()));
            }
            else if(fieldDescribe.getType()==Schema.DisplayType.DATE)
            {
                sobj.put(fieldName.trim(), Date.valueOf(fieldValue.trim()));
            }
            else if(fieldDescribe.getType()==Schema.DisplayType.DATETIME)
            {
                sobj.put(fieldName.trim(), DateTime.valueOf(fieldValue.trim()));
            }
        }
    }
}
        }
        String name=(String)sobj.get('Name') + (String)sobj.get('SetupOwnerId');
        system.debug('keyset'+name);
        //if(currentFileName=='Migration_Objects__c')
        //system.debug((String)sobj.get('objectName__c'));
        if(sobjectMap.containsKey(name)){
            sobject sobjtemp=sobjectMap.get(name);
            sobj.put('Id',sobjtemp.get('Id'));
            updateList.add(sobj);
        }
        else {
            insertList.add(sobj);
        }      
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

    if(fileNames.size()>0){
        system.enqueueJob(new readZipQueueable(zipFile,fileNames));
    }
}
catch(exception ex){
    MetadataHandlerClass.sendMail(ex.getMessage(), ex.getMessage() + '\n' + ex.getStackTraceString());
}
}
}
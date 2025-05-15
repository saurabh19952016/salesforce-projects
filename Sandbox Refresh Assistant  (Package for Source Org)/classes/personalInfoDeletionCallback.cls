public with sharing class personalInfoDeletionCallback  implements Metadata.DeployCallback {
    private string selectedObj;
    private string fieldList;

        public personalInfoDeletionCallback(string selectedObj,string fieldList){
        this.selectedObj=selectedObj;
        this.fieldList=fieldList;
    }

    public void handleResult(Metadata.DeployResult result,
                             Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            if(selectedObj!=null){
                system.debug('fieldList' + fieldList);
                createFieldList(selectedObj,fieldList);
            }
            System.debug('success: '+ result);
        } else {
            // Deployment was not successful
            System.debug('fail: '+ result.errorMessage);
        }
    }

    public static void createFieldList(string selectedObj, string fieldList){
        try{
            string namespaceprefix='';
        system.debug('fieldList' + fieldList);
        refresh_setting_met__mdt refsetting=(refresh_setting_met__mdt)customMetadataService.getQuery('select id,developerName from refresh_setting_met__mdt where developerName=\'' + selectedObj + '\' limit 1')[0];
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        string fullname=string.valueof(system.now());
        fullname=fullname.replaceAll('[^0-9+]','');
        customMetadata.fullName = nameSpacePrefix + 'fieldList.flds_' + fullname;
        customMetadata.label = fullname;
        
       Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField = new Metadata.CustomMetadataValue();
        customField.field = 'fieldList__c';
        customField.value = fieldList;
        customMetadata.values.add(customField);
      
        customField = new Metadata.CustomMetadataValue();
        customField.field = 'refresh_settings__c';
        customField.value = refsetting.developerName;
        customMetadata.values.add(customField);               
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        personalInfoDeletionCallback callback = new personalInfoDeletionCallback(null,null);
        if(!test.isRunningTest()){
                    Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);

        }
        }
            catch(exception ex){
                    MetadataHandlerClass.sendMail('Preference creation failed.', 'Preference creation failed for the object' + selectedObj + 'for below fields :\n' +
                                                  string.join(fieldList.split(','),'\n') 
                                                 + 'Exception : ' + ex.getMessage());

            }
    }
}
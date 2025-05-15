({
    doInit : function(component, event, helper) {
        var columns=[];
        columns.push({label: 'Job Id', fieldName: 'jobId__c', type: 'text'});
        columns.push({label: 'Object Name', fieldName: 'DeveloperName', type: 'text'});
        columns.push({label: 'Job Status', fieldName: 'Status__c', type: 'text'});
        columns.push({type: "button", typeAttributes: {
            label: 'View Preferences',
            name: 'view',
            title: 'view',
            disabled: false,
            value: 'view',
            variant:'brand',
            iconName: 'utility:preview'
        }});
        columns.push({type: "button", typeAttributes: {
            label: 'Delete Preferences',
            name: 'delete',
            title: 'delete',
            disabled: false,
            value: 'delete',
            variant:'destructive',
            iconName: 'utility:delete'
        }});
        component.set("v.columns",columns);
        var objectName=component.get("v.objectName");
        helper.getPromise(component,helper);
    },

    viewRecord : function(component, event, helper) {
        $A.util.addClass(component.find("message"),"slds-hide");

        var recId = event.getParam('row').Id;
        console.log(recId);
        var actionName = event.getParam('action').name;
        if ( actionName == 'view' ) {
            component.set("v.isOpen",true);
            var jobList=component.get("v.jobStatusList");
            for(var i in jobList){
                console.log(jobList[i]);
                if(jobList[i].Id==recId){
                    component.set("v.selectedObj",jobList[i]);
                    break;
                }
            }
        }
        else if ( actionName == 'delete' ) {
            var action=component.get("c.deleteMetadata");
            action.setParams({
                'recId':recId
            });
            action.setCallback(this,function(response){
                if(response.getReturnValue==false){
                    $A.util.removeClass(component.find("message"),"slds-hide");
                    component.set("v.message","No Preferences exist for the selection.");
                    component.set("v.type","error");                     
                }
                else{
                    $A.util.removeClass(component.find("message"),"slds-hide");
                    component.set("v.message","Job to delete preferences submitted successfully");
                    component.set("v.type","success");                     
                }
            });
            $A.enqueueAction(action);
        }
    }
})
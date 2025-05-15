({
    
    handleFieldEvent: function(component, event, helper) {
        $A.util.toggleClass(component.find("spinner"),"slds-hide");
        var action=component.get("c.getObjectFields");
        var object=component.get("v.settings.Object_Name__c");
        action.setParams({
            "selectedObj":object
        });
        action.setCallback(this,function(response){
            console.log(response.getState());
            if(response.getState()=='SUCCESS'){
                console.log(response.getReturnValue());
                component.set("v.fieldList",response.getReturnValue());
            }
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    clearFields:function(component, event, helper) {
        component.set("v.fieldList",[]);
        component.set("v.settings.Object_Name__c",null);
    },
    runBatchClass: function(component, event, helper) {
        component.set("v.disabled",true);
        $A.util.toggleClass(component.find("spinner"),"slds-hide");
        var action=component.get("c.runBatch");
        action.setParams({
            "objectName":component.get("v.settings.Object_Name__c"),
            "objectType":component.get("v.settings.Object_type__c")
        })
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){ 
                if(response.getReturnValue()=='success')
                {
                    component.set("v.message","");
                    component.set("v.type","");
                }
                else if(response.getReturnValue()=='fail'){
                    component.set("v.message",component.get("v.settings.Object_Name__c") + " Settings does not exist. Please insert the required settings to run Archival batch.");
                    component.set("v.type","error");
                    component.set("v.disabled",false);
                    
                }
                    else{
                        component.set("v.message",response.getReturnValue());
                        component.set("v.type","error");
                        component.set("v.disabled",false);
                        
                    }
                $A.util.toggleClass(component.find("spinner"),"slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
     runAttachtoCase:function(component, event, helper) {
            var cmpEvent = $A.get("e.c:attachReparentEvent");
            var  bool=true;
	            cmpEvent.setParams({
                "switch":bool
            });
            cmpEvent.fire();
        },
    reparent:function(component, event, helper) {
        helper.makeParent(component,event,helper);
    },
})
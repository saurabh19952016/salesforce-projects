({
    doInit : function(component, event, helper) {
        var action=component.get("c.checkJobRunning");
        action.setCallback(this,function(response){
            component.set("v.isJobRunning",response.getReturnValue());
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
        });
        $A.enqueueAction(action);
    },
    deleteJobs : function(component, event, helper) {
        $A.util.toggleClass(component.find("spinner"),"slds-hide");
        var action=component.get("c.deleteJobMethod");
        action.setCallback(this,function(response){
            $A.util.toggleClass(component.find("message"),"slds-hide");
             $A.util.addClass(component.find("card"),"slds-hide");
             $A.util.toggleClass(component.find("spinner"),"slds-hide");
            component.set("v.message","Job has been submitted successfully");
             component.set("v.type","success");
        });
        $A.enqueueAction(action);
    },
})
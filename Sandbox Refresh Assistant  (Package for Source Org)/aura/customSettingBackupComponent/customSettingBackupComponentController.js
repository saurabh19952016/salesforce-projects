({
    doInit : function(component, event, helper) {
            var action=component.get("c.isJobRunning");
            action.setCallback(this,function(response){
                component.set("v.isJobRunning",response.getReturnValue());
            });
            $A.enqueueAction(action);
    }
})
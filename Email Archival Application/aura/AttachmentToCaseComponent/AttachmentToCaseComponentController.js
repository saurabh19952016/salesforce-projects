({
    attachReparent : function(component, event, helper) {
        component.set("v.Status","Pending");
       /* var action = component.get("c.getDate");
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                component.set("v.dateLimit",response.getReturnValue());  
                  if(!component.get("v.email"))*/
              		  helper.handleAttachments(component,event,helper);
                
           /* } else if (state === "ERROR") {
                // generic error handler
               helper.handleError(component);
            }
        });
        
        $A.enqueueAction(action);*/
 
    },
     /*emailToAttachment : function(component, event, helper) {
        component.set("v.Status","Pending");
        var action = component.get("c.getDate");
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                component.set("v.dateLimit",response.getReturnValue());  
                if(component.get("v.email"))
              		  helper.handleEmails(component,event,helper);
            } else if (state === "ERROR") {
                // generic error handler
               helper.handleError(component);
            }
        });
        
        $A.enqueueAction(action);
    }*/
})
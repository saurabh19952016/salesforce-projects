({
        checkBatchExecuting: function(component, event, helper) {
            var action=component.get("c.getBatchStatus");
            action.setCallback(this,function(response){
                console.log('new set --> ',response.getReturnValue());
                if(response.getState()=='SUCCESS'){
                    if(response.getReturnValue()==true){
                        component.set("v.disableBatch",false);
                    }
                }
                else
                {
                    helper.handleError(component,event,response);
                }
            });
            $A.enqueueAction(action);
        },
        
        findEmails : function(component, event, helper) {
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
            
            helper.getArchived(component,event,helper);
            component.set('v.columns', [
                {label: 'FromAddress', fieldName: 'FromAddress', type: 'text'},
                {label: 'ToAddress', fieldName: 'ToAddress', type: 'text'},
                {label: 'Subject', fieldName: 'Subject', type: 'text'},
                {label: 'Body', fieldName: 'TextBody', type: 'text'}
            ]);
        },
      
        runBatch:function(component, event, helper) {
            component.set("v.disableBatch",true);
            
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
            var action=component.get("c.ArchiveEmailMessages");
            console.log("handler")
            action.setCallback(this,function(response){
                console.log('new set --> ',response.getState());
                if(response.getState()!='SUCCESS'){
                    helper.handleError(component,event,response);
                }
                $A.util.toggleClass(component.find("spinner"),"slds-hide");
            });
            $A.enqueueAction(action);
        },
        runAttachtoCase:function(component, event, helper) {
            var cmpEvent = $A.get("e.c:attachReparentEvent");
            var  bool=true;
            component.set("v.disabled",true);
            cmpEvent.setParams({
                "switch":bool
            });
            cmpEvent.fire();
        },
   /* runEmailtoAttachment:function(component, event, helper) {
            var cmpEvent = $A.get("e.c:emailToAttachmentEvent");
            var  bool=true;
            component.set("v.disableEmailToAttach",true);
            cmpEvent.setParams({
                "switch":bool
            });
            cmpEvent.fire();
        },*/
    })
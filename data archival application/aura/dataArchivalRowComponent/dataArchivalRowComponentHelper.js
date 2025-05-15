({
    makeParent:function(component, event, helper) {
        component.set("v.disabled",true);
        $A.util.toggleClass(component.find("spinner"),"slds-hide");
        var action=component.get("c.changeParent");
        action.setParams({
            "newsetting":component.get("v.settings"),
            "parentRecord":component.get("v.parentSetting")
        })
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){ 

               var cpevent=$A.get("e.c:refreshParent");
                cpevent.setParams({
                    "visibleTab":"subParent"
                });
                cpevent.fire();
            }
            else {
                component.set("v.message","Reparenting failed due to error");
                component.set("v.type","error");
            }
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
            component.set("v.disabled",false);
            
        });
        $A.enqueueAction(action);
    }
})
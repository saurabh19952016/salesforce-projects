({
    doInit : function(component,event,switchTab) {
        var action=component.get("c.getMaxHierarchyLevel");
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){                
                component.set("v.IntList",response.getReturnValue());
                if(switchTab==true){
                    var select= event.getParam("visibleTab");
                    if(select>1){
                        select=select-1;            
                        component.set("v.message","Reparenting successful");
                        component.set("v.type","success");   
                    }
                    else{
                        component.set("v.message","Delete Successful");
                        component.set("v.type","success");   
                    }
                    component.find("tabset").set("v.selectedTabId",(select).toString());
                    
                }
                
            }
            else {
                component.set("v.message","Error displaying component");
                component.set("v.type","error");
            }
            
        });
        $A.enqueueAction(action);
    }
})
({
    makeParent:function(component, event, helper) {
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
                    "visibleTab":response.getReturnValue()+1
                });
                cpevent.fire();
            }
            else {
                component.set("v.message","Reparenting failed due to error");
                component.set("v.type","error");
            }
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
            
        });
        $A.enqueueAction(action);
    },
    
    runBatch:function(component,event,helper){
        var objectSettings=component.get("v.settings");
        var fields=component.get("v.selectedFields");
        var bool=false;
      if(objectSettings.Hierarchy_Level__c==1 && fields.length==0){
            $A.util.removeClass(component.find("message"),"slds-hide");
            component.set("v.message","Please Select Fields");
            component.set("v.type","error");  
            bool=true;
        }
      /*   if( /[^a-zA-Z0-9,'()\-\/]/.test( objectSettings.filterValue_1__c ) || /[^a-zA-Z0-9,'()\-\/]/.test( objectSettings.filterValue_2__c )) {
            $A.util.removeClass(component.find("message"),"slds-hide");
            component.set("v.message","Filter values should not contain special characters except [()',]");
            component.set("v.type","error");  
            bool=true;
        }
          if(objectSettings.filterValue_1__c!=undefined && objectSettings.filterValue_2__c!=undefined && (objectSettings.filterValue_1__c.length>255 || objectSettings.filterValue_2__c.length>255)){
            $A.util.removeClass(component.find("message"),"slds-hide");
            component.set("v.message","Filter values character limit exceeded.Limit is 255 characters.");
            component.set("v.type","error");  
             bool=true;
       }
       if(objectSettings.filterField_1__c!='' && objectSettings.filterField_2__c!='' && objectSettings.filterField_1__c==objectSettings.filterField_2__c){
            $A.util.removeClass(component.find("message"),"slds-hide");
            component.set("v.message","Please select different fields for each filter");
            component.set("v.type","error");  
              bool=true;
      }
      
        if(bool==false){ */
        else{
            
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
            
            var action=component.get("c.runBatch");
            
            action.setParams({
                "objectName":objectSettings,
                "fields":fields
            })
            action.setCallback(this,function(response){
                console.log(response.getReturnValue());
                if(response.getState()=='SUCCESS'){ 
                    objectSettings.Status__c='Running';
                    component.set("v.settings",objectSettings);
                    $A.util.toggleClass(component.find("spinner"),"slds-hide");
                }
            });
            $A.enqueueAction(action);
       // }
     }
    }
})
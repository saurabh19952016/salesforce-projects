({
   handleFieldEvent:function(component,event,helper){
        var settings=component.get("v.settings");
        console.log(settings.Object_type__c);
        if(settings.Id!=null && settings.Object_type__c=='Child'){
          	component.set('v.selectedFields',[]);
            var action=component.get("c.getFieldList");
            action.setParams({
                "selectedObj":settings.objectName__c
            });
            action.setCallback(this,function(response){
                console.log(response.getState());
                if(response.getState()=='SUCCESS'){
                    var  objectDetails=response.getReturnValue();
                    console.log(objectDetails);
                    var options=[];
                    for(var i in objectDetails.fieldList){
                        options.push({'label': objectDetails.fieldList[i],'value':objectDetails.fieldList[i]});
                    }
                    component.set("v.fieldList",options);
                    component.set("v.objectDetails",objectDetails);
                }
            $A.util.addClass(component.find("spinner"),'slds-hide');
                
            });
            $A.enqueueAction(action);
        }
       else{
            $A.util.addClass(component.find("spinner"),'slds-hide');
       }        
    },
    
    clearFields:function(component, event, helper) {
        component.set("v.fieldList",[]);
        component.set("v.objectName","");
        
    },
    
   
    reparent:function(component, event, helper) {
        helper.makeParent(component,event,helper);
    },
    
    runBatchClass: function(component, event, helper) {
    	helper.runBatch(component, event, helper);
    },
     
    onInputCheck :function (cmp, event) {
     var allValues=[]; 
        if(cmp.find("checkbox").get("v.checked")){
             var options=cmp.get("v.fieldList");        
             for(var i in options){
                allValues.push(options[i].label);            
             }
        }   
        cmp.set("v.selectedFields", allValues);
    },
})
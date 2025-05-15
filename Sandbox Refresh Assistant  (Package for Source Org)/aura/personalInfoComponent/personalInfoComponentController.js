({
    handleNext : function(component, event, helper) {
        var currentValue=parseInt(component.get("v.currentStep"));
        if(component.get("v.objectName")==undefined){
            $A.util.removeClass(component.find("message"),"slds-hide");
            component.set("v.message","Please select an object before you proceed.");
            component.set("v.type","error");  
        }
        else if(currentValue<2 ){
            $A.util.addClass(component.find("message"),"slds-hide");
            currentValue+=1;
            component.set("v.currentStep",currentValue.toString());
        }
    },
    handlePrevious : function(component, event, helper) {
        var currentValue=parseInt(component.get("v.currentStep"));
            currentValue-=1;
            component.set("v.currentStep",currentValue.toString());
    },
    handleChange : function(component, event, helper) {
        $A.util.toggleClass(component.find("spinner"),"slds-hide");
            helper.callActionAsPromise(
            component,
            helper,
            'c.checkJobRunning',
            {objectName:component.get("v.objectName")}
        ).then(function(response){
            $A.util.addClass(component.find("message"),"slds-hide");
            component.set("v.jobRunning",response);
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
            if(response==false){
                $A.util.removeClass(component.find("message"),"slds-hide");
                component.set("v.message","The Job is already running. Please select a different object.");
                component.set("v.type","error");    
            }
              
            })
    },
    selectFields: function(component,event,helper){
        component.set("v.selected", event.getParam("fields"));
        component.set("v.objectName", event.getParam("object"));
        component.set("v.currentStep","2");
    }
})
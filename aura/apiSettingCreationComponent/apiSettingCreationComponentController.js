({
    doInit : function(component, event, helper) {
        component.set("v.userEndpoint","Target environment user retrieval endpoint (use {!userId} in the url as the merge field for salesforce"+
                      " user's Identifier that gets mapped to the target environment (Mostly Federation Id)");
        helper.initialize(component,event,helper);
    },
    
    handleChange : function(component, event, helper) {
        var elementId=event.getSource().getLocalId();
        var apiSettingMap=component.get("v.apiSettingMap");
        apiSettingMap[elementId]=event.getSource().get("v.value");
        component.set("v.apiSettingMap",apiSettingMap);
    },
    
    handleSave : function(component, event, helper) {
        	$A.util.removeClass(component.find("spinner"),"slds-hide");
        var apiSettingMap=component.get("v.apiSettingMap");
        var userEndpoint=component.find("API_getUser_endpoint");
        if(!userEndpoint.get("v.value").includes('{!userId}')){
            userEndpoint.setCustomValidity("Please add {!userId} to be used as the merge field in the endpoint to search for the corresponding caller id in the target environment.");
            userEndpoint.reportValidity();
             helper.showToast("ERROR","One or more fields have an invalid input.","error");
          
        }
        else{
            helper.save(component, event, helper);
            
        }
    },
    
    openNamedCredentialTab: function(component, event, helper) {
         var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": event.getSource().get("v.name")
        });
        urlEvent.fire();
    },
})
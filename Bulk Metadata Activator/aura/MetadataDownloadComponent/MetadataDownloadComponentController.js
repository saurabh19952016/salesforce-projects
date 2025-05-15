({
    init : function(component, event, helper) {
        helper.toggleSpinner(component);
        var action=component.get('c.getsobjectList');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.sObjectList",response.getReturnValue());
            }
            helper.toggleSpinner(component);
            component.set('v.objname','Account');
            
        });
        console.log('test');
        $A.enqueueAction(action);
    },
    
    getObjectMetadata : function(component,event,helper){
        var action=component.get('c.getMetadata');
        var objName=component.get('v.objname');
        action.setParams({
            'objectname':objName
        });
        helper.toggleSpinner(component);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state+ component.get('v.objname'));
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                component.set("v.metadatamap", arrayMapKeys);
                component.set("v.SizeOfMap", arrayMapKeys.length);
                component.set("v.objnameLower",objName.toLowerCase());
                helper.toggleSpinner(component);
                console.log(arrayMapKeys.length);
            }
        });	
        $A.enqueueAction(action);
    }
})
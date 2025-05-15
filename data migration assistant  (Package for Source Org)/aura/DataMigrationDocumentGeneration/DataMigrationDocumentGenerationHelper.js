({
    callActionAsPromise : function(component, helper, actionName, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get(actionName);
            action.setParams(params);
            action.setCallback(helper, function(actionResult) {
                if (actionResult.getState() === 'SUCCESS') {
                    resolve(actionResult.getReturnValue());
                } else {
                    let errors = actionResult.getError();
                    reject(new Error(errors && Array.isArray(errors) && errors.length === 1 ? errors[0].message : JSON.stringify(errors)));
                }
            });
            $A.enqueueAction(action);
        }));
    },
    getPromise: function(component,helper,actionName,getChild,considerValidation,SFDCtoSFDC,authCredentials){
        var object=component.get("v.objectName");
        return helper.callActionAsPromise(
            component,
            helper,
            actionName,
            {
                "selectedObj":object,
                "getChild":getChild,
                "considerValidation":considerValidation,
                "SFDCtoSFDC":SFDCtoSFDC,
                "authwrap":authCredentials
            }
        )  
    },
    
    successCallback: function(component,helper,response){
        var objList=[];  
        console.log(response);
        for(var key in response){
            objList.push({key:key,value:response[key]});
        }
        component.set("v.objList",objList);
    },
    

})
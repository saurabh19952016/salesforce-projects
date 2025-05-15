({
    getPromise:function(component,helper,actionName,params){
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
                $A.util.addClass(component.find("spinner"),"slds-hide");
            });
            $A.enqueueAction(action);
        }));
    },

    getConflictRecords : function(component,event,helper) {
        var selectedObject=component.get("v.selectedObject");
        var params={
            name:selectedObject.Name,
            base64Data:selectedObject.base64Data
        };
        var method= helper.getPromise(component,helper,'c.getConflicts',params);
        method.then(function(result){
            console.log(result);
            component.set("v.recordWrapList",result);
            component.set("v.TotalPages",Math.round(result.length/20));
        });
        /* var action=component.get("c.getConflicts");
        var selectedObject=component.get("v.selectedObject");
        action.setParams({
            name:selectedObject.Name,
            base64Data:selectedObject.base64Data
        });
        action.setCallback(this,function(response){
            console.log(response.getReturnValue());
            component.set("v.recordWrapList",response.getReturnValue());
        });
        $A.enqueueAction(action);*/
    },

    getFields : function(component,event,helper) {
        var selectedObject=component.get("v.selectedObject");
        var params={
            selectedObj:selectedObject.Name
        };
        var method= helper.getPromise(component,helper,'c.getObjectFields',params);
        method.then(function(result){
            console.log(result);
            component.set("v.fieldList",result);
        });

        /*var action=component.get("c.getObjectFields");
        var selectedObject=component.get("v.selectedObject");
        action.setParams({
            selectedObj:selectedObject.Name
        });
        action.setCallback(this,function(response){
            console.log(response.getReturnValue());
            component.set("v.fieldList",response.getReturnValue());
        });
        $A.enqueueAction(action);*/
    },

    saveRecords:function(component,event,helper){
        var sobjectList=[];
        var recordList=component.get("v.recordWrapList");
        for(var i in recordList){
            recordList[i].backupRecord.sobjectType=component.get("v.selectedObject.Name");
            sobjectList.push(recordList[i].backupRecord);
        }
        var params={
            settingsList:sobjectList
        };
        console.log(sobjectList);
        var method= helper.getPromise(component,helper,'c.saveMergedRecords',params);
        method.then(function(result){
            console.log(result);
            var cmpEvent = component.getEvent("goToList"); 
            cmpEvent.setParams({
                      "eventType" : "Success"
                    }); 
            alert("Records saved successfully.");
           cmpEvent.fire(); 
        })
        .catch(function(error){
            console.log(error);
                alert(error);
        });
    }
})
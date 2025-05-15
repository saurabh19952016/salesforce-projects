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
            });
            $A.enqueueAction(action);
        }));
    },

    loadMetadataList: function(component,event,helper){
        $A.util.addClass(component.find("spinner"),"slds-hide");
        component.set("v.jobStatuses",[]);
        var getMetadataJobIds=helper.getPromise(component,helper,'c.getMetadataJobIds',{operation:'retreive'});
        getMetadataJobIds.then(function(result){
            component.set("v.jobStatuses",result);
            console.log(result);
            if(result.length == 0){
                var getAllMetadata=helper.getPromise(component,helper,'c.getAllMetadata',{});
                getAllMetadata.then(function(result){
                var options=[];
                for(var i in result){
                    options.push({label: result[i],value:result[i]});
                }
                component.set("v.options",options);
                console.log(options);
            });
            $A.util.addClass(component.find("spinner"),"slds-hide");

            }
            else{
                helper.checkRetreive(component,event,helper);  
            }
        });
},

submitJob: function(component,event,helper){
    var selected= component.get("v.selectValues");
   $A.util.toggleClass(component.find("spinner"),'slds-hide'); 
    console.log("Helper started");
    var promises=[];
    selected.forEach(element => 
        {
            var params= {
                'metadataSelected':element
            };
            promises.push(helper.getPromise(component,helper,'c.submitRetreiveJob',params));
    });
    Promise.all(promises).then($A.getCallback(function(value){
        component.set("v.jobStatuses",value);
        $A.util.toggleClass(component.find("spinner"),'slds-hide'); 
        helper.checkRetreive(component,event,helper); 
    }));
  },

  checkRetreive:function(component,event,helper){
    $A.util.toggleClass(component.find("spinner"),"slds-hide");
    console.log("Helper started");
    var promises=[];
    var jobIds=component.get("v.jobStatuses");
    console.log('jobIds'+jobIds);
    jobIds.forEach(element => 
        {
            if(element.status!='Succeeded' && element.status!='Failed'){
            var params= {
                'jobId':element.jobId
            };
            promises.push(helper.getPromise(component,helper,'c.checkJobRetrieve',params));
        }
    });
    if(promises.length>0){
    Promise.all(promises).then($A.getCallback(function(value){
        console.log(value);
        var completed=0;
        value.forEach(element=>{
            if(element.status=='Succeeded' || element.status=='Failed' || element.status=='Exception'){
                completed+=1;
                console.log(completed);
            }
        });
        if(completed==value.length){
            console.log('refreshing');
            $A.util.removeClass(component.find("spinner"),"slds-hide");
           helper.loadMetadataList(component,event,helper);
        }
        else{
            //component.set("v.jobStatuses",value);
            //$A.util.addClass(component.find("status"),'slds-hide');
            helper.checkRetreive(component,event,helper);  
        }
  
    }));
    }   
  },

 
})
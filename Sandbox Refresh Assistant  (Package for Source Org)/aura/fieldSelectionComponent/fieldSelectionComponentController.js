({
    doInit : function(component, event, helper) {
        $A.util.toggleClass(component.find("spinner"),"slds-hide");
        $A.util.removeClass(component.find("layout"),"slds-hide");
        var objectName=component.get("v.objectName");
        helper.callActionAsPromise(
            component,
            helper,
            'c.getObjectFields',
            {selectedObj:component.get("v.objectName")}
        ).then(function(response){
            var returnValue=[];
            for(var i in response){
                returnValue.push({label:response[i],value:response[i]});
            }
            component.set("v.fieldList",returnValue);
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
        })
    },
 handleClick : function(component, event, helper) {
    $A.util.toggleClass(component.find("spinner"),"slds-hide");
    var objectName=component.get("v.objectName");
            var selected=component.get("v.selectedValues");
            console.log(selected);
            helper.callActionAsPromise(
                component,
                helper,
                'c.submitJob',
                {selectedObj:objectName,
                fieldList:selected}
            ).then(function(response){
                $A.util.toggleClass(component.find("spinner"),"slds-hide");
                $A.util.toggleClass(component.find("message"),"slds-hide");
                
                if(response=='SUCCESS'){
                    $A.util.addClass(component.find("layout"),"slds-hide");
                    component.set("v.message","Job has been submitted successfully");
                    component.set("v.type","success");
                    component.set('v.objectName','');
                }
              else if(response=='ERROR'){
                component.set("v.message","Job Submission Failed due to too many field preferences for selected object. Please delete the custom metadata to proceed");
                component.set("v.type","error");  
            }
            else{
                component.set("v.message","Job Submission Failed");
                component.set("v.type","error");

              }
            });
        },
        selectFields: function(component,event,helper){
            var fields = event.getParam("fields");
            component.set("v.selected",fields);
        },
        onInputCheck :function (cmp, event) {
            var allValues=[]; 
               if(cmp.find("checkbox").get("v.checked")){
                    var fields=cmp.get("v.fieldList");        
                    for(var i in fields){
                       allValues.push(fields[i].value);            
                    }
               }   
               cmp.set("v.selectedValues", allValues);
           },
})
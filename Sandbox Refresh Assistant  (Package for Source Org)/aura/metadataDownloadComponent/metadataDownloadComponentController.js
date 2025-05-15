({
    doInit : function(component, event, helper) {
        if(event.getParam("isSizeExceeded") && component.get("v.type")!='error'){
            $A.util.toggleClass(component.find("message"),"slds-hide");
            $A.util.toggleClass(component.find("layout"),"slds-hide");
            component.set("v.message","File Storage has exceeded the limit of 1 GB in the backup storage org. Please delete existing files to continue taking backups.");
            component.set("v.type","error");
        }
        else{
             helper.loadMetadataList(component,event,helper);
        }
    },
    
    onInputCheck :function (cmp, event) {
     var allValues=[]; 
        if(cmp.find("checkbox").get("v.checked")){
             var options=cmp.get("v.options");        
             for(var i in options){
                allValues.push(options[i].label);            
             }
        }   
        cmp.set("v.selectValues", allValues);
    },

    submitAction: function (cmp, event, helper) {
        // This will contain an array of the "value" attribute of the selected options             

       helper.submitJob(cmp,event,helper);
    },

})
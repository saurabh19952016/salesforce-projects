({
    doInit : function(component, event, helper) {
        console.log("Inside CSide Cont");
        if(event.getParam("isSizeExceeded")){
            $A.util.addClass(component.find("layout"),"slds-hide");
            $A.util.toggleClass(component.find("message"),"slds-hide");
            component.set("v.message","File Storage has exceeded the limit of 1 GB in the backup storage org. Please delete existing files to continue taking backups.");
            component.set("v.type","error");
            
        }
        else{
            helper.loadCSList(component);

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
       var selected= cmp.get("v.selectValues");
       helper.submitJob(selected,cmp,helper);
    },

})
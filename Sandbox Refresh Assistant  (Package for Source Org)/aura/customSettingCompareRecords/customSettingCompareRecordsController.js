({


     getConflictRecords:function(component, event, helper) {
         console.log('conflicts');
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        helper.getFields(component,event,helper);
        helper.getConflictRecords(component,event,helper);  
    
     },

     handleSave: function(component, event, helper) {
        console.log('conflicts');
       // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
       $A.util.toggleClass(component.find("spinner"),"slds-hide");
       helper.saveRecords(component,event,helper);
   
    },

    handleBack: function(component, event, helper) {
        console.log('conflicts');
       // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
       var cmpEvent = component.getEvent("goToList"); 
                   cmpEvent.setParams({
                             "eventType" : "Error"
                   }); 
       
       cmpEvent.fire();    
    },

    handlePrevious: function(component, event, helper) {
        $A.util.removeClass(component.find("spinner"),"slds-hide");
        component.set("v.pageNumber",component.get("v.pageNumber")-1);
        component.set("v.start",component.get("v.start")-20);
        component.set("v.end",component.get("v.end")-20);
        console.log('done prev');
    },
    handleNext: function(component, event, helper) {
        $A.util.removeClass(component.find("spinner"),"slds-hide");
        component.set("v.pageNumber",component.get("v.pageNumber")+1);
        component.set("v.start",component.get("v.start")+20);
        component.set("v.end",component.get("v.end")+20);
        console.log('done next');
    },
    toggleSpinner:function(component, event, helper) {
        if(component.get("v.load")==true){
        $A.util.addClass(component.find("spinner"),"slds-hide");
        }
    },
    
})
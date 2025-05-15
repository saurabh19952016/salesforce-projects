({
    selectRecord : function(component, event, helper){      
     // get the selected record from list  
       var getSelectRecord = component.get("v.oRecord");
     // call the event   
       console.log(getSelectRecord);
       var compEvent = component.getEvent("oSelectedValueEvent");
     // set the Selected sObject Record to the event attribute.  
       compEvent.setParams({"selectedValue":getSelectRecord });  
     // fire the event  
          compEvent.fire();
     },
 })
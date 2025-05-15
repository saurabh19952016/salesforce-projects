({
    loadCSList: function(component){
  console.log("Helper started");
  var action = component.get("c.CSList");
  action.setCallback(this,function(response){//invoked after the server-side action returns.
  var state = response.getState();
  if (state === "SUCCESS"){
      var returnValue=response.getReturnValue();
      var options=[];

      for(var i in returnValue){
          options.push({label: returnValue[i],value:returnValue[i]});

      }
      component.set("v.options",options);
      console.log(options);
      }
      else {
      console.log("Failed with state: " + state);
      }
  });

  //send action off to be executed
  $A.enqueueAction(action);//calling a server side action
},

submitJob: function(selected,component,helper){
  $A.util.toggleClass(component.find("spinner"),'slds-hide'); 
  console.log("Helper started");
    var action = component.get("c.submitJob");
    action.setParams({
        'customSettings':selected
    })
    action.setCallback(this,function(response){//invoked after the server-side action returns.
      $A.util.toggleClass(component.find("spinner"),'slds-hide'); 
      $A.util.toggleClass(component.find("message"),"slds-hide");
          $A.util.addClass(component.find("layout"),"slds-hide");
          component.set("v.message","Job has been submitted successfully");
          component.set("v.type","success");
    });
  
    //send action off to be executed
    $A.enqueueAction(action);//calling a server side action
  },
})
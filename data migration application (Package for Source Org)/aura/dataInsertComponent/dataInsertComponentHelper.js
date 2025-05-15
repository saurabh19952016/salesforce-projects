({
    getObjects:function(component,event,helper)
    {
        var action=component.get("c.getObjectsPushed");
        $A.util.removeClass(component.find("spinner"),"slds-hide");
        
        action.setCallback(this,function(response){
            console.log(response.getState());
            if(response.getState()=='SUCCESS'){
                console.log(response.getReturnValue());
                component.set("v.objectList",response.getReturnValue());
            }
            $A.util.addClass(component.find("spinner"),"slds-hide");
            
        });
        $A.enqueueAction(action);            
    },
    
    commit:function(component,event,helper)
    {
        $A.util.addClass(component.find("message"),"slds-hide");
        var objectOrders=component.get("v.objectList");
        var orders=[];
        var bool=false;
        objectOrders.forEach(element=>{
            if( orders.includes(element.order) ){
          $A.util.removeClass(component.find("message"),"slds-hide");
          component.set("v.message","Duplicate order numbers present");
            component.set("v.type","error");    
            bool=true;
            console.log('error');
        }
                             else if(element.order==undefined){
         	$A.util.removeClass(component.find("message"),"slds-hide");
           component.set("v.message","Provide an order of insertion for all objects");
            component.set("v.type","error"); 
            bool=true;
            console.log('error');
        }
        else{
            orders.push(element.order);
        }
    });
    if(bool==false){
    var action=component.get("c.commitRecords");
    action.setParams({
    "objectOrders":objectOrders
});
$A.util.removeClass(component.find("spinner"),"slds-hide");

action.setCallback(this,function(response){
    console.log(response.getState());
    if(response.getState()=='SUCCESS'){
        console.log(response.getReturnValue());
          	$A.util.removeClass(component.find("message"),"slds-hide");
       component.set("v.message","Job submitted successfully for Commit.");
        component.set("v.type","success"); 
         $A.util.addClass(component.find("card"),"slds-hide");
   }
    $A.util.addClass(component.find("spinner"),"slds-hide");
    
});
$A.enqueueAction(action);      
}

}
})
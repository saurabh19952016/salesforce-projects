({
    initialize : function(component,event,helper) {
        helper.getPromise(
            component,
            helper,
            "c.getApiSettingRecords",
            {}
        ).then(function(response){
            var apiSettingMap={};
            for(let key in response){
               
                component.find(key).set("v.value",response[key]);
        		apiSettingMap[key]=response[key];
                
            }
            console.log(apiSettingMap);
            component.set("v.apiSettingMap",apiSettingMap);
        	$A.util.addClass(component.find("spinner"),"slds-hide");
        })
        .catch(function(error){
             helper.showToast("ERROR",error.message,"error");
        })
    },
    
    save :function(component,event,helper) {
        helper.getPromise(
            component,
            helper,
            "c.saveSettingRecords",
            {settingMap:component.get("v.apiSettingMap")}
        ).then(function(response){
             helper.showToast("SUCCESS","Settings saved successfully!","success");
        	$A.util.addClass(component.find("spinner"),"slds-hide");
        })
        .catch(function(error){
            helper.showToast("ERROR",error.message,"error");
         	$A.util.addClass(component.find("spinner"),"slds-hide");
          
        })
        
    },
    
  
    
})
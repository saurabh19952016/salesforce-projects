({
    init: function(component, event, helper) {
        helper.callActionAsPromise(
            component,
            helper,
            'c.getAuthWrapper',
            {}
        ).then(function(response){
            response.endpoint='https://login.salesforce.com';
            component.set("v.authCredentials",response);           
        })
        helper.callActionAsPromise(
            component,
            helper,
            'c.getBigObjects',
            {}
        ).then(function(response){
            component.set("v.displayBooleans",response);
            $A.util.addClass(component.find("spinner"),"slds-hide");
            
        })
    },
    
    getInfo : function(component, event, helper) {
        var authCredentials = component.get("v.authCredentials");
        $A.util.addClass(component.find("message"),"slds-hide");
        if(((authCredentials.clientId!=undefined && authCredentials.clientSecret!=undefined && authCredentials.username!=undefined
            && authCredentials.password!=undefined && authCredentials.targetOrgId!=undefined && authCredentials.securityToken!=undefined) &&
           component.get("v.objectName")!=undefined) ||(component.get("v.objectName")!=undefined && component.get("v.SFDCtoSFDC")==false)){
            $A.util.removeClass(component.find("spinner"),"slds-hide");
            var getChild=component.get("v.getChild");
            var considerValidation=component.get("v.considerValidation");
            var SFDCtoSFDC=component.get("v.SFDCtoSFDC");
            helper.getPromise(component,helper,'c.submitJob',getChild,considerValidation,SFDCtoSFDC,authCredentials).then(function(response){
                $A.util.addClass(component.find("spinner"),"slds-hide");
                $A.util.removeClass(component.find("message"),"slds-hide");
                component.set("v.displayBooleans",response);
                if(response.errorMessage=='' || response.errorMessage==undefined || response.errorMessage==null){
                    component.set("v.type",'success');
                component.set("v.message","Job has been submitted you will receive an email once done. Come back and see the report later.");
                }
                else{
         		 component.set("v.type",'error');
                component.set("v.message",response.errorMessage);
                    
                }
                
            })
        } 
        else
        {
            component.set("v.type",'error');
            if(authCredentials.targetOrgId==undefined){
             component.set("v.message","Please enter target Org Id.");
            }
            else if(authCredentials.username==undefined){
             component.set("v.message","Please enter username.");
            }
            else if(authCredentials.password==undefined){
             component.set("v.message","Please enter password.");
            }
            else if(authCredentials.clientSecret==undefined){
             component.set("v.message","Please enter Client Secret.");
            }
            else if(authCredentials.clientId==undefined){
             component.set("v.message","Please enter Client Id.");
            }
            else if(authCredentials.securityToken==undefined){
             component.set("v.message","Please enter security Token.");
            }
                else{
           component.set("v.message","Please select an object to proceed.");
                }
            $A.util.removeClass(component.find("message"),"slds-hide");
        }
       
    },
    print:function(component,event,helper){
        var appEvent = $A.get("e.c:PrintEvent");
        appEvent.fire();
    },
    clearBigObject:function(component,event,helper){
        $A.util.toggleClass(component.find("spinner"),"slds-hide");
        var action=component.get("c.deleteBigObjectRecords");
        action.setCallback(this,function(response){
                component.set("v.displayBooleans",response);
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
        });
        $A.enqueueAction(action);
    }, 
    handleChange:function(component,event,helper){
        $A.util.removeClass(component.find("spinner"),"slds-hide");
        var relationship=component.get("v.value");  
        var methodToCall='c.getBigObjectRecords';
        if(relationship.includes('Picklist')){
            methodToCall='c.getBigObjectPicklist';
            relationship=relationship.replace("Picklist", "");
        }
        helper.callActionAsPromise(
            component,
            helper,
            methodToCall,
            {hierarchy:relationship}
        ).then(function(response){
            console.log(methodToCall);
       	 if(methodToCall=='c.getBigObjectPicklist'){
                component.set("v.isPicklist",true);
           	component.set("v.objList",response);
               console.log(response);
         }
            else{
                  component.set("v.isPicklist",false);
            	helper.successCallback(component,helper,response);
         }
            $A.util.addClass(component.find("spinner"),"slds-hide");
        })
    }, 
    
})
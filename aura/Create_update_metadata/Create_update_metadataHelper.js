({
    fetchData : function( component,helper ) {
        
        helper.getPromise(
            component,
            helper,
            "c.getAllRecords",
            {}
        ).then(function(response){
            var responseMap={};
            response.forEach(elem=>{
                responseMap[elem.id]=elem;
            });
                component.set( "v.data", response);
                component.set("v.dataMap",responseMap);
                $A.util.addClass(component.find("spinner"),'slds-hide');
            })
                .catch(function(error){
                console.log('error'+error);
                helper.showToast("ERROR",error.message,"error");
                 $A.util.addClass(component.find("spinner"),'slds-hide');
           });
                
            },
                
                saveRecords : function(component,draftNewList,helper) {
                    console.log('draftNewList in helper'+draftNewList);
                    console.log(draftNewList);
                    
                    helper.getPromise(
                        component,
                        helper,
                        "c.saveRecord",
                        {
                            wrap:JSON.stringify(draftNewList),
                            length: (component.get("v.data")).length
                        }
                    ).then(function(response){
                  		$A.util.addClass(component.find("spinner"),'slds-hide');
                       $A.util.addClass(component.find("table"),'slds-hide');
                        helper.showToast("SUCCESS","Instructions created successfully! Please refresh the screen.","success");
                        $A.get('e.force:refreshView').fire();
                    })
                    .catch(function(error){
                        console.log('error'+error);
                 		$A.util.addClass(component.find("spinner"),'slds-hide');
                        helper.showToast("ERROR",error.message,"error");
                    });
                }, 
                
                validateRecords :function(component,draftNewList,helper) {
                  $A.util.removeClass(component.find("spinner"),'slds-hide');
                   var dataMap=component.get("v.dataMap");
                    var keys=Object.keys(dataMap);
                    console.log(keys);
                    var newDraftList=draftNewList.map(elem=>{
                        var originalData= dataMap[elem.id];
                        if(originalData!=undefined && keys.length!=0){
                        var originalKeys=Object.keys(originalData);
                        originalKeys.forEach(newKey=>{
                        if (!(newKey in elem)){
                        elem[newKey]=originalData[newKey];
                    }
                   });
                }
                return elem;
            });          
            var orderList=[];
            var radioCount=0;
            var searchBoxCount=0;
            var captureCount=0;
            var error=0;
            for(let i=0 ;i<newDraftList.length;i++){
                var elem=newDraftList[i];
                if((elem.Radio && elem.Capture) ||  (elem.SearchBox && elem.Capture) || (elem.Radio && elem.SearchBox)
                   || (elem.Radio && elem.Capture && elem.SearchBox)){
                    helper.showToast("ERROR","Cannot have multiple checkboxes checked for the same row","error");
                    error=true;
                    break;
                }
                else{
                    radioCount+=elem.Radio?1:0;
                    captureCount+=elem.Capture?1:0;
                    searchBoxCount+=elem.SearchBox?1:0;
                    
                    if(orderList.includes(elem.order)){
                        helper.showToast("ERROR","Duplicate order field values found in records.","error");
                        error=true;
                        break;
                    }
                    else if(elem.order==null || elem.order==undefined || elem.order==''){
                        helper.showToast("ERROR","Order field cannot be blank.","error");
                        error=true;
                        break;
                    }
                        else{
                            orderList.push(elem.order);
                        }
                }
            }
            if(radioCount>1){
                error=true;
                helper.showToast("ERROR","Environment Selection checkbox cannot be checked for multiple records","error");
            }
            if(captureCount>1){
                error=true;
                helper.showToast("ERROR","Screen Capture Option checkbox cannot be checked for multiple records","error");
            }
            if(searchBoxCount>1){
                error=true;
                helper.showToast("ERROR","Group Selection checkbox cannot be checked for multiple records","error");
            }
            
            if(error==false){
                helper.saveRecords(component,newDraftList,helper);
            }
        },  
               
               })
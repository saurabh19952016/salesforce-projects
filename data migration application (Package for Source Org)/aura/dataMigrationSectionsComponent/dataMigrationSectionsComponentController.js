({
    switchTab : function(component, event, helper) {
        
        
        helper.doInit(component,event,true);
    },
    
    init:  function(component, event, helper) {
        helper.doInit(component,event,false);
    },
    
    onSelectTab: function(component,event,helper){
        var id=event.getSource().get('v.selectedTabId');
        if(id=='commit'){
            var comp=component.find('commit');       
            comp.refreshView();
        }
    }
})
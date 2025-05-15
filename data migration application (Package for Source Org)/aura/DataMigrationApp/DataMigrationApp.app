<aura:application extends="force:slds" >
    <c:mainAppHeader appHeader="Data Migration Application" appTitle="Migrate your data to sandbox"
                     iconName="custom:custom108" theme="slds-theme--info"/>  
    
    <div  class="slds-p-around--small">
        <c:getAuthComponent appName="migration"/>
        
        <c:dataMigrationSectionsComponent/>
    </div>
</aura:application>
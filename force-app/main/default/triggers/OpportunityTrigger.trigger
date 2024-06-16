trigger OpportunityTrigger on Opportunity (before update, before delete) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            // Validate Amount > 5000 on update
            //Error message: 'Opportunity amount must be greater than 5000'
            for (Opportunity opp : Trigger.new) {
                if (opp.Amount <= 5000) {
                    opp.addError('Opportunity amount must be greater than 5000');
                }
            }
            // Before update to run before the updates to Opp records are committed to database 
            //Collect Account Ids via set to store unique Account Ids from updated Opps within Trigger.new
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity opp : Trigger.new) {
                accountIds.add(opp.AccountId);
            }
            
            // SOQL query for Contacts with 'CEO' Title from the Accounts retrieved in accountIds
            //Store in a Contact map where the key == Account ID && Value == Contact 
            Map<Id, Contact> ceosByAccountId = new Map<Id, Contact>();
            for (Contact c : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO']) {
                ceosByAccountId.put(c.AccountId, c);
            }
            
            //Loop over updated Opps (from Trigger.new) 
            //Check if ceosByAccountId contains Contact with the same Accound Id as the Opportunity
            // If found, set Primary Contact on opportunities
            for (Opportunity opp : Trigger.new) {
                if (ceosByAccountId.containsKey(opp.AccountId)) {
                    Contact ceo = ceosByAccountId.get(opp.AccountId);
                    opp.Primary_Contact__c = ceo.Id;
                }
            }
        } else if (Trigger.isDelete) {
            // Prevent deletion of closed-won opportunities for banking accounts
            // Need to retrieve related Account in a set --> map to then checking if Industry = 'Banking'
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity opp : Trigger.old) {
                if (opp.StageName == 'Closed Won') {
                    accountIds.add(opp.AccountId);
                }
            }
            
            if (!accountIds.isEmpty()) {
                Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN :accountIds]);
                
                for (Opportunity opp : Trigger.old) {
                    if (opp.StageName == 'Closed Won' && accountsMap.containsKey(opp.AccountId) && accountsMap.get(opp.AccountId).Industry == 'Banking') {
                        opp.addError('Cannot delete closed opportunity for a banking account that is won');
                    }
                }
            }
        }
    }
}

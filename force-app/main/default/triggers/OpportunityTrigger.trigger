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

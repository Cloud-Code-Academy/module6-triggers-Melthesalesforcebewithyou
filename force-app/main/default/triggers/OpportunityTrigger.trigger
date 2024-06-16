trigger OpportunityTrigger on Opportunity (before update) {
    for (Opportunity opp : Trigger.new) {

        if(Trigger.isBefore){
            //After Opp update, validate that Amount > 5000
            //Error message: 'Opportunity amount must be greater than 5000'
            if(opp.Amount <= 5000) {
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }
}
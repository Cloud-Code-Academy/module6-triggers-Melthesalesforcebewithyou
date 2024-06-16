trigger AccountTrigger on Account (before insert) {
    //After insert: change Account Type to 'Prospect' if null
    for (Account acc : Trigger.new) {
        if (acc.Type == null) {
            acc.Type = 'Prospect';
        }
    }
}
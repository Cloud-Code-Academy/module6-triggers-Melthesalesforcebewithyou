trigger AccountTrigger on Account (before insert, after insert) {

    if(Trigger.isBefore){
    //After insert: change Account Type to 'Prospect' if null
    for (Account acc : Trigger.new) {
        if (acc.Type == null) {
            acc.Type = 'Prospect';
            }
        //When an Account is inserted, copy the shipping address to the billing address 
        //Check if Shipping address == null prior to copying values 
        if(acc.ShippingStreet != null && acc.ShippingCity != null && acc.ShippingState != null && acc.ShippingPostalCode != null && acc.ShippingCountry != null) {
            acc.BillingStreet = acc.ShippingStreet;
            acc.BillingCity = acc.ShippingCity;
            acc.BillingState = acc.ShippingState;
            acc.BillingPostalCode = acc.ShippingPostalCode;
            acc.BillingCountry = acc.ShippingCountry;
                }
        //Set Rating to 'Hot' if Phone, Website, && Fax != null 
        if (acc.Phone != null && acc.Website != null && acc.Fax != null) {
            acc.Rating = 'Hot';
        }
        }
    }

    if(Trigger.isAfter){
    /*Create Contact related to the acc with default values 
      LastName = 'DefaultContact'
      Email = 'default@email.com' 
    */
    List<Contact> contactsToCreate = new List<Contact>();
    for(Account acc: Trigger.new) {
        Contact newContact = new Contact (
            LastName = 'DefaultContact', 
            Email = 'default@email.com',
            AccountId = acc.Id
        ); 
        contactsToCreate.add(newContact);
    }
    if(!contactsToCreate.isEmpty()) {
        insert contactsToCreate;
    }
    }
}
trigger GenerateApplicationCode on Application__c (before insert) {
    Set<String> existingCodes = new Set<String>();

    // Fetch existing codes from the database to ensure uniqueness
    for (Application__c c : [SELECT Application_Code__c FROM Application__c WHERE Application_Code__c != null]) {
        existingCodes.add(c.Application_Code__c);
    }

    for (Application__c newApplication : Trigger.new) {
        String randomCode;

        // Generate random code based on Application_Type__c
        if (newApplication.Application_Type__c == 'Full time') {
            // Keep generating until we find a unique 5-character code
            do {
                String letters = '';
                for (Integer i = 0; i < 5; i++) {
                    Integer randomNum = Math.round(Math.random() * 25 + 65); // Generate a random uppercase letter (ASCII 65-90)
                    letters += String.fromCharArray(new Integer[] { randomNum });
                }
                randomCode = letters;
            } while (existingCodes.contains(randomCode));
        } else if (newApplication.Application_Type__c == 'Graduate') {
            // Keep generating until we find a unique 5-digit code
            do {
                Integer code = Math.round(Math.random() * 89999 + 10000); // Generates a number between 10000–99999
                randomCode = String.valueOf(code);
            } while (existingCodes.contains(randomCode));
        } else {
            // Handle other application types if needed
            randomCode = 'DEFAULT';
        }

        existingCodes.add(randomCode);
        newApplication.Application_Code__c = randomCode;
    }
}
/**
 * This class contains method for helping multi-currency functionality
 *
 * Version      Author              Date(dd/mm/yyyy)       Comments
 * 1.0          Ajinkya Hingne      28/02/2016             Initial version
 */
public class MultiCurrencyHelper {

    /**
     * Method to check if org has multi-currency enabled
     */
    public static Boolean isMultiCurrencyEnabled() {
        return Schema.getGlobalDescribe().containsKey('CurrencyType');
    }

    /**
     * Method to convert currency value to current user's currency
     */
    public static Decimal convertToUserCurrency(Decimal currencyValue) {
        // If multi-currency is not enabled, return value as it is.
        if(!isMultiCurrencyEnabled()) {
            return currencyValue;
        }
        // If multi-currency is enabled, check whether user currency is not same as corporate currency
        // Convert if not same and return converted value
        String currencyType = UserInfo.getDefaultCurrency();
        String strQuery = 'SELECT ConversionRate, IsCorporate, IsoCode FROM CurrencyType WHERE IsoCode =: currencyType LIMIT 1';
        List<sObject> currencyTypes = new List<sObject>();
        currencyTypes = Database.query(strQuery);
        if(currencyTypes.size() > 0 && !Boolean.valueOf(currencyTypes[0].get('IsCorporate'))) {
            return currencyValue * Decimal.valueOf(String.valueOf(currencyTypes[0].get('ConversionRate')));
        }
        return currencyValue;
    }

    /**
     * Method to return current user's currency symbol
     */
    public static String getUserCurrencySymbol() {
        String symbol = CURRENCY_SYMBOL.get(UserInfo.getDefaultCurrency());
        return symbol != null ? symbol : '';
    }

    /**
     * Map of currency ISO code to their respective symbol
     */
    private static Map<String, String> CURRENCY_SYMBOL = new Map<String, String> {
        'ALL'=>'Lek',
        'USD'=>'$',
        'ARS'=>'$',
        'AWG'=>'ƒ',
        'AUD'=>'$',
        'BSD'=>'$',
        'BBD'=>'$',
        'BYR'=>'p.',
        'EUR'=>'€',
        'BZD'=>'BZ$',
        'BMD'=>'$',
        'BOB'=>'$b',
        'BAM'=>'KM',
        'BWP'=>'P',
        'BRL'=>'R$',
        'GBP'=>'£',
        'BND'=>'$',
        'CAD'=>'$',
        'KYD'=>'$',
        'CLP'=>'$',
        'CNY'=>'¥',
        'COP'=>'$',
        'CRC'=>'¢',
        'HRK'=>'kn',
        'EUR'=>'€',
        'CZK'=>'Kc',
        'DKK'=>'kr',
        'DOP'=>'RD$',
        'XCD'=>'$',
        'EGP'=>'£',
        'SVC'=>'$',
        'GBP'=>'£',
        'EEK'=>'kr',
        'EUR'=>'€',
        'FKP'=>'£',
        'FJD'=>'$',
        'EUR'=>'€',
        'GHC'=>'¢',
        'GIP'=>'£',
        'EUR'=>'€',
        'GTQ'=>'Q',
        'GGP'=>'£',
        'GYD'=>'$',
        'EUR'=>'€',
        'HNL'=>'L',
        'HKD'=>'$',
        'HUF'=>'Ft',
        'ISK'=>'kr',
        'IDR'=>'Rp',
        'EUR'=>'€',
        'IMP'=>'£',
        'EUR'=>'€',
        'JMD'=>'J$',
        'JPY'=>'¥',
        'JEP'=>'£',
        'LVL'=>'Ls',
        'LBP'=>'£',
        'LRD'=>'$',
        'CHF'=>'CHF',
        'LTL'=>'Lt',
        'EUR'=>'€',
        'MYR'=>'RM',
        'EUR'=>'€',
        'MXN'=>'$',
        'MZN'=>'MT',
        'NAD'=>'$',
        'ANG'=>'ƒ',
        'EUR'=>'€',
        'NZD'=>'$',
        'NIO'=>'C$',
        'NOK'=>'kr',
        'PAB'=>'B/.',
        'PYG'=>'Gs',
        'PEN'=>'S/.',
        'PHP'=>'Php',
        'PLN'=>'zl',
        'RON'=>'lei',
        'SHP'=>'£',
        'SGD'=>'$',
        'EUR'=>'€',
        'SBD'=>'$',
        'SOS'=>'S',
        'ZAR'=>'R',
        'EUR'=>'€',
        'SEK'=>'kr',
        'CHF'=>'CHF',
        'SRD'=>'$',
        'SYP'=>'£',
        'TWD'=>'NT$',
        'TTD'=>'TT$',
        'TRY'=>'TL',
        'TRL'=>'£',
        'TVD'=>'$',
        'GBP'=>'£',
        'USD'=>'$',
        'UYU'=>'$U',
        'EUR'=>'€',
        'VEF'=>'Bs',
        'ZWD'=>'Z$',
        'INR'=>'₹'
    };

}
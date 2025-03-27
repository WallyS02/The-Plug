export interface AppUser {
    id: number;
    username: string;
    rating: number | null;
    isPartner: boolean;
    isSlanderer: boolean;
    plug: number;
    //meeting: Meeting[];
}

export interface Plug {
    id: number;
    rating: number | null;
    isPartner: boolean;
    isSlanderer: boolean;
    minimal_break_between_meetings_in_minutes: number;
    user: number;
    //location: Location[];
    //herbOffer: HerbOffer[];
}

export interface Location {
    id: number;
    latitude: number;
    longitude: number;
    street_name?: string;
    street_number?: string;
    city?: string;
    plug: number;
}

export interface Meeting {
    id: string;
    isAcceptedByPlug: boolean;
    isHighOrLowClientSatisfaction: string;
    isHighOrLowPlugSatisfaction: string;
    date: Date;
    location_id: string;
    isCanceled: boolean;
    isCanceledByPlug: boolean;
    user: number;
    //chosen_offer: ChosenOffer[];
}

export interface ChosenOffer {
    id: string;
    number_of_grams: number;
    meeting: number;
    herb_offer: number;
}

export interface HerbOffer {
    id: string;
    grams_in_stock: number;
    price_per_gram: number;
    currency: string;
    description: string;
    //chosen_offer: number[];
    herb: number;
    plug: number;
}

export interface Herb {
    id: number;
    name: string;
    wikipedia_link: string;
    //herbOffer: HerbOffer[];
}

export enum MapMode {
    Browse,
    AddLocation,
    EditLocation,
    MeetingPanel
}

export const currencies = [
    { name: "United States Dollar", symbol: "$" },
    { name: "Canadian Dollar", symbol: "CA$" },
    { name: "Euro", symbol: "€" },
    { name: "United Arab Emirates Dirham", symbol: "AED" },
    { name: "Afghan Afghani", symbol: "Af" },
    { name: "Albanian Lek", symbol: "ALL" },
    { name: "Armenian Dram", symbol: "AMD" },
    { name: "Argentine Peso", symbol: "AR$" },
    { name: "Australian Dollar", symbol: "AU$" },
    { name: "Azerbaijani Manat", symbol: "man." },
    { name: "Bosnia-Herzegovina Convertible Mark", symbol: "KM" },
    { name: "Bangladeshi Taka", symbol: "Tk" },
    { name: "Bulgarian Lev", symbol: "BGN" },
    { name: "Bahraini Dinar", symbol: "BD" },
    { name: "Burundian Franc", symbol: "FBu" },
    { name: "Brunei Dollar", symbol: "BN$" },
    { name: "Bolivian Boliviano", symbol: "Bs" },
    { name: "Brazilian Real", symbol: "R$" },
    { name: "Botswana Pula", symbol: "BWP" },
    { name: "Belarusian Ruble", symbol: "Br" },
    { name: "Belize Dollar", symbol: "BZ$" },
    { name: "Congolese Franc", symbol: "CDF" },
    { name: "Swiss Franc", symbol: "CHF" },
    { name: "Chilean Peso", symbol: "CL$" },
    { name: "Chinese Yuan", symbol: "CN¥" },
    { name: "Colombian Peso", symbol: "CO$" },
    { name: "Costa Rican Colón", symbol: "₡" },
    { name: "Cape Verdean Escudo", symbol: "CV$" },
    { name: "Czech Koruna", symbol: "Kč" },
    { name: "Djiboutian Franc", symbol: "Fdj" },
    { name: "Danish Krone", symbol: "Dkr" },
    { name: "Dominican Peso", symbol: "RD$" },
    { name: "Algerian Dinar", symbol: "DA" },
    { name: "Egyptian Pound", symbol: "EGP" },
    { name: "Eritrean Nakfa", symbol: "Nfk" },
    { name: "Ethiopian Birr", symbol: "Br" },
    { name: "British Pound", symbol: "£" },
    { name: "Georgian Lari", symbol: "GEL" },
    { name: "Ghanaian Cedi", symbol: "GH₵" },
    { name: "Guinean Franc", symbol: "FG" },
    { name: "Guatemalan Quetzal", symbol: "GTQ" },
    { name: "Hong Kong Dollar", symbol: "HK$" },
    { name: "Honduran Lempira", symbol: "HNL" },
    { name: "Croatian Kuna", symbol: "kn" },
    { name: "Hungarian Forint", symbol: "Ft" },
    { name: "Indonesian Rupiah", symbol: "Rp" },
    { name: "Israeli New Shekel", symbol: "₪" },
    { name: "Indian Rupee", symbol: "₹" },
    { name: "Iraqi Dinar", symbol: "IQD" },
    { name: "Iranian Rial", symbol: "IRR" },
    { name: "Icelandic Króna", symbol: "Ikr" },
    { name: "Jamaican Dollar", symbol: "J$" },
    { name: "Jordanian Dinar", symbol: "JD" },
    { name: "Japanese Yen", symbol: "¥" },
    { name: "Kenyan Shilling", symbol: "Ksh" },
    { name: "Cambodian Riel", symbol: "KHR" },
    { name: "Comorian Franc", symbol: "CF" },
    { name: "South Korean Won", symbol: "₩" },
    { name: "Kuwaiti Dinar", symbol: "KD" },
    { name: "Kazakhstani Tenge", symbol: "KZT" },
    { name: "Lebanese Pound", symbol: "L.L." },
    { name: "Sri Lankan Rupee", symbol: "SLRs" },
    { name: "Libyan Dinar", symbol: "LD" },
    { name: "Moroccan Dirham", symbol: "MAD" },
    { name: "Moldovan Leu", symbol: "MDL" },
    { name: "Malagasy Ariary", symbol: "MGA" },
    { name: "Macedonian Denar", symbol: "MKD" },
    { name: "Myanma Kyat", symbol: "MMK" },
    { name: "Macanese Pataca", symbol: "MOP$" },
    { name: "Mauritian Rupee", symbol: "MURs" },
    { name: "Mexican Peso", symbol: "MX$" },
    { name: "Malaysian Ringgit", symbol: "RM" },
    { name: "Mozambican Metical", symbol: "MTn" },
    { name: "Namibian Dollar", symbol: "N$" },
    { name: "Nigerian Naira", symbol: "₦" },
    { name: "Nicaraguan Córdoba", symbol: "C$" },
    { name: "Norwegian Krone", symbol: "Nkr" },
    { name: "Nepalese Rupee", symbol: "NPRs" },
    { name: "New Zealand Dollar", symbol: "NZ$" },
    { name: "Omani Rial", symbol: "OMR" },
    { name: "Panamanian Balboa", symbol: "B/." },
    { name: "Peruvian Sol", symbol: "S/." },
    { name: "Philippine Peso", symbol: "₱" },
    { name: "Pakistani Rupee", symbol: "PKRs" },
    { name: "Polish Złoty", symbol: "zł" },
    { name: "Paraguayan Guaraní", symbol: "₲" },
    { name: "Qatari Riyal", symbol: "QR" },
    { name: "Romanian Leu", symbol: "RON" },
    { name: "Serbian Dinar", symbol: "din." },
    { name: "Russian Ruble", symbol: "RUB" },
    { name: "Rwandan Franc", symbol: "RWF" },
    { name: "Saudi Riyal", symbol: "SR" },
    { name: "Sudanese Pound", symbol: "SDG" },
    { name: "Swedish Krona", symbol: "Skr" },
    { name: "Singapore Dollar", symbol: "S$" },
    { name: "Somali Shilling", symbol: "Ssh" },
    { name: "Syrian Pound", symbol: "SY£" },
    { name: "Thai Baht", symbol: "฿" },
    { name: "Tunisian Dinar", symbol: "DT" },
    { name: "Tongan Paʻanga", symbol: "T$" },
    { name: "Turkish Lira", symbol: "TL" },
    { name: "Trinidad and Tobago Dollar", symbol: "TT$" },
    { name: "New Taiwan Dollar", symbol: "NT$" },
    { name: "Tanzanian Shilling", symbol: "TSh" },
    { name: "Ukrainian Hryvnia", symbol: "₴" },
    { name: "Ugandan Shilling", symbol: "USh" },
    { name: "Uruguayan Peso", symbol: "$U" },
    { name: "Uzbekistani Som", symbol: "UZS" },
    { name: "Venezuelan Bolívar Soberano", symbol: "Bs.S." },
    { name: "Vietnamese Đồng", symbol: "₫" },
    { name: "Central African CFA Franc", symbol: "FCFA" },
    { name: "West African CFA Franc", symbol: "CFA" },
    { name: "Yemeni Rial", symbol: "YR" },
    { name: "South African Rand", symbol: "R" },
    { name: "Zambian Kwacha", symbol: "ZMW" },
    { name: "Zimbabwean Dollar", symbol: "ZWL$" }
];

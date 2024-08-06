export interface AppUser {
    id: number;
    username: string;
    isPartner: boolean;
    isSlanderer: boolean;
    plug: Plug;
    meeting: Meeting[];
}

export interface Plug {
    id: number;
    rating: number;
    user: AppUser;
    location: Location[];
    drugOffer: DrugOffer[];
}

export interface Location {
    id: number;
    latitude: number;
    longitude: number;
    street_name?: string;
    street_number?: string;
    city?: string;
    plug: Plug;
}

export interface Meeting {
    id: string;
    isAcceptedByPlug: boolean;
    isHighOrLowClientSatisfaction: string;
    isHighOrLowPlugSatisfaction: string;
    date: Date;
    user: AppUser;
    chosen_offer: ChosenOffer[];
}

export interface ChosenOffer {
    id: string;
    meeting: Meeting;
    drug_offer: DrugOffer;
}

export interface DrugOffer {
    id: string;
    grams_in_stock: number;
    price_per_gram: number;
    description: string;
    chosen_offer: number[];
    drug: number;
    plug: number;
}

export interface Drug {
    id: number;
    name: string;
    wikipedia_link: string;
    drugOffer: DrugOffer[];
}

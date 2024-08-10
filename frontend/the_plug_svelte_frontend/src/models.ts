export interface AppUser {
    id: number;
    username: string;
    isPartner: boolean;
    isSlanderer: boolean;
    plug: number;
    //meeting: Meeting[];
}

export interface Plug {
    id: number;
    rating: number;
    user: number;
    //location: Location[];
    //drugOffer: DrugOffer[];
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
    user: number;
    //chosen_offer: ChosenOffer[];
}

export interface ChosenOffer {
    id: string;
    meeting: number;
    drug_offer: number;
}

export interface DrugOffer {
    id: string;
    grams_in_stock: number;
    price_per_gram: number;
    description: string;
    //chosen_offer: number[];
    drug: number;
    plug: number;
}

export interface Drug {
    id: number;
    name: string;
    wikipedia_link: string;
    //drugOffer: DrugOffer[];
}

export enum MapMode {
    Browse,
    AddLocation,
    EditLocation,
}
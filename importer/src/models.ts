export type CardSet = {
    id: string;
    set: string;
    source: string;
};

export type PromptCard = {
    cid: string;
    text: string;
    special?: string;
    set: string;
    source: string;
};

export type ResponseCard = {
    cid: string;
    text: string;
    set: string;
    source: string;
};

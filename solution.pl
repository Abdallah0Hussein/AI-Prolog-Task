:- consult('data.pl').


% _____________________ Task 6 ___________________________________________________
% Given the item name or company name, determine whether we need to boycott or not.

isBoycott(ItemOrCompany) :-
    % Check if the item has an alternative
    % If found, then this item is considered boycotted, so return true.
    alternative(ItemOrCompany, _),
    % Cut operator to prevent conutinuing if an alternative is found
    !.
% If the item does not have an alternative, check if the company is listed in the boycott_company facts
isBoycott(ItemOrCompany) :-
    boycott_company(ItemOrCompany, _).

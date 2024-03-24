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

% _____________________ Task 7 ___________________________________________________
% Given the company name or an item name, find the justification why you need to boycott this company/item.

whyToBoycott(ItemOrCompany, Justification) :-
    % Check if the given item or company directly appears in the boycott_company facts.
    % if found, return corresponding justification.
    boycott_company(ItemOrCompany, Justification),
    !.
whyToBoycott(ItemOrCompany, Justification) :-
    % get the company associated with the given item.
    item(ItemOrCompany, Company, _),
    % Check if the company is in the boycott_company facts.
    boycott_company(Company, Justification).

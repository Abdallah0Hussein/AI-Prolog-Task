:- consult('data.pl').

% _____________________ Task 5 ___________________________________________________
% Calculate the price of a given order given Customer Name and order id

calcPriceOfOrder(CustomerName, OrderID, TotalPrice) :-
    % Retrieve the customer ID based on the customer name
    customer(CustomerID, CustomerName),
    % Retrieve the items as a list in the specified order for the given customer
    order(CustomerID, OrderID, Items),
    % Call calcPriceOfItems to compute the total price
    calcPriceOfItems(Items, 0, TotalPrice),
    % Cut operator to stop backtracking, as we only need one solution
    !.
% Base case: When there are no more items, the accumulated total price is the final total price
calcPriceOfItems([],Accumulator, Accumulator).


calcPriceOfItems([Item|RestItems], Accumulator, TotalPrice):-
    % Retrieve the price of the current item
    item(Item, _, Price),
    % Update the accumulator by adding the price of the current item
    NewAccumulator is Accumulator + Price,

    calcPriceOfItems(RestItems, NewAccumulator, TotalPrice). % Recursively accumulate the total price.

% _____________________ Task 6 ___________________________________________________
% Given the item name or company name, determine whether we need to boycott or not.

isBoycott(ItemOrCompany) :-
    item(ItemOrCompany, Company, _),
    isBoycott(Company),
    % Cut operator to prevent conutinuing
    !.

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

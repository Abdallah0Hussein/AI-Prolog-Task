:- consult('data.pl').
% Make it dynamic, as the compiled code results in static predicates (cannot be modified at runtime).
:- dynamic (item/3).
:- dynamic (alternative/2).
:- dynamic (boycott_company/2).

% _____________________ Task 1  ___________________________________________________

% Check if X is a member of List T
ismember(X, [_|T]) :-
    ismember(X, T).
ismember(X, [X|_]).


list_orders(CustomerName, X) :-
    customer(CustID, CustomerName),
    list_orders(CustID, [], X).

list_orders(CustID, Acc, [H|Orders]) :-
    order(CustID, OrderID, Items),
    \+ ismember(order(CustID, OrderID, Items), Acc),
    H = order(CustID, OrderID, Items),
    list_orders(CustID, [H|Acc], Orders), !.

list_orders(_, _, []).


% _____________________ Task 3 ___________________________________________________
getItemsInOrderById(CustName, OrderID, X) :-
    customer(CustID, CustName),
    order(CustID, OrderID, X).

% _____________________ Task 4 ___________________________________________________
len2([_|T], N) :-
    len2(T, N1),
    N is N1 + 1.

len2([], 0).

getNumOfItems(CustName, OrderID, Count) :-
    customer(CustID, CustName),
    order(CustID, OrderID, Items),
    len(Items, Count).

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
    boycott_company(Company, _),
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

% _____________________ Task 8 ___________________________________________________
% Given an username and order ID, remove all the boycott items from this order.

removeBoycottItemsFromAnOrder(CustomerName, OrderID, NewList) :-
    customer(CustomerID, CustomerName),
    order(CustomerID, OrderID, Items),
    removeBoycottItems(Items, [], NewList),
    !.

removeBoycottItems([], Acc, Acc).

% If the current item is boycotted, skip it and continue checking the rest of the list
removeBoycottItems([Item|RestItems], Acc, NewList):-
    isBoycott(Item),
    removeBoycottItems(RestItems, Acc, NewList).

% If the current item is not boycotted, add it to the accumulator and continue checking the rest of the list
removeBoycottItems([Item|RestItems], Acc, NewList):-
    \+ isBoycott(Item),
    removeBoycottItems(RestItems, [Item|Acc], NewList).

% _____________________ Task 9 ___________________________________________________
% Given an username and order ID, update the order such that all boycott items are replaced by an alternative (if exists).

replaceBoycottItemsFromAnOrder(CustomerName, OrderID, NewList) :-
    customer(CustomerID, CustomerName),
    order(CustomerID, OrderID, Items),
    replaceBoycottItems(Items, [], NewList),
    !.

replaceBoycottItems([], Acc, Acc).

replaceBoycottItems([Item|RestItems], Acc, NewList):-
    \+ isBoycott(Item),
    replaceBoycottItems(RestItems, [Item|Acc], NewList).

replaceBoycottItems([Item|RestItems], Acc, NewList):-
    isBoycott(Item),
    alternative(Item, Alternative),
    replaceBoycottItems(RestItems,[Alternative|Acc], NewList).

% _____________________ Task 12 ___________________________________________________
% Insert/Remove (1)item, (2)alternative and (3)new boycott company to/from the knowledge base.

add_item(ItemName, Company, Price) :-
    % if not exists, add it
    \+ item(ItemName, Company, Price),
    assert(item(ItemName, Company, Price)).

remove_item(ItemName, Company, Price) :-
    % if exists, retract it (remove it)
    retract(item(ItemName, Company, Price)).

add_alternative(ItemName, AlternativeItem) :-
    % if not exists, add it
    \+ alternative(ItemName, AlternativeItem),
    assert(alternative(ItemName, AlternativeItem)).

remove_alternative(ItemName, AlternativeItem) :-
    % if exists, retract it (remove it)
    retract(alternative(ItemName, AlternativeItem)).

add_boycott_company(CompanyName, Justification) :-
    % if not exists, add it
    \+ boycott_company(CompanyName, _),
    assert(boycott_company(CompanyName, Justification)).

remove_boycott_company(CompanyName) :-
    % if exists, retract it (remove it)
    retract(boycott_company(CompanyName, _)).

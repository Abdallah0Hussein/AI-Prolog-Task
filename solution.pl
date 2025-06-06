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

% _____________________ Task 2 ___________________________________________________

countOrdersOfCustomer(CustUsername,Count):-
% get all orders that match with this CustomerUsername
    list_orders(CustUsername, X),
    getLengthOfListOrders(X,0, Count).

getLengthOfListOrders([],Count, Count).
getLengthOfListOrders([_|Orders], Counter, Count):-
   NewCounter is Counter + 1,
   getLengthOfListOrders(Orders, NewCounter, Count).

% _____________________ Task 3 ___________________________________________________
getItemsInOrderById(CustName, OrderID, X) :-
    customer(CustID, CustName),
    order(CustID, OrderID, X),
    !.

% _____________________ Task 4 ___________________________________________________
len([_|T], N) :-
    len(T, N1),
    N is N1 + 1.

len([], 0).

getNumOfItems(CustName, OrderID, Count) :-
    customer(CustID, CustName),
    order(CustID, OrderID, Items),
    len(Items, Count),
    !.

% _____________________ Task 5 ___________________________________________________
% Calculate the price of a given order given Customer Name and order id

calcPriceOfOrder(CustomerName, OrderID, TotalPrice) :-
    % get the customer ID based on the customer name
    customer(CustomerID, CustomerName),
    % get the items as a list
    order(CustomerID, OrderID, Items),
    getTotalPrice(Items, 0, TotalPrice),
    % Cut operator to stop backtracking, as we only need one solution
    !.

% Base case: When there are no more items, the accumulated total price is the final total price
getTotalPrice([], Acc, Acc).

getTotalPrice([Item| Rest], Acc, TotalPrice):-
    item(Item, _, Price),
    NewAcc is Price + Acc,
    getTotalPrice(Rest, NewAcc, TotalPrice).

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
    % if found, return corresponding justification.
    boycott_company(ItemOrCompany, Justification),
    !.
whyToBoycott(ItemOrCompany, Justification) :-
    % get the company associated with the given item.
    item(ItemOrCompany, Company, _),
    % check if the company of the item is in the boycott_company facts.
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

% replaceBoycottItems([Item|RestItems], Acc, NewList):-
  %  isBoycott(Item),
   % \+ alternative(Item, _),
    % replaceBoycottItems(RestItems,[Item|Acc], NewList).


% _____________________ Task 10 ___________________________________________________

% use task 9&5 to replace alternatives & get Total Price
calcPriceAfterReplacingBoycottItemsFromAnOrder(CustomerUsername,OrderID,NewList,TotalPrice):-
    replaceBoycottItemsFromAnOrder(CustomerUsername, OrderID, NewList),
    getTotalPrice(NewList, 0 ,TotalPrice).

% _____________________ Task 11 ___________________________________________________

getTheDifferenceInPriceBetweenItemAndAlternative(ItemName, AlternativeItem, DiffPrice):-
    alternative(ItemName,AlternativeItem),
    % get price for item that is given
    item(ItemName,_,  Price1),
    % get price for Alternative Item that is given
    item(AlternativeItem,_, Price2),
    DiffPrice is Price1 - Price2,!.


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
    \+ alternative(ItemName, AlternativeItem),
    assert(alternative(ItemName, AlternativeItem)).

remove_alternative(ItemName, AlternativeItem) :-
    retract(alternative(ItemName, AlternativeItem)).

add_boycott_company(CompanyName, Justification) :-
    \+ boycott_company(CompanyName, _),
    assert(boycott_company(CompanyName, Justification)).

remove_boycott_company(CompanyName) :-
    retract(boycott_company(CompanyName, _)).

/* 1.
Lister tous les plats avec un prix inférieur à 20 €. 
*/

-- Plats avec un prix inférieur à 20 €
SELECT * FROM dishes WHERE price < 20;


/* 2.
Lister tous les plats des restaurants de cuisine Française et de cuisine Italienne en utilisant IN. 
*/

-- Plats des restaurants de cuisine Française et de cuisine Italienne
-- Plats des restaurants de cuisine Française et de cuisine Italienne
SELECT dishes.name AS 'Plat', restaurants.cuisine_type AS 'Type de cuisine' 
FROM dishes
JOIN chefs ON dishes.chef_id = chefs.id
JOIN restaurants ON chefs.restaurant_id = restaurants.id
WHERE restaurants.cuisine_type = 'Française' OR restaurants.cuisine_type = 'Italienne';


/* 3.
Lister tous les ingrédients du Bœuf Bourguignon. 
*/

-- Ingrédients du Bœuf Bourguignon
SELECT dishes.name AS 'Plat', ingredients.name AS 'Ingrédient' 
FROM ingredients
JOIN dishes ON dishes.id = ingredients.dish_id
JOIN chefs ON chefs.id = dishes.chef_id
WHERE dishes.name = 'Bœuf Bourguignon';


/* 4.
Lister tous les chefs (leur nom uniquement) et leurs restaurants (leur nom uniquement). 
*/

-- Chefs et leurs restaurants
SELECT chefs.name AS 'Chef', restaurants.name AS 'Restaurant'
FROM chefs
JOIN restaurants ON chefs.restaurant_id = restaurants.id;


/* 5.
Lister les chefs et le nombre de plats qu'ils ont créés. 
*/

-- Chefs et leur nombre de plats créés
SELECT chefs.name, COUNT(dishes.id) AS 'Nombre de plats créés' 
FROM chefs
JOIN dishes ON chef_id = chefs.id
GROUP BY chef_id;


/* 6.
Lister les chefs qui ont créé plus d'un plat. 
*/

-- Chefs ayant créé plus d'un plat
SELECT chefs.name AS 'Chef', COUNT(dishes.id) AS 'Nombre de plats créés' 
FROM chefs
JOIN dishes ON chef_id = chefs.id
GROUP BY chef_id
HAVING COUNT(dishes.id) > 1;

/* 7.
Calculez le nombre de chefs ayant créé un seul plat. 
*/

-- Nombre de chefs ayant créé un seul plat
SELECT COUNT(chef_id) AS 'Nombre de chefs ayant créé un seul plat'
FROM dishes
GROUP BY chef_id
HAVING COUNT(chef_id) = 1;


/* 8.
Calculez le nombre de plats pour chaque type de cuisine. 
*/

-- Nombre de plats pour chaque type de cuisine
SELECT restaurants.cuisine_type AS 'Type de cuisine', COUNT(dishes.id) AS 'Nombre de plats'
FROM dishes
JOIN chefs ON dishes.chef_id = chefs.id
JOIN restaurants ON chefs.restaurant_id = restaurants.id
GROUP BY restaurants.cuisine_type;


/* 9.
Calculez le prix moyen des plats par type de cuisine. 
*/

-- Prix moyen des plats par type de cuisine
SELECT restaurants.cuisine_type AS 'Type de cuisine', AVG(dishes.price) AS 'Prix moyen des plats'
FROM dishes
JOIN chefs ON dishes.chef_id = chefs.id
JOIN restaurants ON chefs.restaurant_id = restaurants.id
GROUP BY restaurants.cuisine_type;


/* 10
.Trouver le prix moyen des plats créés par chaque chef, en incluant seulement les chefs ayant créé plus de 2 plats 
*/

-- Prix moyen des plats créés par chaque chef, avec seulement les chefs qui ont créé 2 plats ou plus
SELECT chefs.name AS 'Chef', AVG(dishes.price) AS 'Prix moyen des plats'
FROM chefs
JOIN dishes ON chef_id = chefs.id
GROUP BY chef_id
HAVING COUNT(dishes.id) >= 2;

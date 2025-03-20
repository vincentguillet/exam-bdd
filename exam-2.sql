/* 1. 
Créer la base de données "bibliotheque" en UTF8. 
Créer les 3 tables en respectant les contraintes de relation et de référence. Les # ne doivent pas paraître dans le nom des champs.
*/

-- Création de la base de données bibliotheque
CREATE DATABASE IF NOT EXISTS bibliotheque CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Positionnement sur la base de données bibliotheque
USE bibliotheque;

-- Création de la table adherents
CREATE TABLE IF NOT EXISTS adherents (
    id_adherent INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    adresse VARCHAR(255) NOT NULL,
    date_inscription DATE NOT NULL,
    a_surveiller BOOLEAN NOT NULL
);

-- Création de la table livres
CREATE TABLE IF NOT EXISTS livres (
    isbn VARCHAR(13) PRIMARY KEY NOT NULL,
    titre VARCHAR(255) NOT NULL,
    auteur VARCHAR(100) NOT NULL,
    annee_publication INT NOT NULL, /*Utilisation de INT au lieu de YEAR car YEAR ne fonctionne que pour des années entre 1901 et 2155*/
    disponible BOOLEAN NOT NULL
);

-- Création de la table emprunts
CREATE TABLE IF NOT EXISTS emprunts (
    id_adherent INT,
    isbn VARCHAR(13),
    date_emprunt DATE NOT NULL,
    date_retour DATE NOT NULL,
    PRIMARY KEY (id_adherent, isbn),
    FOREIGN KEY (id_adherent) REFERENCES adherents(id_adherent) ON DELETE CASCADE,
    FOREIGN KEY (isbn) REFERENCES livres(isbn)
);


/* 2. 
Créer un utilisateur « bibliothecaire » avec le mot de passe « secret » ayant accès uniquement à cette base de données bibliotheque avec tous les droits. 
*/

-- Création de l'utilisateur bibliothecaire
CREATE USER IF NOT EXISTS 'bibliothecaire'@'localhost' IDENTIFIED BY 'secret';

-- Attribution de tous les droits à l'utilisateur bibliothecaire sur la base de données bibliotheque
GRANT ALL PRIVILEGES ON bibliotheque.* TO 'bibliothecaire'@'localhost';


/* 3. 
Ajouter les adhérents : Jane Austen, Charles Dickens, Jules Verne, Mary Shelley.
Ajouter les livres : "Orgueil et Préjugés", "David Copperfield", "Vingt mille lieues sous les mers", "Frankenstein".
Ajouter des emprunts pour que chaque adhérent emprunte chaque chaque livre.
*/

-- Ajout des adhérents

    -- Jane Austen
    INSERT INTO adherents (nom, adresse, date_inscription, a_surveiller) 
    VALUES ('Jane Austen', 'Steventon, Royaume-Uni', '1775-12-16', FALSE);

    -- Charles Dickens
    INSERT INTO adherents (nom, adresse, date_inscription, a_surveiller) 
    VALUES ('Charles Dickens', 'Landport, Portsmouth, Royaume-Uni', '1812-02-07', FALSE);

    -- Jules Verne
    INSERT INTO adherents (nom, adresse, date_inscription, a_surveiller) 
    VALUES ('Jules Verne', 'Nantes, France', '1828-02-08', FALSE);

    -- Mary Shelley
    INSERT INTO adherents (nom, adresse, date_inscription, a_surveiller) 
    VALUES ('Mary Shelley', 'Somers Town, Londres, Royaume-Uni', '1797-08-30', FALSE);

-- Ajout des livres

    -- Orgueil et Préjugés
    INSERT INTO livres (isbn, titre, auteur, annee_publication, disponible) 
    VALUES ('9782253088905', 'Orgueil et Préjugés', 'Jane Austen', 1813, TRUE);

    -- David Copperfield
    INSERT INTO livres (isbn, titre, auteur, annee_publication, disponible) 
    VALUES ('9782013227445', 'David Copperfield', 'Charles Dickens', 1850, TRUE);

    -- Vingt mille lieues sous les mers
    INSERT INTO livres (isbn, titre, auteur, annee_publication, disponible) 
    VALUES ('9782210758810', 'Vingt mille lieues sous les mers', 'Jules Verne', 1870, TRUE);

    -- Frankenstein
    INSERT INTO livres (isbn, titre, auteur, annee_publication, disponible) 
    VALUES ('9782266196772', 'Frankenstein', 'Mary Shelley', 1818, TRUE);

-- Ajout des emprunts

    -- Jane Austen emprunte Frankenstein
    INSERT INTO emprunts (id_adherent, isbn, date_emprunt, date_retour) 
    VALUES (1, '9782266196772', '2025-03-20', '2025-04-19');

    -- Charles Dickens emprunte Vingt mille lieues sous les mers
    INSERT INTO emprunts (id_adherent, isbn, date_emprunt, date_retour) 
    VALUES (2, '9782210758810', '2025-03-12', '2025-04-11');

    -- Jules Verne emprunte Orgueil et Préjugés
    INSERT INTO emprunts (id_adherent, isbn, date_emprunt, date_retour) 
    VALUES (3, '9782253088905', '2025-02-15', '2025-03-14');

    -- Mary Shelley emprunte David Copperfield
    INSERT INTO emprunts (id_adherent, isbn, date_emprunt, date_retour) 
    VALUES (4, '9782013227445', '2025-01-18', '2025-02-17');
    


/* 4. 
Charles Dickens déménage, mettez à jour son adresse dans la base de données.
*/

    -- Mise à jour de l'adresse de Charles Dickens
    UPDATE adherents 
    SET adresse = 'Riom, France' 
    WHERE id_adherent = 2;


/* 5.
Un livre est empruntable 30 jours, faites une vue qui affiche les personnes qui ont des livres en retard et les livres en question
*/

-- Liste des personnes qui ont des livres en retard (+ livres concernés)
CREATE VIEW livres_en_retard AS
SELECT a.nom AS 'Adhérent',
        a.adresse AS 'Adresse',
        l.titre AS 'Livre',
        l.auteur AS 'Auteur',
        e.date_emprunt "Date d'emprunt",
        e.date_retour 'Date de retour'
FROM emprunts e
JOIN adherents a ON e.id_adherent = a.id_adherent
JOIN livres l ON e.isbn = l.isbn
WHERE e.date_retour < CURDATE();


/* 6.
Créer un trigger qui passe le booléen « disponible » à true si la date de retour d’un livre est précisée
*/

-- Création du trigger
DELIMITER //

CREATE TRIGGER maj_dispo_si_date_retour
AFTER UPDATE ON emprunts
FOR EACH ROW
BEGIN
    IF NEW.date_retour IS NOT NULL THEN
        UPDATE livres
        SET disponible = TRUE
        WHERE isbn = NEW.isbn;
    END IF;
END //

DELIMITER ;


/* 7.
Créer une procédure stockée qui passe le booléen « a_surveiller » à true si une personne a un retard de plus de 30 jours
*/

-- Création de la procédure
DELIMITER //

CREATE PROCEDURE surveiller_retards()
BEGIN
    UPDATE adherents
    SET a_surveiller = TRUE
    WHERE id_adherent IN (
        SELECT e.id_adherent
        FROM emprunts e
        WHERE e.date_retour < CURDATE() - INTERVAL 30 DAY
    );
END //

DELIMITER ;


/* 8.
Mary Shelley arrête son adhésion à la bibliothèque, supprimez son enregistrement de la base de données.
*/

-- Suppression de l'enregistrement de Mary Shelley
DELETE FROM adherents WHERE nom = 'Mary Shelley';


/*9.
Sur quel(s) champ(s) pourrait-on mettre un index pour optimiser les requêtes et pourquoi ?

On pourrait mettre un index sur les champs suivants pour optimiser les requêtes :

1. `id_adherent` dans la table `adherents` : 
Cela accélérerait les recherches par identifiant d'adhérent, qui est souvent utilisé dans les jointures et les conditions WHERE.

2. `isbn` dans la table `livres` : 
Cela accélérerait les recherches par ISBN, qui est également utilisé dans les jointures et les conditions WHERE.

3. `date_retour` dans la table `emprunts` : 
Cela optimiserait les requêtes qui filtrent ou trient par date de retour, comme celles pour identifier les retards.
*/

-- Exemple de création d'index :
CREATE INDEX ix_adherent_id ON adherents(id_adherent);
CREATE INDEX ix_livres_isbn ON livres(isbn);
CREATE INDEX ix_emprunts_date_retour ON emprunts(date_retour);


/*10. 
La bibliothèque doit se conformer à la RGPD. Quelle requête SQL utiliseriez-vous pour anonymiser la base de données? pour supprimer toute la base de données ?
*/

-- Anonymiser la base de données
UPDATE adherents 
SET nom = CONCAT('Adherent_', id_adherent), adresse = NULL;

UPDATE livres 
SET titre = CONCAT('Livre_', isbn), auteur = NULL;

-- Supprimer toute la base de données
DROP DATABASE IF EXISTS bibliotheque;

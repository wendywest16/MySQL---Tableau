CREATE DATABASE IF NOT EXISTS yellowtail;
USE yellowtail;

DROP TABLE IF EXISTS voyage, fishingday, catches,stomachcontents;

CREATE TABLE voyage
(
voyageID int(10) unsigned NOT NULL AUTO_INCREMENT,
sampling_site varchar(150) NOT NULL,
contact_person varchar(150) NOT NULL,
PRIMARY KEY (`voyageID`)
);

CREATE TABLE fishingday
(
dayID int(11) NOT NULL AUTO_INCREMENT,
voyageID int(11) unsigned DEFAULT NULL,
sampling_date date NOT NULL,
latitude decimal(4,2) DEFAULT NULL,
longitude decimal(4,2) DEFAULT NULL,
PRIMARY KEY (dayID),
FOREIGN KEY (voyageID) REFERENCES voyage (voyageID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE catches
(
fishID int(11) NOT NULL AUTO_INCREMENT,
dayID int(11) NOT NULL,
fishnr int(11) NOT NULL UNIQUE,
fishspp varchar(20) NOT NULL,
FL_mm int(11) DEFAULT NULL,
sex VARCHAR(1) DEFAULT NULL,
CHECK(sex IN('F', 'M', 'U')),
fishweight_kg float(5,3) DEFAULT NULL,
stomachcontents_g DECIMAL(4,1) DEFAULT NULL,  #wouldn't work as float. Why?
PRIMARY KEY (`fishID`),
FOREIGN KEY (dayID) REFERENCES fishingday (dayID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE stomachcontents
(
preyID int(11) NOT NULL AUTO_INCREMENT,
fishID int(11) NOT NULL,
preyspp varchar(255) DEFAULT NULL,
prey_phylum varchar(2) DEFAULT NULL,
prey_class varchar(100) DEFAULT NULL,
prey_order varchar(100) DEFAULT NULL,
prey_family varchar(100) DEFAULT NULL,
prey_weight_g DECIMAL(4,1) NOT NULL,  #fill blanks with zeroes
PRIMARY KEY (`preyID`),
CHECK (prey_phylum in ('O','CE','CU','F','M')),
FOREIGN KEY (fishID) REFERENCES catches (fishID) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO voyage(sampling_site, contact_person) VALUES ('Walters Shoal', 'Sheroma'),
('Vema seamount', 'Sven');

SHOW VARIABLES LIKE 'secure_file_priv'; #The location where the .csv file must be stored

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fishingday.csv' 
INTO TABLE fishingday 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/catches.csv' 
INTO TABLE catches 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stomachcontents.csv' 
INTO TABLE stomachcontents 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#==========================================
#QUERY DATA MANIPULATION
#==========================================
USE yellowtail;

#Number of yellowtail sampled per sex and per sampling site
SELECT 
    t1.sampling_site, t3.sex, COUNT(t3.fishnr) AS number_of_yellowtail
FROM
    voyage t1
        INNER JOIN
    fishingday t2 ON t1.voyageID = t2.voyageID
        INNER JOIN
    catches t3 ON t2.dayID = t3.dayID
GROUP BY t1.sampling_site, t3.sex;

#Average:
# FL 
# fish weight
# stomach weight per sex per sampling site

#1. Create new table from multiple tables
#2. Query on new table
CREATE TABLE averages_fish AS SELECT t1.sampling_site,
    t3.sex,
    t3.FL_mm,
    t3.fishweight_kg,
    t3.stomachcontents_g FROM
    voyage t1
        INNER JOIN
    fishingday t2 ON t1.voyageID = t2.voyageID
        INNER JOIN
    catches t3 ON t2.dayID = t3.dayID;


SELECT 
    sampling_site,
    sex,
    AVG(fl_mm) AS Average_FL_mm,
    AVG(fishweight_kg) AS Average_FishWeight_kg,
    AVG(stomachcontents_g) AS Average_StomachContents_g
FROM
    averages_fish
GROUP BY sampling_site , sex
ORDER BY sex;


#Number of different species per sampling site

SELECT 
    t1.sampling_site,
    COUNT(DISTINCT t4.preyspp) AS Species_count,
    MIN(t4.fishID) AS Minimum_fishID,
    MAX(t4.fishID) AS Maximum_fishID
FROM
    voyage t1
        INNER JOIN
    fishingday t2 ON t1.voyageID = t2.voyageID
        INNER JOIN
    catches t3 ON t2.dayID = t3.dayID
        INNER JOIN
    stomachcontents t4 ON t3.fishID = t4.fishID
GROUP BY sampling_site;

#Frequency of Occurence (FO) of each phylum (Crustacean, Cephalopod, Fish, Mollusc, Other) for sampling sites. Subquery
#Calculation: (Count of the presence of the phylum per stomach / Total number of stomachs)*100

#1. Total number of stomachs
CREATE TABLE number_of_stomachs AS SELECT t1.sampling_site, COUNT(DISTINCT fishID) AS Fish_per_site FROM
    voyage t1
        INNER JOIN
    fishingday t2 ON t1.voyageID = t2.voyageID
        INNER JOIN
    catches t3 ON t2.dayID = t3.dayID
GROUP BY t1.sampling_site;


#2. FO of prey phylum
CREATE TABLE fo_prey_phylum AS SELECT A.sampling_site,
    A.prey_phylum,
    ((COUNT(A.prey_phylum) / B.Fish_per_site) * 100) AS Frequency_of_Occurence FROM
    (SELECT 
        t1.sampling_site, t4.fishID, t4.prey_phylum
    FROM
        voyage t1
    INNER JOIN fishingday t2 ON t1.voyageID = t2.voyageID
    INNER JOIN catches t3 ON t2.dayID = t3.dayID
    INNER JOIN stomachcontents t4 ON t3.fishID = t4.fishID
    GROUP BY t1.sampling_site , t4.fishID , t4.prey_phylum) AS A,
    number_of_stomachs AS B
GROUP BY A.sampling_site , A.prey_phylum;

#Plot table in Tableau...

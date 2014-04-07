SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`organisatie`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`organisatie` (
  `organisatie_id` INT NOT NULL,
  `beleidsdomein` VARCHAR(50) NULL COMMENT 'Default: Mobiliteit en Openbare Werken',
  `entiteit` VARCHAR(50) NULL,
  `afdeling` VARCHAR(50) NULL,
  PRIMARY KEY (`organisatie_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`persoon`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`persoon` (
  `persoon_id` INT NOT NULL,
  `naam` VARCHAR(50) NULL,
  `voornaam` VARCHAR(50) NULL,
  `email` VARCHAR(50) NULL,
  `organisatie_id` INT NULL DEFAULT -1,
  PRIMARY KEY (`persoon_id`),
  INDEX `organisatie_fk_idx` (`organisatie_id` ASC),
  CONSTRAINT `organisatie_fk`
    FOREIGN KEY (`organisatie_id`)
    REFERENCES `mydb`.`organisatie` (`organisatie_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`indicatorfiche`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`indicatorfiche` (
  `indicatorfiche_id` INT NOT NULL,
  `indicator_naam` VARCHAR(255) NULL,
  `definitie` VARCHAR(4000) NULL,
  `doel_meting` VARCHAR(4000) NULL,
  `meettechniek` VARCHAR(4000) NULL,
  `type_indicator` VARCHAR(30) NULL,
  `meeteenheid` VARCHAR(255) NULL,
  `meetfrequentie` VARCHAR(255) NULL,
  `tijdvenster` VARCHAR(255) NULL,
  `aantal_percentage` VARCHAR(1) NULL,
  `streefwaarde` VARCHAR(4000) NULL,
  `streefwaardedefault` FLOAT NULL,
  `streefwaardetype` VARCHAR(30) NULL,
  `geografische_info` VARCHAR(1) NULL,
  `bron` VARCHAR(255) NULL,
  `aanspreekpunt_id` INT NULL DEFAULT -1,
  `aanspreekpuntorganisatie_id` INT NULL DEFAULT -1,
  `fiche_laatst_bijgewerkt` TIMESTAMP NULL,
  `opmerking` VARCHAR(4000) NULL,
  `vrijgave_metrics` VARCHAR(1) NULL,
  `url_rapport` VARCHAR(500) NULL,
  `url_invoer` VARCHAR(500) NULL,
  PRIMARY KEY (`indicatorfiche_id`),
  INDEX `aanspreekpunt_fk_idx` (`aanspreekpunt_id` ASC),
  INDEX `aanspreekorganisatie_fk_idx` (`aanspreekpuntorganisatie_id` ASC),
  CONSTRAINT `aanspreekpunt_fk`
    FOREIGN KEY (`aanspreekpunt_id`)
    REFERENCES `mydb`.`persoon` (`persoon_id`)
    ON DELETE SET NULL
    ON UPDATE NO ACTION,
  CONSTRAINT `aanspreekorganisatie_fk`
    FOREIGN KEY (`aanspreekpuntorganisatie_id`)
    REFERENCES `mydb`.`organisatie` (`organisatie_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`indicator`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`indicator` (
  `indicator_id` INT NOT NULL,
  `periode` VARCHAR(50) NULL,
  `aantal` FLOAT NULL,
  `indicatorfiche_id` INT NULL,
  PRIMARY KEY (`indicator_id`),
  INDEX `indicator2fiche_fk_idx` (`indicatorfiche_id` ASC),
  CONSTRAINT `indicator2fiche_fk`
    FOREIGN KEY (`indicatorfiche_id`)
    REFERENCES `mydb`.`indicatorfiche` (`indicatorfiche_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`dimensie`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`dimensie` (
  `dimensie_id` INT NOT NULL,
  `waarde` VARCHAR(255) NULL,
  PRIMARY KEY (`dimensie_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`dim_element`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`dim_element` (
  `dim_element_id` INT NOT NULL,
  `dimensie_id` INT NOT NULL,
  `waarde` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`dim_element_id`),
  INDEX `dim_element_fk_idx` (`dimensie_id` ASC),
  CONSTRAINT `dim_element_fk`
    FOREIGN KEY (`dimensie_id`)
    REFERENCES `mydb`.`dimensie` (`dimensie_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`dimensie_fiche`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`dimensie_fiche` (
  `dimensie_fiche_id` INT NOT NULL,
  `dimensie_id` INT NULL,
  `fiche_id` INT NULL,
  PRIMARY KEY (`dimensie_fiche_id`),
  INDEX `fiche_fk_idx` (`fiche_id` ASC),
  INDEX `dimensie_fk3_idx` (`dimensie_id` ASC),
  CONSTRAINT `fiche_fk`
    FOREIGN KEY (`fiche_id`)
    REFERENCES `mydb`.`indicatorfiche` (`indicatorfiche_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `dimensie_fk3`
    FOREIGN KEY (`dimensie_id`)
    REFERENCES `mydb`.`dimensie` (`dimensie_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`indicator_element`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`indicator_element` (
  `indicator_element_id` INT NOT NULL,
  `indicator_id` INT NOT NULL,
  `dim_element_id` INT NOT NULL,
  PRIMARY KEY (`indicator_element_id`),
  INDEX `indicator_element_fk_idx` (`indicator_id` ASC),
  INDEX `indicator_element_fk2_idx` (`dim_element_id` ASC),
  CONSTRAINT `indicator_element_fk`
    FOREIGN KEY (`indicator_id`)
    REFERENCES `mydb`.`indicator` (`indicator_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `indicator_element_fk2`
    FOREIGN KEY (`dim_element_id`)
    REFERENCES `mydb`.`dim_element` (`dim_element_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`rol`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`rol` (
  `rol_id` INT NOT NULL,
  `type` VARCHAR(50) NULL,
  `indicatorfiche_id` INT NULL COMMENT 'Indien ingevuld, dan verwijst dit naar de beheerder van de indicator fiche.',
  `persoon_id` INT NULL,
  PRIMARY KEY (`rol_id`),
  INDEX `persoon_fk_idx` (`persoon_id` ASC),
  INDEX `indicatorfiche_fk_idx` (`indicatorfiche_id` ASC),
  CONSTRAINT `persoon_fk`
    FOREIGN KEY (`persoon_id`)
    REFERENCES `mydb`.`persoon` (`persoon_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `indicatorfiche_fk`
    FOREIGN KEY (`indicatorfiche_id`)
    REFERENCES `mydb`.`indicatorfiche` (`indicatorfiche_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`beleidsdocument`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`beleidsdocument` (
  `beleidsdocument_id` INT NOT NULL,
  `titel` VARCHAR(255) NULL,
  `parent_id` INT NULL,
  PRIMARY KEY (`beleidsdocument_id`),
  INDEX `beleidsdocument_parent_idx` (`parent_id` ASC),
  CONSTRAINT `beleidsdocument_parent`
    FOREIGN KEY (`parent_id`)
    REFERENCES `mydb`.`beleidsdocument` (`beleidsdocument_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`document_fiche`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`document_fiche` (
  `document_fiche_id` INT NOT NULL,
  `beleidsdocument_id` INT NULL,
  `indicatorfiche_id` INT NULL,
  PRIMARY KEY (`document_fiche_id`),
  INDEX `document_fk_idx` (`beleidsdocument_id` ASC),
  INDEX `indicator_fk_idx` (`indicatorfiche_id` ASC),
  CONSTRAINT `document_fk`
    FOREIGN KEY (`beleidsdocument_id`)
    REFERENCES `mydb`.`beleidsdocument` (`beleidsdocument_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `indicator_fk`
    FOREIGN KEY (`indicatorfiche_id`)
    REFERENCES `mydb`.`indicatorfiche` (`indicatorfiche_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`referentie`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`referentie` (
  `referentie_id` INT NOT NULL,
  `type` VARCHAR(30) NOT NULL COMMENT 'Categorie van de referentie waarde. Keuzelijst wordt gebruikt om de keuzes bij bepaalde velden in tabellen bij te houden.  Frequentie wordt gebruikt om de frequentie labels op te slaan. Tabel is leeg voor dit type, veld wordt als discriminator gebruikt.',
  `tabel` VARCHAR(50) NULL,
  `veld` VARCHAR(50) NULL COMMENT 'Veld van een tabel waar de keuzelijst voor gebruikt wordt, of discriminator in andere gevallen.',
  `waarde` VARCHAR(255) NULL,
  `actief` VARCHAR(1) NULL,
  `gewicht` INT NULL COMMENT 'Het gewicht laat toe om de waarden te ordenen volgens de voorkeur van de gebruiker. Bevoorbeeld maanden worden per gewicht geordend.',
  PRIMARY KEY (`referentie_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`indicator_report`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`indicator_report` (
  `indicator_report` INT NOT NULL,
  `indicator_fiche_id` INT NOT NULL,
  `periode` VARCHAR(50) NOT NULL,
  `aantal` FLOAT NULL,
  `percentage` FLOAT NULL,
  `actief` VARCHAR(1) NULL,
  `type_dag` INT NULL DEFAULT -1,
  `dagdeel` INT NULL DEFAULT -1,
  `type_verkeerssituatie` INT NULL DEFAULT -1,
  `provincie` INT NULL DEFAULT -1,
  `gemeente` INT NULL DEFAULT -1,
  `netwerk` INT NULL DEFAULT -1,
  `netwerklink` INT NULL DEFAULT -1,
  `type_infrastructuur` INT NULL DEFAULT -1,
  `entiteit` INT NULL DEFAULT -1,
  `type_medewerker` INT NULL DEFAULT -1,
  `verplaatsingsmotief` INT NULL DEFAULT -1,
  `hoofdvervoerswijze` INT NULL DEFAULT -1,
  `afstandsklasse` INT NULL DEFAULT -1,
  `vervoersbewijs` INT NULL DEFAULT -1,
  `voertuigtype` INT NULL DEFAULT -1,
  `referentiejaar` INT NULL DEFAULT -1,
  `stormvloedpijl` INT NULL DEFAULT -1,
  `type_toelage` INT NULL DEFAULT -1,
  `type_onderhoud` INT NULL DEFAULT -1,
  `type_incident` INT NULL DEFAULT -1,
  `type_onderwijs` INT NULL DEFAULT -1,
  `type_dooimddel` INT NULL DEFAULT -1,
  `klasse_fietspaden` INT NULL DEFAULT -1,
  `laatst_bijgewerkt` TIMESTAMP NULL,
  `gereserveerd_1` INT NULL DEFAULT -1,
  `gereserveerd_2` INT NULL DEFAULT -1,
  `gereserveerd_3` INT NULL DEFAULT -1,
  `voertuigmodel` INT NULL DEFAULT -1,
  PRIMARY KEY (`indicator_report`),
  INDEX `indicator_report_fk_idx` (`indicator_fiche_id` ASC),
  CONSTRAINT `indicator_report_fk`
    FOREIGN KEY (`indicator_fiche_id`)
    REFERENCES `mydb`.`indicatorfiche` (`indicatorfiche_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`user` (
  `username` VARCHAR(16) NOT NULL,
  `email` VARCHAR(255) NULL,
  `password` VARCHAR(32) NOT NULL,
  `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP);


-- -----------------------------------------------------
-- Table `mydb`.`trefwoord_fiche`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`trefwoord_fiche` (
  `trefwoord_fiche_id` INT NOT NULL,
  `referentie_id` INT NOT NULL,
  `indicatorfiche_id` INT NOT NULL,
  PRIMARY KEY (`trefwoord_fiche_id`),
  INDEX `trefwoord_ref_fk_idx` (`referentie_id` ASC),
  INDEX `trefwoord_ind_fk_idx` (`indicatorfiche_id` ASC),
  CONSTRAINT `trefwoord_ref_fk`
    FOREIGN KEY (`referentie_id`)
    REFERENCES `mydb`.`referentie` (`referentie_id`)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION,
  CONSTRAINT `trefwoord_ind_fk`
    FOREIGN KEY (`indicatorfiche_id`)
    REFERENCES `mydb`.`indicatorfiche` (`indicatorfiche_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`commentaar`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`commentaar` (
  `commentaar_id` INT NOT NULL,
  `indicatorfiche_id` INT NOT NULL,
  `periode` VARCHAR(50) NULL,
  `beschrijving` VARCHAR(4000) NULL,
  `laatst_bijgewerkt` TIMESTAMP NULL,
  PRIMARY KEY (`commentaar_id`),
  INDEX `commentaar_fk_idx` (`indicatorfiche_id` ASC),
  CONSTRAINT `commentaar_fk`
    FOREIGN KEY (`indicatorfiche_id`)
    REFERENCES `mydb`.`indicatorfiche` (`indicatorfiche_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`gepubliceerd_fiche`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`gepubliceerd_fiche` (
  `gepubliceerd_fiche_id` INT NOT NULL,
  `indicatorfiche_id` INT NOT NULL,
  `referentie_id` INT NOT NULL,
  PRIMARY KEY (`gepubliceerd_fiche_id`),
  INDEX `gepubliceerd_fiche_id_idx` (`indicatorfiche_id` ASC),
  INDEX `gepubliceerd_ref_id_idx` (`referentie_id` ASC),
  CONSTRAINT `gepubliceerd_fiche_id`
    FOREIGN KEY (`indicatorfiche_id`)
    REFERENCES `mydb`.`indicatorfiche` (`indicatorfiche_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `gepubliceerd_ref_id`
    FOREIGN KEY (`referentie_id`)
    REFERENCES `mydb`.`referentie` (`referentie_id`)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`frequenties`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`frequenties` (
  `dagnr` INT NOT NULL,
  `datum` DATE NULL,
  `dag_week` VARCHAR(20) NULL,
  `dag` INT NULL,
  `maand` VARCHAR(20) NULL,
  `jaar` INT NULL,
  `maandnr` INT NULL,
  `kwartaal` VARCHAR(20) NULL,
  `maand_label` VARCHAR(50) NULL,
  `kwartaal_label` VARCHAR(50) NULL,
  `schooljaar_label` VARCHAR(10) NULL,
  PRIMARY KEY (`dagnr`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

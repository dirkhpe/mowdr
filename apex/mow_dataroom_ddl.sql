CREATE TABLE  "AANT" 
   (    "INDICATORFICHE_ID" NUMBER, 
    "AANTAL_PERCENTAGE" VARCHAR2(30 CHAR), 
     CONSTRAINT "AANT_PK" PRIMARY KEY ("INDICATORFICHE_ID") ENABLE
   )
/
CREATE TABLE  "APEX_ACCESS_SETUP" 
   (    "ID" NUMBER, 
    "APPLICATION_MODE" VARCHAR2(255 CHAR), 
    "APPLICATION_ID" NUMBER, 
     CONSTRAINT "APEX_ACCESS_SETUP_PK" PRIMARY KEY ("ID") ENABLE, 
     CONSTRAINT "APEX_ACCESS_SETUP_UK" UNIQUE ("APPLICATION_ID") ENABLE
   )
/
CREATE TABLE  "APEX_ACCESS_CONTROL" 
   (    "ID" NUMBER, 
    "ADMIN_USERNAME" VARCHAR2(255 CHAR), 
    "ADMIN_PRIVILEGES" VARCHAR2(255 CHAR), 
    "SETUP_ID" NUMBER, 
    "CREATED_BY" VARCHAR2(255 CHAR), 
    "CREATED_ON" DATE, 
    "UPDATED_ON" DATE, 
    "UPDATED_BY" VARCHAR2(255 CHAR), 
     CONSTRAINT "APEX_ACCESS_CONTROL_PK" PRIMARY KEY ("ID") ENABLE, 
     CONSTRAINT "APEX_ACCESS_CONTROL_UK" UNIQUE ("ADMIN_USERNAME", "SETUP_ID") ENABLE
   )
/
CREATE TABLE  "BELEIDSDOCUMENT" 
   (    "BELEIDSDOCUMENT_ID" NUMBER NOT NULL ENABLE, 
    "TITEL" VARCHAR2(255 CHAR), 
    "PARENT_ID" NUMBER, 
    "TOC" VARCHAR2(255 CHAR), 
    "DOC_ID" NUMBER, 
     CONSTRAINT "BELEIDSDOCUMENT_PK" PRIMARY KEY ("BELEIDSDOCUMENT_ID") ENABLE
   )
/
CREATE TABLE  "FREQUENTIES" 
   (    "DAGNR" NUMBER NOT NULL ENABLE, 
    "DATUM" DATE NOT NULL ENABLE, 
    "DAG_WEEK" VARCHAR2(20 CHAR), 
    "DAG" NUMBER, 
    "MAAND" VARCHAR2(20 CHAR), 
    "JAAR" NUMBER, 
    "MAANDNR" NUMBER, 
    "KWARTAAL" VARCHAR2(20 CHAR), 
    "MAAND_LABEL" VARCHAR2(50 CHAR), 
    "KWARTAAL_LABEL" VARCHAR2(50 CHAR), 
    "SCHOOLJAAR_LABEL" VARCHAR2(10 CHAR), 
     CONSTRAINT "FREQUENTIES_PK" PRIMARY KEY ("DAGNR") ENABLE
   )
/
CREATE TABLE  "REFERENTIE" 
   (    "REFERENTIE_ID" NUMBER, 
    "TYPE" VARCHAR2(30 CHAR) NOT NULL ENABLE, 
    "TABEL" VARCHAR2(50 CHAR), 
    "WAARDE" VARCHAR2(255 CHAR), 
    "ACTIEF" CHAR(1 CHAR) NOT NULL ENABLE, 
    "VELD" VARCHAR2(50 CHAR), 
    "GEWICHT" NUMBER, 
     CONSTRAINT "REFERENTIE_PK" PRIMARY KEY ("REFERENTIE_ID") ENABLE
   )
/
CREATE TABLE  "ORGANISATIE" 
   (    "ORGANISATIE_ID" NUMBER NOT NULL ENABLE, 
    "BELEIDSDOMEIN" NUMBER, 
    "ENTITEIT" NUMBER, 
    "AFDELING" NUMBER, 
     CONSTRAINT "ORGANISATIE_PK" PRIMARY KEY ("ORGANISATIE_ID") ENABLE
   )
/
CREATE TABLE  "INDICATORFICHE" 
   (    "INDICATORFICHE_ID" NUMBER NOT NULL ENABLE, 
    "INDICATOR_NAAM" VARCHAR2(255 CHAR), 
    "DEFINITIE" VARCHAR2(4000 CHAR), 
    "DOEL_METING" VARCHAR2(4000 CHAR), 
    "MEETTECHNIEK" VARCHAR2(4000 CHAR), 
    "TYPE_INDICATOR" NUMBER, 
    "MEETEENHEID" NUMBER, 
    "MEETFREQUENTIE" VARCHAR2(255 CHAR), 
    "TIJDVENSTER" VARCHAR2(255 CHAR), 
    "AANTAL_PERCENTAGE" VARCHAR2(1 CHAR), 
    "STREEFWAARDE" VARCHAR2(4000 CHAR), 
    "STREEFWAARDEDEFAULT" NUMBER, 
    "STREEFWAARDETYPE" NUMBER, 
    "GEOGRAFISCHE_INFO" VARCHAR2(1 CHAR), 
    "BRON" VARCHAR2(255 CHAR), 
    "AANSPREEKORGANISATIE_ID" NUMBER DEFAULT -1, 
    "FICHE_LAATST_BIJGEWERKT" TIMESTAMP (6), 
    "OPMERKING" VARCHAR2(4000 CHAR), 
    "VRIJGAVE_METRICS" VARCHAR2(1 CHAR), 
    "URL_RAPPORT" VARCHAR2(2000 CHAR), 
    "URL_INVOER" VARCHAR2(500 CHAR), 
    "SLEUTEL" VARCHAR2(255 CHAR), 
    "BEREKENINGSWIJZE" VARCHAR2(4000 CHAR), 
    "URL_RAPPORT_MAP" VARCHAR2(1000 CHAR), 
     CONSTRAINT "INDICATORFICHE_PK" PRIMARY KEY ("INDICATORFICHE_ID") ENABLE
   )
/
CREATE TABLE  "COMMENTAAR" 
   (    "COMMENTAAR_ID" NUMBER NOT NULL ENABLE, 
    "INDICATORFICHE_ID" NUMBER NOT NULL ENABLE, 
    "PERIODE" VARCHAR2(50 CHAR), 
    "BESCHRIJVING" VARCHAR2(4000 CHAR), 
    "LAATST_BIJGEWERKT" TIMESTAMP (6), 
    "DAGNR" NUMBER, 
     CONSTRAINT "COMMENTAAR_PK" PRIMARY KEY ("COMMENTAAR_ID") ENABLE
   )
/
CREATE TABLE  "COMM_LOAD" 
   (    "COMM_LOAD_ID" NUMBER NOT NULL ENABLE, 
    "INDICATORFICHE_ID" NUMBER NOT NULL ENABLE, 
    "NAAM" VARCHAR2(255 CHAR), 
    "JAAR" NUMBER, 
    "KWARTAAL" NUMBER, 
    "MAAND" NUMBER, 
    "COMMENTAAR" VARCHAR2(4000 CHAR), 
    "LINENUMBER" NUMBER, 
     CONSTRAINT "COMM_LOAD_PK" PRIMARY KEY ("COMM_LOAD_ID") ENABLE
   )
/
CREATE TABLE  "CSV_FILES" 
   (    "CSV_FILES_ID" NUMBER NOT NULL ENABLE, 
    "SCRIPTFILE" VARCHAR2(255 CHAR), 
    "DATESTR" VARCHAR2(255 CHAR), 
    "TIMESTR" VARCHAR2(255 CHAR), 
    "FILENAME" VARCHAR2(255 CHAR), 
    "STATUS" VARCHAR2(255 CHAR), 
    "LAST_MODIFIED" TIMESTAMP (6), 
     CONSTRAINT "CSV_FILES_PK" PRIMARY KEY ("CSV_FILES_ID") ENABLE
   )
/
CREATE TABLE  "CSV_LOAD" 
   (    "CSV_LOAD_ID" NUMBER NOT NULL ENABLE, 
    "NAAM" VARCHAR2(255 CHAR), 
    "AANTAL" NUMBER, 
    "PERCENTAGE" NUMBER, 
    "JAAR" NUMBER, 
    "KWARTAAL" NUMBER, 
    "MAAND" NUMBER, 
    "ENTITEIT" VARCHAR2(255 CHAR), 
    "TYPE_MEDEWERKER" VARCHAR2(255 CHAR), 
    "INDICATORFICHE_ID" NUMBER, 
    "LINENUMBER" NUMBER, 
     CONSTRAINT "CSV_LOAD_PK" PRIMARY KEY ("CSV_LOAD_ID") ENABLE
   )
/
CREATE TABLE  "DIMENSIE" 
   (    "DIMENSIE_ID" NUMBER NOT NULL ENABLE, 
    "WAARDE" VARCHAR2(255 CHAR) NOT NULL ENABLE, 
    "TYPE" VARCHAR2(50 CHAR), 
     CONSTRAINT "DIMENSIE_PK" PRIMARY KEY ("DIMENSIE_ID") ENABLE
   )
/
CREATE TABLE  "DIM_ELEMENT" 
   (    "DIM_ELEMENT_ID" NUMBER NOT NULL ENABLE, 
    "DIMENSIE_ID" NUMBER NOT NULL ENABLE, 
    "WAARDE" VARCHAR2(255 CHAR) NOT NULL ENABLE, 
     CONSTRAINT "DIM_ELEMENT_PK" PRIMARY KEY ("DIM_ELEMENT_ID") ENABLE
   )
/
CREATE TABLE  "DIMENSIE_FICHE" 
   (    "DIMENSIE_FICHE_ID" NUMBER NOT NULL ENABLE, 
    "DIMENSIE_ID" NUMBER, 
    "FICHE_ID" NUMBER, 
     CONSTRAINT "DIMENSIE_FICHE_PK" PRIMARY KEY ("DIMENSIE_FICHE_ID") ENABLE
   )
/
CREATE TABLE  "DOCUMENT_FICHE" 
   (    "DOCUMENT_FICHE_ID" NUMBER NOT NULL ENABLE, 
    "BELEIDSDOCUMENT_ID" NUMBER, 
    "INDICATORFICHE_ID" NUMBER, 
     CONSTRAINT "DOCUMENT_FICHE_PK" PRIMARY KEY ("DOCUMENT_FICHE_ID") ENABLE
   )
/
CREATE TABLE  "FILE_OBJECT" 
   (    "FILE_OBJECT_ID" NUMBER NOT NULL ENABLE, 
    "SOURCE" VARCHAR2(255 CHAR) NOT NULL ENABLE, 
    "FILENAME" VARCHAR2(255 CHAR) NOT NULL ENABLE, 
    "DATESTR" VARCHAR2(50 CHAR) NOT NULL ENABLE, 
    "TIMESTR" VARCHAR2(50 CHAR) NOT NULL ENABLE, 
    "FOUND" TIMESTAMP (6) NOT NULL ENABLE, 
     CONSTRAINT "FILE_OBJECT_PK" PRIMARY KEY ("FILE_OBJECT_ID") ENABLE
   )
/
CREATE TABLE  "FILE_PROCESS" 
   (    "FILE_PROCESS_ID" NUMBER NOT NULL ENABLE, 
    "FILE_OBJECT_ID" NUMBER NOT NULL ENABLE, 
    "STATUS" VARCHAR2(255 CHAR), 
    "MESSAGE" VARCHAR2(1024 CHAR), 
    "LINENUMBER" NUMBER, 
    "PROCESS_TIME" TIMESTAMP (6), 
     CONSTRAINT "FILE_PROCESS_PK" PRIMARY KEY ("FILE_PROCESS_ID") ENABLE
   )
/
CREATE TABLE  "GEO_OBJECT" 
   (    "GEO_OBJECT_ID" NUMBER, 
    "NAAM" VARCHAR2(255 CHAR), 
    "LABEL" VARCHAR2(255 CHAR), 
    "TYPE_MONITORINGSYSTEEM" NUMBER DEFAULT -1, 
    "TYPE_SIGNALISATIESYSTEEM" NUMBER DEFAULT -1, 
    "GERESERVEERD_1" NUMBER DEFAULT -1, 
    "GERESERVEERD_2" NUMBER DEFAULT -1, 
    "GERESERVEERD_3" NUMBER DEFAULT -1, 
     CONSTRAINT "GEO_OBJECT_PK" PRIMARY KEY ("GEO_OBJECT_ID") ENABLE
   )
/
CREATE TABLE  "GEO_COORDINATEN" 
   (    "GEO_COORDINATEN_ID" NUMBER NOT NULL ENABLE, 
    "GEO_OBJECT_ID" NUMBER NOT NULL ENABLE, 
    "THE_GEOM_1" VARCHAR2(4000 CHAR), 
    "THE_GEOM_2" VARCHAR2(4000 CHAR), 
    "THE_GEOM_3" VARCHAR2(4000 CHAR), 
    "THE_GEOM_4" VARCHAR2(4000 CHAR), 
    "THE_GEOM_5" VARCHAR2(4000 CHAR), 
    "THE_GEOM_6" VARCHAR2(4000 CHAR), 
    "THE_GEOM_7" VARCHAR2(4000 CHAR), 
    "THE_GEOM_8" VARCHAR2(4000 CHAR), 
     CONSTRAINT "GEO_COORDINATEN_PK" PRIMARY KEY ("GEO_COORDINATEN_ID") ENABLE
   )
/
CREATE TABLE  "GEO_GROEP" 
   (    "GEO_GROEP_ID" NUMBER NOT NULL ENABLE, 
    "NAAM" VARCHAR2(255 CHAR), 
    "OMSCHRIJVING" VARCHAR2(255 CHAR), 
     CONSTRAINT "GEO_GROEP_PK" PRIMARY KEY ("GEO_GROEP_ID") ENABLE
   )
/
CREATE TABLE  "GEO_GROEP_FICHE" 
   (    "GEO_GROEP_FICHE_ID" NUMBER NOT NULL ENABLE, 
    "GEO_GROEP_ID" NUMBER NOT NULL ENABLE, 
    "INDICATORFICHE_ID" NUMBER NOT NULL ENABLE, 
     CONSTRAINT "GEO_GROEP_FICHE_PK" PRIMARY KEY ("GEO_GROEP_FICHE_ID") ENABLE
   )
/
CREATE TABLE  "GEO_OBJECT_GROEP" 
   (    "GEO_OBJECT_GROEP_ID" NUMBER NOT NULL ENABLE, 
    "GEO_OBJECT_ID" NUMBER NOT NULL ENABLE, 
    "GEO_GROEP_ID" NUMBER NOT NULL ENABLE, 
     CONSTRAINT "GEO_OBJECT_GROEP_PK" PRIMARY KEY ("GEO_OBJECT_GROEP_ID") ENABLE
   )
/
CREATE TABLE  "GEO_STATUS" 
   (    "GEO_STATUS_ID" NUMBER NOT NULL ENABLE, 
    "GEO_GROEP_ID" NUMBER NOT NULL ENABLE, 
    "WAARDE" VARCHAR2(255 CHAR) NOT NULL ENABLE, 
     CONSTRAINT "GEO_STATUS_PK" PRIMARY KEY ("GEO_STATUS_ID") ENABLE
   )
/
CREATE TABLE  "GEO_REPORT" 
   (    "GEO_REPORT_ID" NUMBER NOT NULL ENABLE, 
    "INDICATORFICHE_ID" NUMBER NOT NULL ENABLE, 
    "GEO_OBJECT_ID" NUMBER NOT NULL ENABLE, 
    "DAGNR" NUMBER, 
    "PERIODE" VARCHAR2(50 CHAR), 
    "LABEL" VARCHAR2(50 CHAR), 
    "SCHOOLJAAR" VARCHAR2(50 CHAR), 
    "JAAR" NUMBER, 
    "GEO_STATUS_ID" NUMBER NOT NULL ENABLE, 
    "COMMENTAAR" VARCHAR2(4000 CHAR), 
    "ACTIEF" VARCHAR2(1 CHAR) NOT NULL ENABLE, 
    "LAATST_BIJGEWERKT" TIMESTAMP (6), 
     CONSTRAINT "GEO_REPORT_PK" PRIMARY KEY ("GEO_REPORT_ID") ENABLE
   )
/
CREATE TABLE  "GEPUBLICEERD_FICHE" 
   (    "GEPUBLICEERD_FICHE_ID" NUMBER NOT NULL ENABLE, 
    "INDICATORFICHE_ID" NUMBER NOT NULL ENABLE, 
    "REFERENTIE_ID" NUMBER NOT NULL ENABLE, 
     CONSTRAINT "GEPUBLICEERD_FICHE_PK" PRIMARY KEY ("GEPUBLICEERD_FICHE_ID") ENABLE
   )
/
CREATE TABLE  "INDICATOR_REPORT" 
   (    "INDICATOR_REPORT_ID" NUMBER NOT NULL ENABLE, 
    "INDICATORFICHE_ID" NUMBER NOT NULL ENABLE, 
    "PERIODE" VARCHAR2(200 CHAR), 
    "AANTAL" NUMBER, 
    "PERCENTAGE" NUMBER, 
    "ACTIEF" VARCHAR2(1 CHAR), 
    "TYPE_DAG" NUMBER DEFAULT -1, 
    "DAGDEEL" NUMBER DEFAULT -1, 
    "TYPE_VERKEERSSITUATIE" NUMBER DEFAULT -1, 
    "PROVINCIE" NUMBER DEFAULT -1, 
    "GEMEENTE" NUMBER DEFAULT -1, 
    "NETWERK" NUMBER DEFAULT -1, 
    "NETWERKLINK" NUMBER DEFAULT -1, 
    "TYPE_INFRASTRUCTUUR" NUMBER DEFAULT -1, 
    "ENTITEIT" NUMBER DEFAULT -1, 
    "TYPE_MEDEWERKER" NUMBER DEFAULT -1, 
    "VERPLAATSINGSMOTIEF" NUMBER DEFAULT -1, 
    "HOOFDVERVOERSWIJZE" NUMBER DEFAULT -1, 
    "AFSTANDSKLASSE" NUMBER DEFAULT -1, 
    "VERVOERSBEWIJS" NUMBER DEFAULT -1, 
    "VOERTUIGTYPE" NUMBER DEFAULT -1, 
    "REFERENTIEJAAR" NUMBER DEFAULT -1, 
    "STORMVLOEDPEIL" NUMBER DEFAULT -1, 
    "TYPE_TOELAGE" NUMBER DEFAULT -1, 
    "TYPE_ONDERHOUD" NUMBER DEFAULT -1, 
    "TYPE_INCIDENT" NUMBER DEFAULT -1, 
    "TYPE_ONDERWIJS" NUMBER DEFAULT -1, 
    "TYPE_DOOIMIDDEL" NUMBER DEFAULT -1, 
    "KLASSE_FIETSPADEN" NUMBER DEFAULT -1, 
    "LAATST_BIJGEWERKT" TIMESTAMP (6), 
    "VOERTUIGMODEL" NUMBER DEFAULT -1, 
    "TYPE_AANVRAGER_EXPERTISE" NUMBER DEFAULT -1, 
    "TYPE_KUSTPATRIMONIUM" NUMBER DEFAULT -1, 
    "TYPE_MONITORINGSYSTEEM" NUMBER DEFAULT -1, 
    "TYPE_SIGNALISATIESYSTEEM" NUMBER DEFAULT -1, 
    "GERESERVEERD_1" NUMBER DEFAULT -1, 
    "GERESERVEERD_2" NUMBER DEFAULT -1, 
    "GERESERVEERD_3" NUMBER DEFAULT -1, 
    "DAGNR" NUMBER, 
    "LABEL" VARCHAR2(50 CHAR), 
    "SCHOOLJAAR" VARCHAR2(50 CHAR), 
    "JAAR" NUMBER, 
     CONSTRAINT "INDICATOR_REPORT_PK" PRIMARY KEY ("INDICATOR_REPORT_ID") ENABLE
   )
/
CREATE TABLE  "LOGTBL" 
   (    "EVT_IDX" NUMBER NOT NULL ENABLE, 
    "EVT_TIME" TIMESTAMP (6), 
    "EVT_PROC" VARCHAR2(255 CHAR), 
    "EVT_SEV" VARCHAR2(1 CHAR), 
    "EVT_MSG" VARCHAR2(4000 CHAR), 
     CONSTRAINT "LOGTBL_PK" PRIMARY KEY ("EVT_IDX") ENABLE
   )
/
CREATE TABLE  "MDK_LOG" 
   (    "SCRIPTFILE" VARCHAR2(255 CHAR), 
    "DATESTR" VARCHAR2(255 CHAR), 
    "TIMESTR" VARCHAR2(255 CHAR), 
    "MSG" VARCHAR2(255 CHAR)
   ) 
   ORGANIZATION EXTERNAL 
    ( TYPE ORACLE_LOADER
      DEFAULT DIRECTORY "DATAROOM_LOG"
      ACCESS PARAMETERS
      ( records delimited by newline
                  NOBADFILE NODISCARDFILE NOLOGFILE
                  fields terminated by ";"    )
      LOCATION
       ( 'mdk2apex.sh.11'
       )
    )
   REJECT LIMIT UNLIMITED
/
CREATE TABLE  "PERSOON" 
   (    "PERSOON_ID" NUMBER NOT NULL ENABLE, 
    "NAAM" VARCHAR2(50 CHAR), 
    "VOORNAAM" VARCHAR2(50 CHAR), 
    "EMAIL" VARCHAR2(50 CHAR), 
    "ORGANISATIE_ID" NUMBER DEFAULT -1, 
    "LDAP" VARCHAR2(20 CHAR), 
     CONSTRAINT "PERSOON_PK" PRIMARY KEY ("PERSOON_ID") ENABLE
   )
/
CREATE TABLE  "ROL" 
   (    "ROL_ID" NUMBER NOT NULL ENABLE, 
    "TYPE" VARCHAR2(50 CHAR), 
    "INDICATORFICHE_ID" NUMBER, 
    "PERSOON_ID" NUMBER, 
     CONSTRAINT "ROL_PK" PRIMARY KEY ("ROL_ID") ENABLE
   )
/
CREATE TABLE  "TREFWOORD_FICHE" 
   (    "TREFWOORD_FICHE_ID" NUMBER NOT NULL ENABLE, 
    "REFERENTIE_ID" NUMBER NOT NULL ENABLE, 
    "INDICATORFICHE_ID" NUMBER NOT NULL ENABLE, 
     CONSTRAINT "TREFWOORD_FICHE_PK" PRIMARY KEY ("TREFWOORD_FICHE_ID") ENABLE
   )
/
ALTER TABLE  "INDICATORFICHE" ADD CONSTRAINT "AANSPREEKORGANISATIE_FK" FOREIGN KEY ("AANSPREEKORGANISATIE_ID")
      REFERENCES  "ORGANISATIE" ("ORGANISATIE_ID") ENABLE
/
ALTER TABLE  "APEX_ACCESS_CONTROL" ADD CONSTRAINT "APEX_ACCESS_CONTROL_FK" FOREIGN KEY ("SETUP_ID")
      REFERENCES  "APEX_ACCESS_SETUP" ("ID") ENABLE
/
ALTER TABLE  "BELEIDSDOCUMENT" ADD CONSTRAINT "BELEIDSDOCUMENT_PARENT" FOREIGN KEY ("PARENT_ID")
      REFERENCES  "BELEIDSDOCUMENT" ("BELEIDSDOCUMENT_ID") ENABLE
/
ALTER TABLE  "COMMENTAAR" ADD CONSTRAINT "COMMENTAAR_FICHE_FK" FOREIGN KEY ("INDICATORFICHE_ID")
      REFERENCES  "INDICATORFICHE" ("INDICATORFICHE_ID") ENABLE
/
ALTER TABLE  "COMMENTAAR" ADD CONSTRAINT "COMMENTAAR_FREQ_FK" FOREIGN KEY ("DAGNR")
      REFERENCES  "FREQUENTIES" ("DAGNR") ENABLE
/
ALTER TABLE  "DIMENSIE_FICHE" ADD CONSTRAINT "DIMENSIE_FK3" FOREIGN KEY ("DIMENSIE_ID")
      REFERENCES  "DIMENSIE" ("DIMENSIE_ID") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "DIM_ELEMENT" ADD CONSTRAINT "DIM_EL_DIMENSIE_FK" FOREIGN KEY ("DIMENSIE_ID")
      REFERENCES  "DIMENSIE" ("DIMENSIE_ID") ENABLE
/
ALTER TABLE  "DOCUMENT_FICHE" ADD CONSTRAINT "DOCUMENT_FK" FOREIGN KEY ("BELEIDSDOCUMENT_ID")
      REFERENCES  "BELEIDSDOCUMENT" ("BELEIDSDOCUMENT_ID") ENABLE
/
ALTER TABLE  "DIMENSIE_FICHE" ADD CONSTRAINT "FICHE_FK" FOREIGN KEY ("FICHE_ID")
      REFERENCES  "INDICATORFICHE" ("INDICATORFICHE_ID") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "GEO_COORDINATEN" ADD CONSTRAINT "GEO_COORDINATEN_OBJECT_FK" FOREIGN KEY ("GEO_OBJECT_ID")
      REFERENCES  "GEO_OBJECT" ("GEO_OBJECT_ID") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "GEO_GROEP_FICHE" ADD CONSTRAINT "GEO_GROEP_FICHE_FK2" FOREIGN KEY ("INDICATORFICHE_ID")
      REFERENCES  "INDICATORFICHE" ("INDICATORFICHE_ID") ENABLE
/
ALTER TABLE  "GEO_GROEP_FICHE" ADD CONSTRAINT "GEO_GROEP_FK" FOREIGN KEY ("GEO_GROEP_ID")
      REFERENCES  "GEO_GROEP" ("GEO_GROEP_ID") ENABLE
/
ALTER TABLE  "GEO_OBJECT_GROEP" ADD CONSTRAINT "GEO_OBJECT_GROEP_FK" FOREIGN KEY ("GEO_OBJECT_ID")
      REFERENCES  "GEO_OBJECT" ("GEO_OBJECT_ID") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "GEO_OBJECT_GROEP" ADD CONSTRAINT "GEO_OBJECT_GROEP_GROEP_FK" FOREIGN KEY ("GEO_GROEP_ID")
      REFERENCES  "GEO_GROEP" ("GEO_GROEP_ID") ENABLE
/
ALTER TABLE  "GEO_REPORT" ADD CONSTRAINT "GEO_REPORT_FREQUENTIE_FK" FOREIGN KEY ("DAGNR")
      REFERENCES  "FREQUENTIES" ("DAGNR") ENABLE
/
ALTER TABLE  "GEO_REPORT" ADD CONSTRAINT "GEO_REPORT_INDICATORFICHE_FK" FOREIGN KEY ("INDICATORFICHE_ID")
      REFERENCES  "INDICATORFICHE" ("INDICATORFICHE_ID") ENABLE
/
ALTER TABLE  "GEO_REPORT" ADD CONSTRAINT "GEO_REPORT_OBJECT_FK" FOREIGN KEY ("GEO_OBJECT_ID")
      REFERENCES  "GEO_OBJECT" ("GEO_OBJECT_ID") ENABLE
/
ALTER TABLE  "GEO_REPORT" ADD CONSTRAINT "GEO_REPORT_STATUS_FK" FOREIGN KEY ("GEO_STATUS_ID")
      REFERENCES  "GEO_STATUS" ("GEO_STATUS_ID") ENABLE
/
ALTER TABLE  "GEO_STATUS" ADD CONSTRAINT "GEO_STATUS_FK" FOREIGN KEY ("GEO_GROEP_ID")
      REFERENCES  "GEO_GROEP" ("GEO_GROEP_ID") ENABLE
/
ALTER TABLE  "GEPUBLICEERD_FICHE" ADD CONSTRAINT "GEPUBLICEERD_FICHE_FK" FOREIGN KEY ("INDICATORFICHE_ID")
      REFERENCES  "INDICATORFICHE" ("INDICATORFICHE_ID") ENABLE
/
ALTER TABLE  "GEPUBLICEERD_FICHE" ADD CONSTRAINT "GEPUBLICEERD_REF_FK" FOREIGN KEY ("REFERENTIE_ID")
      REFERENCES  "REFERENTIE" ("REFERENTIE_ID") ENABLE
/
ALTER TABLE  "ROL" ADD CONSTRAINT "INDICATORFICHE_FK" FOREIGN KEY ("INDICATORFICHE_ID")
      REFERENCES  "INDICATORFICHE" ("INDICATORFICHE_ID") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "INDICATOR_REPORT" ADD CONSTRAINT "INDICATOR_FICHE_FK" FOREIGN KEY ("INDICATORFICHE_ID")
      REFERENCES  "INDICATORFICHE" ("INDICATORFICHE_ID") ENABLE
/
ALTER TABLE  "DOCUMENT_FICHE" ADD CONSTRAINT "INDICATOR_FK" FOREIGN KEY ("INDICATORFICHE_ID")
      REFERENCES  "INDICATORFICHE" ("INDICATORFICHE_ID") ENABLE
/
ALTER TABLE  "INDICATOR_REPORT" ADD CONSTRAINT "INDICATOR_FREQ_FK" FOREIGN KEY ("DAGNR")
      REFERENCES  "FREQUENTIES" ("DAGNR") ENABLE
/
ALTER TABLE  "INDICATORFICHE" ADD CONSTRAINT "INDIC_STREEFWAARDETYPE_FK" FOREIGN KEY ("STREEFWAARDETYPE")
      REFERENCES  "REFERENTIE" ("REFERENTIE_ID") ENABLE
/
ALTER TABLE  "INDICATORFICHE" ADD CONSTRAINT "IND_REF_MEETEENHEID_FK" FOREIGN KEY ("MEETEENHEID")
      REFERENCES  "REFERENTIE" ("REFERENTIE_ID") ENABLE
/
ALTER TABLE  "INDICATORFICHE" ADD CONSTRAINT "IND_REF_TYPE_INDIC_FK" FOREIGN KEY ("TYPE_INDICATOR")
      REFERENCES  "REFERENTIE" ("REFERENTIE_ID") ENABLE
/
ALTER TABLE  "PERSOON" ADD CONSTRAINT "ORGANISATIE_FK" FOREIGN KEY ("ORGANISATIE_ID")
      REFERENCES  "ORGANISATIE" ("ORGANISATIE_ID") ON DELETE SET NULL ENABLE
/
ALTER TABLE  "ORGANISATIE" ADD CONSTRAINT "ORGANISATIE_REF_AFDELING_FK" FOREIGN KEY ("AFDELING")
      REFERENCES  "REFERENTIE" ("REFERENTIE_ID") ENABLE
/
ALTER TABLE  "ORGANISATIE" ADD CONSTRAINT "ORG_REF_DOMEIN_FK" FOREIGN KEY ("BELEIDSDOMEIN")
      REFERENCES  "REFERENTIE" ("REFERENTIE_ID") ENABLE
/
ALTER TABLE  "ORGANISATIE" ADD CONSTRAINT "ORG_REF_ENTITEIT_FK" FOREIGN KEY ("ENTITEIT")
      REFERENCES  "REFERENTIE" ("REFERENTIE_ID") ENABLE
/
ALTER TABLE  "ROL" ADD CONSTRAINT "PERSOON_FK" FOREIGN KEY ("PERSOON_ID")
      REFERENCES  "PERSOON" ("PERSOON_ID") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "TREFWOORD_FICHE" ADD CONSTRAINT "TREFWOORD_FICHE_FK" FOREIGN KEY ("INDICATORFICHE_ID")
      REFERENCES  "INDICATORFICHE" ("INDICATORFICHE_ID") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "TREFWOORD_FICHE" ADD CONSTRAINT "TREFWOORD_REF_FK" FOREIGN KEY ("REFERENTIE_ID")
      REFERENCES  "REFERENTIE" ("REFERENTIE_ID") ENABLE
/
CREATE OR REPLACE FUNCTION  "LDAP_AUTHENTICATE" 
(p_username in VARCHAR2, p_password in VARCHAR2) 
return boolean
is
    proc_name CONSTANT logtbl.evt_proc%TYPE := 'LDAP_AUTHENTICATE';
    err_msg varchar2(255);
    invalid_credentials EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_credentials, -31202);
    l_ldap_host VARCHAR2(256) := 'ldapp.vlaanderen.be';
    l_ldap_port VARCHAR2(256) := '389';
    l_session DBMS_LDAP.session;
    l_session2 DBMS_LDAP.session;
    l_retval PLS_INTEGER; 
    l_ldap_user VARCHAR2(256) := 'uid=et_ivo21_app,ou=admins,o=vlaanderen,c=be';
    l_ldap_base VARCHAR2(256) := 'o=vlaanderen,c=be';
    l_dn VARCHAR2(256);
    l_attrs DBMS_LDAP.string_collection;
    l_message DBMS_LDAP.message;
    l_deleted_in_db VARCHAR2(1); 
    l_present_in_db VARCHAR2(1); 
    cte number;
    v_aantal number;
BEGIN
    p_log(proc_name, 'I', 'Trying to authenticate User: ' || p_username);
    if (p_password is null) then 
        p_log(proc_name, 'I', 'User : ' || p_username || ' failed to authenticate (pwd null)');
        return false;
    end if;
    DBMS_LDAP.USE_EXCEPTION := TRUE; 
    --We halen via een admin de dn van de te valideren gebruiker op.
    l_session := DBMS_LDAP.init(hostname => l_ldap_host,
                                portnum => l_ldap_port);
    l_retval := DBMS_LDAP.simple_bind_s(ld => l_session,
                                        dn => l_ldap_user,
                                        passwd => NULL);
    l_attrs(1) := 'inr';
    l_retval := DBMS_LDAP.search_s(ld => l_session, 
                                   base => l_ldap_base, 
                                   scope => DBMS_LDAP.SCOPE_SUBTREE,
                                   filter => 'uid=' || p_username,
                                   attrs => l_attrs,
                                   attronly => 1,
                                   res => l_message);
    IF DBMS_LDAP.count_entries(ld => l_session, msg => l_message) > 0 THEN 
        l_dn := DBMS_LDAP.get_dn(ld => l_session, ldapEntry => DBMS_LDAP.first_entry(ld => l_session, msg => l_message));
    ELSE
        p_log(proc_name, 'I', 'User : ' || p_username || ' failed to authenticate. (user not found)');
        return false;
    END IF;
    l_retval := DBMS_LDAP.unbind_s(ld => l_session);
    --We checken of de combinatie gebruikernaam/paswoord juist is 
    l_session := DBMS_LDAP.init(hostname => l_ldap_host,
                                portnum => l_ldap_port);
    l_retval := DBMS_LDAP.simple_bind_s(ld => l_session,
                                        dn => l_dn,
                                        passwd => p_password); 
    l_retval := DBMS_LDAP.unbind_s(ld => l_session);
-- Test of de aangelogde gebruiker gekend is in de 
-- gebruikerstabel van de toepassing 
-- deze gebruikerstabel moet kolommen LDAP en ACTIEF hebben!!
Select count(*)
into v_Aantal 
from persoon
where lower(ldap) = lower(p_username);
If v_aantal < 1 then
p_log(proc_name, 'I', 'User : ' || p_username || ' niet in persoon tabel.');
return false;
end if;
    p_log(proc_name, 'I', 'User : ' || p_username || ' successful authentication.');
    return true;
EXCEPTION
    WHEN invalid_credentials THEN
        p_log(proc_name, 'I', 'User : ' || p_username || ' invalid credentials');
        return false;

    WHEN OTHERS THEN
        l_retval := DBMS_LDAP.unbind_s(ld => l_session);
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
    RETURN false;
END;
/

CREATE OR REPLACE FUNCTION  "F_URL_RAPPORT_MAP" (indic_naam IN indicatorfiche.indicator_naam%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_url_rapport_map';
    v_host varchar2(255);
    v_indic_naam_url varchar2(500);
    v_url_host varchar2(255);
    v_url indicatorfiche.url_rapport%TYPE;
    v_prod number;
    v_url_host_prep varchar2(255) := 'https://vobip-bi-ontw.vonet.be:443';
    v_url_host_prod varchar2(255) := 'https://vobip-bi.vonet.be:443';
    v_url_p0 varchar2(500) := '/cognos10/cgi-bin/cognosisapi.dll?b_action=xts.run&m=portal/cc.xts&m_path=%2fcontent%2ffolder%5b%40name%3d%271M%20-%20Mobiliteit%20en%20Openbare%20Werken%20(MOW)%27%5d%2ffolder%5b%40name%3d%27Dataroom%27%5d%2ffolder%5b%40name%3d%27Standaardrapporten%27%5d%2ffolder%5b%40name%3d%27';
    v_url_p1 varchar2(500) := '%27%5d';
    
    err_num number;
    err_line number;
    err_msg varchar2(255);
BEGIN
    
    v_indic_naam_url := apex_util.url_encode(indic_naam);
    v_host := owa_util.get_cgi_env('HTTP_HOST');
    select instr(v_host, 'prod') into v_prod from dual;
    if v_prod > 0 then
        v_url_host := v_url_host_prod;
    else
        v_url_host := v_url_host_prep;
    end if;
    
    v_url := v_url_host || v_url_p0 || v_indic_naam_url || v_url_p1;
    
    RETURN v_url;
 
EXCEPTION
    
    WHEN OTHERS THEN
       err_msg:= SUBSTR(SQLERRM, 1, 100);
       err_num:= SQLCODE;
       err_line := $$PLSQL_LINE;
       p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
       RETURN '(geen URL - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_URL_RAPPORT" (indic_naam IN indicatorfiche.indicator_naam%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_url_rapport';
    v_host varchar2(255);
    v_indic_naam_url varchar2(500);
    v_url_host varchar2(255);
    v_url indicatorfiche.url_rapport%TYPE;
    v_prod number;
    v_url_host_prep varchar2(255) := 'https://vobip-bi-ontw.vonet.be:443';
    v_url_host_prod varchar2(255) := 'https://vobip-bi.vonet.be:443';
    v_url_p1 varchar2(500) := '/cognos10/cgi-bin/cognosisapi.dll?b_action=cognosViewer&ui.action=run&ui.object=%2fcontent%2ffolder%5b%40name%3d%271M%20-%20Mobiliteit%20en%20Openbare%20Werken%20(MOW)%27%5d%2ffolder%5b%40name%3d%27Dataroom%27%5d%2ffolder%5b%40name%3d%27Standaardrapporten%27%5d%2ffolder%5b%40name%3d%27';
    v_url_p2 varchar2(500) := '%27%5d%2freport%5b%40name%3d%27';
    v_url_p3 varchar2(500) := '%27%5d&ui.name=';
    v_url_p4 varchar2(255) := '&run.outputFormat=&run.prompt=true';
    err_num number;
    err_line number;
    err_msg varchar2(255);
BEGIN
    
    v_indic_naam_url := apex_util.url_encode(indic_naam);
    v_host := owa_util.get_cgi_env('HTTP_HOST');
    select instr(v_host, 'prod') into v_prod from dual;
    if v_prod > 0 then
        v_url_host := v_url_host_prod;
    else
        v_url_host := v_url_host_prep;
    end if;
    
    v_url := v_url_host || v_url_p1 || v_indic_naam_url || v_url_p2 || v_indic_naam_url || v_url_p3 || v_indic_naam_url || v_url_p4;
    
    RETURN v_url;
 
--EXCEPTION
    
    -- WHEN OTHERS THEN
    --   err_msg:= SUBSTR(SQLERRM, 1, 100);
    --    err_num:= SQLCODE;
    --    err_line := $$PLSQL_LINE;
    --    p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
    --    RETURN '(geen URL - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_URL_INVOER_HTML" (f_indic_id IN indicatorfiche.indicatorfiche_id%TYPE,
                                              f_geografische_info IN indicatorfiche.geografische_info%TYPE)
RETURN varchar2
IS
    -- This procedure will calculate the link to Cijferrecord /Geo Report invoer
    -- We cannot use the url_invoer field since it does not contain the (dynamic) session ID.
    -- As a result you are forced to log again on each URL selection.
    proc_name logtbl.evt_proc%TYPE := 'f_url_invoer_html';
    v_host varchar2(255);
    v_script varchar2(255);
    v_applid number;
    v_session number;
    v_page number;
    v_itemname varchar2(255);
    v_url varchar2(4000);
    v_res varchar2(4000);
    v_target varchar2(45);
    err_msg varchar2(255);
BEGIN
    
    v_host := owa_util.get_cgi_env('HTTP_HOST');
    v_script := owa_util.get_cgi_env('SCRIPT_NAME');
    v_applid := NV('APP_ID');
    v_session := NV('SESSION');
    IF upper(f_geografische_info) = 'J' THEN
        v_page := 36;
        v_target := 'Geo Rapport';
    ELSE
        v_page := 28; -- will this remain unchanged across application migration apexprep-apexprod?
        v_target := 'Cijferrecords';
    END IF;
    v_itemname := 'P' || v_page || '_INDICATORFICHE_ID';
    v_url := 'https://' || v_host || v_script || '/f?p=' || v_applid || ':' || v_page || ':' || v_session || '::NO::' ||
             v_itemname || ':' || f_indic_id;
    v_res := '<a href="' || v_url || '">' || v_target || '</a>';
    
    RETURN v_res;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN '(geen URL - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_URL_INVOER" (f_indic_id IN indicatorfiche.indicatorfiche_id%TYPE,
                                            f_geografische_info IN indicatorfiche.geografische_info%TYPE DEFAULT 'N')
RETURN varchar2
IS
    -- This script sets the URL for cijferrecord input or Geografische informatie Input
    -- depending on the setting of the field 'geografische_info'.
    proc_name logtbl.evt_proc%TYPE := 'f_url_invoer';
    v_host varchar2(255);
    v_script varchar2(255);
    v_applid number;
    v_page number;
    v_itemname varchar2(255);
    v_url varchar2(4000);
    err_msg varchar2(255);
BEGIN
    
    v_host := owa_util.get_cgi_env('HTTP_HOST');
    v_script := owa_util.get_cgi_env('SCRIPT_NAME');
    v_applid := NV('APP_ID');
    IF (upper(f_geografische_info) = 'N') THEN
        v_page := 28; -- will this remain unchanged across application migration apexprep-apexprod?
    ELSE
        v_page := 36;
    END IF;
    v_itemname := 'P' || to_char(v_page) || '_INDICATORFICHE_ID';
    v_url := 'https://' || v_host || v_script || '/f?p=' || v_applid || ':' || v_page || ':::NO::' ||
             v_itemname || ':' || f_indic_id;
    
    RETURN v_url;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN '(geen URL - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_SLEUTEL" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_sleutel';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    sleutel varchar2(500);
    
    indic_naam indicatorfiche.indicator_naam%TYPE;
    org_id indicatorfiche.aanspreekorganisatie_id%TYPE;
    org_naam varchar2(255);
BEGIN
    
    SELECT indicator_naam, aanspreekorganisatie_id INTO indic_naam, org_id
    FROM indicatorfiche
    WHERE indicatorfiche_id = indic_id;
    org_naam := f_organisatie(org_id);
    sleutel := org_naam || ' * ' || indic_naam;
    RETURN sleutel;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        p_log(proc_name, 'E', 'Geen indicatorfiche gevonden voor ' || indic_id);
        RETURN '(geen sleutel)';
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(geen sleutel - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_SHOW_AANSPREEKORGANISATIE" (f_indicatorfiche_id IN indicatorfiche.indicatorfiche_id%TYPE)
    RETURN boolean
    IS
    proc_name logtbl.evt_proc%TYPE := 'f_show_aanspreekorganisatie';
    err_msg varchar2(255);
    v_aanspreekpersoon_id rol.persoon_id%TYPE;
    cursor aanspreekpersoon_cursor IS
        SELECT persoon_id
        FROM rol
        WHERE type = 'Aanspreekpunt'
        AND indicatorfiche_id = f_indicatorfiche_id;
    PROCEDURE ip_reset_aanspreekorganisatie 
        IS
        
        v_aanspreekorganisatie_id indicatorfiche.aanspreekorganisatie_id%TYPE;
        v_query varchar2(255);
        
        cursor aanspreekorganisatie_cursor IS
            SELECT aanspreekorganisatie_id
            FROM indicatorfiche
            WHERE indicatorfiche_id = f_indicatorfiche_id
            AND aanspreekorganisatie_id > -1;
    BEGIN
        OPEN aanspreekorganisatie_cursor;
        FETCH aanspreekorganisatie_cursor INTO v_aanspreekorganisatie_id;
        IF aanspreekorganisatie_cursor%NOTFOUND THEN
            -- OK, id already set to -1, nothing left to do...
            RETURN;
        ELSE
            v_query := 'UPDATE INDICATORFICHE SET aanspreekorganisatie_id = -1 WHERE indicatorfiche_id = ' || f_indicatorfiche_id;
            EXECUTE IMMEDIATE v_query;
        END IF;
    END;
BEGIN
    
    OPEN aanspreekpersoon_cursor;
    FETCH aanspreekpersoon_cursor INTO v_aanspreekpersoon_id;
    IF aanspreekpersoon_cursor%NOTFOUND THEN
        -- Do not reset the aanspreekorganisatie.
        --ip_reset_aanspreekorganisatie;
        RETURN FALSE;
    END IF;
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        -- not sure what happened, so show the 'aanspreekorganisatie'.
        RETURN TRUE;
END;
/

CREATE OR REPLACE FUNCTION  "F_SEC2NUMBER" (v_username IN persoon.ldap%TYPE, v_indic_id IN indicator_report.indicatorfiche_id%TYPE)
RETURN number
IS
    -- The purpose of this function is to convert boolean true/false into 1/0 so that
    -- the outcome can be used in a SELECT statement.
    proc_name logtbl.evt_proc%TYPE := 'f_sec2number';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    
BEGIN
    
    if f_sec(v_username, v_indic_id) then
        return 1;
    else
        return 0;
    end if;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION  "F_SEC" (username IN varchar2, indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN BOOLEAN
IS
    proc_name logtbl.evt_proc%TYPE := 'f_sec';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    pers_id persoon.persoon_id%TYPE;
    cnt_drb number;
BEGIN
    
    -- First get the persoon_id
    SELECT persoon_id INTO pers_id
        FROM persoon
        WHERE ldap = lower(username);
    
    -- Then check if user is 'Dataroom Beheerder'
    -- In this case the user is allowed to do everything.
    -- Use 'count' to avoid ERROR when no records are found.
    -- Dataroom beheerder is defined in table apex_access_control
    SELECT count(admin_username) INTO cnt_drb
        FROM apex_access_control
        WHERE lower(admin_username) = lower(username);
    
    IF (cnt_drb > 0) THEN
        RETURN TRUE;
    END IF;
    
    -- Finally check if persoon is indicator beheerder for this indicator
    SELECT persoon_id INTO cnt_drb
        FROM rol
        WHERE persoon_id = pers_id
        AND indicatorfiche_id = indic_id
        AND type = 'Indicator Beheerder';
    
    -- If no record found, the NO_DATA_FOUND exception is called
    -- If record is  found, the user is beheerder for this indicatorfiche.
    RETURN TRUE;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN FALSE;
END;
/

CREATE OR REPLACE FUNCTION  "F_REFERENTIELABEL" (label_id IN referentie.referentie_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_referentielabel';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    label varchar2(255);
BEGIN
    
    select waarde into label
    from referentie
    where referentie_id = label_id;
        
    RETURN label;
    
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        RETURN '(' || label_id || ' niet gedefinieerd)';
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(niet gedefinieerd - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_PERIODE_SCHOOLJAAR" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN boolean
IS
    proc_name logtbl.evt_proc%TYPE := 'f_periode_label';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    freq indicatorfiche.meetfrequentie%TYPE;
BEGIN
    select meetfrequentie into freq
    from indicatorfiche
    where indicatorfiche_id = indic_id;
        
    if (freq = 'schooljaar') then
        RETURN TRUE;
    else
        RETURN FALSE;
    end if;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        p_log(proc_name, 'E', 'No indicatorfiche found exception for ' || indic_id);
        RETURN TRUE;
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN TRUE;
END;
/

CREATE OR REPLACE FUNCTION  "F_PERIODE_LABEL" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN boolean
IS
    proc_name logtbl.evt_proc%TYPE := 'f_periode_label';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    freq indicatorfiche.meetfrequentie%TYPE;
BEGIN
    select meetfrequentie into freq
    from indicatorfiche
    where indicatorfiche_id = indic_id;
        
    if ((freq = 'maand') OR (freq = 'kwartaal')) then
        RETURN TRUE;
    else
        RETURN FALSE;
    end if;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        p_log(proc_name, 'E', 'No indicatorfiche found exception for ' || indic_id);
        RETURN TRUE;
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN TRUE;
END;
/

CREATE OR REPLACE FUNCTION  "F_PERIODE_JAAR" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN boolean
IS
    proc_name logtbl.evt_proc%TYPE := 'f_periode_label';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    freq indicatorfiche.meetfrequentie%TYPE;
BEGIN
    select meetfrequentie into freq
    from indicatorfiche
    where indicatorfiche_id = indic_id;
        
    if (freq = 'schooljaar') then
        RETURN FALSE;
    else
        RETURN TRUE;
    end if;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        p_log(proc_name, 'E', 'No indicatorfiche found exception for ' || indic_id);
        RETURN TRUE;
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN TRUE;
END;
/

CREATE OR REPLACE FUNCTION  "F_ORGANISATIE" (org_id IN organisatie.organisatie_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_organisatie';
    w_entiteit referentie.waarde%TYPE;
    w_afdeling referentie.waarde%TYPE;
    err_num number;
    err_line number;
    err_msg varchar2(255);
    volledige_org varchar2(255);
BEGIN
    
    select a.waarde entiteit, b.waarde afdeling into w_entiteit, w_afdeling
    from organisatie, referentie a, referentie b
    where organisatie_id = org_id
    and a.referentie_id = entiteit 
    and b.referentie_id = afdeling;
    volledige_org := w_entiteit || ' - ' || w_afdeling;
        
    RETURN volledige_org;
    
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        RETURN '(geen organisatie)';
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(geen organisatie - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_NAAM_PLUS" (naam_id IN persoon.persoon_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_naam';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    volledige_naam varchar2(255);
    em persoon.email%TYPE;
    org_id persoon.organisatie_id%TYPE;
    org varchar2(255);
BEGIN
    
    select (voornaam || ' ' || naam) full_name, email, organisatie_id into volledige_naam, em, org_id
    from persoon
    where persoon_id = naam_id;
    org := f_organisatie(org_id);
        
    RETURN volledige_naam || ' * ' || em || ' * ' || org;
    
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        RETURN '(geen naam)';
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(geen naam - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_NAAM" (naam_id IN persoon.persoon_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_naam';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    volledige_naam varchar2(255);
BEGIN
    
    select (voornaam || ' ' || naam) full_name into volledige_naam
    from persoon
    where persoon_id = naam_id;
        
    RETURN volledige_naam;
    
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        RETURN '(geen naam)';
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(geen naam - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_JN_AANTAL" (JN IN varchar2)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_jn_aantal';
    err_num number;
    err_line number;
    err_msg varchar2(255);
BEGIN
    IF (lower(JN) = 'j') THEN
        RETURN 'Aantal';
    ELSIF (lower(JN) = 'n') THEN
        RETURN 'Percentage';
    ELSE
        p_log(proc_name, 'E', 'Ja / Neen (aantal/percentage) kan niet vertaald worden: ' || JN);
        RETURN '(zie log)';
    END IF;
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(geen naam - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_JN" (JN IN varchar2)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_jn';
    err_num number;
    err_line number;
    err_msg varchar2(255);
BEGIN
    IF (lower(JN) = 'j') THEN
        RETURN 'Ja';
    ELSIF (lower(JN) = 'n') THEN
        RETURN 'Neen';
    ELSE
        p_log(proc_name, 'E', 'Ja / Neen kan niet vertaald worden: ' || JN);
        RETURN '(zie log)';
    END IF;
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(geen naam - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_IND_TREFWOORDEN" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_ind_trefwoorden';
    cursor tw_cursor is
    select waarde 
    from trefwoord_fiche t, referentie r
    where t.indicatorfiche_id = indic_id
      and r.referentie_id     = t.referentie_id
    order by waarde;
    err_num number;
    err_line number;
    err_msg varchar2(255);
    tw referentie.waarde%TYPE;
    tw_str varchar2(4000) := '';
BEGIN
    
    OPEN tw_cursor;
    LOOP
        FETCH tw_cursor INTO tw;
        EXIT WHEN tw_cursor%NOTFOUND;
        tw_str := tw_str || tw || CHR(10);
    END LOOP;
    RETURN tw_str;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(geen info gevonden - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_INDIC_NAAM" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_indic_naam';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    indic_naam indicatorfiche.indicator_naam%TYPE;
BEGIN
    select indicator_naam into indic_naam
    from indicatorfiche
    where indicatorfiche_id = indic_id;
        
    RETURN indic_naam;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        p_log(proc_name, 'E', 'No indicatorfiche found exception for ' || indic_id);
        RETURN '(' || indic_id || ' geen info gevonden)';
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(' || indic_id || ' geen info gevonden - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_INDIC_AANTAL" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN boolean
IS
    proc_name logtbl.evt_proc%TYPE := 'f_indic_aantal';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    aantal_of_perc indicatorfiche.aantal_percentage%TYPE;
BEGIN
    select aantal_percentage into aantal_of_perc
    from indicatorfiche
    where indicatorfiche_id = indic_id;
        
    if (aantal_of_perc = 'J') then
        RETURN TRUE;
    else
        RETURN FALSE;
    end if;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        p_log(proc_name, 'E', 'No indicatorfiche found exception for ' || indic_id);
        RETURN TRUE;
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN TRUE;
END;
/

CREATE OR REPLACE FUNCTION  "F_IND_GEPUBL" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_ind_gepubl';
    cursor tw_cursor is
    select waarde 
    from gepubliceerd_fiche t, referentie r
    where t.indicatorfiche_id = indic_id
      and r.referentie_id     = t.referentie_id
    order by waarde;
    err_num number;
    err_line number;
    err_msg varchar2(255);
    tw referentie.waarde%TYPE;
    tw_str varchar2(4000) := '';
BEGIN
    
    OPEN tw_cursor;
    LOOP
        FETCH tw_cursor INTO tw;
        EXIT WHEN tw_cursor%NOTFOUND;
        tw_str := tw_str || tw || CHR(10);
    END LOOP;
    RETURN tw_str;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(geen info gevonden - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_IND_DIM" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_ind_dim';
    cursor dim_cursor is
    select waarde 
    from dimensie d, dimensie_fiche f
    where f.fiche_id = indic_id
      and f.dimensie_id = d.dimensie_id
    order by waarde;
    err_num number;
    err_line number;
    err_msg varchar2(255);
    dim dimensie.waarde%TYPE;
    dim_str varchar2(4000) := '';
BEGIN
    
    OPEN dim_cursor;
    LOOP
        FETCH dim_cursor INTO dim;
        EXIT WHEN dim_cursor%NOTFOUND;
        dim_str := dim_str || dim || CHR(10);
    END LOOP;
    RETURN dim_str;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(geen info gevonden - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_IND_BELEIDDOCS" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_ind_beleiddocs';
    cursor tw_cursor is
    select doc.titel, doel.toc, doel.titel
    from document_fiche f, beleidsdocument doel, beleidsdocument doc
    where f.indicatorfiche_id  = indic_id
      and f.beleidsdocument_id = doel.beleidsdocument_id
      and doel.doc_id = doc.beleidsdocument_id
    order by doc.titel, doel.titel;
    TYPE tw_record IS RECORD (
        doc_titel beleidsdocument.titel%TYPE,
        doel_toc beleidsdocument.toc%TYPE,
        doel_titel beleidsdocument.titel%TYPE);
    tw tw_record;
    tw_str varchar2(4000) := '';
    err_msg varchar2(255);
BEGIN
    
    OPEN tw_cursor;
    LOOP
        FETCH tw_cursor INTO tw;
        EXIT WHEN tw_cursor%NOTFOUND;
        tw_str := tw_str || tw.doc_titel || ' - ' || tw.doel_toc || ' ' || tw.doel_titel || CHR(10);
    END LOOP;
    RETURN tw_str;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN '(geen info gevonden - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_IND_BEHEERDERS" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE, beh_type IN rol.type%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_ind_beheerders';
    cursor beh_cursor is
    select p.persoon_id 
    from persoon p, rol r
    where r.indicatorfiche_id = indic_id
      and r.persoon_id        = p.persoon_id
      and type                = beh_type
    order by naam;
    err_num number;
    err_line number;
    err_msg varchar2(255);
    beh_id persoon.persoon_id%TYPE;
    beh_str varchar2(4000) := '';
BEGIN
    
    OPEN beh_cursor;
    LOOP
        FETCH beh_cursor INTO beh_id;
        EXIT WHEN beh_cursor%NOTFOUND;
        beh_str := beh_str || f_naam(beh_id) || CHR(10);
    END LOOP;
    RETURN beh_str;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(geen info gevonden - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_GROEP_STATUSLIJST" (f_geo_groep_id IN geo_groep.geo_groep_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_groep_statuslijst';
    cursor status_cursor is
        select waarde 
        from geo_status
        where geo_groep_id = f_geo_groep_id
        order by waarde;
    err_msg varchar2(255);
    v_waarde geo_status.waarde%TYPE;
    v_waarde_str varchar2(4000) := '';
BEGIN
    
    OPEN status_cursor;
    LOOP
        FETCH status_cursor INTO v_waarde;
        EXIT WHEN status_cursor%NOTFOUND;
        v_waarde_str := v_waarde_str || v_waarde || CHR(10);
    END LOOP;
    RETURN v_waarde_str;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN '(geen info gevonden - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_GROEP_OBJECTEN" (f_geo_groep_id IN geo_groep.geo_groep_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_groep_objecten';
    cursor object_cursor is
        select naam 
        from geo_object_groep g, geo_object o
        where g.geo_groep_id = f_geo_groep_id
        and o.geo_object_id = g.geo_object_id
        order by naam;
    err_msg varchar2(255);
    v_naam geo_object.naam%TYPE;
    v_naam_str varchar2(4000) := '';
BEGIN
    
    OPEN object_cursor;
    LOOP
        FETCH object_cursor INTO v_naam;
        EXIT WHEN object_cursor%NOTFOUND;
        v_naam_str := v_naam_str || v_naam || CHR(10);
    END LOOP;
    RETURN v_naam_str;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN '(geen info gevonden - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_GROEP_INDICATOREN" (f_geo_groep_id IN geo_groep.geo_groep_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_groep_indicatoren';
    cursor indic_cursor is
        select indicator_naam 
        from geo_groep_fiche g, indicatorfiche i
        where g.geo_groep_id = f_geo_groep_id
        and i.indicatorfiche_id = g.indicatorfiche_id
        order by indicator_naam;
    err_msg varchar2(255);
    v_indicator_naam indicatorfiche.indicator_naam%TYPE;
    v_indic_str varchar2(4000) := '';
BEGIN
    
    OPEN indic_cursor;
    LOOP
        FETCH indic_cursor INTO v_indicator_naam;
        EXIT WHEN indic_cursor%NOTFOUND;
        v_indic_str := v_indic_str || v_indicator_naam || CHR(10);
    END LOOP;
    RETURN v_indic_str;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN '(geen info gevonden - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_GROEP_INDICATOR" (f_geo_groep_id IN geo_groep.geo_groep_id%TYPE)
RETURN boolean
IS
    -- This procedure will check if at least one indicatorfiche is assigned to the groep.
    -- An indicatorfiche needs to be assigned to understand the dimensies that need to be filled in in the geo_object.
    proc_name logtbl.evt_proc%TYPE := 'f_groep_indicator';
    err_msg varchar2(255);
    v_count number;
    
BEGIN
    
    SELECT count(*) INTO v_count
    FROM geo_groep_fiche
    WHERE geo_groep_id = f_geo_groep_id;
    IF v_count = 0 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
        
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN FALSE;
END;
/

CREATE OR REPLACE FUNCTION  "F_GET_DOC_TITEL" (beleidsdoc_id IN beleidsdocument.beleidsdocument_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_get_doc_titel';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    w_titel beleidsdocument.titel%TYPE;
    
BEGIN
    
    select b.titel into w_titel
    from beleidsdocument a, beleidsdocument b
    where a.beleidsdocument_id = beleidsdoc_id
    and b.doc_id = a.doc_id
    and b.parent_id = -1;
    
    RETURN w_titel;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(geen info gevonden - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_EPOCH_TO_DATE" ( p_epoch in number)
return date
is 
begin
   return to_date('1904-01-01', 'YYYY-MM-DD') + p_epoch; 
end;
/

CREATE OR REPLACE FUNCTION  "F_EL" (el_id IN dim_element.dim_element_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_el';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    el_naam dim_element.waarde%TYPE;
BEGIN
    select waarde into el_naam
    from dim_element
    where dim_element_id = el_id;
        
    RETURN el_naam;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        RETURN '';
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(' || el_id || ' zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_DIMENSION4INDICATOR" (dim_id IN dimensie.dimensie_id%TYPE, indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN boolean
IS
    proc_name logtbl.evt_proc%TYPE := 'f_dimension4indicator';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    dim_fiche_id dimensie_fiche.dimensie_fiche_id%TYPE;
BEGIN
    select dimensie_fiche_id into dim_fiche_id
    from dimensie_fiche
    where dimensie_id = dim_id
    and fiche_id = indic_id;
        
    RETURN TRUE;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN FALSE;
END;
/

CREATE OR REPLACE FUNCTION  "F_DIMENSION4GROUP" (f_dim_id IN dimensie.dimensie_id%TYPE, f_geo_groep_id IN geo_groep.geo_groep_id%TYPE)
RETURN boolean
IS
    -- This function returns TRUE if geo groep has this dimension via one or more indicators, false otherwise.
    -- Used to understand which columns need to be displayed.
    proc_name logtbl.evt_proc%TYPE := 'f_dimension4group';
    err_msg varchar2(255);
    
    v_count number;
BEGIN
    select count(*) into v_count
    from geo_groep_fiche g, dimensie_fiche d
    where g.geo_groep_id = f_geo_groep_id
    and d.dimensie_id = f_dim_id
    and g.indicatorfiche_id = d.fiche_id;
    IF v_count > 0 THEN     
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN FALSE;
END;
/

CREATE OR REPLACE FUNCTION  "F_DIMENSIE" (dim_id IN dimensie.dimensie_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_dimensie';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    label varchar2(255);
BEGIN
    
    select waarde into label
    from dimensie
    where dimensie_id = dim_id;
        
    RETURN label;
    
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        RETURN '(' || dim_id || ' niet gedefinieerd)';
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(niet gedefinieerd - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_DATE_TO_EPOCH" (in_datum in date)
return number
is 
begin
    return trunc(in_datum) - to_date('1904-01-01', 'YYYY-MM-DD'); 
end;
/

CREATE OR REPLACE FUNCTION  "F_DAGNR_PERIODE" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE,
                                            v_dagnr IN indicator_report.dagnr%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_dagnr_periode';
    periode_lbl varchar2(100);
    periode indicatorfiche.meetfrequentie%TYPE;
    err_num number;
    err_line number;
    err_msg varchar2(255);
BEGIN
    
    select meetfrequentie into periode
    from indicatorfiche
    where indicatorfiche_id = indic_id;
    if (lower(periode) = 'jaar') THEN
        select to_char(jaar) into periode_lbl
        from frequenties
        where dagnr = v_dagnr;
    elsif (lower(periode) = 'schooljaar') THEN
        select schooljaar_label into periode_lbl
        from frequenties
        where dagnr = v_dagnr;
    elsif (lower(periode) = 'maand') THEN
        select to_char(jaar) || '-' || to_char(maandnr, '09') into periode_lbl
        from frequenties 
        where dagnr = v_dagnr;
    elsif (lower(periode) = 'kwartaal') THEN 
            select to_char(jaar) || ' ' || kwartaal into periode_lbl 
        from frequenties 
        where dagnr = v_dagnr;
    end if;
    RETURN periode_lbl;
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '';
END;
/

CREATE OR REPLACE FUNCTION  "F_DAGNR_LBL" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE,
                                        v_dagnr IN indicator_report.dagnr%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_dagnr_lbl';
    lbl    frequenties.maand%TYPE;  -- lbl is kwartaal of maand, afhankelijk van de meetfrequentie.
    periode indicatorfiche.meetfrequentie%TYPE;
    err_num number;
    err_line number;
    err_msg varchar2(255);
BEGIN
    
    select meetfrequentie into periode
    from indicatorfiche
    where indicatorfiche_id = indic_id;
    if (lower(periode) = 'maand') THEN
        select maand into lbl 
        from frequenties 
        where dagnr = v_dagnr;
    elsif (lower(periode) = 'kwartaal') THEN 
        select kwartaal into lbl 
        from frequenties 
        where dagnr = v_dagnr;
    end if;
    RETURN lbl;
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '';
END;
/

CREATE OR REPLACE FUNCTION  "F_CREATE_CSV_LOAD" (p_filename IN varchar2)
RETURN BOOLEAN
IS
    proc_name logtbl.evt_proc%TYPE := 'f_create_csv_load';
    err_msg varchar2(255);
    v_query varchar2(1000);
    
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    v_query := 'create table csv_load 
                (indicatorfiche_id number,
                 naam varchar2(255), 
                 aantal number,  
                 percentage number,
                 jaar number,
                 kwartaal number,
                 maand number,
                 entiteit varchar2(255),
                 type_medewerker varchar2(255))
                organization external
                (type oracle_loader
                 default directory "DATAROOM_IN"
                 access parameters
                 (records delimited by newline
                  skip 1
                  fields terminated by ";"
                  missing field values are null)
                 location (''' || lower(p_filename) || '''))
                 reject limit unlimited';
    p_log(proc_name, 'T', v_query);
    EXECUTE IMMEDIATE v_query;
    p_log(proc_name, 'I', 'End Application');
    RETURN TRUE; 
    
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN FALSE;
        
END;
/

CREATE OR REPLACE FUNCTION  "F_COMM_LAATST_BIJGEWERKT" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_comm_laatst_bijgewerkt';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    last_upd varchar2(50);
BEGIN
    SELECT to_char(max(laatst_bijgewerkt), 'DD-MON-YYYY HH24:MI:SS') INTO last_upd
    FROM commentaar
    WHERE indicatorfiche_id = indic_id;
    RETURN last_upd;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        RETURN '';
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN '(zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_CIJFERS_LAATST_BIJGEWERKT" (f_indic_id IN indicatorfiche.indicatorfiche_id%TYPE,
                                                           f_geografische_info IN indicatorfiche.geografische_info%TYPE DEFAULT 'N')
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_cijfers_laatst_bijgewerkt';
    err_msg varchar2(255);
    last_upd varchar2(50);
BEGIN
    IF upper(f_geografische_info) = 'N' THEN
        SELECT to_char(max(laatst_bijgewerkt), 'DD-MON-YYYY HH24:MI:SS') INTO last_upd
            FROM indicator_report
            WHERE indicatorfiche_id = f_indic_id;
            RETURN last_upd;
    ELSE 
        SELECT to_char(max(laatst_bijgewerkt), 'DD-MON-YYYY HH24:MI:SS') INTO last_upd
            FROM geo_report
            WHERE indicatorfiche_id = f_indic_id;
            RETURN last_upd;       
    END IF;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        RETURN '';
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN '(zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_CALC_DAGNR" (indic_id IN indicatorfiche.indicatorfiche_id%TYPE,
                                         period_str IN varchar2)
RETURN number
IS
    proc_name logtbl.evt_proc%TYPE := 'f_calc_dagnr';
    l_vc_arr2 APEX_APPLICATION_GLOBAL.VC_ARR2;
    sch_yr frequenties.schooljaar_label%TYPE;
    yr     frequenties.jaar%TYPE;
    lbl    frequenties.maand%TYPE;  -- lbl is kwartaal of maand, afhankelijk van de meetfrequentie.
    periode indicatorfiche.meetfrequentie%TYPE;
    dagnr indicator_report.dagnr%TYPE;
    err_num number;
    err_line number;
    err_msg varchar2(255);
BEGIN
    
    l_vc_arr2 := APEX_UTIL.STRING_TO_TABLE(period_str, '*');
    sch_yr := l_vc_arr2(1);
    yr := l_vc_arr2(2);
    lbl := l_vc_arr2(3);
    select meetfrequentie into periode
    from indicatorfiche
    where indicatorfiche_id = indic_id;
    if (lower(periode) = 'jaar') THEN
        select min(dagnr) into dagnr 
        from frequenties 
        where jaar = yr;
    elsif (lower(periode) = 'schooljaar') THEN
        select min(dagnr) into dagnr 
        from frequenties 
        where schooljaar_label = sch_yr;
    elsif (lower(periode) = 'maand') THEN
        select min(dagnr) into dagnr 
        from frequenties 
        where jaar = yr
        and maand = lbl;
    elsif (lower(periode) = 'kwartaal') THEN 
        select min(dagnr) into dagnr 
        from frequenties 
        where jaar = yr
        and kwartaal = lbl;
    else
        p_log(proc_name, 'E', 'Meetfrequentie niet gedefinieerd: ' || periode);
        RETURN 27759;      -- Return 1/01/1980, because this is a foreign key that needs to be defined
    end if;
    RETURN dagnr;
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN 27759;      -- Return 1/01/1980, because this is a foreign key that needs to be defined
END;
/

CREATE OR REPLACE FUNCTION  "F_BELEIDDOC_IND" (f_beleidsdocument_id IN beleidsdocument.beleidsdocument_id%TYPE)
RETURN varchar2
IS
    proc_name logtbl.evt_proc%TYPE := 'f_beleiddoc_ind';
    cursor tw_cursor is
    select i.indicator_naam
        from document_fiche b, indicatorfiche i
        where b.beleidsdocument_id = f_beleidsdocument_id
        and b.indicatorfiche_id = i.indicatorfiche_id
        order by i.indicator_naam;
    v_indicator_naam indicatorfiche.indicator_naam%TYPE;
    tw_str varchar2(32767) := '';
    err_msg varchar2(255);
BEGIN
    
    OPEN tw_cursor;
    LOOP
        FETCH tw_cursor INTO v_indicator_naam;
        EXIT WHEN tw_cursor%NOTFOUND;
        tw_str := tw_str || v_indicator_naam || '<br>';
    END LOOP;
    RETURN tw_str;
 
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN '(geen info gevonden - zie log)';
END;
/

CREATE OR REPLACE FUNCTION  "F_AUTH_FOR_TEST" (p_username IN varchar2, p_password IN varchar2)
RETURN BOOLEAN
IS
    proc_name logtbl.evt_proc%TYPE := 'f_auth_for_test';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    l_user persoon.ldap%TYPE;
BEGIN
    
    p_log(proc_name, 'I', 'Trying to authenticate user: ' || p_username);
    SELECT ldap INTO l_user
    FROM persoon
    WHERE ldap = lower(p_username);
    p_log(proc_name, 'I', 'Authenticated user: ' || p_username);
    RETURN TRUE;
EXCEPTION
    
    WHEN NO_DATA_FOUND THEN
        p_log(proc_name, 'I', 'Could not find user: ' || p_username);
        RETURN FALSE;
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        RETURN FALSE;
END;
/

CREATE UNIQUE INDEX  "AANT_PK" ON  "AANT" ("INDICATORFICHE_ID")
/
CREATE UNIQUE INDEX  "APEX_ACCESS_CONTROL_PK" ON  "APEX_ACCESS_CONTROL" ("ID")
/
CREATE UNIQUE INDEX  "APEX_ACCESS_CONTROL_UK" ON  "APEX_ACCESS_CONTROL" ("ADMIN_USERNAME", "SETUP_ID")
/
CREATE UNIQUE INDEX  "APEX_ACCESS_SETUP_PK" ON  "APEX_ACCESS_SETUP" ("ID")
/
CREATE UNIQUE INDEX  "APEX_ACCESS_SETUP_UK" ON  "APEX_ACCESS_SETUP" ("APPLICATION_ID")
/
CREATE UNIQUE INDEX  "BELEIDSDOCUMENT_PK" ON  "BELEIDSDOCUMENT" ("BELEIDSDOCUMENT_ID")
/
CREATE UNIQUE INDEX  "COMMENTAAR_PK" ON  "COMMENTAAR" ("COMMENTAAR_ID")
/
CREATE UNIQUE INDEX  "COMM_LOAD_PK" ON  "COMM_LOAD" ("COMM_LOAD_ID")
/
CREATE UNIQUE INDEX  "CSV_FILES_PK" ON  "CSV_FILES" ("CSV_FILES_ID")
/
CREATE UNIQUE INDEX  "CSV_LOAD_PK" ON  "CSV_LOAD" ("CSV_LOAD_ID")
/
CREATE UNIQUE INDEX  "DIMENSIE_FICHE_PK" ON  "DIMENSIE_FICHE" ("DIMENSIE_FICHE_ID")
/
CREATE UNIQUE INDEX  "DIMENSIE_PK" ON  "DIMENSIE" ("DIMENSIE_ID")
/
CREATE UNIQUE INDEX  "DIM_ELEMENT_PK" ON  "DIM_ELEMENT" ("DIM_ELEMENT_ID")
/
CREATE UNIQUE INDEX  "DOCUMENT_FICHE_PK" ON  "DOCUMENT_FICHE" ("DOCUMENT_FICHE_ID")
/
CREATE UNIQUE INDEX  "FILE_OBJECT_PK" ON  "FILE_OBJECT" ("FILE_OBJECT_ID")
/
CREATE UNIQUE INDEX  "FILE_PROCESS_PK" ON  "FILE_PROCESS" ("FILE_PROCESS_ID")
/
CREATE UNIQUE INDEX  "FREQUENTIES_PK" ON  "FREQUENTIES" ("DAGNR")
/
CREATE UNIQUE INDEX  "GEO_COORDINATEN_PK" ON  "GEO_COORDINATEN" ("GEO_COORDINATEN_ID")
/
CREATE UNIQUE INDEX  "GEO_GROEP_FICHE_PK" ON  "GEO_GROEP_FICHE" ("GEO_GROEP_FICHE_ID")
/
CREATE UNIQUE INDEX  "GEO_GROEP_PK" ON  "GEO_GROEP" ("GEO_GROEP_ID")
/
CREATE UNIQUE INDEX  "GEO_OBJECT_GROEP_PK" ON  "GEO_OBJECT_GROEP" ("GEO_OBJECT_GROEP_ID")
/
CREATE UNIQUE INDEX  "GEO_OBJECT_PK" ON  "GEO_OBJECT" ("GEO_OBJECT_ID")
/
CREATE UNIQUE INDEX  "GEO_REPORT_PK" ON  "GEO_REPORT" ("GEO_REPORT_ID")
/
CREATE UNIQUE INDEX  "GEO_STATUS_PK" ON  "GEO_STATUS" ("GEO_STATUS_ID")
/
CREATE UNIQUE INDEX  "GEPUBLICEERD_FICHE_PK" ON  "GEPUBLICEERD_FICHE" ("GEPUBLICEERD_FICHE_ID")
/
CREATE UNIQUE INDEX  "INDICATORFICHE_PK" ON  "INDICATORFICHE" ("INDICATORFICHE_ID")
/
CREATE UNIQUE INDEX  "INDICATOR_REPORT_PK" ON  "INDICATOR_REPORT" ("INDICATOR_REPORT_ID")
/
CREATE UNIQUE INDEX  "LOGTBL_PK" ON  "LOGTBL" ("EVT_IDX")
/
CREATE UNIQUE INDEX  "ORGANISATIE_PK" ON  "ORGANISATIE" ("ORGANISATIE_ID")
/
CREATE UNIQUE INDEX  "PERSOON_PK" ON  "PERSOON" ("PERSOON_ID")
/
CREATE UNIQUE INDEX  "REFERENTIE_PK" ON  "REFERENTIE" ("REFERENTIE_ID")
/
CREATE UNIQUE INDEX  "ROL_PK" ON  "ROL" ("ROL_ID")
/
CREATE UNIQUE INDEX  "TREFWOORD_FICHE_PK" ON  "TREFWOORD_FICHE" ("TREFWOORD_FICHE_ID")
/
CREATE OR REPLACE PACKAGE  "STRING_FNC" 
IS 
 
TYPE t_array IS TABLE OF VARCHAR2(255) 
   INDEX BY BINARY_INTEGER; 
 
FUNCTION SPLIT (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array; 
 
FUNCTION SPLIT_ARRAY (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array;
 
END;
/
CREATE OR REPLACE PACKAGE BODY  "STRING_FNC" 
IS 
 
   FUNCTION SPLIT (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array  
   IS 
    -- This is the special split function removing the last character from line read from file.
    
      i       number :=0; 
      pos     number :=0; 
      lv_str  varchar2(1024) := p_in_string;
 
      strings t_array; 
    
   BEGIN
       
      -- First strip last character from the  string
      lv_str := substr(lv_str, 1, length(lv_str)-1);
      -- Then add delimiter 
      lv_str := lv_str || p_delim;
      -- p_log('string_fnc', 'I', 'This is the string: *' || lv_str || '*');
       
      -- determine first chuck of string   
      pos := instr(lv_str,p_delim,1,1); 
    
      -- while there are chunks left, loop  
      WHILE ( pos != 0) LOOP 
          
         -- increment counter  
         i := i + 1; 
          
         -- create array element for chuck of string  
         strings(i) := substr(lv_str,1,pos-1); 
          
         -- remove chunk from string  
         lv_str := substr(lv_str,pos+1,length(lv_str)); 
          
         -- determine next chunk  
         pos := instr(lv_str,p_delim,1,1); 
         
         IF pos = 0 THEN 
         
             strings(i+1) := lv_str; 
          
         END IF; 
       
      END LOOP; 
    
      -- return array  
      RETURN strings; 
       
   END SPLIT; 
 
   FUNCTION SPLIT_ARRAY (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array  
   IS 
    -- This is the 'normal' split function without special end-of-line processing.
      i       number :=0; 
      pos     number :=0; 
      lv_str  varchar2(1024) := p_in_string;
 
      strings t_array; 
    
   BEGIN
       
      -- Then add delimiter 
      lv_str := lv_str || p_delim;
      -- p_log('string_fnc', 'I', 'This is the string: *' || lv_str || '*');
       
      -- determine first chuck of string   
      pos := instr(lv_str,p_delim,1,1); 
    
      -- while there are chunks left, loop  
      WHILE ( pos != 0) LOOP 
          
         -- increment counter  
         i := i + 1; 
          
         -- create array element for chuck of string  
         strings(i) := substr(lv_str,1,pos-1); 
          
         -- remove chunk from string  
         lv_str := substr(lv_str,pos+1,length(lv_str)); 
          
         -- determine next chunk  
         pos := instr(lv_str,p_delim,1,1); 
         
--         IF pos = 0 THEN 
         
--             strings(i+1) := lv_str; 
          
--         END IF; 
       
      END LOOP; 
    
      -- return array  
      RETURN strings; 
       
   END SPLIT_ARRAY; 
 
END;
/

CREATE OR REPLACE PROCEDURE  "P_XML_DUMP" 
IS
    proc_name logtbl.evt_proc%TYPE := 'p_xml_dump';
BEGIN
    p_log(proc_name, 'I', 'Start procedure');
    p_log(proc_name, 'I', 'Launch p_fiche2xml');
    p_fiche2xml;
    p_log(proc_name, 'I', 'Launch p_beleidsdocument2xml');
    p_beleidsdocument2xml;
    p_log(proc_name, 'I', 'End procedure');
END;
/

CREATE OR REPLACE PROCEDURE  "P_WORK_ON_CSV_FILE" (p_csv_files_id IN varchar2)
IS
    proc_name logtbl.evt_proc%TYPE := 'p_work_on_csv_file';
    err_msg varchar2(255);
    v_indicatorfiche_id number;
    v_query varchar2(1000);
    CURSOR valid_ids_cursor IS
        SELECT indicatorfiche_id
        FROM csv_load
        WHERE NOT (indicatorfiche_id IN (24,40,43,47,48,51,52,59,70,80,81,84));
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    -- Check if only valid indicatorfiche_ids have been found
    OPEN valid_ids_cursor;
    LOOP
        FETCH valid_ids_cursor INTO v_indicatorfiche_id;
        EXIT WHEN valid_ids_cursor%NOTFOUND;
        v_query := 'UPDATE csv_files SET status = ''Onverwachte Indicator ID ' || v_indicatorfiche_id || '''
                                    WHERE csv_files_id = ' || p_csv_files_id;
        EXECUTE IMMEDIATE v_query;
        commit;
        RETURN;
    END LOOP;
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_SEND_SUMM" 
    IS
    
    proc_name logtbl.evt_proc%TYPE := 'p_send_summ';
    err_msg varchar2(255);
    v_p_body_html VARCHAR2(4000); 
    v_resultaat number;
    v_msg_token varchar2(50) := 'Mail Log Information Checkpoint';
    cursor log_cursor IS
        SELECT * FROM logtbl
        WHERE evt_time > (select max(evt_time) from logtbl where evt_msg = v_msg_token)
        AND ((evt_sev = 'E') OR (evt_proc = 'LDAP_AUTHENTICATE'))
        ORDER BY evt_idx ASC;
    log_rec logtbl%ROWTYPE;
    PROCEDURE ip_send_mail
        IS
    BEGIN
        wwv_flow_api.set_security_group_id(102662831743521529); -- Workspace: MOW_DATAROOM_PROD
        v_p_body_html := '<html><body><h3>MOW Dataroom bericht</h3><br>' ||
                         '<table><tr><th>Index<th>Time<th>Procedure<th>Sev<th>Message</tr>' ||
                         v_p_body_html || '</table></body></html>';
        v_resultaat := APEX_MAIL.SEND(
            p_to        => 'dirk.vermeylen@hp.com',
            p_from      => 'dirk.vermeylen@hp.com',
            p_subj      => 'MOW Dataroom Information',
            p_body      => 'Tekst body',
            p_body_html => v_p_body_html
            );
        APEX_MAIL.PUSH_QUEUE;
        p_log(proc_name, 'T', 'Summary message sent');
    EXCEPTION
        WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name || ' in ip_send_mail', 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
    END;
BEGIN
    
    OPEN log_cursor;
    LOOP
        FETCH log_cursor INTO log_rec;
        EXIT WHEN log_cursor%NOTFOUND;
        v_p_body_html := v_p_body_html ||
                         '<tr><td>'  || log_rec.evt_idx  || 
                         '</td><td>' || to_char(log_rec.evt_time, 'DD/MM/YYYY HH24:MI:SS') ||
                         '</td><td>' || log_rec.evt_proc ||
                         '</td><td>' || log_rec.evt_sev  ||
                         '</td><td>' || log_rec.evt_msg  ||
                         '</td></tr>';
        IF (length(v_p_body_html) > 3200) THEN 
            -- Exit loop when message is too long,
            -- the user has been warned....
            v_p_body_html := v_p_body_html || '<tr><td><td><td><td><td><b><font color=red>More messages in logtbl...</font></b></tr>';
            EXIT;
        END IF;
    END LOOP;
            
            p_log(proc_name, 'I', v_msg_token);
    IF length(v_p_body_html) > 0 THEN
        ip_send_mail;
    END IF;
        
EXCEPTION
    WHEN OTHERS THEN
    err_msg:= SUBSTR(SQLERRM, 1, 100);
    p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
END;
/

CREATE OR REPLACE PROCEDURE  "P_SEND_ERROR" (p_evt_time IN logtbl.evt_time%TYPE, 
                                          p_evt_proc IN logtbl.evt_proc%TYPE, 
                                          p_evt_msg  IN logtbl.evt_msg%TYPE)
    IS
    
    v_p_body_html VARCHAR2(4000); 
    v_resultaat number;
    v_evt_time varchar2(20);
BEGIN
        
    wwv_flow_api.set_security_group_id(102662831743521529); -- Workspace: HB_CMDB_PROD
    v_evt_time := to_char(p_evt_time, 'DD/MM/YYYY HH24:MI:SS');
    v_p_body_html := '<html><body><h3>MOW Dataroom bericht</h3>';
    v_p_body_html := v_p_body_html || 'Procedure: ' || p_evt_proc || '<br>';
    v_p_body_html := v_p_body_html || 'Tijd: ' || v_evt_time || '<br>';
    v_p_body_html := v_p_body_html || 'Bericht: ' || p_evt_msg || '</body></html>';
    v_resultaat := APEX_MAIL.SEND(p_to => 'dirk.vermeylen@hp.com',
        p_from => 'dirk.vermeylen@hp.com',
        p_subj => 'MOW Dataroom Information',
        p_body => 'Tekst body',
        p_body_html => v_p_body_html
        );
    APEX_MAIL.PUSH_QUEUE;
END;
/

CREATE OR REPLACE PROCEDURE  "P_READ_LOGFILE" 
IS
    proc_name logtbl.evt_proc%TYPE := 'p_read_logfile';
    err_msg varchar2(255);
    v_filename varchar2(255);
    v_filename_found varchar2(255);
    v_file_object_id file_object.file_object_id%TYPE;
    csv_file mdk_log%ROWTYPE;
    CURSOR csv_file_cursor IS
        SELECT scriptfile, datestr, timestr, msg 
        FROM mdk_log
        WHERE msg LIKE 'databestand % van de dropserver afgehaald'
        ORDER BY timestr;
    CURSOR handle_file_cursor IS
        SELECT filename 
        FROM file_object
        WHERE source   = csv_file.scriptfile
          AND datestr  = csv_file.datestr
          AND timestr  = csv_file.timestr
          AND filename = v_filename;
   
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    
    -- Find csv files on server
    OPEN csv_file_cursor;
    LOOP
        FETCH csv_file_cursor INTO csv_file;
        EXIT WHEN csv_file_cursor%NOTFOUND;
        -- first remove identifier 'databestand ' from beginning of string
        v_filename := substr(csv_file.msg, length('databestand') + 2);
        -- then remove 'van de dropserver afgehaald' from end of string
        v_filename := substr(v_filename, 0, length(v_filename) - length(' van de dropserver afgehaald'));
        p_log(proc_name, 'T', 'Filename: *' || v_filename || '*');
        -- Now check if Filename has been handled already
        OPEN handle_file_cursor;
        FETCH handle_file_cursor INTO v_filename_found;
        IF handle_file_cursor%NOTFOUND THEN
            
            -- Remember that file has been found
            INSERT INTO file_object (source, datestr, timestr, filename)
                VALUES (csv_file.scriptfile, csv_file.datestr, csv_file.timestr, v_filename)
                RETURNING file_object_id INTO v_file_object_id;
                       
            -- Check if this is prep, commentaar or cijferrecord file
            IF instr(lower(v_filename), 'prep') > 0 THEN
                -- Error message to force mail
                p_log(proc_name, 'E', v_filename || ' prep file gevonden om op te laden');
            ELSIF instr(lower(v_filename), 'cijfers') > 0 THEN
                -- Error message to force mail
                p_log(proc_name, 'E', 'Cijfer file gevonden: ' || v_filename);
                p_csv_log(v_file_object_id, 'Cijfer file gevonden');
                p_csv_load(v_filename, v_file_object_id);
                p_load_report(v_file_object_id);
            ELSIF instr(lower(v_filename), 'commentaar') > 0 THEN
                -- Error message to force mail
                p_log(proc_name, 'E', 'Commentaar file gevonden: ' || v_filename);
                p_csv_log(v_file_object_id, 'Commentaar file gevonden');
                p_comm_load(v_filename, v_file_object_id);
                p_load_report(v_file_object_id);
            ELSE 
                p_log(proc_name, 'E', 'Onbekend file type gevonden: ' || v_filename);
                p_csv_log(v_file_object_id, 'Onbekend file type gevonden');
            END IF;
        END IF;
        CLOSE handle_file_cursor;
    END LOOP;
    CLOSE csv_file_cursor;
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_POP_REF_JAAR" 
IS
    proc_name logtbl.evt_proc%TYPE := 'p_pop_ref_jaar';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    yr number := 1980;
    sch_yr varchar2(10);
    BEGIN
    delete from referentie where veld = 'jaar';
    delete from referentie where veld = 'schooljaar';
    LOOP
        EXIT WHEN yr > 2030;
        INSERT INTO referentie (type, veld, waarde, actief)
            VALUES ('Frequentie', 'jaar', yr, 'J');
        
        sch_yr := yr || '-' || to_char(yr + 1);
        INSERT INTO referentie (type, veld, waarde, actief)
            VALUES ('Frequentie', 'schooljaar', sch_yr, 'J');
        
        yr := yr + 1;
    
    END LOOP;
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
       
END;
/

CREATE OR REPLACE PROCEDURE  "P_POP_FREQUENTIES" 
IS
    proc_name logtbl.evt_proc%TYPE := 'p_pop_frequenties';
    err_num number;
    err_line number;
    err_msg varchar2(255);
    start_epoch frequenties.dagnr%TYPE := f_date_to_epoch(to_date('1980-01-01', 'YYYY-MM-DD'));
    end_epoch   frequenties.dagnr%TYPE := f_date_to_epoch(to_date('2030-12-31', 'YYYY-MM-DD'));
    curr_epoch  frequenties.dagnr%TYPE := start_epoch;
    curr_date date;
    month_nr number;
    day_nr number;
    day_week number;
    yr number;
    kwartaal_lbl varchar2(15);
    sch_yr varchar2(10);
    TYPE maand_type IS VARRAY(12) OF varchar2(20);
    naam_maand maand_type := maand_type('januari', 'februari', 'maart', 'april', 'mei', 'juni', 'juli', 'augustus', 'september', 'oktober', 'november', 'december');
    TYPE dag_type IS VARRAY(7) OF varchar2(20);
    naam_dag dag_type := dag_type('zondag', 'maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag');
BEGIN
    dbms_output.put_line(start_epoch || ' * ' || end_epoch || ' * ' || curr_epoch);
    EXECUTE IMMEDIATE 'truncate table FREQUENTIES';
    LOOP
        EXIT WHEN curr_epoch > end_epoch;
        curr_date := f_epoch_to_date(curr_epoch);
        month_nr := to_char(curr_date, 'MM');
        day_nr := to_char(curr_date, 'DD');
        yr := to_char(curr_date, 'YYYY');
        -- month_nr := extract(month from curr_date);
        day_week := to_char(curr_date, 'D'); 
        IF month_nr < 4 THEN
            kwartaal_lbl := 'kwartaal 1';
        ELSIF month_nr < 7 THEN
            kwartaal_lbl := 'kwartaal 2';
        ELSIF month_nr < 10 THEN
            kwartaal_lbl := 'kwartaal 3';
        ELSE
            kwartaal_lbl := 'kwartaal 4';
        END IF;
        IF month_nr < 9 THEN
            sch_yr := to_char(yr - 1) || '-' || yr;
        ELSE
            sch_yr := yr || '-' || to_char(yr + 1);
        END IF;
        INSERT INTO FREQUENTIES (dagnr, datum, dag_week, maand, jaar, maandnr, dag, kwartaal, kwartaal_label, maand_label,schooljaar_label)
            VALUES (curr_epoch, curr_date, naam_dag(day_week), naam_maand(month_nr), yr, month_nr, day_nr, kwartaal_lbl, yr || ' ' || kwartaal_lbl, yr || ' ' || naam_maand(month_nr), sch_yr);
        
        curr_epoch := curr_epoch + 1;
    
    END LOOP;
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
       
END;
/

CREATE OR REPLACE PROCEDURE  "P_LOG_MAINT" 
    IS
    proc_name CONSTANT logtbl.evt_proc%TYPE := 'p_log_maint';
    err_msg varchar2(255);
BEGIN
    p_log(proc_name, 'I', 'Start Procedure');
    
    EXECUTE IMMEDIATE 'delete from logtbl where (evt_time < (sysdate -7)) and (not(evt_proc = ''LDAP_AUTHENTICATE''))';
    p_log(proc_name, 'I', 'End Procedure');
EXCEPTION
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
END;
/

CREATE OR REPLACE PROCEDURE  "P_LOG" (proc_name IN logtbl.evt_proc%TYPE,
                                           sev IN logtbl.evt_sev%TYPE,
                                           msg IN logtbl.evt_msg%TYPE)
    AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO logtbl (
        evt_time,
        evt_proc,
        evt_sev,
        evt_msg)
    VALUES (
        sysdate,
        proc_name,
        sev,
        msg);
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE  "P_LOAD_REPORT" (p_file_object_id IN file_object.file_object_id%TYPE)
IS
    proc_name logtbl.evt_proc%TYPE := 'p_load_report';
    err_msg varchar2(255);
    cursor file_process_cursor is
    select file_process_id,
           status,
           message,
           linenumber,
           process_time
    from file_process
    where file_object_id = p_file_object_id
    order by file_process_id asc;
    type file_process_record is record (
        r_file_process_id file_process.file_process_id%TYPE,
        r_status file_process.status%TYPE,
        r_message file_process.message%TYPE,
        r_linenumber file_process.linenumber%TYPE,
        r_process_time file_process.process_time%TYPE);
    fr file_process_record;
    v_filename file_object.filename%TYPE;
    v_datestr file_object.datestr%TYPE;
    v_timestr file_object.timestr%TYPE;
    v_file_out varchar2(255);
    f utl_file.file_type;
BEGIN
    p_log(proc_name, 'I', 'Start Application');
    SELECT filename, datestr, timestr
        INTO v_filename, v_datestr, v_timestr
        FROM file_object
        WHERE file_object_id = p_file_object_id;
 
    v_file_out := 'result_' || v_filename;
    f := utl_file.fopen('DATAROOM_OUT', v_file_out, 'w');
    
    utl_file.put_line(f, 'id;status;message;linenumber;process_time');
    OPEN file_process_cursor;
    LOOP
        FETCH file_process_cursor INTO fr;
        EXIT WHEN file_process_cursor%NOTFOUND;
        utl_file.put_line(f,fr.r_file_process_id || ';' || fr.r_status || ';' || fr.r_message || ';' || fr.r_linenumber || ';' || fr.r_process_time);
    END LOOP;
    utl_file.fclose(f);
    p_log(proc_name, 'I', 'End Application');
    
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_HANDLE_FILE" (p_filename IN varchar2, p_scriptname IN varchar2,
                                          p_datestr  IN varchar2, p_timestr    IN varchar2)
IS
    proc_name logtbl.evt_proc%TYPE := 'p_handle_file';
    err_msg varchar2(255);
    v_query varchar2(1000);
    v_csv_files_id csv_files.csv_files_id%TYPE;
    v_cnt number;
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    INSERT INTO csv_files (scriptfile, datestr, timestr, filename, status)
        VALUES (p_scriptname, p_datestr, p_timestr, p_filename, 'Start Processing')
        RETURNING csv_files_id INTO v_csv_files_id;
    p_drop_if_exists('csv_load');
    v_query := 'create table csv_load 
                (indicatorfiche_id number,
                 naam varchar2(255), 
                 aantal number,  
                 percentage number,
                 jaar number,
                 kwartaal number,
                 maand number,
                 entiteit varchar2(255),
                 type_medewerker varchar2(255))
                organization external
                (type oracle_loader
                 default directory "DATAROOM_IN"
                 access parameters
                 (records delimited by newline
                  skip 1
                  fields terminated by ";"
                  missing field values are null)
                 location (''' || lower(p_filename) || '''))
                 reject limit unlimited';
    p_log(proc_name, 'T', v_query);
    EXECUTE IMMEDIATE v_query;
    commit;
    
    p_work_on_csv_file(v_csv_files_id);
    
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_GET_LOGFILE" 
IS
    proc_name logtbl.evt_proc%TYPE := 'p_get_logfile';
    err_msg varchar2(255);
    v_mdk_log varchar2(255);
    v_query varchar2(1000);
    v_daynr varchar2(2);
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    v_daynr   := to_char(sysdate, 'DD');
    v_mdk_log := 'MDK2APEX.SH.' || v_daynr;
    p_drop_if_exists('mdk_log');
    v_query := 'create table mdk_log ' ||
               '(scriptfile varchar2(255), 
                 datestr varchar2(255), 
                 timestr varchar2(255),  
                 msg varchar2(255))
                organization external
                (type oracle_loader
                 default directory "DATAROOM_LOG"
                 access parameters
                 (records delimited by newline
                  NOBADFILE NODISCARDFILE NOLOGFILE
                  fields terminated by ";")
                 location (''' || lower(v_mdk_log) || '''))
                 reject limit unlimited';
    p_log(proc_name, 'T', v_query);
    EXECUTE IMMEDIATE v_query;
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_FICHE2XML" 
IS
    proc_name logtbl.evt_proc%TYPE := 'p_fiche2xml';
    cursor fiche_cursor is
    select indicatorfiche_id,
        indicator_naam,
        sleutel,
        definitie,
        berekeningswijze,
        doel_meting,
        meettechniek,
        f_referentielabel(type_indicator) w_type_indicator,
        f_referentielabel(meeteenheid) w_meeteenheid,
        meetfrequentie,
        tijdvenster,
        f_jn_aantal(aantal_percentage) w_aantal_percentage,
        f_jn(geografische_info) w_geografische_info,
        bron,
        aanspreekorganisatie_id,
        url_rapport,
        url_rapport_map,
        url_invoer
    from indicatorfiche;
    type fiche_record is record (
        r_indicatorfiche_id indicatorfiche.indicatorfiche_id%TYPE,
        r_indicator_naam indicatorfiche.indicator_naam%TYPE,
        r_sleutel indicatorfiche.sleutel%TYPE,
        r_definitie indicatorfiche.definitie%TYPE,
        r_berekeningswijze indicatorfiche.berekeningswijze%TYPE,
        r_doel_meting indicatorfiche.doel_meting%TYPE,
        r_meettechniek indicatorfiche.meettechniek%TYPE,
        r_type_indicator referentie.waarde%TYPE,
        r_meeteenheid referentie.waarde%TYPE,
        r_meetfrequentie indicatorfiche.meetfrequentie%TYPE,
        r_tijdvenster indicatorfiche.tijdvenster%TYPE,
        r_aantal_percentage varchar2(255),
        r_geografische_info varchar2(255),
        r_bron indicatorfiche.bron%TYPE,
        r_aanspreekorganisatie_id indicatorfiche.aanspreekorganisatie_id%TYPE,
        r_url_rapport indicatorfiche.url_rapport%TYPE,
        r_url_rapport_map indicatorfiche.url_rapport_map%TYPE,
        r_url_invoer indicatorfiche.url_invoer%TYPE);
    fiche fiche_record;
    f utl_file.file_type;
    err_msg varchar2(255);
    procedure ip_dimensies (v_indicatorfiche_id IN indicatorfiche.indicatorfiche_id%TYPE) 
    is
        cursor dimensie_cursor is
        select waarde
        from dimensie_fiche f, dimensie d
        where fiche_id = v_indicatorfiche_id
        and f.dimensie_id = d.dimensie_id;
        dim_waarde dimensie.waarde%TYPE;
    begin
        
        open dimensie_cursor;
        loop
            fetch dimensie_cursor into dim_waarde;
            exit when dimensie_cursor%NOTFOUND;
            utl_file.put_line(f,'<dimensie><![CDATA[' || dim_waarde || ']]></dimensie>');
        end loop;
    EXCEPTION
        WHEN OTHERS THEN
            err_msg:= SUBSTR(SQLERRM, 1, 100);
            p_log(proc_name || ' in ip_dimensies', 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace); 
    end;
    procedure ip_trefwoorden (v_indicatorfiche_id IN indicatorfiche.indicatorfiche_id%TYPE) 
    is
        cursor trefwoorden_cursor is
        select waarde
        from referentie r, trefwoord_fiche f
        where indicatorfiche_id = v_indicatorfiche_id
        and f.referentie_id = r.referentie_id;
        dim_waarde dimensie.waarde%TYPE;
    begin
        open trefwoorden_cursor;
        loop
            fetch trefwoorden_cursor into dim_waarde;
            exit when trefwoorden_cursor%NOTFOUND;
            utl_file.put_line(f,'<trefwoord><![CDATA[' || dim_waarde || ']]></trefwoord>');
        end loop;
    EXCEPTION
        WHEN OTHERS THEN
            err_msg:= SUBSTR(SQLERRM, 1, 100);
            p_log(proc_name || ' in ip_trefwoorden', 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace); 
    end;
    procedure ip_publicaties (v_indicatorfiche_id IN indicatorfiche.indicatorfiche_id%TYPE) 
    is
        cursor publicaties_cursor is
        select waarde
        from referentie r, gepubliceerd_fiche f
        where indicatorfiche_id = v_indicatorfiche_id
        and f.referentie_id = r.referentie_id;
        dim_waarde dimensie.waarde%TYPE;
    begin
        
        open publicaties_cursor;
        loop
            fetch publicaties_cursor into dim_waarde;
            exit when publicaties_cursor%NOTFOUND;
            utl_file.put_line(f,'<publicatie><![CDATA[' || dim_waarde || ']]></publicatie>');
        end loop;
    EXCEPTION
        WHEN OTHERS THEN
            err_msg:= SUBSTR(SQLERRM, 1, 100);
            p_log(proc_name || ' in ip_publicaties', 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace); 
    end;
    procedure ip_beleidsdocumenten (v_indicatorfiche_id IN indicatorfiche.indicatorfiche_id%TYPE) 
    is
        cursor beleidsdocumenten_cursor is
        select titel, b.beleidsdocument_id
        from beleidsdocument b, document_fiche f
        where indicatorfiche_id = v_indicatorfiche_id
        and b.beleidsdocument_id = f.beleidsdocument_id;
        dim_waarde beleidsdocument.titel%TYPE;
        v_doc_titel beleidsdocument.titel%TYPE;   
        w_beleidsdocument_id beleidsdocument.beleidsdocument_id%TYPE;
    begin
        
        open beleidsdocumenten_cursor;
        loop
            fetch beleidsdocumenten_cursor into dim_waarde, w_beleidsdocument_id;
            exit when beleidsdocumenten_cursor%NOTFOUND;
            utl_file.put_line(f,'<beleidsdocument>');
            v_doc_titel := f_get_doc_titel(w_beleidsdocument_id);
            utl_file.put_line(f,'<document><![CDATA[' || v_doc_titel || ']]></document>');
            utl_file.put_line(f,'<id>' || w_beleidsdocument_id || '</id>');
            utl_file.put_line(f,'<titel><![CDATA[' || dim_waarde || ']]></titel>');
            utl_file.put_line(f,'</beleidsdocument>');
        end loop;
    EXCEPTION
        WHEN OTHERS THEN
            err_msg:= SUBSTR(SQLERRM, 1, 100);
            p_log(proc_name || ' in ip_beleidsdocumenten', 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace); 
    end;
    procedure ip_organisatie(w_org_id IN indicatorfiche.aanspreekorganisatie_id%TYPE)
    is
        cursor org_cursor is 
        select a.waarde entiteit, b.waarde afdeling
        from organisatie,
        referentie a,
        referentie b
        where organisatie_id = w_org_id
        and a.referentie_id = entiteit
        and b.referentie_id = afdeling;
        
        v_entiteit referentie.waarde%TYPE;
        v_afdeling referentie.waarde%TYPE;
    begin
        
        open org_cursor;
        loop 
            fetch org_cursor into v_entiteit, v_afdeling;
            exit when org_cursor%NOTFOUND;
            utl_file.put_line(f,'<entiteit><![CDATA[' || v_entiteit || ']]></entiteit>');
            utl_file.put_line(f,'<afdeling><![CDATA[' || v_afdeling || ']]></afdeling>');
            
        end loop;
    EXCEPTION
    
        WHEN OTHERS THEN
            err_msg:= SUBSTR(SQLERRM, 1, 100);
            p_log(proc_name || ' in ip_organisatie', 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace); 
        

    end;
BEGIN
    p_log(proc_name, 'I', 'Start Application');
    f := utl_file.fopen('DATAROOM_OUT', 'indicatorfiches.xml', 'w');
    
    utl_file.put_line(f, '<?xml version="1.0"?>');
    utl_file.put_line(f, '<indicatorfiches>');
    OPEN fiche_cursor;
    LOOP
        FETCH fiche_cursor INTO fiche;
        EXIT WHEN fiche_cursor%NOTFOUND;
        utl_file.put_line(f,'<indicatorfiche>');
        utl_file.put_line(f,'<indicatorfiche_id>' || fiche.r_indicatorfiche_id || '</indicatorfiche_id>');
        utl_file.put_line(f,'<indicator_naam><![CDATA[' || fiche.r_indicator_naam || ']]></indicator_naam>');
        utl_file.put_line(f,'<sleutel><![CDATA[' || fiche.r_sleutel || ']]></sleutel>');
        utl_file.put_line(f,'<definitie><![CDATA[' || fiche.r_definitie || ']]></definitie>');
        utl_file.put_line(f,'<berekeningswijze><![CDATA[' || fiche.r_berekeningswijze || ']]></berekeningswijze>');
        utl_file.put_line(f,'<doel_meting><![CDATA[' || fiche.r_doel_meting || ']]></doel_meting>');
        utl_file.put_line(f,'<meettechniek><![CDATA[' || fiche.r_meettechniek || ']]></meettechniek>');
        utl_file.put_line(f,'<type_indicator><![CDATA[' || fiche.r_type_indicator || ']]></type_indicator>');
        utl_file.put_line(f,'<meeteenheid><![CDATA[' || fiche.r_meeteenheid || ']]></meeteenheid>');
        utl_file.put_line(f,'<meetfrequentie><![CDATA[' || fiche.r_meetfrequentie || ']]></meetfrequentie>');
        utl_file.put_line(f,'<dimensies>');
        ip_dimensies(fiche.r_indicatorfiche_id);
        utl_file.put_line(f,'</dimensies>');
        utl_file.put_line(f,'<trefwoorden>');
        ip_trefwoorden(fiche.r_indicatorfiche_id);
        utl_file.put_line(f,'</trefwoorden>');
        utl_file.put_line(f,'<publicaties>');
        ip_publicaties(fiche.r_indicatorfiche_id);
        utl_file.put_line(f,'</publicaties>');
        utl_file.put_line(f,'<beleidsdocumenten>');
        ip_beleidsdocumenten(fiche.r_indicatorfiche_id);
        utl_file.put_line(f,'</beleidsdocumenten>');
        utl_file.put_line(f,'<tijdvenster><![CDATA[' || fiche.r_tijdvenster || ']]></tijdvenster>');
        utl_file.put_line(f,'<aantal_percentage><![CDATA[' || fiche.r_aantal_percentage || ']]></aantal_percentage>');
        utl_file.put_line(f,'<geografische_info><![CDATA[' || fiche.r_geografische_info || ']]></geografische_info>');
        utl_file.put_line(f,'<bron><![CDATA[' || fiche.r_bron || ']]></bron>');
        utl_file.put_line(f,'<organisatie>');
        if (fiche.r_aanspreekorganisatie_id > 0) then
            ip_organisatie(fiche.r_aanspreekorganisatie_id);
        end if;
        utl_file.put_line(f,'</organisatie>');
        utl_file.put_line(f,'<url_rapport><![CDATA[' || fiche.r_url_rapport || ']]></url_rapport>');
        utl_file.put_line(f,'<url_rapport_map><![CDATA[' || fiche.r_url_rapport_map || ']]></url_rapport_map>');
        utl_file.put_line(f,'<url_invoer><![CDATA[' || fiche.r_url_invoer || ']]></url_invoer>');
    
        utl_file.put_line(f,'</indicatorfiche>');
         
    END LOOP;
    utl_file.put_line(f, '</indicatorfiches>');
    utl_file.fclose(f);
    p_log(proc_name, 'I', 'End Application');
    
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_DROP_IF_EXISTS" (p_tablename IN varchar2)
IS
    -- This procedure accepts a tablename 
    -- and drops the table if it exists already.
    proc_name logtbl.evt_proc%TYPE := 'p_drop_if_exists';
    err_msg varchar2(255);
    v_query varchar2(1000);
    v_tablename varchar2(255);
    cursor tables_cursor IS
    SELECT table_name
    FROM user_tables 
    WHERE lower(table_name) = lower(p_tablename);
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    OPEN tables_cursor;
    FETCH tables_cursor INTO v_tablename;
    IF tables_cursor%FOUND THEN 
        p_log(proc_name, 'T', v_tablename || ' gevonden, wordt gedelete.');
        v_query := 'DROP TABLE ' || v_tablename; 
        p_log(proc_name, 'T', v_query);
        EXECUTE IMMEDIATE v_query;
    ELSE
        p_log(proc_name, 'T', p_tablename || ' bestaat nog niet');
    END IF;
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_CSV_MERGE" (p_file_object_id IN file_process.file_object_id%TYPE)
IS
    -- Procedure to merge the table csv_load into indicator_report table
    proc_name logtbl.evt_proc%TYPE := 'p_csv_merge';
    err_msg varchar2(255);
    v_status file_process.status%TYPE := 'Data van csv tabel naar indicator_report overzetten';
    v_query varchar2(1000);
    v_indicatorfiche_id csv_load.indicatorfiche_id%TYPE;
    v_meetfrequentie indicatorfiche.meetfrequentie%TYPE;
    v_aantal_percentage indicatorfiche.aantal_percentage%TYPE;
    TYPE valid_ids_type IS TABLE OF number;
    valid_ids valid_ids_type := valid_ids_type(24, 40, 43, 47, 48, 51, 52, 59, 70, 80, 81, 84);
    CURSOR fiches_cursor IS
        SELECT distinct indicatorfiche_id 
        FROM csv_load;
    CURSOR fiches_freq_cursor IS
        SELECT distinct c.indicatorfiche_id, meetfrequentie, aantal_percentage 
        FROM csv_load c, indicatorfiche i
        WHERE c.indicatorfiche_id = i.indicatorfiche_id;
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    -- Check for valid indicatorfiche_ids
    -- If invalid, remove records from csv_load
    OPEN fiches_cursor;
    LOOP
        FETCH fiches_cursor into v_indicatorfiche_id;
        EXIT WHEN fiches_cursor%NOTFOUND;
        
        IF v_indicatorfiche_id MEMBER OF valid_ids THEN
            p_csv_log(p_file_object_id, v_status, 'Indicatorfiche ID ' || v_indicatorfiche_id || ' gedelete uit indicator_report');
            v_query := 'DELETE FROM indicator_report WHERE indicatorfiche_id = ' || v_indicatorfiche_id;
            EXECUTE IMMEDIATE v_query;
        ELSE
            p_csv_log(p_file_object_id, v_status, 'Ongeldige indicatofiche_id: ' || v_indicatorfiche_id);
            v_query := 'DELETE FROM csv_load WHERE indicatorfiche_id = ' || v_indicatorfiche_id;
            EXECUTE IMMEDIATE v_query;
        END IF;
    END LOOP;
    -- Then handle all remaining indicatorfiches
    OPEN fiches_freq_cursor;
    LOOP
        FETCH fiches_freq_cursor into v_indicatorfiche_id, v_meetfrequentie, v_aantal_percentage;
        EXIT WHEN fiches_freq_cursor%NOTFOUND;
        p_csv_handle_id(p_file_object_id, v_indicatorfiche_id, v_meetfrequentie, v_aantal_percentage);
        END LOOP;
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_CSV_LOG" (p_object_id file_process.file_object_id%TYPE,
                                        p_status file_process.status%TYPE,
                                        p_message file_process.message%TYPE DEFAULT NULL,
                                        p_linenumber file_process.linenumber%TYPE DEFAULT NULL)
    AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    --p_log('p_csv_log', 'T', 'Object ID: ' || p_object_id || ' Status: ' || p_status);
    INSERT INTO file_process (
        file_object_id,
        status,
        message,
        linenumber)
    VALUES (
        p_object_id,
        p_status,
        p_message,
        p_linenumber);
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE  "P_CSV_LOAD" (p_filename IN varchar2, p_file_object_id IN file_process.file_object_id%TYPE)
IS
    -- Procedure to read the csv file and load it in the table csv_load
    proc_name logtbl.evt_proc%TYPE := 'p_csv_load';
    err_msg varchar2(255);
    v_status file_process.status%TYPE := 'File in csv tabel laden';
    v_delim varchar2(1) := ';';
    v_query varchar2(1000);
    csv_file utl_file.file_type;
    v_line varchar2(1024);    -- 1024 is default length of a line.
    v_col   string_fnc.t_array;
    v_array string_fnc.t_array;
    v_col_str varchar2(1024);
    v_array_str varchar2(1024);
    v_value varchar2(255);
    v_linecnt number := 0;
    v_reccnt number;
    v_lineok boolean;
    
    FUNCTION if_verify_field (f_column IN varchar2, f_value IN varchar2, f_linecnt IN number)
    RETURN varchar2
    IS
        v_value varchar2(255);
        TYPE str_val_type IS TABLE OF varchar2(255);
        str_val str_val_type := str_val_type('naam', 'entiteit', 'type_medewerker');
        TYPE num_val_type IS TABLE OF varchar2(255);
        num_val num_val_type := num_val_type('aantal', 'percentage', 'jaar', 'kwartaal', 'maand', 'indicatorfiche_id');
    BEGIN
        IF f_column member of str_val THEN
            -- No further checking required, add single quotes to string
            RETURN f_value;
        ELSIF f_column member of num_val THEN
            -- Accept value only if numeric 
            BEGIN
                v_value := to_number(f_value);
                RETURN v_value;
            EXCEPTION
                WHEN OTHERS THEN
                v_lineok := false;
                p_csv_log(p_file_object_id, v_status, f_column || ' heeft niet-numerieke waarde *' || f_value || '*', f_linecnt);
                RETURN '';
            END;
        ELSE
            v_lineok := false;
            p_csv_log(p_file_object_id, v_status, f_column || ' onbekende kolom', f_linecnt);
            RETURN '';
        END IF;
    END;
    
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    -- First clean up csv_load table
    v_query := 'DELETE FROM csv_load';
    EXECUTE IMMEDIATE v_query;
    -- Then  open file for reading
    csv_file := utl_file.fopen('DATAROOM_IN', p_filename, 'r');
    -- Get the columns
    utl_file.get_line(csv_file, v_line);
    v_linecnt := v_linecnt + 1;
    v_col := string_fnc.split(v_line, v_delim);
    
    -- Then handle all lines
    LOOP
        BEGIN
            utl_file.get_line(csv_file, v_line);
            v_linecnt := v_linecnt + 1;
            v_array := string_fnc.split(v_line, v_delim);
            v_col_str := 'linenumber';
            v_array_str := v_linecnt;
            v_lineok := true;
            FOR i IN 1..v_array.count LOOP
                IF (length(v_array(i)) > 0) THEN 
                    v_value := if_verify_field(v_col(i), v_array(i), v_linecnt);
                    IF (length(v_value) > 0) THEN
                        v_col_str := v_col(i) || ',' || v_col_str;
                        v_array_str := '''' || v_array(i) || ''',' || v_array_str;
                    END IF;
                END IF;
            END LOOP;
            IF v_lineok THEN
                v_query := 'INSERT into csv_load (' || v_col_str || ') VALUES (' || v_array_str || ')';
                -- p_log(proc_name, 'T', 'Ready to execute query: ' || v_query);
                EXECUTE IMMEDIATE v_query;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN EXIT;
        END;
    END LOOP;
    
    -- Finally close the file
    utl_file.fclose(csv_file);
    -- And print statistics
    SELECT count(*) INTO v_reccnt FROM csv_load;
    p_csv_log(p_file_object_id, v_status, v_linecnt-1 || ' lijnen gelezen, ' || v_reccnt || ' records geschreven.');
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_CSV_HANDLE_ID" (p_file_object_id IN file_process.file_object_id%TYPE,
                                             p_indicatorfiche_id IN csv_load.indicatorfiche_id%TYPE,
                                             p_meetfrequentie IN indicatorfiche.meetfrequentie%TYPE,
                                             p_aantal_percentage IN indicatorfiche.aantal_percentage%TYPE)
IS
    -- Procedure to handle one indicatorfiche_id 
    proc_name logtbl.evt_proc%TYPE := 'p_csv_handle_id';
    err_msg varchar2(255);
    v_status file_process.status%TYPE := 'Records overladen voor ID ' || p_indicatorfiche_id;
    v_query varchar2(1000);
    v_cols varchar2(1024);
    v_vals varchar2(1024);
    v_lineok boolean;
    v_rec_ok number := 0;
    v_rec_tot number := 0;
    csv_rec csv_load%ROWTYPE;
    dim_cnt number;
    TYPE maand_type IS VARRAY(12) OF varchar2(20);
    naam_maand maand_type := maand_type('januari', 'februari', 'maart', 'april', 'mei', 'juni', 'juli', 'augustus', 'september', 'oktober', 'november', 'december');
    TYPE dim_el_type IS TABLE OF number INDEX BY varchar2(64);
    dim_el dim_el_type;
    dim2id dim_el_type;
    dimensies string_fnc.t_array;
    i number;
    v_dim_id dimensie.dimensie_id%TYPE;
    v_dim_waarde dimensie.waarde%TYPE;
    v_dim_el_id dim_element.dim_element_id%TYPE;
    v_dim_el_waarde dim_element.waarde%TYPE;
    dim_arr_id string_fnc.t_array;
    dim_arr_name string_fnc.t_array;
    CURSOR csv_rec_cursor IS
        SELECT * 
        FROM csv_load
        WHERE indicatorfiche_id = p_indicatorfiche_id;
    CURSOR dimensies_cursor IS
        SELECT f.dimensie_id, d.waarde
        FROM dimensie d, dimensie_fiche f
        WHERE f.fiche_id = p_indicatorfiche_id
        AND f.dimensie_id = d.dimensie_id;
    CURSOR dim_el_cursor IS
        SELECT dimensie_id || '_' || waarde, dim_element_id
        FROM dim_element
        WHERE dim_element_id > 0;
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    -- Find if there are any dimensies for the indicatorfiche_id
    dim_cnt := 0;
    OPEN dimensies_cursor;
    LOOP
        dim_cnt := dim_cnt + 1;
        FETCH dimensies_cursor INTO v_dim_id, v_dim_waarde;
        EXIT WHEN dimensies_cursor%NOTFOUND;
        SELECT replace(v_dim_waarde, ' ', '_') INTO v_dim_waarde FROM dual;
        dim_arr_name(dim_cnt) := v_dim_waarde;
        dim_arr_id(dim_cnt) := v_dim_id;
    END LOOP;
    IF i > 0 THEN 
    -- Dimensies found, check for dimensie elementen
        OPEN dim_el_cursor;
        LOOP
            FETCH dim_el_cursor into v_dim_el_waarde, v_dim_el_id;
            EXIT WHEN dim_el_cursor%NOTFOUND;
            dim_el(v_dim_el_waarde) := v_dim_el_id;
        END LOOP;
    END IF;
    OPEN csv_rec_cursor;
    LOOP
        FETCH csv_rec_cursor into csv_rec;
        EXIT WHEN csv_rec_cursor%NOTFOUND;
        v_cols := 'actief,indicatorfiche_id';
        v_vals := '''J'',' || p_indicatorfiche_id;
        v_lineok := true;
        v_rec_tot := v_rec_tot + 1;
        
        -- Handle meetfrequentie
        IF p_meetfrequentie = 'maand' THEN
            IF ((csv_rec.maand > 0) and (csv_rec.maand < 13)) THEN
                v_cols := 'label,' || v_cols;
                v_vals := '''' || naam_maand(csv_rec.maand) || ''',' || v_vals; 
            ELSE
                p_csv_log(p_file_object_id, v_status, 'Ongeldig maandnummer: ' || csv_rec.maand, csv_rec.linenumber);
                v_lineok := false;
            END IF;
        END IF;
        IF p_meetfrequentie = 'kwartaal' THEN
            IF ((csv_rec.kwartaal > 0) and (csv_rec.kwartaal < 5)) THEN
                v_cols := 'label,' || v_cols;
                v_vals := '''kwartaal ' || csv_rec.kwartaal || ''',' || v_vals; 
            ELSE
                p_csv_log(p_file_object_id, v_status, 'Ongeldig kwartaalnummer: ' || csv_rec.kwartaal, csv_rec.linenumber);
                v_lineok := false;
            END IF;
        END IF;
        IF ((p_meetfrequentie = 'maand') OR (p_meetfrequentie = 'jaar') OR (p_meetfrequentie = 'kwartaal')) THEN
            IF ((csv_rec.jaar > 1979) and (csv_rec.jaar < 2031)) THEN
                v_cols := 'jaar,' || v_cols;
                v_vals := csv_rec.jaar || ',' || v_vals; 
            ELSE
                p_csv_log(p_file_object_id, v_status, 'Ongeldig jaar: ' || csv_rec.jaar, csv_rec.linenumber);
                v_lineok := false;
            END IF;
        END IF;
        IF (p_meetfrequentie = 'schooljaar') THEN
            p_csv_log(p_file_object_id, v_status, 'Meetfrequentie schooljaar kan nog niet behandeld worden', csv_rec.linenumber);
        END IF;
    
        -- Handle aantal/percentage
        IF p_aantal_percentage = 'J' THEN
            IF (length(csv_rec.aantal) > 0) THEN
                v_cols := 'aantal,' || v_cols;
                v_vals := csv_rec.aantal || ',' || v_vals; 
            ELSE
                p_csv_log(p_file_object_id, v_status, 'Aantal vereist, maar niet ingevuld', csv_rec.linenumber);
                v_lineok := false;
            END IF;
        ELSE
            IF ((csv_rec.percentage >= 0) and (csv_rec.percentage <= 100)) THEN
                v_cols := 'percentage,' || v_cols;
                v_vals := csv_rec.percentage || ',' || v_vals; 
            ELSE
                p_csv_log(p_file_object_id, v_status, 'Percentage niet (correct) ingevuld' || csv_rec.percentage, csv_rec.linenumber);
                v_lineok := false;
            END IF;
        END IF;
        -- Handle dimensies
-- Can I work with csv_rec.dim_arr_name(cnt) ???
-- If not, I need to list all dimensies individually...
        
        
        IF v_lineok THEN
            v_query := 'INSERT INTO indicator_report (' || v_cols || ') VALUES (' || v_vals || ')';
            p_log(proc_name, 'T', 'Ready for query: ' || v_query);
            EXECUTE IMMEDIATE v_query;
            v_rec_ok := v_rec_ok + 1;
        END IF;
    END LOOP;
    p_csv_log(p_file_object_id, v_status, v_rec_tot || ' records geevalueerd, ' || v_rec_ok || ' records in indicator_report opgeladen');
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_COMM_MERGE" (p_file_object_id IN file_process.file_object_id%TYPE)
IS
    -- Procedure to merge the table comm_load into commentaar table
    proc_name logtbl.evt_proc%TYPE := 'p_comm_merge';
    err_msg varchar2(255);
    v_status file_process.status%TYPE := 'Data van comm_table naar commentaar tabel overzetten';
    v_query varchar2(1000);
    v_indicatorfiche_id comm_load.indicatorfiche_id%TYPE;
    v_meetfrequentie indicatorfiche.meetfrequentie%TYPE;
    
    TYPE valid_ids_type IS TABLE OF number;
    valid_ids valid_ids_type := valid_ids_type(24, 40, 43, 47, 48, 51, 52, 59, 70, 80, 81, 84);
    CURSOR fiches_cursor IS
        SELECT distinct indicatorfiche_id 
        FROM comm_load;
    CURSOR fiches_freq_cursor IS
        SELECT distinct c.indicatorfiche_id, meetfrequentie 
        FROM comm_load c, indicatorfiche i
        WHERE c.indicatorfiche_id = i.indicatorfiche_id;
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    -- Check for valid indicatorfiche_ids
    -- If invalid, remove records from csv_load
    OPEN fiches_cursor;
    LOOP
        FETCH fiches_cursor into v_indicatorfiche_id;
        EXIT WHEN fiches_cursor%NOTFOUND;
        
        IF v_indicatorfiche_id MEMBER OF valid_ids THEN
            p_csv_log(p_file_object_id, v_status, 'Indicatorfiche ID ' || v_indicatorfiche_id || ' gedelete uit commentaar tabel');
            v_query := 'DELETE FROM commentaar WHERE indicatorfiche_id = ' || v_indicatorfiche_id;
            EXECUTE IMMEDIATE v_query;
        ELSE
            p_csv_log(p_file_object_id, v_status, 'Ongeldige indicatofiche_id: ' || v_indicatorfiche_id);
            v_query := 'DELETE FROM comm_load WHERE indicatorfiche_id = ' || v_indicatorfiche_id;
            EXECUTE IMMEDIATE v_query;
        END IF;
    END LOOP;
    -- Then handle all remaining indicatorfiches
    OPEN fiches_freq_cursor;
    LOOP
        FETCH fiches_freq_cursor into v_indicatorfiche_id, v_meetfrequentie;
        EXIT WHEN fiches_freq_cursor%NOTFOUND;
        p_comm_handle_id(p_file_object_id, v_indicatorfiche_id, v_meetfrequentie);
        END LOOP;
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_COMM_LOAD" (p_filename IN varchar2, p_file_object_id IN file_process.file_object_id%TYPE)
IS
    -- Procedure to read the commentaar file and load it in the table comm_load
    proc_name logtbl.evt_proc%TYPE := 'p_comm_load';
    err_msg varchar2(255);
    v_status file_process.status%TYPE := 'File in commentaar tabel laden';
    v_delim varchar2(1) := ';';
    v_query varchar2(1000);
    csv_file utl_file.file_type;
    v_line varchar2(1024);    -- 1024 is default length of a line.
    v_col   string_fnc.t_array;
    v_array string_fnc.t_array;
    v_col_str varchar2(1024);
    v_array_str varchar2(1024);
    v_value varchar2(255);
    v_linecnt number := 0;
    v_reccnt number;
    v_lineok boolean;
    
    FUNCTION if_verify_field (f_column IN varchar2, f_value IN varchar2, f_linecnt IN number)
    RETURN varchar2
    IS
        v_value varchar2(255);
        TYPE str_val_type IS TABLE OF varchar2(255);
        str_val str_val_type := str_val_type('naam', 'commentaar');
        TYPE num_val_type IS TABLE OF varchar2(255);
        num_val num_val_type := num_val_type('jaar', 'kwartaal', 'maand', 'indicatorfiche_id');
    BEGIN
        IF f_column member of str_val THEN
            -- No further checking required, add single quotes to string
            RETURN f_value;
        ELSIF f_column member of num_val THEN
            -- Accept value only if numeric 
            BEGIN
                v_value := to_number(f_value);
                RETURN v_value;
            EXCEPTION
                WHEN OTHERS THEN
                v_lineok := false;
                p_csv_log(p_file_object_id, v_status, f_column || ' heeft niet-numerieke waarde *' || f_value || '*', f_linecnt);
                RETURN '';
            END;
        ELSE
            -- v_lineok := false; Onbekende kolom wordt genegeerd, geen fout.
            p_csv_log(p_file_object_id, v_status, f_column || ' onbekende kolom', f_linecnt);
            RETURN '';
        END IF;
    END;
    
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    -- First clean up comm_load table
    v_query := 'DELETE FROM comm_load';
    EXECUTE IMMEDIATE v_query;
    -- Then  open file for reading
    csv_file := utl_file.fopen('DATAROOM_IN', p_filename, 'r');
    -- Get the columns
    utl_file.get_line(csv_file, v_line);
    v_linecnt := v_linecnt + 1;
    v_col := string_fnc.split(v_line, v_delim);
    
    -- Then handle all lines
    LOOP
        BEGIN
            utl_file.get_line(csv_file, v_line);
            v_linecnt := v_linecnt + 1;
            v_array := string_fnc.split(v_line, v_delim);
            v_col_str := 'linenumber';
            v_array_str := v_linecnt;
            v_lineok := true;
            FOR i IN 1..v_array.count LOOP
                IF (length(v_array(i)) > 0) THEN 
                    v_value := if_verify_field(v_col(i), v_array(i), v_linecnt);
                    IF (length(v_value) > 0) THEN
                        v_col_str := v_col(i) || ',' || v_col_str;
                        v_array_str := '''' || v_array(i) || ''',' || v_array_str;
                    END IF;
                END IF;
            END LOOP;
            IF v_lineok THEN
                v_query := 'INSERT into comm_load (' || v_col_str || ') VALUES (' || v_array_str || ')';
                -- p_log(proc_name, 'T', 'Ready to execute query: ' || v_query);
                EXECUTE IMMEDIATE v_query;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN EXIT;
        END;
    END LOOP;
    
    -- Finally close the file
    utl_file.fclose(csv_file);
    -- And print statistics
    SELECT count(*) INTO v_reccnt FROM comm_load;
    p_csv_log(p_file_object_id, v_status, v_linecnt-1 || ' lijnen gelezen, ' || v_reccnt || ' records geschreven.');
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_COMM_HANDLE_ID" (p_file_object_id IN file_process.file_object_id%TYPE,
                                             p_indicatorfiche_id IN comm_load.indicatorfiche_id%TYPE,
                                             p_meetfrequentie IN indicatorfiche.meetfrequentie%TYPE)
IS
    -- Procedure to handle one indicatorfiche_id 
    proc_name logtbl.evt_proc%TYPE := 'p_comm_handle_id';
    err_msg varchar2(255);
    v_status file_process.status%TYPE := 'Records overladen voor ID ' || p_indicatorfiche_id;
    v_query varchar2(1000);
    v_cols varchar2(1024);
    v_vals varchar2(1024);
    v_lineok boolean;
    v_rec_ok number := 0;
    v_rec_tot number := 0;
    v_label number;
    v_jaar number;
    comm_rec comm_load%ROWTYPE;
    v_periode_label commentaar.periode%TYPE;
    v_dagnr commentaar.dagnr%TYPE;
    TYPE maand_type IS VARRAY(12) OF varchar2(20);
    naam_maand maand_type := maand_type('januari', 'februari', 'maart', 'april', 'mei', 'juni', 'juli', 'augustus', 'september', 'oktober', 'november', 'december');
    CURSOR comm_rec_cursor IS
        SELECT * 
        FROM comm_load
        WHERE indicatorfiche_id = p_indicatorfiche_id;
BEGIN
    
    p_log(proc_name, 'I', 'Start Application');
    OPEN comm_rec_cursor;
    LOOP
        FETCH comm_rec_cursor into comm_rec;
        EXIT WHEN comm_rec_cursor%NOTFOUND;
        v_cols := 'indicatorfiche_id';
        v_vals := p_indicatorfiche_id;
        v_lineok := true;
        v_rec_tot := v_rec_tot + 1;
        
        -- Handle meetfrequentie
        IF p_meetfrequentie = 'maand' THEN
            IF ((comm_rec.maand > 0) and (comm_rec.maand < 13)) THEN
                v_label := comm_rec.maand;
                v_periode_label := naam_maand(v_label);
            ELSE
                p_csv_log(p_file_object_id, v_status, 'Ongeldig maandnummer: ' || comm_rec.maand, comm_rec.linenumber);
                v_lineok := false;
            END IF;
        END IF;
        IF p_meetfrequentie = 'kwartaal' THEN
            IF ((comm_rec.kwartaal > 0) and (comm_rec.kwartaal < 5)) THEN
                v_label := comm_rec.kwartaal; 
                v_periode_label := 'kwartaal ' || v_label;
            ELSE
                p_csv_log(p_file_object_id, v_status, 'Ongeldig kwartaalnummer: ' || comm_rec.kwartaal, comm_rec.linenumber);
                v_lineok := false;
            END IF;
        END IF;
        IF ((p_meetfrequentie = 'maand') OR (p_meetfrequentie = 'jaar') OR (p_meetfrequentie = 'kwartaal')) THEN
            IF ((comm_rec.jaar > 1979) and (comm_rec.jaar < 2031)) THEN
                v_jaar := comm_rec.jaar; 
            ELSE
                p_csv_log(p_file_object_id, v_status, 'Ongeldig jaar: ' || comm_rec.jaar, comm_rec.linenumber);
                v_lineok := false;
            END IF;
        END IF;
        IF (p_meetfrequentie = 'schooljaar') THEN
            p_csv_log(p_file_object_id, v_status, 'Meetfrequentie schooljaar kan nog niet behandeld worden', comm_rec.linenumber);
        END IF;
    
        -- Handle Commentaar veld
        IF (length(comm_rec.commentaar) > 0) THEN
            v_cols := 'beschrijving,' || v_cols;
            v_vals := '''' || comm_rec.commentaar || ''',' || v_vals; 
        ELSE
            p_csv_log(p_file_object_id, v_status, 'Commentaar vereist, maar niet ingevuld', comm_rec.linenumber);
            v_lineok := false;
        END IF;
        IF v_lineok THEN
            -- Convert to dagnr
            v_dagnr := f_calc_dagnr(p_indicatorfiche_id, '*' || v_jaar || '*' || v_label);
            v_cols := 'periode,dagnr,' || v_cols;
            v_vals := '''' || v_jaar || ' ' || v_periode_label || ''',' || v_dagnr || ',' || v_vals;
            v_query := 'INSERT INTO commentaar (' || v_cols || ') VALUES (' || v_vals || ')';
            p_log(proc_name, 'T', 'Ready for query: ' || v_query);
            EXECUTE IMMEDIATE v_query;
            v_rec_ok := v_rec_ok + 1;
        END IF;
    END LOOP;
    p_csv_log(p_file_object_id, v_status, v_rec_tot || ' records geevalueerd, ' || v_rec_ok || ' records in commentaar tabel opgeladen');
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_CALC_PARENT" (p_doc_id IN beleidsdocument.doc_id%TYPE)
IS
    -- This procedure will recalculate the parent-ids
    -- for a specific Beleidsdocument.
    
    proc_name logtbl.evt_proc%TYPE := 'p_calc_parent';
    err_msg varchar2(255);
    cursor doc_cursor is
        select *
        from beleidsdocument
        where doc_id = p_doc_id
        and ((not (parent_id = -1)) or (parent_id is null))
        order by toc;
    doc_rec beleidsdocument%ROWTYPE;
    TYPE title_id_type IS TABLE OF beleidsdocument.parent_id%TYPE INDEX BY BINARY_INTEGER;
    title_id title_id_type;
    v_lvl number;
    v_prev_lvl number := 0;
    v_id4doc beleidsdocument.doc_id%TYPE;
    v_parent_id beleidsdocument.parent_id%TYPE;
    v_query varchar2(2000);
    v_cnt number;
    PROCEDURE ip_update_parent_id(ip_doc_rec IN beleidsdocument%ROWTYPE,
                                  ip_parent_id IN beleidsdocument.parent_id%TYPE)
    -- Procedure to update parent ID if required
    IS
    BEGIN
        -- Is parent_id NULL or is this a change in parent_id?
        p_log(proc_name || ' ip_update_parent', 'T', 'ID: ' || ip_doc_rec.beleidsdocument_id || ' Parent: ' || ip_doc_rec.parent_id || ' New Parent: ' || ip_parent_id);
        IF ((ip_doc_rec.parent_id is NULL) OR (NOT(ip_parent_id = ip_doc_rec.parent_id))) THEN
            v_query := 'UPDATE beleidsdocument SET parent_id = ' || ip_parent_id ||
                       ' WHERE beleidsdocument_id = ' || ip_doc_rec.beleidsdocument_id;
            p_log(proc_name || ' ip_update_parent', 'T', v_query);
            EXECUTE IMMEDIATE v_query;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            err_msg:= SUBSTR(SQLERRM, 1, 100);
            p_log(proc_name || ' ip_update_parent', 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
    END;
       
BEGIN
    
    p_log(proc_name, 'I', 'Start Application for DOC ID: ' || p_doc_id);
    -- Get beleidsdocument_id for Document
    SELECT beleidsdocument_id INTO v_id4doc
    FROM beleidsdocument
    WHERE doc_id = p_doc_id
    AND parent_id = -1;
    title_id(0) := v_id4doc;
    
    OPEN doc_cursor;
    LOOP
        FETCH doc_cursor INTO doc_rec;
        EXIT WHEN doc_cursor%NOTFOUND;
        -- Check if dot is last character,
        -- add if it is not (then number of dots = level)
        IF (NOT(regexp_like(doc_rec.toc, '\.$'))) THEN
            doc_rec.toc := doc_rec.toc || '.';
        END IF;
        v_lvl := regexp_count(doc_rec.toc, '\.');
        IF (v_lvl = (v_prev_lvl + 1)) THEN
            v_parent_id := title_id(v_prev_lvl);
            title_id(v_lvl) := doc_rec.beleidsdocument_id;
            v_prev_lvl := v_lvl;
            ip_update_parent_id(doc_rec, v_parent_id);
        ELSIF (v_lvl <= v_prev_lvl) THEN
            IF (v_lvl > 0) THEN
                v_parent_id := title_id(v_lvl - 1);
                title_id(v_lvl) := doc_rec.beleidsdocument_id;
                v_prev_lvl := v_lvl;
                ip_update_parent_id(doc_rec, v_parent_id);
            ELSE
                p_log(proc_name, 'E', doc_rec.beleidsdocument_id || ' ID with invalid TOC (level 0)');
                ip_update_parent_id(doc_rec, v_id4doc);
            END IF;
        ELSE
            p_log(proc_name, 'E', doc_rec.beleidsdocument_id || ' ID with unexpected jump from level ' || v_prev_lvl || ' to level ' || v_lvl);
            -- Update title_id for all levels up to ID from document
            FOR v_cnt IN (v_prev_lvl + 1) .. v_lvl
            LOOP
                title_id(v_cnt) := title_id(v_prev_lvl);
            END LOOP;
            v_parent_id := title_id(v_prev_lvl);
            ip_update_parent_id(doc_rec, v_parent_id);            
            v_prev_lvl := v_lvl;
            title_id(v_lvl) := doc_rec.beleidsdocument_id;
        END IF;
    END LOOP;
        
    p_log(proc_name, 'I', 'End Application');
    
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_BELEIDSDOCUMENT2XML" 
IS
    proc_name logtbl.evt_proc%TYPE := 'p_beleidsdocument2xml';
    cursor doc_cursor is
    select beleidsdocument_id,
        parent_id,
        toc,
        titel,
        doc_id
    from beleidsdocument
    where beleidsdocument_id > 0;
    type doc_record is record (
        r_id beleidsdocument.beleidsdocument_id%TYPE,
        r_parent_id beleidsdocument.parent_id%TYPE,
        r_toc beleidsdocument.toc%TYPE,
        r_titel beleidsdocument.titel%TYPE,
        r_doc_id beleidsdocument.doc_id%TYPE);
        
    doc doc_record;
    f utl_file.file_type;
    err_num number;
    err_line number;
    err_msg varchar2(255);
BEGIN
    f := utl_file.fopen('DATAROOM_OUT', 'beleidsdocumenten.xml', 'w');
    
    utl_file.put_line(f, '<?xml version="1.0"?>');
    utl_file.put_line(f, '<beleidsdocumenten>');
    
    OPEN doc_cursor;
    LOOP
        FETCH doc_cursor INTO doc;
        EXIT WHEN doc_cursor%NOTFOUND;
    
        utl_file.put_line(f,'<beleidsdocument>');
        utl_file.put_line(f,'<id>' || doc.r_id || '</id>');
        if (length(doc.r_parent_id) > 0) then
            utl_file.put_line(f,'<parent_id>' || doc.r_parent_id || '</parent_id>');
        end if;
        if (length(doc.r_toc) > 0) then
            utl_file.put_line(f,'<toc><![CDATA[' || doc.r_toc || ']]></toc>');
        end if;
        utl_file.put_line(f,'<doc_id>' || doc.r_doc_id || '</doc_id>');
        utl_file.put_line(f,'<titel>');
        utl_file.put_line(f,'<![CDATA[' || doc.r_titel || ']]>');
        utl_file.put_line(f,'</titel>');
        
        utl_file.put_line(f,'</beleidsdocument>');
         
    END LOOP;
    utl_file.put_line(f, '</beleidsdocumenten>');
    utl_file.fclose(f);
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        err_num:= SQLCODE;
        err_line := $$PLSQL_LINE;
        p_log(proc_name, 'E', 'Onverwachte fout lijn: ' || err_line || ' nr: ' || err_num || ' msg: ' || err_msg);
        
END;
/

CREATE OR REPLACE PROCEDURE  "P_ADD_AANSPREEKORGANISATIE" (p_indicatorfiche_id IN indicatorfiche.indicatorfiche_id%TYPE,
                                                       p_persoon_id IN persoon.persoon_id%TYPE)
    IS
    
    -- This procedure will add the aanspreekorganisatie if there is no aanspreekorganisatie defined 
    -- and if the persoon is member of an aanspreekorganisatie.
    proc_name logtbl.evt_proc%TYPE := 'p_add_aanspreekorganisatie';
    err_msg varchar2(255);
    v_organisatie_id indicatorfiche.aanspreekorganisatie_id%TYPE;
    v_query varchar2(255);
    cursor aanspreekorganisatie_cursor IS
        SELECT p.organisatie_id
        FROM indicatorfiche i, persoon p
        WHERE i.indicatorfiche_id = p_indicatorfiche_id
        AND i.aanspreekorganisatie_id = -1
        AND p.persoon_id = p_persoon_id
        AND NOT (p.organisatie_id = -1);
    
BEGIN
    
    OPEN aanspreekorganisatie_cursor;
    FETCH aanspreekorganisatie_cursor INTO v_organisatie_id;
    IF aanspreekorganisatie_cursor%NOTFOUND THEN
        -- aanspreekorganisatie already available (not -1)
        -- or persoon not part of organisatie
        RETURN;
    ELSE
        -- aanspreekorganisatie not available (= -1)
        -- and persoon part of organisatie
        v_query := 'UPDATE INDICATORFICHE SET aanspreekorganisatie_id = ' || v_organisatie_id || ' WHERE indicatorfiche_id = ' || p_indicatorfiche_id;
        EXECUTE IMMEDIATE v_query;
    END IF;
    RETURN;
    
EXCEPTION
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
        RETURN;
END;
/

 CREATE SEQUENCE   "AANT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "APEX_ACCESS_CONTROL_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1060 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "BELEIDSDOCUMENT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1080 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "COMMENTAAR_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1080 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "COMM_LOAD_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 121 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "CSV_FILES_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 161 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "CSV_LOAD_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 6401 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "DIMENSIE_FICHE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1340 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "DIMENSIE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1000 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "DIM_ELEMENT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1080 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "DOCUMENT_FICHE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1000 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "FILE_OBJECT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 561 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "FILE_PROCESS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 3521 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "GEO_COORDINATEN_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 402 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "GEO_GROEP_FICHE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 21 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "GEO_GROEP_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 2 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "GEO_OBJECT_GROEP_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 20404 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "GEO_OBJECT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 21221 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "GEO_REPORT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 20607 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "GEO_STATUS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1224 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "GEPUBLICEERD_FICHE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1020 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "INDICATORFICHE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1000 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "INDICATOR_ELEMENT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1000 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "INDICATOR_REPORT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 5080 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "LOGTBL_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 15680 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "ORGANISATIE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1180 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "PERSOON_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1100 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "REFERENTIE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1220 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "ROL_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1400 CACHE 20 NOORDER  NOCYCLE
/
 CREATE SEQUENCE   "TREFWOORD_FICHE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1002 NOCACHE  NOORDER  NOCYCLE
/
CREATE OR REPLACE TRIGGER  "INDICATOR_REPORT_UPD" 
BEFORE
insert or update on "INDICATOR_REPORT"
for each row
begin
:new.LAATST_BIJGEWERKT := sysdate;
end;

/
ALTER TRIGGER  "INDICATOR_REPORT_UPD" ENABLE
/
CREATE OR REPLACE TRIGGER  "INDICATOR_REPORT_DAGNR" 
BEFORE
insert or update on "INDICATOR_REPORT"
for each row
declare
    v_meetfrequentie indicatorfiche.meetfrequentie%type;
    proc_name varchar2(255) := 'indicator_report_dagnr';
begin
    select meetfrequentie into v_meetfrequentie 
    from indicatorfiche 
    where indicatorfiche_id = :new.indicatorfiche_id;
    if (v_meetfrequentie = 'jaar') then 
        select min(f.dagnr) into :new.dagnr 
        from frequenties f
        where f.jaar = :new.jaar;
        select jaar into :new.periode
        from frequenties f
        where f.dagnr = :new.dagnr;
    elsif (v_meetfrequentie = 'maand') then
        select min(f.dagnr) into :new.dagnr
        from frequenties f
        where f.jaar = :new.jaar
        and f.maand = :new.label;
        select maand_label into :new.periode
        from frequenties f
        where f.dagnr = :new.dagnr;
    elsif (v_meetfrequentie = 'kwartaal') then
        select min(f.dagnr) into :new.dagnr
        from frequenties f
        where f.jaar = :new.jaar
        and f.kwartaal = :new.label;
        select kwartaal_label into :new.periode
        from frequenties f
        where f.dagnr = :new.dagnr;
    elsif (v_meetfrequentie = 'schooljaar') then
        select min(f.dagnr) into :new.dagnr
        from frequenties f
        where f.schooljaar_label = :new.schooljaar;
        select schooljaar_label into :new.periode
        from frequenties f
        where f.dagnr = :new.dagnr;
    else
        p_log(proc_name, 'E', 'Unknown meetfrequentie ' || v_meetfrequentie);
        select min(f.dagnr) into :new.dagnr
        from frequenties f;
    end if;
end;

/
ALTER TRIGGER  "INDICATOR_REPORT_DAGNR" ENABLE
/
CREATE OR REPLACE TRIGGER  "INDICATORFICHE_T1" 
BEFORE
insert or update on "INDICATORFICHE"
for each row
begin
:new.FICHE_LAATST_BIJGEWERKT := sysdate;
end;
/
ALTER TRIGGER  "INDICATORFICHE_T1" ENABLE
/
CREATE OR REPLACE TRIGGER  "INDICATORFICHE_FICHE_UPD" 
BEFORE
insert or update on "INDICATORFICHE"
for each row
begin
:new.FICHE_LAATST_BIJGEWERKT := sysdate;
end;

/
ALTER TRIGGER  "INDICATORFICHE_FICHE_UPD" ENABLE
/
CREATE OR REPLACE TRIGGER  "GEO_REPORT_UPD" 
BEFORE
insert or update on "GEO_REPORT"
for each row
begin
:new.LAATST_BIJGEWERKT := sysdate;
end;

/
ALTER TRIGGER  "GEO_REPORT_UPD" ENABLE
/
CREATE OR REPLACE TRIGGER  "GEO_REPORT_DAGNR" 
BEFORE
insert or update on "GEO_REPORT"
for each row
begin
declare
    v_meetfrequentie indicatorfiche.meetfrequentie%type;
    proc_name varchar2(255) := 'geo_report_dagnr';
begin
    select meetfrequentie into v_meetfrequentie 
        from indicatorfiche 
        where indicatorfiche_id = :new.indicatorfiche_id;
    if (v_meetfrequentie = 'jaar') then 
        select min(f.dagnr) into :new.dagnr 
            from frequenties f
            where f.jaar = :new.jaar;
        select jaar into :new.periode
            from frequenties f
            where f.dagnr = :new.dagnr;
    elsif (v_meetfrequentie = 'maand') then
        select min(f.dagnr) into :new.dagnr
            from frequenties f
            where f.jaar = :new.jaar
            and f.maand = :new.label;
        select maand_label into :new.periode
            from frequenties f
            where f.dagnr = :new.dagnr;
    elsif (v_meetfrequentie = 'kwartaal') then
        select min(f.dagnr) into :new.dagnr
            from frequenties f
            where f.jaar = :new.jaar
            and f.kwartaal = :new.label;
        select kwartaal_label into :new.periode
            from frequenties f
            where f.dagnr = :new.dagnr;
    elsif (v_meetfrequentie = 'schooljaar') then
        select min(f.dagnr) into :new.dagnr
            from frequenties f
            where f.schooljaar_label = :new.schooljaar;
        select schooljaar_label into :new.periode
            from frequenties f
            where f.dagnr = :new.dagnr;
    else
        p_log(proc_name, 'E', 'Unknown meetfrequentie ' || v_meetfrequentie);
        select min(f.dagnr) into :new.dagnr
        from frequenties f;
    end if;
end;
end;

/
ALTER TRIGGER  "GEO_REPORT_DAGNR" ENABLE
/
CREATE OR REPLACE TRIGGER  "FILE_PROCESS_T1" 
BEFORE
insert on "FILE_PROCESS"
for each row
begin
:new.PROCESS_TIME := sysdate;
end;
/
ALTER TRIGGER  "FILE_PROCESS_T1" ENABLE
/
CREATE OR REPLACE TRIGGER  "FILE_OBJECT_T1" 
BEFORE
insert on "FILE_OBJECT"
for each row
begin
:new.FOUND := sysdate;
end;
/
ALTER TRIGGER  "FILE_OBJECT_T1" ENABLE
/
CREATE OR REPLACE TRIGGER  "CSV_FILES_UPD" 
BEFORE
insert or update on "CSV_FILES"
for each row
begin
:new.LAST_MODIFIED := sysdate;
end;
/
ALTER TRIGGER  "CSV_FILES_UPD" ENABLE
/
CREATE OR REPLACE TRIGGER  "COMMENTAAR_UPD_T" 
BEFORE
insert or update on "COMMENTAAR"
for each row
begin
:new.LAATST_BIJGEWERKT := sysdate;
end;

/
ALTER TRIGGER  "COMMENTAAR_UPD_T" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_TREFWOORD_FICHE" 
  before insert on "TREFWOORD_FICHE"               
  for each row  
begin   
  if :NEW."TREFWOORD_FICHE_ID" is null then 
    select "TREFWOORD_FICHE_SEQ".nextval into :NEW."TREFWOORD_FICHE_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_TREFWOORD_FICHE" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_ROL" 
  before insert on "ROL"               
  for each row  
begin   
  if :NEW."ROL_ID" is null then 
    select "ROL_SEQ".nextval into :NEW."ROL_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_ROL" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_REFERENTIE" 
  before insert on "REFERENTIE"               
  for each row  
begin   
  if :NEW."REFERENTIE_ID" is null then 
    select "REFERENTIE_SEQ".nextval into :NEW."REFERENTIE_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_REFERENTIE" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_PERSOON" 
  before insert on "PERSOON"               
  for each row  
begin   
  if :NEW."PERSOON_ID" is null then 
    select "PERSOON_SEQ".nextval into :NEW."PERSOON_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_PERSOON" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_ORGANISATIE" 
  before insert on "ORGANISATIE"               
  for each row  
begin   
  if :NEW."ORGANISATIE_ID" is null then 
    select "ORGANISATIE_SEQ".nextval into :NEW."ORGANISATIE_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_ORGANISATIE" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_LOGTBL" 
  before insert on "LOGTBL"               
  for each row  
begin   
  if :NEW."EVT_IDX" is null then 
    select "LOGTBL_SEQ".nextval into :NEW."EVT_IDX" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_LOGTBL" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_INDICATOR_REPORT" 
  before insert on "INDICATOR_REPORT"               
  for each row  
begin   
  if :NEW."INDICATOR_REPORT_ID" is null then 
    select "INDICATOR_REPORT_SEQ".nextval into :NEW."INDICATOR_REPORT_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_INDICATOR_REPORT" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_INDICATORFICHE" 
  before insert on "INDICATORFICHE"               
  for each row  
begin   
  if :NEW."INDICATORFICHE_ID" is null then 
    select "INDICATORFICHE_SEQ".nextval into :NEW."INDICATORFICHE_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_INDICATORFICHE" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_GEPUBLICEERD_FICHE" 
  before insert on "GEPUBLICEERD_FICHE"               
  for each row  
begin   
  if :NEW."GEPUBLICEERD_FICHE_ID" is null then 
    select "GEPUBLICEERD_FICHE_SEQ".nextval into :NEW."GEPUBLICEERD_FICHE_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_GEPUBLICEERD_FICHE" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_GEO_STATUS" 
  before insert on "GEO_STATUS"               
  for each row  
begin   
  if :NEW."GEO_STATUS_ID" is null then 
    select "GEO_STATUS_SEQ".nextval into :NEW."GEO_STATUS_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_GEO_STATUS" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_GEO_REPORT" 
  before insert on "GEO_REPORT"               
  for each row  
begin   
  if :NEW."GEO_REPORT_ID" is null then 
    select "GEO_REPORT_SEQ".nextval into :NEW."GEO_REPORT_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_GEO_REPORT" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_GEO_OBJECT_GROEP" 
  before insert on "GEO_OBJECT_GROEP"               
  for each row  
begin   
  if :NEW."GEO_OBJECT_GROEP_ID" is null then 
    select "GEO_OBJECT_GROEP_SEQ".nextval into :NEW."GEO_OBJECT_GROEP_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_GEO_OBJECT_GROEP" ENABLE
/
CREATE OR REPLACE TRIGGER  "bi_GEO_OBJECT" 
  before insert on "GEO_OBJECT"              
  for each row 
begin  
  if :new."GEO_OBJECT_ID" is null then
    select "GEO_OBJECT_SEQ".nextval into :new."GEO_OBJECT_ID" from sys.dual;
  end if;
end;

/
ALTER TRIGGER  "bi_GEO_OBJECT" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_GEO_GROEP_FICHE" 
  before insert on "GEO_GROEP_FICHE"               
  for each row  
begin   
  if :NEW."GEO_GROEP_FICHE_ID" is null then 
    select "GEO_GROEP_FICHE_SEQ".nextval into :NEW."GEO_GROEP_FICHE_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_GEO_GROEP_FICHE" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_GEO_GROEP" 
  before insert on "GEO_GROEP"               
  for each row  
begin   
  if :NEW."GEO_GROEP_ID" is null then 
    select "GEO_GROEP_SEQ".nextval into :NEW."GEO_GROEP_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_GEO_GROEP" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_GEO_COORDINATEN" 
  before insert on "GEO_COORDINATEN"               
  for each row  
begin   
  if :NEW."GEO_COORDINATEN_ID" is null then 
    select "GEO_COORDINATEN_SEQ".nextval into :NEW."GEO_COORDINATEN_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_GEO_COORDINATEN" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_FILE_PROCESS" 
  before insert on "FILE_PROCESS"               
  for each row  
begin   
  if :NEW."FILE_PROCESS_ID" is null then 
    select "FILE_PROCESS_SEQ".nextval into :NEW."FILE_PROCESS_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_FILE_PROCESS" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_FILE_OBJECT" 
  before insert on "FILE_OBJECT"               
  for each row  
begin   
  if :NEW."FILE_OBJECT_ID" is null then 
    select "FILE_OBJECT_SEQ".nextval into :NEW."FILE_OBJECT_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_FILE_OBJECT" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_DOCUMENT_FICHE" 
  before insert on "DOCUMENT_FICHE"               
  for each row  
begin   
  if :NEW."DOCUMENT_FICHE_ID" is null then 
    select "DOCUMENT_FICHE_SEQ".nextval into :NEW."DOCUMENT_FICHE_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_DOCUMENT_FICHE" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_DIMENSIE_FICHE" 
  before insert on "DIMENSIE_FICHE"               
  for each row  
begin   
  if :NEW."DIMENSIE_FICHE_ID" is null then 
    select "DIMENSIE_FICHE_SEQ".nextval into :NEW."DIMENSIE_FICHE_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_DIMENSIE_FICHE" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_DIMENSIE" 
  before insert on "DIMENSIE"               
  for each row  
begin   
  if :NEW."DIMENSIE_ID" is null then 
    select "DIMENSIE_SEQ".nextval into :NEW."DIMENSIE_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_DIMENSIE" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_DIM_ELEMENT" 
  before insert on "DIM_ELEMENT"               
  for each row  
begin   
  if :NEW."DIM_ELEMENT_ID" is null then 
    select "DIM_ELEMENT_SEQ".nextval into :NEW."DIM_ELEMENT_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_DIM_ELEMENT" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_CSV_LOAD" 
  before insert on "CSV_LOAD"               
  for each row  
begin   
  if :NEW."CSV_LOAD_ID" is null then 
    select "CSV_LOAD_SEQ".nextval into :NEW."CSV_LOAD_ID" from sys.dual; 
  end if; 
end;
/
ALTER TRIGGER  "BI_CSV_LOAD" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_CSV_FILES" 
  before insert on "CSV_FILES"               
  for each row  
begin   
  if :NEW."CSV_FILES_ID" is null then 
    select "CSV_FILES_SEQ".nextval into :NEW."CSV_FILES_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_CSV_FILES" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_COMM_LOAD" 
  before insert on "COMM_LOAD"               
  for each row  
begin   
  if :NEW."COMM_LOAD_ID" is null then 
    select "COMM_LOAD_SEQ".nextval into :NEW."COMM_LOAD_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_COMM_LOAD" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_COMMENTAAR" 
  before insert on "COMMENTAAR"               
  for each row  
begin   
  if :NEW."COMMENTAAR_ID" is null then 
    select "COMMENTAAR_SEQ".nextval into :NEW."COMMENTAAR_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_COMMENTAAR" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_BELEIDSDOCUMENT" 
  before insert on "BELEIDSDOCUMENT"               
  for each row  
begin   
  if :NEW."BELEIDSDOCUMENT_ID" is null then 
    select "BELEIDSDOCUMENT_SEQ".nextval into :NEW."BELEIDSDOCUMENT_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_BELEIDSDOCUMENT" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_APEX_ACCESS_SETUP" 
before insert or update on apex_access_setup 
for each row
begin
if inserting and :new.id is null then
select apex_access_control_seq.nextval into :new.id from sys.dual;
end if;
if :new.application_id is null then
:new.application_id := v('APP_ID');
end if;
end;

/
ALTER TRIGGER  "BI_APEX_ACCESS_SETUP" ENABLE
/
CREATE OR REPLACE TRIGGER  "BI_APEX_ACCESS_CONTROL" 
  before insert or update on apex_access_control
  for each row
begin
    if inserting and :new.id is null then
        select apex_access_control_seq.nextval into :new.id from sys.dual;
    end if;
    if inserting then
        :new.created_by := v('USER');
        :new.created_on := sysdate;
    end if;
    if updating then
        :new.updated_by := v('USER');
        :new.updated_on := sysdate;
    end if;
end; 

/
ALTER TRIGGER  "BI_APEX_ACCESS_CONTROL" ENABLE
/
CREATE OR REPLACE TRIGGER  "bi_AANT" 
  before insert on "AANT"              
  for each row 
begin  
  if :new."INDICATORFICHE_ID" is null then
    select "AANT_SEQ".nextval into :new."INDICATORFICHE_ID" from sys.dual;
  end if;
end;

/
ALTER TRIGGER  "bi_AANT" ENABLE
/
CREATE OR REPLACE FORCE VIEW  "GEO_CONSOLIDATIE" ("INDICATORFICHE_ID", "DAGNR", "TYPE_MONITORINGSYSTEEM", "TYPE_SIGNALISATIESYSTEEM", "GEO_STATUS_ID", "AANTAL", "ACTIEF") AS 
  select r.indicatorfiche_id, r.dagnr, o.type_monitoringsysteem, o.type_signalisatiesysteem, r.geo_status_id, count(*) as aantal, r.actief
from geo_report r, geo_object o
where actief = 'J'
and r.geo_object_id = o.geo_object_id
group by r.indicatorfiche_id, r.dagnr, o.type_monitoringsysteem, o.type_signalisatiesysteem, r.geo_status_id, r.actief
/
CREATE OR REPLACE FORCE VIEW  "GEO_CONSOLIDATIE_LABELS" ("INDICATORFICHE_ID", "INDICATOR_NAAM", "PERIODE", "type monitoringsysteem", "type signalisatiesysteem", "WAARDE", "AANTAL", "ACTIEF") AS 
  select r.indicatorfiche_id, i.indicator_naam, r.periode, e1.waarde "type monitoringsysteem", e2.waarde "type signalisatiesysteem", s.waarde, count(*) as aantal, r.actief
from geo_report r, geo_object o,indicatorfiche i, geo_status s, dim_element e1, dim_element e2
where r.geo_object_id = o.geo_object_id
and r.indicatorfiche_id = i.indicatorfiche_id
and r.geo_status_id = s.geo_status_id
and o.type_monitoringsysteem = e1.dim_element_id
and o.type_signalisatiesysteem = e2.dim_element_id
group by r.indicatorfiche_id, i.indicator_naam, r.periode, e1.waarde, e2.waarde, s.waarde, r.actief
/
CREATE OR REPLACE FORCE VIEW  "INDICATORLIJN" ("INDICATOR_REPORT_ID", "INDICATORFICHE_ID", "PERIODE", "TYPE_DAG", "DAGDEEL", "TYPE VERKEERSSITUATIE", "PROVINCIE", "GEMEENTE", "NETWERK", "NETWERKLINK", "TYPE_INFRASTRUCTUUR", "ENTITEIT", "TYPE_MEDEWERKER", "VERPLAATSINGSMOTIEF", "HOOFDVERVOERSWIJZE", "AFSTANDSKLASSE", "VERVOERSBEWIJS", "VOERTUIGTYPE", "VOERTUIGMODEL", "REFERENTIEJAAR", "STORMVLOEDPEIL", "TYPE_TOELAGE", "TYPE_ONDERHOUD", "TYPE_INCIDENT", "TYPE_ONDERWIJS", "TYPE_DOOIMIDDEL", "KLASSE_FIETSPADEN", "LAATST_BIJGEWERKT", "GERESERVEERD_1", "GERESERVEERD_2", "GERESERVEERD_3", "AANTAL", "PERCENTAGE", "VRIJGEVEN") AS 
  select INDICATOR_REPORT_ID,
    INDICATORFICHE_ID,
    f_dagnr_periode(indicatorfiche_id, dagnr) "PERIODE",
    f_el(TYPE_DAG) "Type Dag",
    f_el(DAGDEEL) "Dagdeel",
    f_el(TYPE_VERKEERSSITUATIE) "Type Verkeerssituatie",
    f_el(PROVINCIE) "Provincie",
    f_el(GEMEENTE) "Gemeente",
    f_el(NETWERK) "Netwerk",
    f_el(NETWERKLINK) "Netwerklink",
    f_el(TYPE_INFRASTRUCTUUR) "Type Infrastructuur",
    f_el(ENTITEIT) "Entiteit",
    f_el(TYPE_MEDEWERKER) "Type Medewerker",
    f_el(VERPLAATSINGSMOTIEF) "Verplaatsingsmotief",
    f_el(HOOFDVERVOERSWIJZE) "Hoofdvervoerswijze",
    f_el(AFSTANDSKLASSE) "Afstandsklasse",
    f_el(VERVOERSBEWIJS) "Vervoersbewijs",
    f_el(VOERTUIGTYPE) "Voertuigtype",
    f_el(VOERTUIGMODEL) "Voertuigmodel",
    f_el(REFERENTIEJAAR) "Referentiejaar",
    f_el(STORMVLOEDPEIL) "Stormvloedpeil",
    f_el(TYPE_TOELAGE) "Type Toelage",
    f_el(TYPE_ONDERHOUD) "Type Onderhoud",
    f_el(TYPE_INCIDENT) "Type Incident",
    f_el(TYPE_ONDERWIJS) "Type Onderwijs",
    f_el(TYPE_DOOIMIDDEL) "Type Dooimiddel",
    f_el(KLASSE_FIETSPADEN) "Klasse Fietspaden",
    LAATST_BIJGEWERKT,
    GERESERVEERD_1,
    GERESERVEERD_2,
    GERESERVEERD_3,
    AANTAL,
    PERCENTAGE,
    f_jn(ACTIEF) VRIJGEVEN
 from INDICATOR_REPORT
/

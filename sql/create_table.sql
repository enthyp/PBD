-- ATTENDEES --
CREATE TABLE ATTENDEES
(
  ATTENDEE_ID NUMBER
    GENERATED BY DEFAULT ON NULL AS IDENTITY
    PRIMARY KEY,
  FIRST_NAME VARCHAR2(50) NOT NULL,
  LAST_NAME VARCHAR2(100) NOT NULL,
  STUDENT_CARD CHAR(10) DEFAULT NULL,
    CONSTRAINT ATTENDEES_STUDENT_CARD_CHK
      CHECK (REGEXP_LIKE(STUDENT_CARD, '^[[:digit:]]+$')),
    CONSTRAINT ATTENDEES_STUDENT_CARD_UK
      UNIQUE (STUDENT_CARD),
  EMAIL VARCHAR2(255) NOT NULL,
    CONSTRAINT ATTENDEES_EMAIL_CHK
      CHECK (EMAIL LIKE '%_@_%'),
    CONSTRAINT ATTENDEES_EMAIL_UK
      UNIQUE (EMAIL),
  PHONE CHAR(9) DEFAULT NULL,
    CONSTRAINT ATTENDEES_PHONE_CHK
      CHECK (REGEXP_LIKE(PHONE, '^[[:digit:]]+$'))
);


-- CLIENTS --
CREATE TABLE CLIENTS
(
    CLIENT_ID NUMBER
      GENERATED BY DEFAULT ON NULL AS IDENTITY
      PRIMARY KEY,
    IS_COMPANY CHAR(1) DEFAULT 'N' NOT NULL,
      CONSTRAINT CLIENTS_IS_COMPANY_CHK
        CHECK (IS_COMPANY IN ('Y', 'N')),
    CLIENT_NAME VARCHAR2(100) NOT NULL,
      CONSTRAINT CLIENTS_CLIENT_NAME_UK
        UNIQUE (CLIENT_NAME),
    COUNTRY VARCHAR2(50) DEFAULT NULL,
    CITY VARCHAR2(50) DEFAULT NULL,
    ADDRESS VARCHAR2(100) DEFAULT NULL,
    PHONE CHAR(9) DEFAULT NULL,
      CONSTRAINT CLIENTS_PHONE_CHK
        CHECK (REGEXP_LIKE(PHONE, '^[[:digit:]]+$')),
    EMAIL VARCHAR2(255) NOT NULL,
      CONSTRAINT CLIENTS_EMAIL_CHK
        CHECK (EMAIL LIKE '%@%'),
      CONSTRAINT CLIENTS_EMAIL_UK
        UNIQUE (EMAIL),
    PASSWORD VARCHAR2(255) NOT NULL
);


-- CONFERENCES --
CREATE TABLE CONFERENCES
(
  CONFERENCE_ID NUMBER
    GENERATED BY DEFAULT ON NULL AS IDENTITY
    PRIMARY KEY,
  CONFERENCE_NAME VARCHAR2(255) NOT NULL,
  COUNTRY VARCHAR2(50) NOT NULL,
  CITY VARCHAR2(50) NOT NULL,
  ADDRESS VARCHAR2(100) NOT NULL,
  FIRST_DAY DATE NOT NULL,
  LAST_DAY DATE NOT NULL,
    CONSTRAINT CONFERENCES_LAST_DAY_CHK
      CHECK (LAST_DAY >= FIRST_DAY),
  STUDENT_DISCOUNT NUMBER(5, 2) DEFAULT 0 NOT NULL,
    CONSTRAINT CONFERENCES_STUDENT_DISCOUNT_CHK
      CHECK (STUDENT_DISCOUNT BETWEEN 0 AND 100)
);


-- BOOKINGS --
CREATE TABLE BOOKINGS
(
  BOOKING_ID NUMBER
    GENERATED BY DEFAULT ON NULL AS IDENTITY
    PRIMARY KEY,
  CLIENT_ID NUMBER NOT NULL,
    CONSTRAINT BOOKINGS_CLIENT_ID_FK
      FOREIGN KEY (CLIENT_ID)
      REFERENCES CLIENTS(CLIENT_ID)
      ON DELETE CASCADE,
  CONFERENCE_ID NUMBER NOT NULL,
    CONSTRAINT BOOKINGS_CONFERENCE_ID_FK
      FOREIGN KEY (CONFERENCE_ID)
      REFERENCES CONFERENCES(CONFERENCE_ID)
      ON DELETE CASCADE,
  IS_CANCELLED  CHAR(1) DEFAULT 'N' NOT NULL,
    CONSTRAINT BOOKINGS_IS_CANCELLED_CHK
      CHECK (IS_CANCELLED IN ('Y', 'N')),
  BOOKING_DATE DATE NOT NULL
);


-- PRICES --
CREATE TABLE PRICES
(
  PRICE_ID NUMBER
    GENERATED BY DEFAULT ON NULL AS IDENTITY
    PRIMARY KEY,
  CONFERENCE_ID NUMBER NOT NULL,
    CONSTRAINT PRICES_CONFERENCE_ID_FK
      FOREIGN KEY (CONFERENCE_ID)
      REFERENCES CONFERENCES(CONFERENCE_ID)
      ON DELETE CASCADE,
  DISCOUNT NUMBER(5, 2) NOT NULL,
    CONSTRAINT PRICES_DISCOUNT_CHK
      CHECK (DISCOUNT BETWEEN 0 AND 100),
  END_DATE DATE NOT NULL,
  CONSTRAINT PRICES_PRICE_UK
    UNIQUE (CONFERENCE_ID, END_DATE)
);


-- CONFERENCE DAYS --
CREATE TABLE CONFERENCE_DAYS
(
  CONF_DAY_ID NUMBER
    GENERATED BY DEFAULT ON NULL AS IDENTITY
    PRIMARY KEY,
  CONFERENCE_ID NUMBER NOT NULL,
    CONSTRAINT CONFERENCE_DAYS_CONFERENCE_ID_FK
      FOREIGN KEY (CONFERENCE_ID)
      REFERENCES CONFERENCES(CONFERENCE_ID)
      ON DELETE CASCADE,
  PRICE NUMBER NOT NULL
    CONSTRAINT CONFERENCE_DAYS_NONNEGATIVE_PRICE_CHK
      CHECK (PRICE >= 0),
  LIMIT INTEGER NOT NULL
    CONSTRAINT CONFERENCE_DAYS_POSITIVE_LIMIT_CHK
      CHECK (LIMIT > 0),
  DAY_DATE DATE NOT NULL,
  CONSTRAINT CONFERENCE_DAYS_CONF_DAY_UK
    UNIQUE (CONFERENCE_ID, DAY_DATE)
);


-- CONFERENCE DAY BOOKINGS --
CREATE TABLE CONF_DAY_BOOKINGS
(
  CONF_DAY_BOOKING_ID NUMBER
    GENERATED BY DEFAULT ON NULL AS IDENTITY
    PRIMARY KEY,
  BOOKING_ID NUMBER NOT NULL,
    CONSTRAINT CONF_DAY_BOOKINGS_BOOKING_ID_FK
      FOREIGN KEY (BOOKING_ID)
      REFERENCES BOOKINGS(BOOKING_ID)
      ON DELETE CASCADE,
  CONF_DAY_ID NUMBER NOT NULL,
    CONSTRAINT CONF_DAY_BOOKINGS_CONF_DAY_ID_FK
      FOREIGN KEY (CONF_DAY_ID)
      REFERENCES CONFERENCE_DAYS(CONF_DAY_ID),
  NUMBER_OF_STUDENTS INTEGER NOT NULL,
    CONSTRAINT CONF_DAY_BOOKINGS_NUM_OF_STUDENTS_CHK
      CHECK (NUMBER_OF_STUDENTS >= 0),
  NUMBER_OF_ATTENDEES INTEGER NOT NULL,
    CONSTRAINT CONF_DAY_BOOKINGS_NUM_OF_ATTENDEES_CHK
      CHECK (NUMBER_OF_ATTENDEES > 0),
    CONSTRAINT CONF_DAY_BOOKINGS_ATTENDEES_GEQ_STUDENTS_CHK
      CHECK (NUMBER_OF_ATTENDEES >= NUMBER_OF_STUDENTS),
  IS_CANCELLED CHAR(1) DEFAULT 'N' NOT NULL,
    CONSTRAINT CONF_DAY_BOOKINGS_IS_CANCELLED_CHK
      CHECK (IS_CANCELLED IN ('Y', 'N'))
);


-- PARTICIPATION CONFERENCE DAYS --
CREATE TABLE PARTICIPATION_CONF_DAYS
(
  PARTICIPATION_CONF_DAY_ID NUMBER
    GENERATED BY DEFAULT ON NULL AS IDENTITY
    PRIMARY KEY,
  CONF_DAY_ID NUMBER NOT NULL,
    CONSTRAINT PARTICIPATION_CONF_DAYS_CONF_DAY_ID_FK
      FOREIGN KEY (CONF_DAY_ID)
      REFERENCES CONFERENCE_DAYS(CONF_DAY_ID),
  ATTENDEE_ID NUMBER NOT NULL,
    CONSTRAINT PARTICIPATION_CONF_DAYS_ATTENDEE_ID_FK
      FOREIGN KEY (ATTENDEE_ID)
      REFERENCES ATTENDEES(ATTENDEE_ID)
      ON DELETE CASCADE,
  BOOKING_ID NUMBER NOT NULL,
    CONSTRAINT PARTICIPATION_CONF_DAYS_BOOKING_ID_FK
      FOREIGN KEY (BOOKING_ID)
      REFERENCES BOOKINGS(BOOKING_ID)
      ON DELETE CASCADE,
  IS_STUDENT CHAR(1) DEFAULT 'N' NOT NULL,
    CONSTRAINT PARTICIPATION_CONF_DAYS_IS_STUDENT_CHK
      CHECK (IS_STUDENT IN ('Y', 'N')),
  CONSTRAINT PARTICIPATION_CONF_DAYS_UK
    UNIQUE (CONF_DAY_ID, ATTENDEE_ID, BOOKING_ID)
);


-- WORKSHOPS --
CREATE TABLE WORKSHOPS
(
  WORKSHOP_ID NUMBER
    GENERATED BY DEFAULT ON NULL AS IDENTITY
    PRIMARY KEY,
  CONF_DAY_ID NUMBER NOT NULL,
    CONSTRAINT WORKSHOPS_CONF_DAY_ID_FK
      FOREIGN KEY (CONF_DAY_ID)
      REFERENCES CONFERENCE_DAYS(CONF_DAY_ID)
      ON DELETE CASCADE,
  WORKSHOP_NAME VARCHAR2(255) NOT NULL,
  START_TIME TIMESTAMP(0) NOT NULL,
  END_TIME TIMESTAMP(0) NOT NULL,
    CONSTRAINT WORKSHOPS_END_AFTER_START_CHK
      CHECK (END_TIME > START_TIME),
    CONSTRAINT WORKSHOPS_END_START_SAME_DAY_CHK
      CHECK (TRUNC(END_TIME) = TRUNC(START_TIME)),
  PRICE NUMBER NOT NULL,
    CONSTRAINT WORKSHOPS_PRICE_CHK
      CHECK (PRICE >= 0),
  LIMIT INTEGER NOT NULL,
    CONSTRAINT WORKSHOPS_LIMIT_CHK
      CHECK (LIMIT > 0)
);

-- PARTICIPATION WORKSHOPS --
CREATE TABLE PARTICIPATION_WORKSHOPS
(
  PARTICIPATION_WORKSHOP_ID NUMBER
    GENERATED BY DEFAULT ON NULL AS IDENTITY
    PRIMARY KEY,
  WORKSHOP_ID NUMBER NOT NULL,
    CONSTRAINT PARTICIPATION_WORKSHOPS_WORKSHOP_ID_FK
      FOREIGN KEY (WORKSHOP_ID)
      REFERENCES WORKSHOPS(WORKSHOP_ID),
  PARTICIPATION_CONF_DAY_ID  NUMBER NOT NULL,
    CONSTRAINT PARTICIPATION_WORKSHOPS_PARTICIPATION_CONF_DAY_ID_FK
      FOREIGN KEY (PARTICIPATION_CONF_DAY_ID)
      REFERENCES PARTICIPATION_CONF_DAYS(PARTICIPATION_CONF_DAY_ID)
      ON DELETE CASCADE
);

-- WORKSHOP BOOKINGS --
CREATE TABLE WORKSHOP_BOOKINGS
(
  WORKSHOP_BOOKING_ID NUMBER
    GENERATED BY DEFAULT ON NULL AS IDENTITY
    PRIMARY KEY,
  CONF_DAY_BOOKING_ID NUMBER NOT NULL,
    CONSTRAINT WORKSHOP_BOOKINGS_CONF_DAY_BOOKING_ID_FK
      FOREIGN KEY (CONF_DAY_BOOKING_ID)
      REFERENCES CONF_DAY_BOOKINGS(CONF_DAY_BOOKING_ID)
      ON DELETE CASCADE,
  WORKSHOP_ID NUMBER NOT NULL,
    CONSTRAINT WORKSHOP_BOOKINGS_WORKSHOP_ID_FK
      FOREIGN KEY (WORKSHOP_ID)
      REFERENCES WORKSHOPS(WORKSHOP_ID),
  NUMBER_OF_STUDENTS INTEGER NOT NULL,
    CONSTRAINT WORKSHOP_BOOKINGS_NUM_OF_STUDENTS_CHK
      CHECK (NUMBER_OF_STUDENTS >= 0),
  NUMBER_OF_ATTENDEES INTEGER NOT NULL,
    CONSTRAINT WORKSHOP_BOOKINGS_NUMBER_OF_ATTENDEES_CHK
      CHECK (NUMBER_OF_ATTENDEES > 0),
    CONSTRAINT WORKSHOP_BOOKINGS_ATTENDEES_GEQ_STUDENT_CHK
      CHECK (NUMBER_OF_ATTENDEES >= NUMBER_OF_STUDENTS),
  IS_CANCELLED CHAR(1) DEFAULT 'N' NOT NULL,
    CONSTRAINT WORKSHOP_BOOKING_IS_CANCELLED_CHK
      CHECK (IS_CANCELLED IN ('Y', 'N'))
);


-- PAYMENTS --
CREATE TABLE PAYMENTS
(
  PAYMENT_ID NUMBER
    GENERATED BY DEFAULT ON NULL AS IDENTITY
    PRIMARY KEY,
  BOOKING_ID  NUMBER NOT NULL,
    CONSTRAINT PAYMENTS_BOOKING_ID_FK
      FOREIGN KEY (BOOKING_ID)
      REFERENCES BOOKINGS(BOOKING_ID)
      ON DELETE CASCADE,
    CONSTRAINT PAYMENTS_BOOKING_ID_UK
      UNIQUE (BOOKING_ID),
  PAYMENT_DATE DATE NOT NULL,
  VALUE NUMBER NOT NULL
    CONSTRAINT PAYMENTS_VALUE_CHK
      CHECK (VALUE >= 0),
  MEANS VARCHAR2(8) NOT NULL,
    CONSTRAINT PAYMENTS_MEANS_CHK
      CHECK (MEANS IN ('card', 'cheque', 'transfer', 'blik'))
);
